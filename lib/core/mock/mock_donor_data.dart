// lib/core/mock/mock_donor_data.dart
//
// Shared mock data standing in for DCC's real donor/donation API, which
// doesn't exist yet. Shaped around DCC's actual schema (AccountType =
// trust: HKMV/HKMI/TSC, SevaCategory, ModeOfPayment, receipt status) so
// every screen that uses this can be swapped to live data later without
// changing its structure.

enum DonationStatus { pending, approved, cancelled }

class MockDonor {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String city;
  final String enrolledByCode;

  const MockDonor({
    required this.id,
    required this.name,
    required this.mobile,
    required this.city,
    required this.enrolledByCode,
    this.email,
  });
}

class MockDonation {
  final String receiptNumber;
  final String donorId;
  final String donorName;
  final String trust; // HKMV / HKMI / TSC
  final String sevaCategory;
  final int amount;
  final String modeOfPayment;
  final DateTime date;
  final DonationStatus status;

  const MockDonation({
    required this.receiptNumber,
    required this.donorId,
    required this.donorName,
    required this.trust,
    required this.sevaCategory,
    required this.amount,
    required this.modeOfPayment,
    required this.date,
    required this.status,
  });

  MockDonation copyWith({DonationStatus? status}) {
    return MockDonation(
      receiptNumber: receiptNumber,
      donorId: donorId,
      donorName: donorName,
      trust: trust,
      sevaCategory: sevaCategory,
      amount: amount,
      modeOfPayment: modeOfPayment,
      date: date,
      status: status ?? this.status,
    );
  }
}

class SevaSubCategory {
  final String category; // parent SevaCategory name
  final String name;
  final String code;
  final int? amount; // fixed seva amount, if any (null = donor enters amount)

  const SevaSubCategory({required this.category, required this.name, required this.code, this.amount});
}

class MockData {
  MockData._();

  static const List<String> trusts = ['HKMV', 'HKMI', 'TSC'];
  static const List<String> sevaCategories = [
    'Annadanam',
    'General Donation',
    'Festival Donations',
    'Nitya Sevas',
    'Temple Construction',
  ];

  // Grounded in DCC's SevaSubCategory table (CategoryId -> SevaCategory).
  static const List<SevaSubCategory> sevaSubCategories = [
    SevaSubCategory(category: 'Annadanam', name: 'Daily Annadanam', code: 'ANN01', amount: 501),
    SevaSubCategory(category: 'Annadanam', name: 'Festival Annadanam', code: 'ANN02', amount: 2501),
    SevaSubCategory(category: 'Annadanam', name: 'Sponsor a Week', code: 'ANN03', amount: 5001),
    SevaSubCategory(category: 'General Donation', name: 'Temple General Fund', code: 'GEN01'),
    SevaSubCategory(category: 'General Donation', name: 'Deity Seva', code: 'GEN02', amount: 1001),
    SevaSubCategory(category: 'Festival Donations', name: 'Janmashtami', code: 'FES01'),
    SevaSubCategory(category: 'Festival Donations', name: 'Rathayatra', code: 'FES02'),
    SevaSubCategory(category: 'Festival Donations', name: 'Gaura Purnima', code: 'FES03'),
    SevaSubCategory(category: 'Nitya Sevas', name: 'Tulasi Seva', code: 'NIT01', amount: 251),
    SevaSubCategory(category: 'Nitya Sevas', name: 'Guru Puja Sponsorship', code: 'NIT02', amount: 501),
    SevaSubCategory(category: 'Temple Construction', name: 'Brick Donation', code: 'CON01', amount: 1116),
    SevaSubCategory(category: 'Temple Construction', name: 'Pillar Sponsorship', code: 'CON02', amount: 100001),
  ];

  static List<SevaSubCategory> subCategoriesFor(String category) =>
      sevaSubCategories.where((s) => s.category == category).toList();

  // Grounded in DCC's ModeOfPayment lookup table (exact spelling: "Cheque/DD").
  static const List<String> modesOfPayment = ['Cash', 'Card', 'Online', 'Cheque/DD', 'Others'];

  static final List<MockDonor> donors = [
    const MockDonor(id: 'D1024', name: 'Ramesh Chandra Rao', mobile: '9866123001', city: 'Visakhapatnam', enrolledByCode: 'ABRD', email: 'ramesh.rao@example.com'),
    const MockDonor(id: 'D1025', name: 'Lakshmi Devi Pusapati', mobile: '9866123002', city: 'Vijayawada', enrolledByCode: 'JTMD', email: 'lakshmi.devi@example.com'),
    const MockDonor(id: 'D1026', name: 'Suresh Babu Kotturi', mobile: '9866123003', city: 'Visakhapatnam', enrolledByCode: 'ABRD'),
    const MockDonor(id: 'D1027', name: 'Anitha Reddy Vempati', mobile: '9866123004', city: 'Guntur', enrolledByCode: 'SRND', email: 'anitha.reddy@example.com'),
    const MockDonor(id: 'D1028', name: 'Krishna Murthy Yalamanchili', mobile: '9866123005', city: 'Rajahmundry', enrolledByCode: 'JTMD'),
    const MockDonor(id: 'D1029', name: 'Padma Priya Chekuri', mobile: '9866123006', city: 'Visakhapatnam', enrolledByCode: 'ABRD', email: 'padma.priya@example.com'),
    const MockDonor(id: 'D1030', name: 'Venkata Ramana Gubbala', mobile: '9866123007', city: 'Kakinada', enrolledByCode: 'SYMD'),
    const MockDonor(id: 'D1031', name: 'Sita Mahalakshmi Nallamothu', mobile: '9866123008', city: 'Visakhapatnam', enrolledByCode: 'ABRD'),
  ];

  static final List<MockDonation> donations = _generateDonations();

  static List<MockDonation> _generateDonations() {
    final now = DateTime(2026, 9, 17);
    final entries = <MockDonation>[];
    final modes = modesOfPayment;
    var counter = 1;

    for (final donor in donors) {
      final donationCount = 2 + (donor.id.hashCode.abs() % 4);
      for (var i = 0; i < donationCount; i++) {
        final trust = trusts[(donor.id.hashCode + i) % trusts.length];
        final seva = sevaCategories[(donor.id.hashCode + i * 3) % sevaCategories.length];
        final daysAgo = (i * 11 + donor.id.hashCode.abs()) % 150;
        final amount = 501 + ((donor.id.hashCode.abs() + i * 777) % 20) * 501;
        final status = i == 0
            ? DonationStatus.pending
            : (counter % 5 == 0 ? DonationStatus.cancelled : DonationStatus.approved);

        entries.add(
          MockDonation(
            receiptNumber: '$trust|2026|${counter.toString().padLeft(4, '0')}',
            donorId: donor.id,
            donorName: donor.name,
            trust: trust,
            sevaCategory: seva,
            amount: amount,
            modeOfPayment: modes[counter % modes.length],
            date: now.subtract(Duration(days: daysAgo)),
            status: status,
          ),
        );
        counter++;
      }
    }
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  static List<MockDonation> donationsForDonor(String donorId) {
    return donations.where((d) => d.donorId == donorId).toList();
  }

  static List<MockDonor> searchDonors(String query) {
    if (query.trim().isEmpty) return donors;
    final q = query.trim().toLowerCase();
    return donors.where((d) => d.name.toLowerCase().contains(q) || d.mobile.contains(q) || d.id.toLowerCase().contains(q)).toList();
  }

  static List<MockDonation> donationsByStatus(DonationStatus status) {
    return donations.where((d) => d.status == status).toList();
  }
}
