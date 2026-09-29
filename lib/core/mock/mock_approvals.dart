// lib/core/mock/mock_approvals.dart
//
// Configurable hierarchy approvals, mirroring the DCC server's
// ApprovalLevel / ApprovalRule / ApprovalRequest tables:
//  * Levels are ordered (Team Leader -> DCC Approver -> Admin). A level is
//    either the requester's TEAM_LEADER or a fixed list of USERS.
//  * Each action type has a rule: enabled flag, optional thresholds and the
//    levels (steps) it needs, each step optionally only above a min amount.
//  * A request copies the applicable steps; the first non-skipped one is
//    PENDING, approving moves to the next, rejecting ends it, and the last
//    approval applies the effect (cancel receipt, update donor, ...).
// In-memory only; pages listen via ChangeNotifier.
import 'package:flutter/material.dart';
import 'package:surabhi/core/mock/demo_identity.dart';
import 'package:surabhi/core/mock/donor_insights.dart';
import 'package:surabhi/core/mock/mock_donor_data.dart';
import 'package:surabhi/core/mock/mock_drm.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/utils/receipt_number.dart';

class ApprovalActionType {
  ApprovalActionType._();

  static const String cancelReceipt = 'CANCEL_RECEIPT';
  static const String donorChange = 'DONOR_CHANGE';
  static const String patronEnrol = 'PATRON_ENROL';
  static const String highValueReceipt = 'HIGH_VALUE_RECEIPT';

  static const List<String> all = [cancelReceipt, donorChange, patronEnrol, highValueReceipt];

  static String shortLabel(String type) => switch (type) {
        cancelReceipt => 'Cancellation',
        donorChange => 'Donor change',
        patronEnrol => 'Patron',
        highValueReceipt => 'High-value',
        _ => type,
      };

  static IconData icon(String type) => switch (type) {
        cancelReceipt => Icons.receipt_long_outlined,
        donorChange => Icons.manage_accounts_outlined,
        patronEnrol => Icons.workspace_premium_outlined,
        highValueReceipt => Icons.currency_rupee,
        _ => Icons.approval,
      };

  static Color color(String type) => switch (type) {
        cancelReceipt => AppColors.deepRed,
        donorChange => AppColors.vaikunthamBlue,
        patronEnrol => AppColors.goldenDark,
        highValueReceipt => AppColors.approverColor,
        _ => Colors.blueGrey,
      };
}

class ApproverType {
  ApproverType._();

  static const String teamLeader = 'TEAM_LEADER';
  static const String users = 'USERS';

  static String label(String type) => type == teamLeader ? "Requester's team leader" : 'Specific users';
}

// Preacher (requester) -> their team leader. SYMD has none, so a
// TEAM_LEADER step on their requests is auto-skipped.
const Map<String, String> kTeamLeaders = {
  'ABRD': 'Govinda Das (TL)',
  'JTMD': 'Govinda Das (TL)',
  'SRND': 'Madhava Das (TL)',
};

class ApprovalLevel {
  final String id;
  String name;
  int order;
  String approverType;
  List<String> members;
  bool isActive;

  ApprovalLevel({
    required this.id,
    required this.name,
    required this.order,
    required this.approverType,
    List<String>? members,
    this.isActive = true,
  }) : members = members ?? [];
}

class RuleStep {
  String levelId;
  int? minAmount; // only needed when the amount is at least this

  RuleStep({required this.levelId, this.minAmount});
}

class ApprovalRule {
  final String actionType;
  final String label;
  bool isEnabled;
  int? thresholdAmount;
  int? cashThresholdAmount;
  final List<RuleStep> steps;

  ApprovalRule({
    required this.actionType,
    required this.label,
    required this.steps,
    this.isEnabled = true,
    this.thresholdAmount,
    this.cashThresholdAmount,
  });
}

enum RequestStatus { pending, approved, rejected, withdrawn }

extension RequestStatusX on RequestStatus {
  String get code => name.toUpperCase();

