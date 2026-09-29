// lib/core/mock/mock_drm.dart
//
// Donor Relationship Management (DRM) mock store, mirroring the DCC server's
// DRM tables: donor tiers (computed), tags, logged interactions, follow-up
// tasks, saved segments and the patron lifecycle (scheme commitment vs
// instalments received, special puja dates, publication entitlements and
// their dispatch records). In-memory only; pages listen via ChangeNotifier.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Tiers
// ---------------------------------------------------------------------------

enum DonorTier { patron, major, regular, lapsed, prospect }

extension DonorTierX on DonorTier {
  String get code => name.toUpperCase();

  String get label => switch (this) {
        DonorTier.patron => 'Patron',
        DonorTier.major => 'Major',
        DonorTier.regular => 'Regular',
        DonorTier.lapsed => 'Lapsed',
        DonorTier.prospect => 'Prospect',
      };

  String get rule => switch (this) {
        DonorTier.patron => 'Enrolled patron',
        DonorTier.major => 'Lifetime ₹1,00,000+',
        DonorTier.regular => 'Gave in last 12 months',
        DonorTier.lapsed => 'No gift in 12 months',
        DonorTier.prospect => 'Never gave',
      };

  Color get color => switch (this) {
        DonorTier.patron => AppColors.goldenDark,
        DonorTier.major => AppColors.deepRed,
        DonorTier.regular => AppColors.successColor,
        DonorTier.lapsed => AppColors.warningColor,
        DonorTier.prospect => AppColors.vaikunthamBlue,
      };

  IconData get icon => switch (this) {
        DonorTier.patron => Icons.workspace_premium,
        DonorTier.major => Icons.star,
        DonorTier.regular => Icons.favorite,
        DonorTier.lapsed => Icons.hourglass_bottom,
        DonorTier.prospect => Icons.person_outline,
      };
}

/// Same precedence as the server: PATRON > MAJOR > REGULAR > LAPSED > PROSPECT.
DonorTier tierOf(DonorInsights insights) {
  if (insights.donor.isPatron) return DonorTier.patron;
  if (insights.lifetime >= 100000) return DonorTier.major;
  return switch (insights.status) {
    CareStatus.active => DonorTier.regular,
    CareStatus.lapsed => DonorTier.lapsed,
    CareStatus.never => DonorTier.prospect,
  };
}

// ---------------------------------------------------------------------------
// Tags, interactions, follow-up tasks
// ---------------------------------------------------------------------------

class DrmTag {
  final String id;
  final String name;
  final Color color;

  const DrmTag({required this.id, required this.name, required this.color});
}

enum InteractionType { call, visit, meeting, note, email }

extension InteractionTypeX on InteractionType {
  String get code => name.toUpperCase();

  String get label => switch (this) {
        InteractionType.call => 'Call',
        InteractionType.visit => 'Visit',
        InteractionType.meeting => 'Meeting',
        InteractionType.note => 'Note',
        InteractionType.email => 'Email',
      };

  IconData get icon => switch (this) {
        InteractionType.call => Icons.call,
        InteractionType.visit => Icons.home_work_outlined,
        InteractionType.meeting => Icons.groups_outlined,
        InteractionType.note => Icons.sticky_note_2_outlined,
        InteractionType.email => Icons.email_outlined,
      };
}

const List<String> kInteractionOutcomes = ['Interested', 'Committed', 'Not now', 'No answer', 'Thanked'];

class DrmInteraction {
  final String id;
  final String donorId;
  final InteractionType type;
  final DateTime date;
  final String notes;
  final String? outcome;
  final String by;

  const DrmInteraction({
    required this.id,
    required this.donorId,
    required this.type,
    required this.date,
    required this.notes,
    required this.by,
    this.outcome,
  });
}

enum TaskPriority { high, normal, low }

extension TaskPriorityX on TaskPriority {
  String get label => switch (this) {
        TaskPriority.high => 'High',
        TaskPriority.normal => 'Normal',
        TaskPriority.low => 'Low',
      };

