class AppSettings {
  final bool darkMode;
  final double fontSize;
  final bool autoSync;

  AppSettings({
    required this.darkMode,
    required this.fontSize,
    required this.autoSync,
  });

  Map<String, dynamic> toMap() => {
    'darkMode': darkMode,
    'fontSize': fontSize,
    'autoSync': autoSync,
  };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
    darkMode: map['darkMode'] ?? false,
    fontSize: map['fontSize']?.toDouble() ?? 16.0,
    autoSync: map['autoSync'] ?? false,
  );
}
