import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/utils/workout_calorie_calculator.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'widgets/progress_ring.dart';

class DashboardView extends StatelessWidget {
  final UserProfile profile;
  final List<Meal> todayMeals;
  final List<Workout> workouts;
  final int todayWaterMl;
  final ValueChanged<int> onAddWater;
  final VoidCallback onNavigateToMeals;
  final VoidCallback onNavigateToWorkouts;

  const DashboardView({
    super.key,
    required this.profile,
    required this.todayMeals,
    required this.workouts,
    required this.todayWaterMl,
    required this.onAddWater,
    required this.onNavigateToMeals,
    required this.onNavigateToWorkouts,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculations
    final double totalCalories = todayMeals.fold(0, (sum, item) => sum + item.calories);
    final double totalProtein = todayMeals.fold(0, (sum, item) => sum + item.protein);

    final double calorieProgress = profile.dailyCalorieGoal > 0 ? totalCalories / profile.dailyCalorieGoal : 0;
    final double proteinProgress = profile.dailyProteinGoal > 0 ? totalProtein / profile.dailyProteinGoal : 0;
    final double waterGoal = profile.dailyWaterGoal > 0 ? profile.dailyWaterGoal : 2500;
    final double waterProgress = (todayWaterMl / waterGoal).clamp(0.0, 1.0);

    final double remainingProtein = profile.dailyProteinGoal - totalProtein;

    // Check smart notifications
    final activeNotifications = _getSmartNotifications(totalProtein);

    // Get today's workout
    final today = DateTime.now();
    final todayWorkout = workouts.firstWhere(
      (w) => w.date.year == today.year && w.date.month == today.month && w.date.day == today.day,
      orElse: () => Workout(date: today, sessions: []),
    );
    final todayWorkoutSummary = WorkoutCalorieCalculator.calculateWorkoutSummary(
      workout: todayWorkout,
      exerciseLibrary: StorageService.getExercises(),
      userWeightKg: profile.weight,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Merhaba, Şampiyon! 👋',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkText : AppTheme.textDark,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkPrimary.withValues(alpha: 0.2) : AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.spa_outlined,
                  color: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Smart Notifications Banner (If any)
          if (activeNotifications.isNotEmpty) ...[
            ...activeNotifications.map((notif) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkAccent.withValues(alpha: 0.15) : AppTheme.accentLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: (isDark ? AppTheme.darkAccent : AppTheme.accent).withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppTheme.darkAccent : AppTheme.accent).withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: isDark ? AppTheme.darkAccent : AppTheme.accent,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Akıllı Beslenme Uyarısı 🚨',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkText : AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            notif,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],

          // Workout Card
          GestureDetector(
            onTap: onNavigateToWorkouts,
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkPrimary.withValues(alpha: 0.12)
                    : AppTheme.primaryLight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: (isDark ? AppTheme.darkPrimary : AppTheme.primary).withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.fitness_center, color: isDark ? Colors.black : Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bugünkü Antrenman',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkText : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          todayWorkout.sessions.isEmpty
                              ? 'Bugün henüz antrenman kaydetmedin.'
                              : '${todayWorkout.sessions.length} hareket (${todayWorkoutSummary.completedSets} set) • 🔥 ${todayWorkoutSummary.caloriesInt} kcal',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Nutrition Card
          GestureDetector(
            onTap: onNavigateToMeals,
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.secondary.withValues(alpha: 0.12)
                    : AppTheme.secondaryLight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: (isDark ? AppTheme.secondary : AppTheme.secondary).withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.restaurant, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Beslenme Günlüğü',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkText : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          todayMeals.isEmpty
                              ? 'Bugün henüz yemek girmedin.'
                              : 'Bugün ${todayMeals.length} adet öğün kaydettin.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? AppTheme.secondary : AppTheme.secondaryDark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 💧 Su Takibi (Water Tracker Card)
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B4D8).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.water_drop, color: Color(0xFF00B4D8), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Su Takibi',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkText : AppTheme.textDark,
                              ),
                            ),
                            Text(
                              'Hedef: ${waterGoal.toInt()} ml',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      '$todayWaterMl ml',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00B4D8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: waterProgress,
                    minHeight: 12,
                    backgroundColor: const Color(0xFF00B4D8).withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00B4D8)),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onAddWater(250),
                        icon: const Icon(Icons.local_drink_outlined, size: 18),
                        label: const Text('+250 ml'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00B4D8),
                          side: BorderSide(color: const Color(0xFF00B4D8).withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => onAddWater(500),
                        icon: const Icon(Icons.water_drop, size: 18, color: Colors.white),
                        label: const Text('+500 ml', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B4D8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: todayWaterMl > 0 ? () => onAddWater(-250) : null,
                      icon: const Icon(Icons.remove_circle_outline, color: AppTheme.accent),
                      tooltip: '-250 ml',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Daily Target Rings Section
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bugünkü Hedefler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkText : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Calorie Ring
                    Column(
                      children: [
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: ProgressRing(
                            progress: calorieProgress,
                            progressColor: AppTheme.secondary,
                            backgroundColor: isDark
                                ? AppTheme.secondary.withValues(alpha: 0.15)
                                : AppTheme.secondaryLight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  totalCalories.toInt().toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.darkText : AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  'kcal',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enerji',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkText : AppTheme.textDark,
                          ),
                        ),
                        Text(
                          '/ ${profile.dailyCalorieGoal.toInt()} kcal',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),

                    // Protein Ring
                    Column(
                      children: [
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: ProgressRing(
                            progress: proteinProgress,
                            progressColor: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                            backgroundColor: isDark
                                ? AppTheme.darkPrimary.withValues(alpha: 0.15)
                                : AppTheme.primaryLight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  totalProtein.toInt().toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.darkText : AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  'g Protein',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Protein',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkText : AppTheme.textDark,
                          ),
                        ),
                        Text(
                          '/ ${profile.dailyProteinGoal.toInt()} g',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(
                  height: 32,
                  color: isDark ? AppTheme.darkBorder : AppTheme.border,
                ),
                
                // Workout Calorie Burn Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Antrenmanda Yakılan:',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                      ),
                    ),
                    Text(
                      '🔥 ${todayWorkoutSummary.caloriesInt} kcal (${todayWorkoutSummary.completedSets} set)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF9F1C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Remaining Protein Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hedefe Kalan Protein:',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                      ),
                    ),
                    Text(
                      remainingProtein > 0 
                          ? '${remainingProtein.toInt()} g daha almalısın'
                          : 'Tebrikler, hedefe ulaştın! 🎉',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: remainingProtein > 0 
                            ? (isDark ? AppTheme.darkPrimary : AppTheme.primaryDark)
                            : (isDark ? AppTheme.secondary : AppTheme.secondaryDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Akıllı Bildirim Kontrolü
  List<String> _getSmartNotifications(double currentProtein) {
    final List<String> messages = [];
    final now = DateTime.now();
    final currentHour = now.hour;

    // Get active reminders
    final reminders = StorageService.getReminders().where((r) => r.isEnabled).toList();

    for (var reminder in reminders) {
      if (currentHour >= reminder.hour) {
        double expectedRatio = 0.5;
        if (reminder.hour >= 18) {
          expectedRatio = 0.8;
        }

        final double threshold = profile.dailyProteinGoal * expectedRatio;
        if (currentProtein < threshold) {
          final timeStr = '${reminder.hour.toString().padLeft(2, '0')}:${reminder.minute.toString().padLeft(2, '0')}';
          messages.add(
            'Saat $timeStr hatırlatıcısı: Şu ana kadar aldığın protein miktarı (${currentProtein.toInt()} g), hedeflenen minimum eşiğin (${threshold.toInt()} g) altında kaldı! Lütfen protein desteği almayı ihmal etme.',
          );
        }
      }
    }

    return messages;
  }
}
