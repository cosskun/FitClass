import 'dart:convert';

class BodyMeasurement {
  final DateTime date;
  final double? weight;
  final double? chest; // cm
  final double? waist; // cm
  final double? arm; // cm
  final double? shoulder; // cm
  final double? leg; // cm
  final double? hip; // cm

  BodyMeasurement({
    required this.date,
    this.weight,
    this.chest,
    this.waist,
    this.arm,
    this.shoulder,
    this.leg,
    this.hip,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      'chest': chest,
      'waist': waist,
      'arm': arm,
      'shoulder': shoulder,
      'leg': leg,
      'hip': hip,
    };
  }

  factory BodyMeasurement.fromMap(Map<String, dynamic> map) {
    return BodyMeasurement(
      date: DateTime.parse(map['date'] as String),
      weight: (map['weight'] as num?)?.toDouble(),
      chest: (map['chest'] as num?)?.toDouble(),
      waist: (map['waist'] as num?)?.toDouble(),
      arm: (map['arm'] as num?)?.toDouble(),
      shoulder: (map['shoulder'] as num?)?.toDouble(),
      leg: (map['leg'] as num?)?.toDouble(),
      hip: (map['hip'] as num?)?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());
  factory BodyMeasurement.fromJson(String source) => BodyMeasurement.fromMap(json.decode(source));
}