  Color get color => switch (this) {
        TaskPriority.high => AppColors.deepRed,
        TaskPriority.normal => AppColors.vaikunthamBlue,
        TaskPriority.low => Colors.blueGrey,
      };
}

enum TaskStatus { open, done }

enum FollowUpBucket { overdue, today, upcoming, done }

class DrmTask {
  final String id;
  final String donorId;
  final String title;
  final String notes;
  final DateTime dueDate;
  final TaskPriority priority;
  final String assignedTo;
  final DateTime createdAt;
  TaskStatus status;
  DateTime? completedAt;

  DrmTask({
    required this.id,
    required this.donorId,
    required this.title,
    required this.dueDate,
    required this.assignedTo,
    required this.createdAt,
    this.notes = '',
    this.priority = TaskPriority.normal,
    this.status = TaskStatus.open,
    this.completedAt,
  });

  bool get isOpen => status == TaskStatus.open;

  FollowUpBucket bucketOn(DateTime today) {
    if (!isOpen) return FollowUpBucket.done;
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    if (due.isBefore(today)) return FollowUpBucket.overdue;
    if (due == today) return FollowUpBucket.today;
    return FollowUpBucket.upcoming;
  }
}

// ---------------------------------------------------------------------------
// Segments
// ---------------------------------------------------------------------------

enum LifetimeBand { any, under10k, from10kTo1L, over1L }

extension LifetimeBandX on LifetimeBand {
  String get label => switch (this) {
        LifetimeBand.any => 'Any amount',
        LifetimeBand.under10k => 'Under ₹10,000',
        LifetimeBand.from10kTo1L => '₹10,000 – ₹1,00,000',
        LifetimeBand.over1L => '₹1,00,000+',
      };

  bool matches(int lifetime) => switch (this) {
        LifetimeBand.any => true,
        LifetimeBand.under10k => lifetime < 10000,
        LifetimeBand.from10kTo1L => lifetime >= 10000 && lifetime < 100000,
        LifetimeBand.over1L => lifetime >= 100000,
      };
}

class SegmentFilter {
  final DonorTier? tier;
  final String? tagId;
  final String? city;
  final LifetimeBand lifetimeBand;
  final int? birthdayMonth; // 1-12
  final String? festivalCode;

  const SegmentFilter({
    this.tier,
    this.tagId,
    this.city,
    this.lifetimeBand = LifetimeBand.any,
    this.birthdayMonth,
    this.festivalCode,
  });

  bool get isEmpty =>
      tier == null && tagId == null && city == null && lifetimeBand == LifetimeBand.any && birthdayMonth == null && festivalCode == null;

  bool matches(DonorInsights ins, Set<String> donorTagIds) {
    final d = ins.donor;
    if (tier != null && tierOf(ins) != tier) return false;
    if (tagId != null && !donorTagIds.contains(tagId)) return false;
    if (city != null && d.city != city) return false;
    if (!lifetimeBand.matches(ins.lifetime)) return false;
    if (birthdayMonth != null && d.dob?.month != birthdayMonth) return false;
    if (festivalCode != null && !ins.byFestival.containsKey(festivalCode)) return false;
    return true;
  }
}

class SavedSegment {
  final String id;
  final String name;
  final SegmentFilter filter;
  // null = visible to admin/employee (all donors); else that preacher's
  final String? preacherCode;

  const SavedSegment({required this.id, required this.name, required this.filter, this.preacherCode});
}

// ---------------------------------------------------------------------------
// Patron lifecycle
// ---------------------------------------------------------------------------

class PatronScheme {
  final String name;
  final int amount;

  const PatronScheme(this.name, this.amount);
}

const List<PatronScheme> kPatronSchemes = [
  PatronScheme('Annadana Patron', 51000),
  PatronScheme('Gau Seva Patron', 51000),
  PatronScheme('Nitya Seva Patron', 100000),
  PatronScheme('Vedic Patron', 151000),
  PatronScheme('Temple Construction Patron', 250000),
  PatronScheme('Grand Patron', 500000),
];