  String get label => switch (this) {
        RequestStatus.pending => 'Pending',
        RequestStatus.approved => 'Approved',
        RequestStatus.rejected => 'Rejected',
        RequestStatus.withdrawn => 'Withdrawn',
      };

  Color get color => switch (this) {
        RequestStatus.pending => AppColors.warningColor,
        RequestStatus.approved => AppColors.successColor,
        RequestStatus.rejected => AppColors.errorColor,
        RequestStatus.withdrawn => Colors.blueGrey,
      };
}

enum StepStatus { waiting, pending, approved, rejected, skipped }

class RequestStep {
  final int order;
  final String levelId;
  final String levelName;
  // Who is expected to act: the team leader's name or the level's members
  final String assignee;
  StepStatus status;
  String? actedBy;
  DateTime? actedAt;
  String? comment;

  RequestStep({
    required this.order,
    required this.levelId,
    required this.levelName,
    required this.assignee,
    required this.status,
    this.actedBy,
    this.actedAt,
    this.comment,
  });
}

class FieldChange {
  final String field; // name / email / address / city / pan
  final String before;
  final String after;

  const FieldChange(this.field, this.before, this.after);

  String get label => switch (field) {
        'name' => 'Name',
        'email' => 'Email',
        'address' => 'Address',
        'city' => 'City',
        'pan' => 'PAN',
        _ => field,
      };
}

class ApprovalRequest {
  final String id;
  final String actionType;
  final String title;
  final String? donorId;
  final String donorName;
  final int? amount;
  final String reason;
  final String requestedBy;
  final DateTime requestedAt;
  final List<RequestStep> steps;
  final List<(String, String)> details;
  final List<FieldChange> changes;
  // Payloads used to apply the effect on final approval
  final String? receiptNumber; // CANCEL_RECEIPT
  final MockDonation? pendingReceipt; // HIGH_VALUE_RECEIPT
  final String? patronScheme; // PATRON_ENROL
  final String? patronTrust;
  RequestStatus status;
  DateTime? closedAt;
  String? outcome; // e.g. "Receipt issued: HKMV|2026|1234"

  ApprovalRequest({
    required this.id,
    required this.actionType,
    required this.title,
    required this.donorName,
    required this.reason,
    required this.requestedBy,
    required this.requestedAt,
    required this.steps,
    this.donorId,
    this.amount,
    this.details = const [],
    this.changes = const [],
    this.receiptNumber,
    this.pendingReceipt,
    this.patronScheme,
    this.patronTrust,
    this.status = RequestStatus.pending,
    this.closedAt,
    this.outcome,
  });

  bool get isPending => status == RequestStatus.pending;

  RequestStep? get currentStep {
    if (!isPending) return null;
    for (final s in steps) {
      if (s.status == StepStatus.pending) return s;
    }
    return null;
  }

  DateTime get lastActivity => closedAt ?? steps.fold(requestedAt, (t, s) => s.actedAt != null && s.actedAt!.isAfter(t) ? s.actedAt! : t);
}

class ApprovalStore extends ChangeNotifier {
  ApprovalStore._() {
    _seed();
  }

  static final ApprovalStore instance = ApprovalStore._();

  final List<ApprovalLevel> levels = [];
  final Map<String, ApprovalRule> rules = {};
  final List<ApprovalRequest> requests = [];
  int _seq = 1000;
  int _levelSeq = 3;

  // --- config -------------------------------------------------------------

  List<ApprovalLevel> get sortedLevels => List.of(levels)..sort((a, b) => a.order.compareTo(b.order));

  ApprovalLevel? levelById(String id) {
    for (final l in levels) {
      if (l.id == id) return l;
    }
    return null;
  }

  ApprovalRule rule(String actionType) => rules[actionType]!;

  /// Called by the settings screen after any in-place edit.
  void touch() => notifyListeners();

