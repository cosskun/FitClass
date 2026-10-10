import 'dart:convert';

class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String imagePath;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'imagePath': imagePath,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      muscleGroup: map['muscleGroup'] as String,
      imagePath: map['imagePath'] as String,
    );
  }

  String toJson() => json.encode(toMap());
  factory Exercise.fromJson(String source) => Exercise.fromMap(json.decode(source));
}

class ExerciseSet {
  double weight; // in kg
  int reps;
  bool isCompleted;

  ExerciseSet({
    required this.weight,
    required this.reps,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'reps': reps,
      'isCompleted': isCompleted,
    };
  }

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      weight: (map['weight'] as num).toDouble(),
      reps: map['reps'] as int,
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());
  factory ExerciseSet.fromJson(String source) => ExerciseSet.fromMap(json.decode(source));
}

class ExerciseSession {
  final String exerciseId;
  final List<ExerciseSet> sets;

  ExerciseSession({
    required this.exerciseId,
    required this.sets,
  });

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'sets': sets.map((x) => x.toMap()).toList(),
    };
  }

  factory ExerciseSession.fromMap(Map<String, dynamic> map) {
    return ExerciseSession(
      exerciseId: map['exerciseId'] as String,
      sets: List<ExerciseSet>.from(
        (map['sets'] as List).map((x) => ExerciseSet.fromMap(x as Map<String, dynamic>)),
      ),
    );
  }

  String toJson() => json.encode(toMap());
  factory ExerciseSession.fromJson(String source) => ExerciseSession.fromMap(json.decode(source));
}

class Workout {
  final DateTime date;
  final List<ExerciseSession> sessions;

  Workout({
    required this.date,
    required this.sessions,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'sessions': sessions.map((x) => x.toMap()).toList(),
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      date: DateTime.parse(map['date'] as String),
      sessions: List<ExerciseSession>.from(
        (map['sessions'] as List).map((x) => ExerciseSession.fromMap(x as Map<String, dynamic>)),
      ),
    );
  }

  String toJson() => json.encode(toMap());
  factory Workout.fromJson(String source) => Workout.fromMap(json.decode(source));
}