const List<String> kPublicationItems = ['Basic publication', 'Vedic encyclopedia', 'Monthly newsletter', 'Second patronship'];
const List<String> kPublicationLanguages = ['Telugu', 'English', 'Hindi'];
const List<String> kDispatchModes = ['Courier', 'Hand', 'Post'];

enum PatronPayStatus { fullyPaid, inProgress, notStarted }

extension PatronPayStatusX on PatronPayStatus {
  String get label => switch (this) {
        PatronPayStatus.fullyPaid => 'Fully paid',
        PatronPayStatus.inProgress => 'In progress',
        PatronPayStatus.notStarted => 'Not started',
      };

  Color get color => switch (this) {
        PatronPayStatus.fullyPaid => AppColors.successColor,
        PatronPayStatus.inProgress => AppColors.warningColor,
        PatronPayStatus.notStarted => AppColors.deepRed,
      };
}

class PatronInstalment {
  final DateTime date;
  final int amount;

  const PatronInstalment(this.date, this.amount);
}

/// A yearly day/month anniversary on which the temple performs a puja.
class SpecialPuja {
  final int day;
  final int month;
  final String occasion;

  const SpecialPuja({required this.day, required this.month, required this.occasion});

  DateTime nextOn(DateTime today) {
    var next = DateTime(today.year, month, day);
    if (next.isBefore(today)) next = DateTime(today.year + 1, month, day);
    return next;
  }
}

class PublicationDispatch {
  final DateTime date;
  final String mode; // Courier / Hand / Post
  final String? trackingNo;

  const PublicationDispatch({required this.date, required this.mode, this.trackingNo});
}

class PublicationEntitlement {
  final String id;
  final String item;
  final String language;
  final List<PublicationDispatch> dispatches;

  PublicationEntitlement({required this.id, required this.item, required this.language, List<PublicationDispatch>? dispatches})
      : dispatches = dispatches ?? [];

  // The newsletter goes out every month; everything else is one-time.
  bool get isRecurring => item == 'Monthly newsletter';

  PublicationDispatch? get lastDispatch => dispatches.isEmpty ? null : dispatches.last;

  bool isPendingOn(DateTime today) {
    final last = lastDispatch;
    if (last == null) return true;
    return isRecurring && !(last.date.year == today.year && last.date.month == today.month);
  }
}

class PatronRecord {
  final String donorId;
  final String schemeName;
  final String trust;
  final int committedAmount;
  final DateTime enrolledOn;
  final List<PatronInstalment> instalments;
  final List<SpecialPuja> pujas;
  final List<PublicationEntitlement> entitlements;

  PatronRecord({
    required this.donorId,
    required this.schemeName,
    required this.trust,
    required this.committedAmount,
    required this.enrolledOn,
    List<PatronInstalment>? instalments,
    List<SpecialPuja>? pujas,
    List<PublicationEntitlement>? entitlements,
  })  : instalments = instalments ?? [],
        pujas = pujas ?? [],
        entitlements = entitlements ?? [];

  int get received => instalments.fold(0, (s, i) => s + i.amount);
  int get pending => received >= committedAmount ? 0 : committedAmount - received;
  double get progress => committedAmount == 0 ? 0 : (received / committedAmount).clamp(0, 1).toDouble();
  DateTime? get lastPayment => instalments.isEmpty ? null : instalments.map((i) => i.date).reduce((a, b) => a.isAfter(b) ? a : b);

  PatronPayStatus get payStatus {
    if (received == 0) return PatronPayStatus.notStarted;
    if (received >= committedAmount) return PatronPayStatus.fullyPaid;
    return PatronPayStatus.inProgress;
  }
}

// ---------------------------------------------------------------------------
// Store
// ---------------------------------------------------------------------------

class DrmStore extends ChangeNotifier {
  DrmStore._() {
    _seed();
  }

  static final DrmStore instance = DrmStore._();

  final List<DrmTag> tags = [];
  final Map<String, Set<String>> _donorTags = {};
  final List<DrmInteraction> interactions = [];
  final List<DrmTask> tasks = [];
  final List<SavedSegment> savedSegments = [];
  final Map<String, PatronRecord> _patrons = {};
  int _seq = 100;

