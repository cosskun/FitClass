import 'dart:convert';

class Meal {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final DateTime timestamp;
  final String? imagePath;

  Meal({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.timestamp,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] as String,
      name: map['name'] as String,
      calories: (map['calories'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      imagePath: map['imagePath'] as String?,
    );
  }

  String toJson() => json.encode(toMap());
  factory Meal.fromJson(String source) => Meal.fromMap(json.decode(source));
}

class MealTemplate {
  final String id;
  final String title;
  final String description;
  final double calories;
  final double protein;

  MealTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.calories,
    required this.protein,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'calories': calories,
      'protein': protein,
    };
  }

  factory MealTemplate.fromMap(Map<String, dynamic> map) {
    return MealTemplate(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      calories: (map['calories'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());
  factory MealTemplate.fromJson(String source) => MealTemplate.fromMap(json.decode(source));
}
