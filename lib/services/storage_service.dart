import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _seedExercisesIfNeeded();
    await _seedDefaultRemindersIfNeeded();
    await _seedDefaultMealTemplatesIfNeeded();
    await _seedDefaultMeasurementsIfNeeded();
    await _seedMockDataIfNeeded();
  }

  static final List<Exercise> defaultExercises = [
    // Göğüs
    Exercise(id: 'bench_press', name: 'Bench Press', muscleGroup: 'Göğüs', imagePath: 'assets/images/exercises/bench_press.png'),
    Exercise(id: 'incline_press', name: 'Incline Bench Press', muscleGroup: 'Göğüs', imagePath: 'assets/images/exercises/bench_press.png'),
    Exercise(id: 'decline_press', name: 'Decline Bench Press', muscleGroup: 'Göğüs', imagePath: 'assets/images/exercises/bench_press.png'),
    Exercise(id: 'db_fly', name: 'Dumbbell Fly', muscleGroup: 'Göğüs', imagePath: 'assets/images/exercises/dumbbell_fly.png'),
    Exercise(id: 'pushups', name: 'Şınav (Push-ups)', muscleGroup: 'Göğüs', imagePath: 'assets/images/exercises/pushups.png'),
    Exercise(id: 'cable_crossover', name: 'Cable Crossover', muscleGroup: 'Göğüs', imagePath: 'assets/images/exercises/dumbbell_fly.png'),
    Exercise(id: 'db_press', name: 'Dumbbell Bench Press', muscleGroup: 'Göğüs', imagePath: 'assets/images/exercises/bench_press.png'),
    Exercise(id: 'incline_db_press', name: 'Incline Dumbbell Press', muscleGroup: 'Göğüs', imagePath: 'assets/images/exercises/bench_press.png'),
    Exercise(id: 'pec_deck', name: 'Pec Deck (Göğüs Sıkıştırma)', muscleGroup: 'Göğüs', imagePath: 'assets/images/exercises/dumbbell_fly.png'),
    Exercise(id: 'chest_dips', name: 'Dips (Göğüs Odaklı)', muscleGroup: 'Göğüs', imagePath: 'assets/images/exercises/pushups.png'),
    
    // Bacak
    Exercise(id: 'squats', name: 'Squat', muscleGroup: 'Bacak', imagePath: 'assets/images/exercises/squats.png'),
    Exercise(id: 'leg_press', name: 'Leg Press', muscleGroup: 'Bacak', imagePath: 'assets/images/exercises/squats.png'),
    Exercise(id: 'leg_extension', name: 'Leg Extension', muscleGroup: 'Bacak', imagePath: 'assets/images/exercises/leg_extension.png'),
    Exercise(id: 'leg_curl', name: 'Leg Curl', muscleGroup: 'Bacak', imagePath: 'assets/images/exercises/leg_extension.png'),
    Exercise(id: 'lunge', name: 'Lunge (Adımlama)', muscleGroup: 'Bacak', imagePath: 'assets/images/exercises/squats.png'),
    Exercise(id: 'calf_raise', name: 'Calf Raise', muscleGroup: 'Bacak', imagePath: 'assets/images/exercises/squats.png'),
    Exercise(id: 'rdl', name: 'Romanian Deadlift (RDL)', muscleGroup: 'Bacak', imagePath: 'assets/images/exercises/deadlift.png'),
    Exercise(id: 'bulgarian_split', name: 'Bulgarian Split Squat', muscleGroup: 'Bacak', imagePath: 'assets/images/exercises/squats.png'),
    Exercise(id: 'hip_thrust', name: 'Hip Thrust', muscleGroup: 'Bacak', imagePath: 'assets/images/exercises/deadlift.png'),
    Exercise(id: 'goblet_squat', name: 'Goblet Squat', muscleGroup: 'Bacak', imagePath: 'assets/images/exercises/squats.png'),
    
    // Sırt
    Exercise(id: 'deadlift', name: 'Deadlift', muscleGroup: 'Sırt', imagePath: 'assets/images/exercises/deadlift.png'),
    Exercise(id: 'lat_pulldown', name: 'Lat Pulldown', muscleGroup: 'Sırt', imagePath: 'assets/images/exercises/pullups.png'),
    Exercise(id: 'pullups', name: 'Barfiks (Pull-ups)', muscleGroup: 'Sırt', imagePath: 'assets/images/exercises/pullups.png'),
    Exercise(id: 'db_row', name: 'Dumbbell Row', muscleGroup: 'Sırt', imagePath: 'assets/images/exercises/deadlift.png'),
    Exercise(id: 'bb_row', name: 'Barbell Row', muscleGroup: 'Sırt', imagePath: 'assets/images/exercises/deadlift.png'),
    Exercise(id: 'cable_row', name: 'Cable Row', muscleGroup: 'Sırt', imagePath: 'assets/images/exercises/deadlift.png'),
    Exercise(id: 'tbar_row', name: 'T-Bar Row', muscleGroup: 'Sırt', imagePath: 'assets/images/exercises/deadlift.png'),
    Exercise(id: 'hyperextension', name: 'Hyperextension (Ters Mekik)', muscleGroup: 'Sırt', imagePath: 'assets/images/exercises/deadlift.png'),
    Exercise(id: 'single_lat_pulldown', name: 'Single Arm Lat Pulldown', muscleGroup: 'Sırt', imagePath: 'assets/images/exercises/pullups.png'),
    
    // Biceps
    Exercise(id: 'bicep_curl', name: 'Bicep Curl', muscleGroup: 'Biceps', imagePath: 'assets/images/exercises/bicep_curl.png'),
    Exercise(id: 'hammer_curl', name: 'Hammer Curl', muscleGroup: 'Biceps', imagePath: 'assets/images/exercises/hammer_curl.png'),
    Exercise(id: 'preacher_curl', name: 'Preacher Curl', muscleGroup: 'Biceps', imagePath: 'assets/images/exercises/bicep_curl.png'),
    Exercise(id: 'conc_curl', name: 'Concentration Curl', muscleGroup: 'Biceps', imagePath: 'assets/images/exercises/bicep_curl.png'),
    Exercise(id: 'incline_db_curl', name: 'Incline Dumbbell Curl', muscleGroup: 'Biceps', imagePath: 'assets/images/exercises/bicep_curl.png'),
    Exercise(id: 'cable_bicep_curl', name: 'Cable Bicep Curl', muscleGroup: 'Biceps', imagePath: 'assets/images/exercises/bicep_curl.png'),
    Exercise(id: 'chinups', name: 'Chin-ups (Ters Tutuş Barfiks)', muscleGroup: 'Biceps', imagePath: 'assets/images/exercises/pullups.png'),
    
    // Triceps
    Exercise(id: 'tricep_pushdown', name: 'Tricep Pushdown', muscleGroup: 'Triceps', imagePath: 'assets/images/exercises/tricep_pushdown.png'),
    Exercise(id: 'overhead_tricep', name: 'Overhead Tricep Extension', muscleGroup: 'Triceps', imagePath: 'assets/images/exercises/triceps.png'),
    Exercise(id: 'skull_crusher', name: 'Skull Crusher', muscleGroup: 'Triceps', imagePath: 'assets/images/exercises/triceps.png'),
    Exercise(id: 'dips', name: 'Dips (Triceps Odaklı)', muscleGroup: 'Triceps', imagePath: 'assets/images/exercises/tricep_pushdown.png'),
    Exercise(id: 'close_grip_bench', name: 'Dar Tutuş Bench Press', muscleGroup: 'Triceps', imagePath: 'assets/images/exercises/bench_press.png'),
    Exercise(id: 'tricep_kickback', name: 'Dumbbell Kickback', muscleGroup: 'Triceps', imagePath: 'assets/images/exercises/triceps.png'),
    
    // Omuz
    Exercise(id: 'shoulder_press', name: 'Shoulder Press', muscleGroup: 'Omuz', imagePath: 'assets/images/exercises/shoulder_press.png'),
    Exercise(id: 'lateral_raise', name: 'Lateral Raise', muscleGroup: 'Omuz', imagePath: 'assets/images/exercises/shoulders.png'),
    Exercise(id: 'front_raise', name: 'Front Raise', muscleGroup: 'Omuz', imagePath: 'assets/images/exercises/shoulders.png'),
    Exercise(id: 'face_pull', name: 'Face Pull', muscleGroup: 'Omuz', imagePath: 'assets/images/exercises/shoulders.png'),
    Exercise(id: 'military_press', name: 'Military Press', muscleGroup: 'Omuz', imagePath: 'assets/images/exercises/shoulder_press.png'),
    Exercise(id: 'arnold_press', name: 'Arnold Press', muscleGroup: 'Omuz', imagePath: 'assets/images/exercises/shoulder_press.png'),
    Exercise(id: 'shrugs', name: 'Shrugs (Trapez Kaldırma)', muscleGroup: 'Omuz', imagePath: 'assets/images/exercises/shoulders.png'),
    Exercise(id: 'rear_delt_fly', name: 'Rear Delt Fly (Arka Omuz)', muscleGroup: 'Omuz', imagePath: 'assets/images/exercises/shoulders.png'),
    
    // Bilek
    Exercise(id: 'wrist_curl', name: 'Wrist Curl', muscleGroup: 'Bilek', imagePath: 'assets/images/exercises/wrist.png'),
    Exercise(id: 'rev_wrist_curl', name: 'Reverse Wrist Curl', muscleGroup: 'Bilek', imagePath: 'assets/images/exercises/wrist.png'),
    Exercise(id: 'wrist_roller', name: 'Wrist Roller (Bilek Rulosu)', muscleGroup: 'Bilek', imagePath: 'assets/images/exercises/wrist.png'),
    Exercise(id: 'farmers_walk', name: 'Farmers Walk', muscleGroup: 'Bilek', imagePath: 'assets/images/exercises/wrist.png'),
  ];

  static Future<void> _seedExercisesIfNeeded() async {
    final String? exercisesJson = _prefs?.getString('exercises');
    final int seedVersion = _prefs?.getInt('exercises_seed_version') ?? 0;
    bool needsSeeding = exercisesJson == null || seedVersion < 2;
    if (exercisesJson != null && !needsSeeding) {
      try {
        final List decoded = json.decode(exercisesJson);
        if (decoded.length < 48) {
          needsSeeding = true;
        }
      } catch (_) {
        needsSeeding = true;
      }
    }
    if (needsSeeding) {
      final List<Map<String, dynamic>> exercisesMap = defaultExercises.map((e) => e.toMap()).toList();
      await _prefs?.setString('exercises', json.encode(exercisesMap));
      await _prefs?.setInt('exercises_seed_version', 2);
    }
  }

  static List<Exercise> getExercises() {
    final String? exercisesJson = _prefs?.getString('exercises');
    if (exercisesJson == null) return defaultExercises;
    final List decoded = json.decode(exercisesJson);
    return decoded.map((item) => Exercise.fromMap(item)).toList();
  }

  static Future<void> addCustomExercise(Exercise exercise) async {
    final List<Exercise> current = getExercises();
    current.add(exercise);
    final List<Map<String, dynamic>> maps = current.map((e) => e.toMap()).toList();
    await _prefs?.setString('exercises', json.encode(maps));
  }

  // --- User Profile ---
  static Future<void> saveProfile(UserProfile profile) async {
    await _prefs?.setString('profile', profile.toJson());
  }

  static UserProfile? getProfile() {
    final String? profileJson = _prefs?.getString('profile');
    if (profileJson == null) return null;
    try {
      return UserProfile.fromJson(profileJson);
    } catch (_) {
      return null;
    }
  }

  // --- Workouts ---
  static List<Workout> getWorkouts() {
    final String? workoutsJson = _prefs?.getString('workouts');
    if (workoutsJson == null) return [];
    try {
      final List decoded = json.decode(workoutsJson);
      return decoded.map((item) => Workout.fromMap(item)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveWorkouts(List<Workout> workouts) async {
    final List<Map<String, dynamic>> workoutsMap = workouts.map((w) => w.toMap()).toList();
    await _prefs?.setString('workouts', json.encode(workoutsMap));
  }

  static Future<void> addWorkout(Workout workout) async {
    final workouts = getWorkouts();
    // Remove existing workout on the same day if any
    workouts.removeWhere((w) => 
      w.date.year == workout.date.year && 
      w.date.month == workout.date.month && 
      w.date.day == workout.date.day
    );
    workouts.add(workout);
    await saveWorkouts(workouts);
  }

  // --- Meals ---
  static List<Meal> getMeals() {
    final String? mealsJson = _prefs?.getString('meals');
    if (mealsJson == null) return [];
    try {
      final List decoded = json.decode(mealsJson);
      return decoded.map((item) => Meal.fromMap(item)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveMeals(List<Meal> meals) async {
    final List<Map<String, dynamic>> mealsMap = meals.map((m) => m.toMap()).toList();
    await _prefs?.setString('meals', json.encode(mealsMap));
  }

  static Future<void> addMeal(Meal meal) async {
    final meals = getMeals();
    meals.add(meal);
    await saveMeals(meals);
  }

  static Future<void> deleteMeal(String mealId) async {
    final meals = getMeals();
    meals.removeWhere((m) => m.id == mealId);
    await saveMeals(meals);
  }

  // --- Reminders ---
  static Future<void> _seedDefaultRemindersIfNeeded() async {
    final String? remindersJson = _prefs?.getString('reminders');
    if (remindersJson == null) {
      final List<NutritionReminder> defaults = [
        NutritionReminder(id: 'rem_1', hour: 14, minute: 0),
        NutritionReminder(id: 'rem_2', hour: 20, minute: 0),
      ];
      await saveReminders(defaults);
    }
  }

  static List<NutritionReminder> getReminders() {
    final String? remindersJson = _prefs?.getString('reminders');
    if (remindersJson == null) return [];
    try {
      final List decoded = json.decode(remindersJson);
      return decoded.map((item) => NutritionReminder.fromMap(item)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveReminders(List<NutritionReminder> reminders) async {
    final List<Map<String, dynamic>> remindersMap = reminders.map((r) => r.toMap()).toList();
    await _prefs?.setString('reminders', json.encode(remindersMap));
  }

  // --- Water Tracking ---
  static List<WaterLog> getWaterLogs() {
    final String? jsonStr = _prefs?.getString('water_logs');
    if (jsonStr == null) return [];
    try {
      final List decoded = json.decode(jsonStr);
      return decoded.map((item) => WaterLog.fromMap(item)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveWaterLogs(List<WaterLog> logs) async {
    final List<Map<String, dynamic>> maps = logs.map((w) => w.toMap()).toList();
    await _prefs?.setString('water_logs', json.encode(maps));
  }

  static int getTodayWater([DateTime? targetDay]) {
    final day = targetDay ?? DateTime.now();
    final logs = getWaterLogs();
    for (final log in logs) {
      if (log.date.year == day.year && log.date.month == day.month && log.date.day == day.day) {
        return log.amountMl;
      }
    }
    return 0;
  }

  static Future<int> addWater(int deltaMl, [DateTime? targetDay]) async {
    final day = targetDay ?? DateTime.now();
    final logs = getWaterLogs();
    int currentAmount = 0;
    int existingIndex = -1;

    for (int i = 0; i < logs.length; i++) {
      if (logs[i].date.year == day.year && logs[i].date.month == day.month && logs[i].date.day == day.day) {
        currentAmount = logs[i].amountMl;
        existingIndex = i;
        break;
      }
    }

    final newAmount = (currentAmount + deltaMl).clamp(0, 10000);
    final updatedLog = WaterLog(
      date: DateTime(day.year, day.month, day.day),
      amountMl: newAmount,
    );

    if (existingIndex >= 0) {
      logs[existingIndex] = updatedLog;
    } else {
      logs.add(updatedLog);
    }

    await saveWaterLogs(logs);
    return newAmount;
  }

  // --- Meal Templates ---
  static final List<MealTemplate> defaultMealTemplates = [
    MealTemplate(
      id: 'tmpl_1',
      title: 'Klasik Sporcu Kahvaltısı',
      description: '3 Yumurta, 80g Yulaf, 1 Muz, 1 Bardak Süt',
      calories: 580,
      protein: 34,
    ),
    MealTemplate(
      id: 'tmpl_2',
      title: 'Tavuk & Pirinç Pilavı',
      description: '200g Izgara Tavuk Göğsü, 150g Pirinç Pilavı, Yeşillik',
      calories: 620,
      protein: 52,
    ),
    MealTemplate(
      id: 'tmpl_3',
      title: 'Antrenman Sonrası Shake',
      description: '1 Ölçek Whey Protein, 1 Muz, 30g Fıstık Ezmesi, 300ml Süt',
      calories: 460,
      protein: 38,
    ),
  ];

  static Future<void> _seedDefaultMealTemplatesIfNeeded() async {
    final String? str = _prefs?.getString('meal_templates');
    if (str == null) {
      await saveMealTemplates(defaultMealTemplates);
    }
  }

  static List<MealTemplate> getMealTemplates() {
    final String? str = _prefs?.getString('meal_templates');
    if (str == null) return defaultMealTemplates;
    try {
      final List decoded = json.decode(str);
      return decoded.map((item) => MealTemplate.fromMap(item)).toList();
    } catch (_) {
      return defaultMealTemplates;
    }
  }

  static Future<void> saveMealTemplates(List<MealTemplate> templates) async {
    final maps = templates.map((t) => t.toMap()).toList();
    await _prefs?.setString('meal_templates', json.encode(maps));
  }

  static Future<void> addMealTemplate(MealTemplate template) async {
    final list = getMealTemplates();
    list.add(template);
    await saveMealTemplates(list);
  }

  static Future<void> deleteMealTemplate(String id) async {
    final list = getMealTemplates();
    list.removeWhere((t) => t.id == id);
    await saveMealTemplates(list);
  }

  // --- Body Measurements ---
  static Future<void> _seedDefaultMeasurementsIfNeeded() async {
    final String? str = _prefs?.getString('body_measurements');
    if (str == null) {
      final now = DateTime.now();
      final defaults = [
        BodyMeasurement(
          date: now.subtract(const Duration(days: 28)),
          weight: 82.5,
          chest: 102.0,
          waist: 86.0,
          arm: 37.0,
          shoulder: 118.0,
          leg: 58.0,
          hip: 99.0,
        ),
        BodyMeasurement(
          date: now.subtract(const Duration(days: 14)),
          weight: 81.2,
          chest: 103.0,
          waist: 84.5,
          arm: 37.5,
          shoulder: 119.0,
          leg: 58.5,
          hip: 98.0,
        ),
        BodyMeasurement(
          date: now.subtract(const Duration(days: 2)),
          weight: 80.0,
          chest: 104.0,
          waist: 83.0,
          arm: 38.0,
          shoulder: 120.0,
          leg: 59.0,
          hip: 97.5,
        ),
      ];
      await saveBodyMeasurements(defaults);
    }
  }

  static List<BodyMeasurement> getBodyMeasurements() {
    final String? str = _prefs?.getString('body_measurements');
    if (str == null) return [];
    try {
      final List decoded = json.decode(str);
      final list = decoded.map((item) => BodyMeasurement.fromMap(item)).toList();
      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveBodyMeasurements(List<BodyMeasurement> list) async {
    final maps = list.map((m) => m.toMap()).toList();
    await _prefs?.setString('body_measurements', json.encode(maps));
  }

  static Future<void> addBodyMeasurement(BodyMeasurement measurement) async {
    final list = getBodyMeasurements();
    // Remove if exists on same day
    list.removeWhere((m) => 
      m.date.year == measurement.date.year &&
      m.date.month == measurement.date.month &&
      m.date.day == measurement.date.day
    );
    list.add(measurement);
    await saveBodyMeasurements(list);
  }

  // --- Progress Photos ---
  static List<ProgressPhoto> getProgressPhotos() {
    final String? str = _prefs?.getString('progress_photos');
    if (str == null) return [];
    try {
      final List decoded = json.decode(str);
      return decoded.map((item) => ProgressPhoto.fromMap(item)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveProgressPhotos(List<ProgressPhoto> list) async {
    final maps = list.map((p) => p.toMap()).toList();
    await _prefs?.setString('progress_photos', json.encode(maps));
  }

  static Future<void> addProgressPhoto(ProgressPhoto photo) async {
    final list = getProgressPhotos();
    list.add(photo);
    await saveProgressPhotos(list);
  }

  static Future<void> deleteProgressPhoto(String id) async {
    final list = getProgressPhotos();
    list.removeWhere((p) => p.id == id);
    await saveProgressPhotos(list);
  }

  // --- Personal Records (PR) Calculation ---
  static List<PersonalRecord> calculatePersonalRecords() {
    final workouts = getWorkouts();
    final exercises = getExercises();
    final exerciseMap = {for (var e in exercises) e.id: e.name};

    final Map<String, PersonalRecord> bestRecords = {};

    for (final workout in workouts) {
      for (final session in workout.sessions) {
        for (final set in session.sets) {
          if (set.isCompleted && set.weight > 0) {
            final exId = session.exerciseId;
            final currentBest = bestRecords[exId];
            if (currentBest == null || set.weight > currentBest.maxWeight) {
              bestRecords[exId] = PersonalRecord(
                exerciseId: exId,
                exerciseName: exerciseMap[exId] ?? exId,
                maxWeight: set.weight,
                reps: set.reps,
                date: workout.date,
              );
            }
          }
        }
      }
    }

    final prList = bestRecords.values.toList();
    prList.sort((a, b) => b.maxWeight.compareTo(a.maxWeight));
    return prList;
  }

  // --- Dark Mode State ---
  static bool isDarkMode() {
    return _prefs?.getBool('is_dark_mode') ?? false;
  }

  static Future<void> setDarkMode(bool isDark) async {
    await _prefs?.setBool('is_dark_mode', isDark);
  }

  // --- Seed Mock Data for Analytics & Walkthrough ---
  static Future<void> _seedMockDataIfNeeded() async {
    final isFirstRun = _prefs?.getBool('first_run_seeded') ?? false;
    if (!isFirstRun) {
      // Seed default user profile
      final mockProfile = UserProfile(
        height: 180,
        weight: 80,
        age: 26,
        gender: 'Erkek',
        activityLevelMultiplier: 1.375, // Light activity
        dailyWaterGoal: 2800,
      );
      await saveProfile(mockProfile);

      // Seed workouts history for analytics graph
      final today = DateTime.now();
      final List<Workout> mockWorkouts = [];

      for (int i = 6; i >= 0; i--) {
        final workoutDate = today.subtract(Duration(days: i));
        
        // Seed workouts on odd days
        if (i % 2 == 1) {
          mockWorkouts.add(
            Workout(
              date: workoutDate,
              sessions: [
                ExerciseSession(
                  exerciseId: 'bench_press',
                  sets: [
                    ExerciseSet(weight: 50.0 + (6 - i) * 2, reps: 10, isCompleted: true),
                    ExerciseSet(weight: 55.0 + (6 - i) * 2, reps: 8, isCompleted: true),
                    ExerciseSet(weight: 60.0 + (6 - i) * 2, reps: 6, isCompleted: true),
                  ],
                ),
                ExerciseSession(
                  exerciseId: 'squats',
                  sets: [
                    ExerciseSet(weight: 60.0 + (6 - i) * 5, reps: 12, isCompleted: true),
                    ExerciseSet(weight: 70.0 + (6 - i) * 5, reps: 10, isCompleted: true),
                    ExerciseSet(weight: 80.0 + (6 - i) * 5, reps: 8, isCompleted: true),
                  ],
                ),
              ],
            ),
          );
        }
      }
      await saveWorkouts(mockWorkouts);

      // Seed meals history for today
      final List<Meal> mockMeals = [
        Meal(
          id: 'meal_1',
          name: 'Kahvaltı: Yumurta ve Yulaf',
          calories: 450,
          protein: 28,
          timestamp: today.subtract(const Duration(hours: 6)),
        ),
        Meal(
          id: 'meal_2',
          name: 'Öğle: Izgara Tavuk ve Pilav',
          calories: 650,
          protein: 45,
          timestamp: today.subtract(const Duration(hours: 3)),
        ),
      ];
      await saveMeals(mockMeals);

      // Seed water logs
      final List<WaterLog> mockWater = [];
      for (int i = 6; i >= 0; i--) {
        mockWater.add(
          WaterLog(
            date: today.subtract(Duration(days: i)),
            amountMl: (2000 + (i % 3) * 350),
          ),
        );
      }
      await saveWaterLogs(mockWater);

      await _prefs?.setBool('first_run_seeded', true);
    }
  }

  // --- Backup & Restore ---
  static String getBackupJson() {
    final Map<String, dynamic> data = {};
    final String? profile = _prefs?.getString('profile');
    final String? exercises = _prefs?.getString('exercises');
    final String? workouts = _prefs?.getString('workouts');
    final String? meals = _prefs?.getString('meals');
    final String? reminders = _prefs?.getString('reminders');
    final String? waterLogs = _prefs?.getString('water_logs');
    final String? mealTemplates = _prefs?.getString('meal_templates');
    final String? bodyMeasurements = _prefs?.getString('body_measurements');
    final String? progressPhotos = _prefs?.getString('progress_photos');
    final bool? isDark = _prefs?.getBool('is_dark_mode');
    final bool? firstRunSeeded = _prefs?.getBool('first_run_seeded');
    final int? exercisesSeedVersion = _prefs?.getInt('exercises_seed_version');

    if (profile != null) data['profile'] = profile;
    if (exercises != null) data['exercises'] = exercises;
    if (workouts != null) data['workouts'] = workouts;
    if (meals != null) data['meals'] = meals;
    if (reminders != null) data['reminders'] = reminders;
    if (waterLogs != null) data['water_logs'] = waterLogs;
    if (mealTemplates != null) data['meal_templates'] = mealTemplates;
    if (bodyMeasurements != null) data['body_measurements'] = bodyMeasurements;
    if (progressPhotos != null) data['progress_photos'] = progressPhotos;
    if (isDark != null) data['is_dark_mode'] = isDark;
    if (firstRunSeeded != null) data['first_run_seeded'] = firstRunSeeded;
    if (exercisesSeedVersion != null) data['exercises_seed_version'] = exercisesSeedVersion;

    return json.encode(data);
  }

  static Future<bool> restoreBackupJson(String jsonString) async {
    try {
      final Map<String, dynamic> data = json.decode(jsonString);
      
      // Basic integrity check
      if (!data.containsKey('profile') && !data.containsKey('workouts')) {
        return false;
      }

      if (data.containsKey('profile')) {
        await _prefs?.setString('profile', data['profile']);
      }
      if (data.containsKey('exercises')) {
        await _prefs?.setString('exercises', data['exercises']);
      }
      if (data.containsKey('workouts')) {
        await _prefs?.setString('workouts', data['workouts']);
      }
      if (data.containsKey('meals')) {
        await _prefs?.setString('meals', data['meals']);
      }
      if (data.containsKey('reminders')) {
        await _prefs?.setString('reminders', data['reminders']);
      }
      if (data.containsKey('water_logs')) {
        await _prefs?.setString('water_logs', data['water_logs']);
      }
      if (data.containsKey('meal_templates')) {
        await _prefs?.setString('meal_templates', data['meal_templates']);
      }
      if (data.containsKey('body_measurements')) {
        await _prefs?.setString('body_measurements', data['body_measurements']);
      }
      if (data.containsKey('progress_photos')) {
        await _prefs?.setString('progress_photos', data['progress_photos']);
      }
      if (data.containsKey('is_dark_mode')) {
        await _prefs?.setBool('is_dark_mode', data['is_dark_mode']);
      }
      if (data.containsKey('first_run_seeded')) {
        await _prefs?.setBool('first_run_seeded', data['first_run_seeded']);
      }
      if (data.containsKey('exercises_seed_version')) {
        await _prefs?.setInt('exercises_seed_version', data['exercises_seed_version']);
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