  void moveLevel(ApprovalLevel level, int delta) {
    final sorted = sortedLevels;
    final i = sorted.indexOf(level);
    final j = i + delta;
    if (i < 0 || j < 0 || j >= sorted.length) return;
    final other = sorted[j];
    final o = level.order;
    level.order = other.order;
    other.order = o;
    notifyListeners();
  }

  ApprovalLevel addLevel({required String name, required String approverType, required List<String> members}) {
    final maxOrder = levels.fold(0, (m, l) => l.order > m ? l.order : m);
    final level = ApprovalLevel(id: 'L${++_levelSeq}', name: name, order: maxOrder + 1, approverType: approverType, members: members);
    levels.add(level);
    notifyListeners();
    return level;
  }

  /// Rule enabled AND, for high-value receipts, over the amount or cash threshold.
  bool isApprovalRequired(String actionType, {int? amount, bool isCash = false}) {
    final r = rules[actionType];
    if (r == null || !r.isEnabled || r.steps.isEmpty) return false;
    if (actionType != ApprovalActionType.highValueReceipt) return true;
    final a = amount ?? 0;
    final overThreshold = r.thresholdAmount != null && a >= r.thresholdAmount!;
    final overCash = isCash && r.cashThresholdAmount != null && a >= r.cashThresholdAmount!;
    return overThreshold || overCash;
  }

  // --- requests -----------------------------------------------------------

  ApprovalRequest? byId(String id) {
    for (final r in requests) {
      if (r.id == id) return r;
    }
    return null;
  }

  List<ApprovalRequest> get newestFirst => List.of(requests)..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

  List<ApprovalRequest> requestsBy(String requester) => newestFirst.where((r) => r.requestedBy == requester).toList();

  List<ApprovalRequest> requestsForDonor(String donorId) => newestFirst.where((r) => r.donorId == donorId).toList();

  List<ApprovalRequest> pendingFor(DemoIdentity who) => newestFirst.where((r) => canAct(r, who)).toList();

  ApprovalRequest? pendingCancellationFor(String receiptNumber) {
    for (final r in requests) {
      if (r.isPending && r.actionType == ApprovalActionType.cancelReceipt && r.receiptNumber == receiptNumber) return r;
    }
    return null;
  }

  bool _isMember(ApprovalLevel? level, DemoIdentity who) =>
      level != null && level.approverType == ApproverType.users && level.members.contains(who.name);

  /// Approver acts where they are a level member; admin can act at any level.
  bool canAct(ApprovalRequest r, DemoIdentity who) {
    final step = r.currentStep;
    if (step == null) return false;
    // Same integrity rules as DCC: nobody approves their own request, and one
    // person approves at most one level of a request
    if (r.requestedBy == who.name || r.requestedBy == who.preacherCode) return false;
    if (r.steps.any((s) => s.status == StepStatus.approved && (s.actedBy ?? '').startsWith(who.name))) return false;
    return who.isAdmin || _isMember(levelById(step.levelId), who);
  }

  /// True when an admin acts on a level they are not a member of.
  bool isOverride(ApprovalRequest r, DemoIdentity who) {
    final step = r.currentStep;
    return step != null && who.isAdmin && !_isMember(levelById(step.levelId), who);
  }

  List<RequestStep> _buildSteps(ApprovalRule rule, int? amount, String requestedBy) {
    // The rule's own step order decides the sequence, as in DCC
    final seen = <String>{};
    final applicable = rule.steps
        .where((s) => s.minAmount == null || (amount ?? 0) >= s.minAmount!)
        .map((s) => levelById(s.levelId))
        .whereType<ApprovalLevel>()
        .where((l) => seen.add(l.id))
        .toList();

    final steps = <RequestStep>[];
    for (final level in applicable) {
      final leader = kTeamLeaders[requestedBy];
      final isTl = level.approverType == ApproverType.teamLeader;
      var status = StepStatus.waiting;
      String? comment;
      if (!level.isActive) {
        status = StepStatus.skipped;
        comment = 'Level is inactive';
      } else if (isTl && leader == null) {
        status = StepStatus.skipped;
        comment = 'No team leader for $requestedBy';
      }
      steps.add(RequestStep(
        order: steps.length + 1,
        levelId: level.id,
        levelName: level.name,
        assignee: isTl ? (leader ?? '-') : level.members.join(', '),
        status: status,
        comment: comment,
      ));
    }
    return steps;
  }

