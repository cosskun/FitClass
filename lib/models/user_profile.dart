import 'dart:convert';

class UserProfile {
  final double height;
  final double weight;
  final int age;
  final String gender;
  final double activityLevelMultiplier; // e.g. 1.2, 1.375, 1.55, 1.725
  final String goal; // 'Kas Kazanımı', 'Kilo Verme', 'Form Koruma', 'Hafif Egzersiz'
  final double dailyProteinGoal;
  final double dailyCalorieGoal;
  final double dailyWaterGoal; // in ml

  UserProfile({
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.activityLevelMultiplier,
    this.goal = 'Kas Kazanımı',
    double? dailyProteinGoal,
    double? dailyCalorieGoal,
    double? dailyWaterGoal,
  })  : dailyProteinGoal = dailyProteinGoal ?? calculateProteinForGoal(weight, goal),
        dailyCalorieGoal = dailyCalorieGoal ?? calculateCaloriesForGoal(weight, height, age, gender, activityLevelMultiplier, goal),
        dailyWaterGoal = dailyWaterGoal ?? (weight * 35); // Default: 35ml per kg

  static UserProfile get defaultProfile => UserProfile(
    height: 175,
    weight: 75,
    age: 25,
    gender: 'Erkek',
    activityLevelMultiplier: 1.375,
    goal: 'Kas Kazanımı',
  );

  /// Protein multiplier according to fitness goal (g/kg)
  static double getProteinMultiplierForGoal(String goal) {
    switch (goal) {
      case 'Kilo Verme':
        return 1.5; // High protein to protect muscle mass during calorie deficit
      case 'Form Koruma':
        return 1.1; // Balanced healthy baseline for maintenance
      case 'Hafif Egzersiz':
        return 1.4; // Moderate for light activity / endurance
      case 'Kas Kazanımı':
      default:
        return 1.8; // High hypertrophy standard
    }
  }

  /// Calculates recommended daily protein intake based on weight and goal
  static double calculateProteinForGoal(double weight, String goal) {
    final multiplier = getProteinMultiplierForGoal(goal);
    return (weight * multiplier).roundToDouble();
  }

  /// Harris-Benedict BMR calculation
  static double calculateBMR(double w, double h, int age, String gender) {
    if (gender.toLowerCase() == 'kadın' || gender.toLowerCase() == 'female') {
      return 447.593 + (9.247 * w) + (3.098 * h) - (4.330 * age);
    }
    return 88.362 + (13.397 * w) + (4.799 * h) - (5.677 * age);
  }

  /// Harris-Benedict TDEE & Goal-adjusted Calories
  static double calculateCaloriesForGoal(double w, double h, int age, String gender, double multiplier, String goal) {
    final bmr = calculateBMR(w, h, age, gender);
    final tdee = bmr * multiplier;

    switch (goal) {
      case 'Kilo Verme':
        return (tdee - 400).clamp(1200, 5000).roundToDouble();
      case 'Kas Kazanımı':
        return (tdee + 300).roundToDouble();
      case 'Form Koruma':
      case 'Hafif Egzersiz':
      default:
        return tdee.roundToDouble();
    }
  }

  /// Legacy helper for default calories
  static double calculateDefaultCalories(double w, double h, int age, String gender, double multiplier) {
    return calculateCaloriesForGoal(w, h, age, gender, multiplier, 'Kas Kazanımı');
  }

  Map<String, dynamic> toMap() {
    return {
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
      'activityLevelMultiplier': activityLevelMultiplier,
      'goal': goal,
      'dailyProteinGoal': dailyProteinGoal,
      'dailyCalorieGoal': dailyCalorieGoal,
      'dailyWaterGoal': dailyWaterGoal,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final weight = (map['weight'] as num).toDouble();
    final height = (map['height'] as num).toDouble();
    final age = map['age'] as int;
    final gender = map['gender'] as String;
    final activityMultiplier = (map['activityLevelMultiplier'] as num).toDouble();
    final goal = (map['goal'] as String?) ?? 'Kas Kazanımı';

    return UserProfile(
      height: height,
      weight: weight,
      age: age,
      gender: gender,
      activityLevelMultiplier: activityMultiplier,
      goal: goal,
      dailyProteinGoal: (map['dailyProteinGoal'] as num?)?.toDouble() ?? calculateProteinForGoal(weight, goal),
      dailyCalorieGoal: (map['dailyCalorieGoal'] as num?)?.toDouble() ?? calculateCaloriesForGoal(weight, height, age, gender, activityMultiplier, goal),
      dailyWaterGoal: (map['dailyWaterGoal'] as num?)?.toDouble() ?? (weight * 35),
    );
  }

  String toJson() => json.encode(toMap());
  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}
