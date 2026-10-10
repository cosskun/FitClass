import '../../models/workout.dart';

class WorkoutSummary {
  final double totalCalories;
  final double totalVolumeKg;
  final int completedSets;
  final int totalSets;

  const WorkoutSummary({
    required this.totalCalories,
    required this.totalVolumeKg,
    required this.completedSets,
    required this.totalSets,
  });

  int get caloriesInt => totalCalories.round();
  int get volumeInt => totalVolumeKg.round();
  double get completionRate => totalSets > 0 ? (completedSets / totalSets) : 0.0;
}

class SessionSummary {
  final double calories;
  final double volumeKg;
  final int completedSets;
  final int totalSets;

  const SessionSummary({
    required this.calories,
    required this.volumeKg,
    required this.completedSets,
    required this.totalSets,
  });

  int get caloriesInt => calories.round();
  int get volumeInt => volumeKg.round();
}

class WorkoutCalorieCalculator {
  /// Kas gruplarının metabolik enerji ve harcama katsayıları (MET tabanlı)
  static const Map<String, double> muscleGroupMultipliers = {
    'Bacak': 1.40,  // En büyük kas kütlesi (Squat, Deadlift, Leg Press vb.)
    'Sırt': 1.25,   // Geniş kas grubu (Barfiks, Lat Pulldown, Row)
    'Göğüs': 1.20,  // Üst gövde itiş (Bench Press, Incline Press)
    'Omuz': 1.00,   // Omuz grubu
    'Biceps': 0.90, // Kol fleksörleri
    'Triceps': 0.90,// Kol ekstansörleri
    'Bilek': 0.80,  // Ön kol
    'Karın': 0.95,  // Merkez bölgesi
  };

  /// Tek bir set için yakılan kaloriyi hesaplar
  static double calculateSetCalories({
    required double setWeightKg,
    required int reps,
    required String muscleGroup,
    double userWeightKg = 75.0,
    bool isCompleted = true,
  }) {
    if (!isCompleted || reps <= 0) return 0.0;

    final double validUserWeight = userWeightKg > 0 ? userWeightKg : 75.0;
    final double multiplier = muscleGroupMultipliers[muscleGroup] ?? 1.0;

    // 1. Set icrası ve EPOC (Egzersiz sonrası oksijen tüketimi) temel metabolik maliyeti
    final double baseCalories = (validUserWeight * 0.13) * multiplier;

    // 2. Mekanik iş ve tonaj katkısı (Kaldırılan ağırlık x Tekrar x Dönüşüm faktörü)
    final double volume = (setWeightKg > 0 ? setWeightKg : (validUserWeight * 0.4)) * reps;
    final double volumeCalories = volume * 0.00075;

    return baseCalories + volumeCalories;
  }

  /// Bir egzersiz oturumu (Session) için toplam yakılan kalori ve hacmi hesaplar
  static SessionSummary calculateSessionSummary({
    required ExerciseSession session,
    required String muscleGroup,
    double userWeightKg = 75.0,
  }) {
    double totalCalories = 0.0;
    double totalVolume = 0.0;
    int completedSets = 0;

    for (final set in session.sets) {
      if (set.isCompleted && set.reps > 0) {
        completedSets++;
        totalCalories += calculateSetCalories(
          setWeightKg: set.weight,
          reps: set.reps,
          muscleGroup: muscleGroup,
          userWeightKg: userWeightKg,
          isCompleted: true,
        );
        totalVolume += (set.weight * set.reps);
      }
    }

    return SessionSummary(
      calories: totalCalories,
      volumeKg: totalVolume,
      completedSets: completedSets,
      totalSets: session.sets.length,
    );
  }

  /// Günlük antrenmanın (Workout) toplam yakılan kalori, tonaj ve set istatistiklerini hesaplar
  static WorkoutSummary calculateWorkoutSummary({
    required Workout workout,
    required List<Exercise> exerciseLibrary,
    double userWeightKg = 75.0,
  }) {
    double totalCalories = 0.0;
    double totalVolume = 0.0;
    int completedSets = 0;
    int totalSets = 0;

    final exerciseMap = {for (var e in exerciseLibrary) e.id: e};

    for (final session in workout.sessions) {
      final exercise = exerciseMap[session.exerciseId];
      final muscleGroup = exercise?.muscleGroup ?? 'Diğer';

      final summary = calculateSessionSummary(
        session: session,
        muscleGroup: muscleGroup,
        userWeightKg: userWeightKg,
      );

      totalCalories += summary.calories;
      totalVolume += summary.volumeKg;
      completedSets += summary.completedSets;
      totalSets += summary.totalSets;
    }

    return WorkoutSummary(
      totalCalories: totalCalories,
      totalVolumeKg: totalVolume,
      completedSets: completedSets,
      totalSets: totalSets,
    );
  }
}