  /// The steps a request would get right now - shown in the forms before
  /// submitting so the requester knows who will approve.
  List<RequestStep> previewSteps(String actionType, {int? amount, required String requestedBy}) {
    final r = rules[actionType];
    if (r == null) return [];
    final steps = _buildSteps(r, amount, requestedBy);
    for (final s in steps) {
      if (s.status == StepStatus.waiting) {
        s.status = StepStatus.pending;
        break;
      }
    }
    return steps;
  }

  /// Creates a request when [actionType] needs approval and returns it. When
  /// the rule is disabled (or under its threshold) the change is applied at
  /// once and null is returned. If every step is skipped, the request is
  /// approved and applied straight away.
  ApprovalRequest? submitOrApply({
    required String actionType,
    required String title,
    required String donorName,
    required String reason,
    required String requestedBy,
    String? donorId,
    int? amount,
    bool isCash = false,
    List<(String, String)> details = const [],
    List<FieldChange> changes = const [],
    String? receiptNumber,
    MockDonation? pendingReceipt,
    String? patronScheme,
    String? patronTrust,
  }) {
    final needsApproval = isApprovalRequired(actionType, amount: amount, isCash: isCash);
    final req = ApprovalRequest(
      id: needsApproval ? 'AR-${++_seq}' : 'DIRECT',
      actionType: actionType,
      title: title,
      donorId: donorId,
      donorName: donorName,
      amount: amount,
      reason: reason,
      requestedBy: requestedBy,
      requestedAt: DateTime.now(),
      steps: needsApproval ? _buildSteps(rule(actionType), amount, requestedBy) : [],
      details: details,
      changes: changes,
      receiptNumber: receiptNumber,
      pendingReceipt: pendingReceipt,
      patronScheme: patronScheme,
      patronTrust: patronTrust,
    );
    if (!needsApproval) {
      _applyEffect(req);
      notifyListeners();
      return null;
    }
    requests.add(req);
    _advance(req);
    notifyListeners();
    return req;
  }

  void _advance(ApprovalRequest r) {
    for (final s in r.steps) {
      if (s.status == StepStatus.waiting) {
        s.status = StepStatus.pending;
        return;
      }
    }
    // Nobody left to approve
    r.status = RequestStatus.approved;
    r.closedAt = DateTime.now();
    _applyEffect(r);
  }

  void approve(ApprovalRequest r, DemoIdentity who, {String? comment}) {
    final step = r.currentStep;
    if (step == null || !canAct(r, who)) return;
    final override = isOverride(r, who);
    step
      ..status = StepStatus.approved
      ..actedBy = override ? '${who.name} (Admin override)' : who.name
      ..actedAt = DateTime.now()
      ..comment = (comment == null || comment.trim().isEmpty) ? null : comment.trim();
    _advance(r);
    notifyListeners();
  }

  void reject(ApprovalRequest r, DemoIdentity who, {required String comment}) {
    final step = r.currentStep;
    if (step == null || !canAct(r, who)) return;
    final override = isOverride(r, who);
    step
      ..status = StepStatus.rejected
      ..actedBy = override ? '${who.name} (Admin override)' : who.name
      ..actedAt = DateTime.now()
      ..comment = comment.trim();
    r.status = RequestStatus.rejected;
    r.closedAt = DateTime.now();
    notifyListeners();
  }

  void withdraw(ApprovalRequest r) {
    if (!r.isPending) return;
    for (final s in r.steps) {
      if (s.status == StepStatus.pending) s.status = StepStatus.waiting;
    }
    r.status = RequestStatus.withdrawn;
    r.closedAt = DateTime.now();
    notifyListeners();
  }

