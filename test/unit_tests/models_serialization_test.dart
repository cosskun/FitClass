import 'package:flutter_test/flutter_test.dart';
import 'package:fitpastel/models/models.dart';

void main() {
  group('Model Serialization Tests', () {
    test('Workout, ExerciseSession and ExerciseSet serialization', () {
      final workout = Workout(
        date: DateTime(2026, 10, 5),
        sessions: [
          ExerciseSession(
            exerciseId: 'bench_press',
            sets: [
              ExerciseSet(weight: 80.0, reps: 10, isCompleted: true),
              ExerciseSet(weight: 85.0, reps: 8, isCompleted: false),
            ],
          ),
        ],
      );

      final json = workout.toJson();
      final fromJson = Workout.fromJson(json);

      expect(fromJson.date.year, 2026);
      expect(fromJson.sessions.length, 1);
      expect(fromJson.sessions[0].exerciseId, 'bench_press');
      expect(fromJson.sessions[0].sets.length, 2);
      expect(fromJson.sessions[0].sets[0].weight, 80.0);
      expect(fromJson.sessions[0].sets[0].reps, 10);
      expect(fromJson.sessions[0].sets[0].isCompleted, true);
      expect(fromJson.sessions[0].sets[1].isCompleted, false);
    });

    test('Meal and MealTemplate serialization', () {
      final meal = Meal(
        id: 'meal_1',
        name: 'Tavuklu Pilav',
        calories: 480.0,
        protein: 22.0,
        timestamp: DateTime(2026, 10, 5, 12, 30),
      );

      final mealJson = meal.toJson();
      final mealRestored = Meal.fromJson(mealJson);

      expect(mealRestored.id, 'meal_1');
      expect(mealRestored.name, 'Tavuklu Pilav');
      expect(mealRestored.calories, 480.0);
      expect(mealRestored.protein, 22.0);

      final tmpl = MealTemplate(
        id: 'tmpl_1',
        title: 'Klasik Kahvaltı',
        description: 'Yulaf + Fıstık Ezmesi',
        calories: 450.0,
        protein: 25.0,
      );

      final tmplJson = tmpl.toJson();
      final tmplRestored = MealTemplate.fromJson(tmplJson);

      expect(tmplRestored.id, 'tmpl_1');
      expect(tmplRestored.title, 'Klasik Kahvaltı');
      expect(tmplRestored.description, 'Yulaf + Fıstık Ezmesi');
      expect(tmplRestored.calories, 450.0);
      expect(tmplRestored.protein, 25.0);
    });

    test('WaterLog, BodyMeasurement and ProgressPhoto serialization', () {
      final water = WaterLog(
        date: DateTime(2026, 10, 5, 10, 0),
        amountMl: 500,
      );
      final waterRestored = WaterLog.fromJson(water.toJson());
      expect(waterRestored.amountMl, 500);
      expect(waterRestored.date.year, 2026);

      final measurement = BodyMeasurement(
        date: DateTime(2026, 10, 5),
        weight: 78.5,
        arm: 38.0,
        waist: 82.0,
        chest: 104.0,
        shoulder: 120.0,
        leg: 58.0,
      );
      final measurementRestored = BodyMeasurement.fromJson(measurement.toJson());
      expect(measurementRestored.weight, 78.5);
      expect(measurementRestored.arm, 38.0);
      expect(measurementRestored.waist, 82.0);

      final photo = ProgressPhoto(
        id: 'p_1',
        date: DateTime(2026, 10, 5),
        imagePath: 'assets/images/form.png',
        note: '1. Ay Gelişimi',
      );
      final photoRestored = ProgressPhoto.fromJson(photo.toJson());
      expect(photoRestored.note, '1. Ay Gelişimi');
    });
  });
}
