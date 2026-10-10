import 'dart:convert';

class NutritionReminder {
  final String id;
  final int hour;
  final int minute;
  bool isEnabled;

  NutritionReminder({
    required this.id,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'isEnabled': isEnabled,
    };
  }

  factory NutritionReminder.fromMap(Map<String, dynamic> map) {
    return NutritionReminder(
      id: map['id'] as String,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      isEnabled: map['isEnabled'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());
  factory NutritionReminder.fromJson(String source) => NutritionReminder.fromMap(json.decode(source));
}
