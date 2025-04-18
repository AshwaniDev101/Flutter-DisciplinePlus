class AppTime {
  final int hour;
  final int minute;

  const AppTime(this.hour, this.minute);

  // Helper method for formatting time as HH:MM
  String remainingTime() {
    if (hour == 0) return "${minute}m";
    if (minute == 0) return "${hour}h";
    return "${hour}h ${minute}m";
  }

  @override
  String toString() {
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour >= 12 ? 'PM' : 'AM';
    return "${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";
  }

  bool get isZero => hour == 0 && minute == 0;

  Map<String, dynamic> toMap() => {
    'hour': hour,
    'minute': minute,
  };

  factory AppTime.fromMap(Map<String, dynamic> map) {
    return AppTime(
      map['hour'] as int,
      map['minute'] as int,
    );
  }
}