  void _applyEffect(ApprovalRequest r) {
    switch (r.actionType) {
      case ApprovalActionType.cancelReceipt:
        if (r.receiptNumber != null) MockData.cancelReceipt(r.receiptNumber!);
        r.outcome = 'Receipt ${r.receiptNumber} cancelled';
      case ApprovalActionType.donorChange:
        final donor = r.donorId == null ? null : MockData.donorById(r.donorId!);
        if (donor != null) {
          String? v(String field) {
            for (final c in r.changes) {
              if (c.field == field) return c.after;
            }
            return null;
          }

          MockData.replaceDonor(
            donor.copyWith(name: v('name'), email: v('email'), address: v('address'), city: v('city'), pan: v('pan')),
          );
        }
        r.outcome = 'Donor details updated';
      case ApprovalActionType.patronEnrol:
        if (r.donorId != null) {
          DrmStore.instance.enrolPatron(
            donorId: r.donorId!,
            schemeName: r.patronScheme ?? 'Patron',
            trust: r.patronTrust ?? 'HKMV',
            committedAmount: r.amount ?? 0,
          );
        }
        r.outcome = 'Enrolled as ${r.patronScheme ?? 'patron'}';
      case ApprovalActionType.highValueReceipt:
        final receipt = r.pendingReceipt;
        if (receipt != null && MockData.donationByReceipt(receipt.receiptNumber) == null) {
          MockData.addDonation(receipt.copyWith(status: DonationStatus.approved));
        }
        r.outcome = 'Receipt issued: ${receipt?.receiptNumber ?? '-'}';
    }
  }

  // --- seed ---------------------------------------------------------------

