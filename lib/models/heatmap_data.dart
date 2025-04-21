class HeatmapData {
  final int year;
  final int month;
  final int date;
  final int heatLevel;

  HeatmapData({
    required this.year,
    required this.month,
    required this.date,
    required this.heatLevel,
  });

  /// Convert to Map for saving in Firestore / local storage
  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'date': date,
      'heatLevel': heatLevel,
    };
  }

  /// Construct from Map
  factory HeatmapData.fromMap(Map<String, dynamic> map) {
    return HeatmapData(
      year: map['year'] as int,
      month: map['month'] as int,
      date: map['date'] as int,
      heatLevel: map['heatLevel'] as int,
    );
  }

  /// Helpful for debugging or printing
  @override
  String toString() {
    return 'HeatmapData(year: $year, month: $month, date: $date, heatLevel: $heatLevel)';
  }
}