  String _nextId(String prefix) => '$prefix${++_seq}';

  // --- tags ---------------------------------------------------------------

  DrmTag? tagById(String id) {
    for (final t in tags) {
      if (t.id == id) return t;
    }
    return null;
  }

  Set<String> tagIdsFor(String donorId) => _donorTags[donorId] ?? const {};

  List<DrmTag> tagsFor(String donorId) => tags.where((t) => tagIdsFor(donorId).contains(t.id)).toList();

  void setTags(String donorId, Set<String> tagIds) {
    _donorTags[donorId] = {...tagIds};
    notifyListeners();
  }

  // --- interactions -------------------------------------------------------

  List<DrmInteraction> interactionsFor(String donorId) =>
      interactions.where((i) => i.donorId == donorId).toList()..sort((a, b) => b.date.compareTo(a.date));

  void logInteraction({
    required String donorId,
    required InteractionType type,
    required DateTime date,
    required String notes,
    required String by,
    String? outcome,
  }) {
    interactions.add(DrmInteraction(
      id: _nextId('I'),
      donorId: donorId,
      type: type,
      date: date,
      notes: notes,
      outcome: outcome,
      by: by,
    ));
    notifyListeners();
  }

  // --- tasks --------------------------------------------------------------

  List<DrmTask> tasksFor(String donorId) => tasks.where((t) => t.donorId == donorId).toList();

  /// Tasks on a preacher's own donors, or every task when [preacherCode] is null.
  List<DrmTask> tasksScoped(String? preacherCode) {
    if (preacherCode == null) return List.of(tasks);
    final mine = MockData.donorsFor(preacherCode).map((d) => d.id).toSet();
    return tasks.where((t) => mine.contains(t.donorId)).toList();
  }

  int openTaskCount(String? preacherCode) => tasksScoped(preacherCode).where((t) => t.isOpen).length;

  void addTask({
    required String donorId,
    required String title,
    required DateTime dueDate,
    required String assignedTo,
    String notes = '',
    TaskPriority priority = TaskPriority.normal,
  }) {
    tasks.add(_task(donorId, title, dueDate, assignedTo, notes: notes, priority: priority));
    notifyListeners();
  }

  /// Bulk "create follow-up for all" from Segments. Returns how many were made.
  int addTasksForAll({
    required Iterable<String> donorIds,
    required String title,
    required DateTime dueDate,
    required String assignedTo,
    TaskPriority priority = TaskPriority.normal,
  }) {
    var n = 0;
    for (final id in donorIds) {
      tasks.add(_task(id, title, dueDate, assignedTo, priority: priority));
      n++;
    }
    notifyListeners();
    return n;
  }

  DrmTask _task(String donorId, String title, DateTime dueDate, String assignedTo,
      {String notes = '', TaskPriority priority = TaskPriority.normal}) {
    return DrmTask(
      id: _nextId('F'),
      donorId: donorId,
      title: title,
      notes: notes,
      dueDate: dueDate,
      priority: priority,
      assignedTo: assignedTo,
      createdAt: DateTime.now(),
    );
  }

  /// Marks a follow-up done; an optional outcome note is also logged as an
  /// interaction so it shows on the donor's timeline.
  void completeTask(DrmTask task, {required String by, String? outcome, String? note}) {
    task.status = TaskStatus.done;
    task.completedAt = DateTime.now();
    if ((note != null && note.trim().isNotEmpty) || outcome != null) {
      interactions.add(DrmInteraction(
        id: _nextId('I'),
        donorId: task.donorId,
        type: InteractionType.note,
        date: DateTime.now(),
        notes: 'Follow-up done: ${task.title}${note == null || note.trim().isEmpty ? '' : ' - ${note.trim()}'}',
        outcome: outcome,
        by: by,
      ));
    }
    notifyListeners();
  }

  void reopenTask(DrmTask task) {
    task.status = TaskStatus.open;
    task.completedAt = null;
    notifyListeners();
  }

