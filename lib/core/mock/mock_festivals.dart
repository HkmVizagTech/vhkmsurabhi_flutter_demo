// lib/core/mock/mock_festivals.dart
//
// Festival master, mirroring DCC's new dbo.Festival / dbo.FestivalSeva:
// every festival has ONE FestivalCode (e.g. JANMASHTAMI-2026) shared by DCC,
// the website and the Vaikuntham app, and each seva has a stable SevaKey
// that DCC maps to its own seva codes. Dates are the real 2026 calendar.

class MockFestivalSeva {
  final String sevaKey;
  final String name;
  final int? suggestedAmount;

  const MockFestivalSeva({required this.sevaKey, required this.name, this.suggestedAmount});
}

class MockFestival {
  final String festivalCode;
  final String name;
  final DateTime festivalDate;
  final DateTime collectionStart;
  final DateTime collectionEnd;
  final String trust;
  // The festival's own DCC seva: Festival Donations > <this sub-category>
  final String dccSubCategory;
  final List<MockFestivalSeva> sevas;

  const MockFestival({
    required this.festivalCode,
    required this.name,
    required this.festivalDate,
    required this.collectionStart,
    required this.collectionEnd,
    required this.trust,
    required this.dccSubCategory,
    required this.sevas,
  });

  bool isCollectingOn(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return !d.isBefore(collectionStart) && !d.isAfter(collectionEnd);
  }

  bool isUpcomingOn(DateTime day) => DateTime(day.year, day.month, day.day).isBefore(collectionStart);
}

// DCC's festival sevas (SevaSubCategoryCode rows under each festival)
const List<MockFestivalSeva> _dccFestivalSevas = [
  MockFestivalSeva(sevaKey: 'ABHISHEKAM', name: 'Abhishekam', suggestedAmount: 1116),
  MockFestivalSeva(sevaKey: 'MANDAPA_SEVA', name: 'Mandapa Seva', suggestedAmount: 2516),
  MockFestivalSeva(sevaKey: 'PUSHPALANKARA_SEVA', name: 'Pushpalankara Seva', suggestedAmount: 5116),
  MockFestivalSeva(sevaKey: 'YAJAMANA_SEVA', name: 'Yajamana Seva', suggestedAmount: 25116),
];

final List<MockFestival> mockFestivals = [
  MockFestival(
    festivalCode: 'DEEPOTSAVA-2026',
    name: 'Deepotsava 2026',
    festivalDate: DateTime(2026, 11, 8),
    collectionStart: DateTime(2026, 10, 15),
    collectionEnd: DateTime(2026, 11, 20),
    trust: 'HKMV',
    dccSubCategory: 'Deepotsava',
    sevas: _dccFestivalSevas,
  ),
  MockFestival(
    festivalCode: 'RADHASHTAMI-2026',
    name: 'Sri Radhashtami 2026',
    festivalDate: DateTime(2026, 9, 19),
    collectionStart: DateTime(2026, 9, 1),
    collectionEnd: DateTime(2026, 10, 5),
    trust: 'HKMV',
    dccSubCategory: 'Sri Radhashtami',
    sevas: _dccFestivalSevas,
  ),
  MockFestival(
    festivalCode: 'JANMASHTAMI-2026',
    name: 'Sri Krishna Janmashtami 2026',
    festivalDate: DateTime(2026, 9, 4),
    collectionStart: DateTime(2026, 8, 1),
    collectionEnd: DateTime(2026, 9, 30),
    trust: 'HKMV',
    dccSubCategory: 'Sri Krishna Janmashtami',
    sevas: _dccFestivalSevas,
  ),
];

MockFestival? festivalByCode(String? code) {
  if (code == null) return null;
  for (final f in mockFestivals) {
    if (f.festivalCode == code) return f;
  }
  return null;
}
