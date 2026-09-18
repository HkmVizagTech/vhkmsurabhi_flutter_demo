// lib/core/mock/mock_donor_data.dart
//
// Shared mock data standing in for DCC's real donor/donation API, which
// doesn't exist yet. Shaped around DCC's actual schema (AccountType =
// trust: HKMV/HKMI/TSC, SevaCategory, ModeOfPayment, receipt status) so
// every screen that uses this can be swapped to live data later without
// changing its structure.

enum DonationStatus { pending, approved, cancelled }

// Demo stand-in for "the logged-in preacher's devotee code". DCC ties a
// donor to a preacher via Donor.EnrolledBy; since the dev-bypass user has
// no real devotee identity, every preacher-scoped screen filters on this
// same code so a preacher only ever sees donors/donations they enrolled.
const String kCurrentPreacherCode = 'ABRD';

class MockDonor {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String city;
  final String enrolledByCode;
  final String? address;
  final String? pan;
  final bool isPatron;

  const MockDonor({
    required this.id,
    required this.name,
    required this.mobile,
    required this.city,
    required this.enrolledByCode,
    this.email,
    this.address,
    this.pan,
    this.isPatron = false,
  });
}

/// Trust (DCC's AccountType) letterhead details used on the donation
/// receipt - name, registered address, contact, PAN and logo/stamp
/// assets, grounded in DCC's PDFService.GenerateDonationReceipt.
class TrustProfile {
  final String foundationName;
  final String footerFoundationName;
  final String addressLine1;
  final String addressLine2;
  final String phone;
  final String email;
  final String? pan;
  final String? logoAsset;
  final String stampAsset;
  final String? registeredOffice;

  const TrustProfile({
    required this.foundationName,
    required this.footerFoundationName,
    required this.addressLine1,
    required this.addressLine2,
    required this.phone,
    required this.email,
    required this.stampAsset,
    this.pan,
    this.logoAsset,
    this.registeredOffice,
  });
}

// Exact text from DCC/Common/PDFService.cs GenerateDonationReceipt's
// per-AccountType switch (GetReceiptHeader/GetReceiptFooter calls).
const Map<String, TrustProfile> trustProfiles = {
  'HKMV': TrustProfile(
    foundationName: 'HARE KRISHNA MOVEMENT VISAKHAPATNAM',
    footerFoundationName: 'HKM, Visakhapatnam',
    addressLine1: '#8-22, Near RTO Office, Next to Akshaya Patra Foundation Kitchen,',
    addressLine2: 'IIM Road, Gambheeram, Visakhapatanam - 530052. (A.P.) INDIA.',
    phone: '+91 9030696108',
    email: 'donorcare@hkmvizag.org',
    logoAsset: 'lib/assets/images/hkmvizaglogo.jpg',
    stampAsset: 'lib/assets/images/hkmvstamp.jpg',
  ),
  'HKMI': TrustProfile(
    foundationName: 'HARE KRISHNA MOVEMENT INDIA',
    footerFoundationName: 'HKM INDIA',
    addressLine1: 'Branch Office : #8-22, Near RTO Office, Next to Akshaya Patra Foundation Kitchen,',
    addressLine2: 'IIM Road, Gambheeram, Visakhapatanam - 530052. (A.P.) INDIA.',
    phone: '+91 9030696108',
    email: 'donorcare@hkmvizag.org',
    pan: 'AABTH4550P',
    logoAsset: 'lib/assets/images/hkmindialogo.JPG',
    stampAsset: 'lib/assets/images/hkmistamp.png',
    registeredOffice: 'Regd. & Head office : Sri Radha Vrindavan Chandra Mandir, Chatikara Road, '
        'Vrindavan, Mathura District, U.P. - 281 121',
  ),
  'TSC': TrustProfile(
    foundationName: 'TOUCHSTONE CHARITIES VISAKHAPATNAM',
    footerFoundationName: 'Touchstone Charities, Visakhapatnam',
    addressLine1: 'Regd. Off : #8-22, Near RTO Office, Next to Akshaya Patra Foundation Kitchen,',
    addressLine2: 'IIM Road, Gambheeram, Visakhapatanam - 530052. (A.P.) INDIA.',
    phone: '+91 9030696108',
    email: 'donorcare@hkmvizag.org',
    pan: 'AACTT5014B',
    stampAsset: 'lib/assets/images/tcvstamp.png',
  ),
};

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
    const MockDonor(id: 'D1024', name: 'Ramesh Chandra Rao', mobile: '9866123001', city: 'Visakhapatnam', enrolledByCode: 'ABRD', email: 'ramesh.rao@example.com', address: '12-3-45, Dwaraka Nagar, Visakhapatnam', pan: 'ABCDE1234F', isPatron: true),
    const MockDonor(id: 'D1025', name: 'Lakshmi Devi Pusapati', mobile: '9866123002', city: 'Vijayawada', enrolledByCode: 'JTMD', email: 'lakshmi.devi@example.com', address: '4-6-12, Governorpet, Vijayawada'),
    const MockDonor(id: 'D1026', name: 'Suresh Babu Kotturi', mobile: '9866123003', city: 'Visakhapatnam', enrolledByCode: 'ABRD', address: '9-1-23, MVP Colony, Visakhapatnam'),
    const MockDonor(id: 'D1027', name: 'Anitha Reddy Vempati', mobile: '9866123004', city: 'Guntur', enrolledByCode: 'SRND', email: 'anitha.reddy@example.com', address: '3-2-8, Brodipet, Guntur', pan: 'BXYPR5678K', isPatron: true),
    const MockDonor(id: 'D1028', name: 'Krishna Murthy Yalamanchili', mobile: '9866123005', city: 'Rajahmundry', enrolledByCode: 'JTMD', address: '7-11-2, Danavaipeta, Rajahmundry'),
    const MockDonor(id: 'D1029', name: 'Padma Priya Chekuri', mobile: '9866123006', city: 'Visakhapatnam', enrolledByCode: 'ABRD', email: 'padma.priya@example.com', address: '15-8-9, Seethammadhara, Visakhapatnam', isPatron: true),
    const MockDonor(id: 'D1030', name: 'Venkata Ramana Gubbala', mobile: '9866123007', city: 'Kakinada', enrolledByCode: 'SYMD', address: '2-4-19, Suryaraopeta, Kakinada'),
    const MockDonor(id: 'D1031', name: 'Sita Mahalakshmi Nallamothu', mobile: '9866123008', city: 'Visakhapatnam', enrolledByCode: 'ABRD', address: '11-2-6, Pedagantyada, Visakhapatnam'),
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

  /// Donors enrolled by a given devotee code (DCC's Donor.EnrolledBy),
  /// optionally narrowed to just their patrons.
  static List<MockDonor> donorsFor(String enrolledByCode, {bool patronsOnly = false}) {
    return donors.where((d) => d.enrolledByCode == enrolledByCode && (!patronsOnly || d.isPatron)).toList();
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