  // --- segments -----------------------------------------------------------

  List<SavedSegment> segmentsFor(String? preacherCode) => savedSegments.where((s) => s.preacherCode == preacherCode).toList();

  void saveSegment(String name, SegmentFilter filter, {String? preacherCode}) {
    savedSegments.add(SavedSegment(id: _nextId('S'), name: name, filter: filter, preacherCode: preacherCode));
    notifyListeners();
  }

  void deleteSegment(SavedSegment segment) {
    savedSegments.remove(segment);
    notifyListeners();
  }

  // --- patrons ------------------------------------------------------------

  PatronRecord? patronFor(String donorId) => _patrons[donorId];

  /// Patron records for a preacher's donors, or all when [preacherCode] is null.
  List<PatronRecord> patronsScoped(String? preacherCode) {
    final ids = (preacherCode == null ? MockData.donors : MockData.donorsFor(preacherCode)).map((d) => d.id).toSet();
    return _patrons.values.where((p) => ids.contains(p.donorId)).toList();
  }

  /// Applied when a PATRON_ENROL request is approved (or the rule is off).
  void enrolPatron({required String donorId, required String schemeName, required String trust, required int committedAmount}) {
    _patrons[donorId] = PatronRecord(
      donorId: donorId,
      schemeName: schemeName,
      trust: trust,
      committedAmount: committedAmount,
      enrolledOn: MockData.today,
      entitlements: [
        PublicationEntitlement(id: _nextId('P'), item: 'Basic publication', language: 'Telugu'),
        PublicationEntitlement(id: _nextId('P'), item: 'Monthly newsletter', language: 'Telugu'),
        if (committedAmount >= 100000) PublicationEntitlement(id: _nextId('P'), item: 'Vedic encyclopedia', language: 'English'),
      ],
    );
    final donor = MockData.donorById(donorId);
    if (donor != null && !donor.isPatron) MockData.replaceDonor(donor.copyWith(isPatron: true));
    notifyListeners();
  }

  void markDispatched(PublicationEntitlement entitlement, PublicationDispatch dispatch) {
    entitlement.dispatches.add(dispatch);
    notifyListeners();
  }

  // --- seed ---------------------------------------------------------------