  void _seed() {
    levels.addAll([
      ApprovalLevel(id: 'L1', name: 'Team Leader', order: 1, approverType: ApproverType.teamLeader),
      ApprovalLevel(id: 'L2', name: 'DCC Approver', order: 2, approverType: ApproverType.users, members: ['Radha Madhava Das', 'Sita Devi Dasi']),
      ApprovalLevel(id: 'L3', name: 'Admin', order: 3, approverType: ApproverType.users, members: ['Temple President']),
    ]);
    rules.addAll({
      ApprovalActionType.cancelReceipt: ApprovalRule(
        actionType: ApprovalActionType.cancelReceipt,
        label: 'Receipt cancellation',
        steps: [RuleStep(levelId: 'L2'), RuleStep(levelId: 'L3', minAmount: 25000)],
      ),
      ApprovalActionType.donorChange: ApprovalRule(
        actionType: ApprovalActionType.donorChange,
        label: 'Donor detail change',
        steps: [RuleStep(levelId: 'L2')],
      ),
      ApprovalActionType.patronEnrol: ApprovalRule(
        actionType: ApprovalActionType.patronEnrol,
        label: 'Patron enrolment / upgrade',
        steps: [RuleStep(levelId: 'L1'), RuleStep(levelId: 'L2'), RuleStep(levelId: 'L3')],
      ),
      ApprovalActionType.highValueReceipt: ApprovalRule(
        actionType: ApprovalActionType.highValueReceipt,
        label: 'High-value / cash receipt',
        thresholdAmount: 100000,
        cashThresholdAmount: 20000,
        steps: [RuleStep(levelId: 'L2'), RuleStep(levelId: 'L3', minAmount: 500000)],
      ),
    });

    final today = MockData.today;
    DateTime at(int daysAgo, int hour) => today.subtract(Duration(days: daysAgo)).add(Duration(hours: hour));
    RequestStep step(int order, String levelId, StepStatus status, {String? by, DateTime? on, String? comment, String? assignee}) {
      final level = levelById(levelId)!;
      return RequestStep(
        order: order,
        levelId: levelId,
        levelName: level.name,
        assignee: assignee ?? level.members.join(', '),
        status: status,
        actedBy: by,
        actedAt: on,
        comment: comment,
      );
    }

    MockDonation? find(bool Function(MockDonation d) test) {
      for (final d in MockData.donations) {
        if (test(d)) return d;
      }
      return null;
    }

    List<(String, String)> receiptDetails(MockDonation d) => [
          ('Receipt no.', d.receiptNumber),
          ('Receipt date', ddmmyyyy(d.date)),
          ('Trust', d.trust),
          ('Seva', d.sevaLabel),
          ('Mode', d.modeOfPayment),
        ];

    // 1. Small cancellation - pending at DCC Approver only (< ₹25,000)
    final small = find((d) => d.donorId == 'D1029' && d.status != DonationStatus.cancelled && d.amount < 25000);
    if (small != null) {
      requests.add(ApprovalRequest(
        id: 'AR-1001',
        actionType: ApprovalActionType.cancelReceipt,
        title: 'Cancel receipt ${small.receiptNumber}',
        donorId: small.donorId,
        donorName: small.donorName,
        amount: small.amount,
        reason: 'Donor paid twice by mistake - duplicate receipt',
        requestedBy: 'ABRD',
        requestedAt: at(2, 10),
        receiptNumber: small.receiptNumber,
        details: receiptDetails(small),
        steps: [step(1, 'L2', StepStatus.pending)],
      ));
    }

    // 2. Large cancellation - DCC Approver done, waiting on Admin
    final large = find((d) => d.donorId == 'D1024' && d.amount == 25116 && d.status != DonationStatus.cancelled);
    if (large != null) {
      requests.add(ApprovalRequest(
        id: 'AR-1002',
        actionType: ApprovalActionType.cancelReceipt,
        title: 'Cancel receipt ${large.receiptNumber}',
        donorId: large.donorId,
        donorName: large.donorName,
        amount: large.amount,
        reason: 'Seva moved to Deepotsava - donor wants a fresh receipt',
        requestedBy: 'ABRD',
        requestedAt: at(5, 9),
        receiptNumber: large.receiptNumber,
        details: receiptDetails(large),
        steps: [
          step(1, 'L2', StepStatus.approved, by: 'Sita Devi Dasi', on: at(4, 15), comment: 'Verified with accounts'),
          step(2, 'L3', StepStatus.pending),
        ],
      ));
    }

    // 3. Donor change - pending at DCC Approver
    final hari = MockData.donorById('D1032');
    if (hari != null) {
      requests.add(ApprovalRequest(
        id: 'AR-1003',
        actionType: ApprovalActionType.donorChange,
        title: 'Update contact details',
        donorId: hari.id,
        donorName: hari.name,
        reason: 'Donor shifted office and shared a new email',
        requestedBy: 'ABRD',
        requestedAt: at(1, 12),
        changes: [
          FieldChange('email', hari.email ?? '-', 'hari.prasad@adapa-infra.example.com'),
          FieldChange('address', hari.address ?? '-', 'Plot 44, IT SEZ, Rushikonda, Visakhapatnam'),
        ],
        steps: [step(1, 'L2', StepStatus.pending)],
      ));
    }

    // 4. Donor change - approved (after == today's data, so it's already applied)
    final anitha = MockData.donorById('D1027');
    if (anitha != null) {
      requests.add(ApprovalRequest(
        id: 'AR-1004',
        actionType: ApprovalActionType.donorChange,
        title: 'Correct address and PAN',
        donorId: anitha.id,
        donorName: anitha.name,
        reason: 'PAN missing on 80G receipts',
        requestedBy: 'Donor Care Office',
        requestedAt: at(10, 11),
        changes: [
          FieldChange('address', '1-5-7, Arundelpet, Guntur', anitha.address ?? '-'),
          const FieldChange('pan', '-', 'BXYPR5678K'),
        ],
        steps: [step(1, 'L2', StepStatus.approved, by: 'Radha Madhava Das', on: at(9, 16))],
        status: RequestStatus.approved,
        closedAt: at(9, 16),
        outcome: 'Donor details updated',
      ));
    }

    // 5. Patron enrolment - TL approved, pending at DCC Approver, Admin waiting
    final suresh = MockData.donorById('D1026');
    if (suresh != null) {
      requests.add(ApprovalRequest(
        id: 'AR-1005',
        actionType: ApprovalActionType.patronEnrol,
        title: 'Enrol as Nitya Seva Patron',
        donorId: suresh.id,
        donorName: suresh.name,
        amount: 100000,
        reason: 'Donor wants to restart giving as a patron',
        requestedBy: 'ABRD',
        requestedAt: at(3, 10),
        patronScheme: 'Nitya Seva Patron',
        patronTrust: 'HKMV',
        details: const [('Scheme', 'Nitya Seva Patron'), ('Trust', 'HKMV'), ('Committed', '₹1,00,000')],
        steps: [
          step(1, 'L1', StepStatus.approved, by: 'Govinda Das (TL)', on: at(3, 18), assignee: 'Govinda Das (TL)', comment: 'Good relationship, approve'),
          step(2, 'L2', StepStatus.pending),
          step(3, 'L3', StepStatus.waiting),
        ],
      ));
    }

    // 6. Patron enrolment - pending at Team Leader (only admin can override)
    final krishna = MockData.donorById('D1028');
    if (krishna != null) {
      requests.add(ApprovalRequest(
        id: 'AR-1006',
        actionType: ApprovalActionType.patronEnrol,
        title: 'Enrol as Annadana Patron',
        donorId: krishna.id,
        donorName: krishna.name,
        amount: 51000,
        reason: 'Regular festival donor, committed at Radhashtami',
        requestedBy: 'JTMD',
        requestedAt: at(1, 9),
        patronScheme: 'Annadana Patron',
        patronTrust: 'HKMV',
        details: const [('Scheme', 'Annadana Patron'), ('Trust', 'HKMV'), ('Committed', '₹51,000')],
        steps: [
          step(1, 'L1', StepStatus.pending, assignee: 'Govinda Das (TL)'),
          step(2, 'L2', StepStatus.waiting),
          step(3, 'L3', StepStatus.waiting),
        ],
      ));
    }

    // 7. High-value cheque - pending at DCC Approver (< ₹5,00,000 so no Admin)
    final ramesh = MockData.donorById('D1024');
    if (ramesh != null) {
      final now = DateTime.now().subtract(const Duration(hours: 6));
      requests.add(ApprovalRequest(
        id: 'AR-1007',
        actionType: ApprovalActionType.highValueReceipt,
        title: 'Receipt ₹1,50,000 by Cheque/DD',
        donorId: ramesh.id,
        donorName: ramesh.name,
        amount: 150000,
        reason: 'Amount at or above ₹1,00,000',
        requestedBy: 'ABRD',
        requestedAt: now,
        details: const [('Trust', 'HKMV'), ('Seva', 'Temple Construction - Pillar Sponsorship'), ('Mode', 'Cheque/DD')],
        pendingReceipt: MockDonation(
          receiptNumber: buildReceiptNumber(trust: 'HKMV', date: now, sequence: 9007),
          donorId: ramesh.id,
          donorName: ramesh.name,
          trust: 'HKMV',
          sevaCategory: 'Temple Construction',
          sevaName: 'Pillar Sponsorship',
          amount: 150000,
          modeOfPayment: 'Cheque/DD',
          date: now,
          status: DonationStatus.pending,
        ),
        steps: [step(1, 'L2', StepStatus.pending)],
      ));
    }

    // 8. Cash receipt - rejected
    final venkata = MockData.donorById('D1030');
    if (venkata != null) {
      requests.add(ApprovalRequest(
        id: 'AR-1008',
        actionType: ApprovalActionType.highValueReceipt,
        title: 'Receipt ₹25,000 in Cash',
        donorId: venkata.id,
        donorName: venkata.name,
        amount: 25000,
        reason: 'Cash at or above ₹20,000',
        requestedBy: 'SYMD',
        requestedAt: at(12, 11),
        details: const [('Trust', 'HKMI'), ('Seva', 'Annadanam - Sponsor a Week'), ('Mode', 'Cash')],
        steps: [
          step(1, 'L2', StepStatus.rejected,
              by: 'Radha Madhava Das', on: at(11, 10), comment: 'Please collect this by cheque or online transfer'),
        ],
        status: RequestStatus.rejected,
        closedAt: at(11, 10),
      ));
    }

    // 9. Cancellation already approved (receipt is cancelled in the data)
    final cancelled = find((d) => d.status == DonationStatus.cancelled);
    if (cancelled != null) {
      requests.add(ApprovalRequest(
        id: 'AR-1009',
        actionType: ApprovalActionType.cancelReceipt,
        title: 'Cancel receipt ${cancelled.receiptNumber}',
        donorId: cancelled.donorId,
        donorName: cancelled.donorName,
        amount: cancelled.amount,
        reason: 'Wrong trust selected',
        requestedBy: 'Donor Care Office',
        requestedAt: at(20, 10),
        receiptNumber: cancelled.receiptNumber,
        details: receiptDetails(cancelled),
        steps: [
          step(1, 'L2', StepStatus.approved, by: 'Sita Devi Dasi', on: at(19, 12)),
          if (cancelled.amount >= 25000) step(2, 'L3', StepStatus.approved, by: 'Temple President', on: at(18, 12)),
        ],
        status: RequestStatus.approved,
        closedAt: at(18, 12),
        outcome: 'Receipt ${cancelled.receiptNumber} cancelled',
      ));
    }

    // 10. Patron enrolment approved (D1032 is a patron in the data)
    if (hari != null) {
      requests.add(ApprovalRequest(
        id: 'AR-1010',
        actionType: ApprovalActionType.patronEnrol,
        title: 'Enrol as Temple Construction Patron',
        donorId: hari.id,
        donorName: hari.name,
        amount: 250000,
        reason: 'Committed during office visit',
        requestedBy: 'ABRD',
        requestedAt: at(8, 10),
        patronScheme: 'Temple Construction Patron',
        patronTrust: 'TSC',
        details: const [('Scheme', 'Temple Construction Patron'), ('Trust', 'TSC'), ('Committed', '₹2,50,000')],
        steps: [
          step(1, 'L1', StepStatus.approved, by: 'Govinda Das (TL)', on: at(8, 14), assignee: 'Govinda Das (TL)'),
          step(2, 'L2', StepStatus.approved, by: 'Radha Madhava Das', on: at(7, 11)),
          step(3, 'L3', StepStatus.approved, by: 'Temple President', on: at(6, 17), comment: 'Welcome aboard'),
        ],
        status: RequestStatus.approved,
        closedAt: at(6, 17),
        outcome: 'Enrolled as Temple Construction Patron',
      ));
    }

    // 11. Withdrawn by the requester
    final kalyani = find((d) => d.donorId == 'D1033' && d.status != DonationStatus.cancelled);
    if (kalyani != null) {
      requests.add(ApprovalRequest(
        id: 'AR-1011',
        actionType: ApprovalActionType.cancelReceipt,
        title: 'Cancel receipt ${kalyani.receiptNumber}',
        donorId: kalyani.donorId,
        donorName: kalyani.donorName,
        amount: kalyani.amount,
        reason: 'Thought the amount was wrong - it was correct',
        requestedBy: 'ABRD',
        requestedAt: at(15, 10),
        receiptNumber: kalyani.receiptNumber,
        details: receiptDetails(kalyani),
        steps: [step(1, 'L2', StepStatus.waiting)],
        status: RequestStatus.withdrawn,
        closedAt: at(15, 13),
      ));
    }
    _seq = 1011;
  }
}

