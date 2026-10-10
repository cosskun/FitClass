import 'package:flutter_test/flutter_test.dart';
import 'package:fitpastel/models/models.dart';

void main() {
  group('UserProfile Calculation & Goal Optimization Tests', () {
    test('Calculates Kas Kazanımı (Hypertrophy) protein and calories accurately', () {
      final profile = UserProfile(
        height: 180.0,
        weight: 80.0,
        age: 25,
        gender: 'Erkek',
        activityLevelMultiplier: 1.55,
        goal: 'Kas Kazanımı',
      );

      // Kas Kazanımı: 80kg * 1.8 = 144g
      expect(profile.dailyProteinGoal, 144.0);

      // BMR = 88.362 + (13.397 * 80) + (4.799 * 180) - (5.677 * 25) = 1882.017
      // TDEE = 1882.017 * 1.55 = 2917.12
      // Kas Kazanımı (+300 kcal surplus) = 3217 kcal
      expect(profile.dailyCalorieGoal, closeTo(2917.0 + 300, 2.0));
      expect(profile.dailyWaterGoal, 80 * 35.0);
    });

    test('Calculates Kilo Verme (Fat Loss) protein and calorie deficit accurately', () {
      final profile = UserProfile(
        height: 175.0,
        weight: 80.0,
        age: 30,
        gender: 'Erkek',
        activityLevelMultiplier: 1.375,
        goal: 'Kilo Verme',
      );

      // Kilo Verme (Kas Koruma): 80kg * 1.5 = 120g
      expect(profile.dailyProteinGoal, 120.0);

      // BMR = 88.362 + (13.397 * 80) + (4.799 * 175) - (5.677 * 30) = 1829.637
      // TDEE = 1829.637 * 1.375 = 2515.75
      // Kilo Verme (-400 kcal deficit) = 2116 kcal
      expect(profile.dailyCalorieGoal, closeTo(2516.0 - 400, 2.0));
    });

    test('Calculates Form Koruma & Sağlıklı Yaşam balanced baseline', () {
      final profile = UserProfile(
        height: 165.0,
        weight: 60.0,
        age: 28,
        gender: 'Kadın',
        activityLevelMultiplier: 1.2,
        goal: 'Form Koruma',
      );

      // Form Koruma: 60kg * 1.1 = 66g
      expect(profile.dailyProteinGoal, 66.0);

      // Female BMR = 447.593 + (9.247 * 60) + (3.098 * 165) - (4.330 * 28) = 1392.343
      // TDEE (maintenance) = 1392.343 * 1.2 = 1671 kcal
      expect(profile.dailyCalorieGoal, closeTo(1671.0, 2.0));
    });

    test('Calculates Hafif Egzersiz moderate baseline', () {
      final profile = UserProfile(
        height: 170.0,
        weight: 70.0,
        age: 26,
        gender: 'Erkek',
        activityLevelMultiplier: 1.375,
        goal: 'Hafif Egzersiz',
      );

      // Hafif Egzersiz: 70kg * 1.4 = 98g
      expect(profile.dailyProteinGoal, 98.0);
    });

    test('JSON serialization and deserialization preserves goal', () {
      final original = UserProfile(
        height: 175.0,
        weight: 70.0,
        age: 30,
        gender: 'Erkek',
        activityLevelMultiplier: 1.2,
        goal: 'Kilo Verme',
        dailyProteinGoal: 105.0,
        dailyCalorieGoal: 1900.0,
        dailyWaterGoal: 2450.0,
      );

      final jsonMap = original.toJson();
      final restored = UserProfile.fromJson(jsonMap);

      expect(restored.height, original.height);
      expect(restored.weight, original.weight);
      expect(restored.age, original.age);
      expect(restored.gender, original.gender);
      expect(restored.activityLevelMultiplier, original.activityLevelMultiplier);
      expect(restored.goal, 'Kilo Verme');
      expect(restored.dailyProteinGoal, 105.0);
      expect(restored.dailyCalorieGoal, 1900.0);
      expect(restored.dailyWaterGoal, 2450.0);
    });
  });
}
