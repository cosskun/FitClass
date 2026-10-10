import 'package:fitpastel/core/utils/workout_calorie_calculator.dart';
import 'package:fitpastel/models/workout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkoutCalorieCalculator Tests', () {
    final library = [
      Exercise(id: 'squat', name: 'Squat', muscleGroup: 'Bacak', imagePath: ''),
      Exercise(id: 'bench', name: 'Bench Press', muscleGroup: 'Göğüs', imagePath: ''),
      Exercise(id: 'pullup', name: 'Barfiks', muscleGroup: 'Sırt', imagePath: ''),
      Exercise(id: 'biceps_curl', name: 'Biceps Curl', muscleGroup: 'Biceps', imagePath: ''),
    ];

    test('Calculates set calories accurately for completed leg set with high tonnage', () {
      final calories = WorkoutCalorieCalculator.calculateSetCalories(
        setWeightKg: 100.0,
        reps: 10,
        muscleGroup: 'Bacak',
        userWeightKg: 80.0,
        isCompleted: true,
      );

      // Base: (80 * 0.13) * 1.4 = 14.56
      // Volume: (100 * 10) * 0.00075 = 0.75
      // Total: ~15.31 kcal
      expect(calories, closeTo(15.31, 0.1));
    });

    test('Returns 0 calories for uncompleted sets or zero reps', () {
      final calUncompleted = WorkoutCalorieCalculator.calculateSetCalories(
        setWeightKg: 80.0,
        reps: 10,
        muscleGroup: 'Göğüs',
        userWeightKg: 75.0,
        isCompleted: false,
      );
      expect(calUncompleted, equals(0.0));

      final calZeroReps = WorkoutCalorieCalculator.calculateSetCalories(
        setWeightKg: 80.0,
        reps: 0,
        muscleGroup: 'Göğüs',
        userWeightKg: 75.0,
        isCompleted: true,
      );
      expect(calZeroReps, equals(0.0));
    });

    test('Calculates full workout summary correctly', () {
      final workout = Workout(
        date: DateTime.now(),
        sessions: [
          ExerciseSession(
            exerciseId: 'squat',
            sets: [
              ExerciseSet(weight: 80.0, reps: 8, isCompleted: true),
              ExerciseSet(weight: 90.0, reps: 6, isCompleted: true),
              ExerciseSet(weight: 100.0, reps: 5, isCompleted: false), // uncompleted
            ],
          ),
          ExerciseSession(
            exerciseId: 'bench',
            sets: [
              ExerciseSet(weight: 60.0, reps: 10, isCompleted: true),
              ExerciseSet(weight: 70.0, reps: 8, isCompleted: true),
            ],
          ),
        ],
      );

      final summary = WorkoutCalorieCalculator.calculateWorkoutSummary(
        workout: workout,
        exerciseLibrary: library,
        userWeightKg: 80.0,
      );

      expect(summary.totalSets, equals(5));
      expect(summary.completedSets, equals(4));
      expect(summary.totalVolumeKg, equals((80 * 8) + (90 * 6) + (60 * 10) + (70 * 8))); // 640+540+600+560 = 2340 kg
      expect(summary.totalCalories, greaterThan(40.0));
      expect(summary.completionRate, equals(4 / 5));
    });
  });
}
