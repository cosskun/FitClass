import 'dart:convert';

class PersonalRecord {
  final String exerciseId;
  final String exerciseName;
  final double maxWeight;
  final int reps;
  final DateTime date;

  PersonalRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.maxWeight,
    required this.reps,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'maxWeight': maxWeight,
      'reps': reps,
      'date': date.toIso8601String(),
    };
  }

  factory PersonalRecord.fromMap(Map<String, dynamic> map) {
    return PersonalRecord(
      exerciseId: map['exerciseId'] as String,
      exerciseName: map['exerciseName'] as String,
      maxWeight: (map['maxWeight'] as num).toDouble(),
      reps: map['reps'] as int,
      date: DateTime.parse(map['date'] as String),
    );
  }

  String toJson() => json.encode(toMap());
  factory PersonalRecord.fromJson(String source) => PersonalRecord.fromMap(json.decode(source));
}