  void _seed() {
    final t = MockData.today;
    DateTime d(int offset) => t.add(Duration(days: offset));
    SpecialPuja puja(int offset, String occasion) {
      final on = d(offset);
      return SpecialPuja(day: on.day, month: on.month, occasion: occasion);
    }

    tags.addAll(const [
      DrmTag(id: 'T1', name: 'Festival regular', color: AppColors.gold),
      DrmTag(id: 'T2', name: 'Corporate', color: AppColors.vaikunthamBlue),
      DrmTag(id: 'T3', name: 'Book distribution', color: AppColors.vaikunthamBrown),
      DrmTag(id: 'T4', name: 'Annadana supporter', color: AppColors.successColor),
      DrmTag(id: 'T5', name: 'VIP', color: AppColors.deepRed),
    ]);
    _donorTags.addAll({
      'D1024': {'T1', 'T5'},
      'D1029': {'T1', 'T4'},
      'D1032': {'T2', 'T3'},
      'D1025': {'T1'},
      'D1027': {'T2', 'T5'},
      'D1026': {'T4'},
      'D1028': {'T1'},
    });

    DrmInteraction i(String id, String donorId, InteractionType type, int day, String notes, String by, [String? outcome]) =>
        DrmInteraction(id: id, donorId: donorId, type: type, date: d(day).add(const Duration(hours: 11)), notes: notes, by: by, outcome: outcome);
    interactions.addAll([
      i('I1', 'D1024', InteractionType.call, -1, 'Discussed Deepotsava Yajamana seva; will confirm next week', 'ABRD', 'Interested'),
      i('I2', 'D1024', InteractionType.visit, -30, 'Delivered Janmashtami prasadam at home', 'ABRD', 'Thanked'),
      i('I3', 'D1026', InteractionType.call, -3, 'Called twice, no response', 'ABRD', 'No answer'),
      i('I4', 'D1026', InteractionType.call, -40, 'Busy with a family function, asked to call after a month', 'ABRD', 'Not now'),
      i('I5', 'D1029', InteractionType.meeting, -12, 'Met at the temple after Radhashtami; keen on sponsoring Annadana', 'ABRD', 'Committed'),
      i('I6', 'D1032', InteractionType.meeting, -7, 'Office visit - agreed to the Temple Construction patron scheme', 'ABRD', 'Committed'),
      i('I7', 'D1032', InteractionType.email, -6, 'Sent the patron welcome letter and scheme details', 'ABRD'),
      i('I8', 'D1033', InteractionType.note, -15, 'Has moved within Gajuwaka - confirm new address on next visit', 'ABRD'),
      i('I9', 'D1031', InteractionType.call, -2, 'Interested in Nitya seva, wants the seva list', 'ABRD', 'Interested'),
      i('I10', 'D1027', InteractionType.meeting, -5, 'CSR team meeting at their office', 'SRND', 'Interested'),
      i('I11', 'D1025', InteractionType.visit, -20, 'Handed over the patron certificate', 'JTMD', 'Thanked'),
    ]);

    DrmTask task(String id, String donorId, String title, int due, TaskPriority p, String by, {int? doneDay, String notes = ''}) =>
        DrmTask(
          id: id,
          donorId: donorId,
          title: title,
          notes: notes,
          dueDate: d(due),
          priority: p,
          assignedTo: by,
          createdAt: d(due - 7),
          status: doneDay == null ? TaskStatus.open : TaskStatus.done,
          completedAt: doneDay == null ? null : d(doneDay).add(const Duration(hours: 17)),
        );
    tasks.addAll([
      task('F1', 'D1026', 'Call about restarting Annadana seva', -3, TaskPriority.high, 'ABRD', notes: 'Lapsed over a year'),
      task('F2', 'D1033', 'Visit with Deepotsava invitation', -1, TaskPriority.normal, 'ABRD'),
      task('F3', 'D1029', 'Birthday wishes and prasadam', 0, TaskPriority.high, 'ABRD'),
      task('F4', 'D1031', 'First-gift conversation - share Nitya seva list', 0, TaskPriority.normal, 'ABRD'),
      task('F5', 'D1024', 'Update on Vedic encyclopedia dispatch', 2, TaskPriority.low, 'ABRD'),
      task('F6', 'D1032', 'Collect first patron instalment', 5, TaskPriority.high, 'ABRD'),
      task('F7', 'D1024', 'Invite for Deepotsava Yajamana seva', 10, TaskPriority.normal, 'ABRD'),
      task('F8', 'D1029', 'Thank for Radhashtami seva', -10, TaskPriority.normal, 'ABRD', doneDay: -9),
      task('F9', 'D1026', 'Send Janmashtami photos', -22, TaskPriority.low, 'ABRD', doneDay: -20),
      task('F10', 'D1025', 'Hand over patron certificate copy', -2, TaskPriority.normal, 'JTMD'),
      task('F11', 'D1027', 'Follow up on CSR proposal', 3, TaskPriority.high, 'SRND'),
      task('F12', 'D1030', 'Remind about pending patron instalment', 0, TaskPriority.normal, 'SYMD'),
      task('F13', 'D1028', 'Thank for Radhashtami Yajamana seva', -8, TaskPriority.normal, 'JTMD', doneDay: -8),
    ]);

    savedSegments.addAll(const [
      SavedSegment(id: 'S1', name: 'Lapsed in Vizag', filter: SegmentFilter(tier: DonorTier.lapsed, city: 'Visakhapatnam'), preacherCode: kCurrentPreacherCode),
      SavedSegment(id: 'S2', name: 'VIP donors', filter: SegmentFilter(tagId: 'T5')),
    ]);

    PublicationEntitlement pub(String id, String item, String lang, [List<PublicationDispatch>? sent]) =>
        PublicationEntitlement(id: id, item: item, language: lang, dispatches: sent);
    final thisMonth = DateTime(t.year, t.month, 1);

    final dob24 = MockData.donorById('D1024')?.dob;
    _patrons.addAll({
      'D1024': PatronRecord(
        donorId: 'D1024',
        schemeName: 'Nitya Seva Patron',
        trust: 'HKMV',
        committedAmount: 100000,
        enrolledOn: d(-400),
        instalments: [PatronInstalment(d(-400), 25000), PatronInstalment(d(-300), 25000), PatronInstalment(d(-200), 25000), PatronInstalment(d(-60), 25000)],
        pujas: [
          if (dob24 != null) SpecialPuja(day: dob24.day, month: dob24.month, occasion: 'Birthday'),
          puja(12, 'Wedding anniversary'),
          puja(45, "Father's remembrance day"),
          puja(160, 'Grihapravesham anniversary'),
        ],
        entitlements: [
          pub('P1', 'Basic publication', 'Telugu', [PublicationDispatch(date: d(-58), mode: 'Hand')]),
          pub('P2', 'Vedic encyclopedia', 'English'),
          pub('P3', 'Monthly newsletter', 'Telugu', [PublicationDispatch(date: thisMonth, mode: 'Post')]),
        ],
      ),
      'D1029': PatronRecord(
        donorId: 'D1029',
        schemeName: 'Annadana Patron',
        trust: 'HKMV',
        committedAmount: 51000,
        enrolledOn: d(-150),
        instalments: [PatronInstalment(d(-150), 21000), PatronInstalment(d(-35), 10000)],
        pujas: [puja(0, 'Birthday'), puja(20, "Son's birthday"), puja(90, 'Wedding anniversary')],
        entitlements: [
          pub('P4', 'Basic publication', 'Telugu', [PublicationDispatch(date: d(-140), mode: 'Courier', trackingNo: 'DTDC7788120')]),
          pub('P5', 'Monthly newsletter', 'Telugu', [PublicationDispatch(date: d(-40), mode: 'Post')]),
        ],
      ),
      'D1032': PatronRecord(
        donorId: 'D1032',
        schemeName: 'Temple Construction Patron',
        trust: 'TSC',
        committedAmount: 250000,
        enrolledOn: d(-6),
        entitlements: [pub('P6', 'Basic publication', 'English')],
      ),
      'D1025': PatronRecord(
        donorId: 'D1025',
        schemeName: 'Nitya Seva Patron',
        trust: 'HKMV',
        committedAmount: 100000,
        enrolledOn: d(-500),
        instalments: [PatronInstalment(d(-500), 50000), PatronInstalment(d(-380), 50000)],
        pujas: [puja(8, 'Wedding anniversary'), puja(70, 'Birthday')],
        entitlements: [
          pub('P7', 'Basic publication', 'Telugu', [PublicationDispatch(date: d(-370), mode: 'Hand')]),
          pub('P8', 'Second patronship', 'Telugu'),
        ],
      ),
      'D1027': PatronRecord(
        donorId: 'D1027',
        schemeName: 'Vedic Patron',
        trust: 'HKMI',
        committedAmount: 151000,
        enrolledOn: d(-240),
        instalments: [PatronInstalment(d(-240), 51000), PatronInstalment(d(-90), 49000)],
        pujas: [puja(60, "Mother's birthday"), puja(25, 'Company foundation day')],
        entitlements: [
          pub('P9', 'Vedic encyclopedia', 'Hindi', [PublicationDispatch(date: d(-80), mode: 'Courier', trackingNo: 'BD4410029IN')]),
          pub('P10', 'Basic publication', 'English'),
        ],
      ),
      'D1030': PatronRecord(
        donorId: 'D1030',
        schemeName: 'Gau Seva Patron',
        trust: 'HKMI',
        committedAmount: 51000,
        enrolledOn: d(-75),
        instalments: [PatronInstalment(d(-75), 11000)],
        pujas: [puja(27, 'Birthday')],
        entitlements: [pub('P11', 'Basic publication', 'Telugu')],
      ),
    });
  }
}
