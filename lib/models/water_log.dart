import 'dart:convert';

class WaterLog {
  final DateTime date;
  final int amountMl;

  WaterLog({
    required this.date,
    required this.amountMl,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'amountMl': amountMl,
    };
  }

  factory WaterLog.fromMap(Map<String, dynamic> map) {
    return WaterLog(
      date: DateTime.parse(map['date'] as String),
      amountMl: map['amountMl'] as int,
    );
  }

  String toJson() => json.encode(toMap());
  factory WaterLog.fromJson(String source) => WaterLog.fromMap(json.decode(source));
}
