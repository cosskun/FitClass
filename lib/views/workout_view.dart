import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/utils/workout_calorie_calculator.dart';
import '../models/models.dart';
import '../services/sound_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'widgets/widgets.dart';

class WorkoutView extends StatefulWidget {
  final List<Workout> workouts;
  final Function(Workout) onWorkoutUpdated;

  const WorkoutView({
    super.key,
    required this.workouts,
    required this.onWorkoutUpdated,
  });

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  DateTime _selectedDate = DateTime.now();
  late List<Exercise> _exerciseLibrary;

  // Rest Timer State
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  int _totalRestDuration = 60;
  bool _isRestTimerActive = false;

  @override
  void initState() {
    super.initState();
    _exerciseLibrary = StorageService.getExercises();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  // --- Rest Timer Methods ---
  void _startRestTimer(int durationSeconds) {
    _restTimer?.cancel();
    setState(() {
      _totalRestDuration = durationSeconds;
      _restSecondsRemaining = durationSeconds;
      _isRestTimerActive = true;
    });

    HapticFeedback.lightImpact();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining > 1) {
        setState(() {
          _restSecondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _restSecondsRemaining = 0;
          _isRestTimerActive = false;
        });
        _onRestTimerFinished();
      }
    });
  }

  void _pauseOrResumeTimer() {
    if (_restTimer?.isActive == true) {
      _restTimer?.cancel();
      setState(() {});
    } else if (_restSecondsRemaining > 0) {
      _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_restSecondsRemaining > 1) {
          setState(() {
            _restSecondsRemaining--;
          });
        } else {
          timer.cancel();
          setState(() {
            _restSecondsRemaining = 0;
            _isRestTimerActive = false;
          });
          _onRestTimerFinished();
        }
      });
      setState(() {});
    }
  }

  void _cancelRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _restSecondsRemaining = 0;
      _isRestTimerActive = false;
    });
  }

  void _onRestTimerFinished() {
    // Play timer sound + haptics
    SoundService().playTimerComplete();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.alarm_on, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '⏱️ Dinlenme süresi bitti! Sıradaki sete hazırsın! 💪',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF70E000),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Workout _getWorkoutForDate(DateTime date) {
    return widget.workouts.firstWhere(
      (w) => w.date.year == date.year && w.date.month == date.month && w.date.day == date.day,
      orElse: () => Workout(date: DateTime(date.year, date.month, date.day), sessions: []),
    );
  }

  void _updateWorkout(Workout workout) {
    widget.onWorkoutUpdated(workout);
    setState(() {});
  }

  // Check and trigger PR celebration
  void _checkForPR(String exerciseId, double currentWeight, int reps) {
    if (currentWeight <= 0) return;

    final allWorkouts = StorageService.getWorkouts();
    double previousMax = 0.0;

    for (final w in allWorkouts) {
      // Don't compare with current set if same workout
      for (final s in w.sessions) {
        if (s.exerciseId == exerciseId) {
          for (final set in s.sets) {
            if (set.weight > previousMax && set.weight != currentWeight) {
              previousMax = set.weight;
            }
          }
        }
      }
    }

    if (currentWeight > previousMax && previousMax > 0) {
      HapticFeedback.heavyImpact();
      final exercise = _exerciseLibrary.firstWhere(
        (e) => e.id == exerciseId,
        orElse: () => Exercise(id: exerciseId, name: 'Egzersiz', muscleGroup: '', imagePath: ''),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'YENİ KİŞİSEL REKOR (PR)! 🎉',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      '${exercise.name}: $currentWeight kg ($reps tekrar)',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFF70A6),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  // --- Plate Calculator Modal ---
  void _showPlateCalculatorDialog() {
    PlateCalculatorDialog.show(context);
  }

  void _showAddExerciseDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String? selectedCategory;
    bool creatingCustom = false;
    final customNameController = TextEditingController();
    final categories = ['Göğüs', 'Bacak', 'Sırt', 'Biceps', 'Triceps', 'Omuz', 'Bilek'];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            if (creatingCustom && selectedCategory != null) {
              return Container(
                padding: const EdgeInsets.all(24),
                height: 550,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => setModalState(() => creatingCustom = false),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Özel Egzersiz Oluştur',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkText : AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Seçilen Kategori: $selectedCategory',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Egzersiz İsmi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: customNameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Örn: Zottman Curl, Incline Fly...',
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = customNameController.text.trim();
                          if (name.isEmpty) return;
                          
                          String img;
                          switch (selectedCategory) {
                            case 'Göğüs': img = 'assets/images/exercises/bench_press.png'; break;
                            case 'Bacak': img = 'assets/images/exercises/squats.png'; break;
                            case 'Sırt': img = 'assets/images/exercises/deadlift.png'; break;
                            case 'Biceps': img = 'assets/images/exercises/bicep_curl.png'; break;
                            case 'Triceps': img = 'assets/images/exercises/triceps.png'; break;
                            case 'Omuz': img = 'assets/images/exercises/shoulders.png'; break;
                            case 'Bilek': img = 'assets/images/exercises/wrist.png'; break;
                            default: img = 'assets/images/exercises/bench_press.png';
                          }

                          final newEx = Exercise(
                            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                            name: name,
                            muscleGroup: selectedCategory!,
                            imagePath: img,
                          );

                          final navigator = Navigator.of(context);
                          await StorageService.addCustomExercise(newEx);
                          
                          setState(() {
                            _exerciseLibrary = StorageService.getExercises();
                          });

                          navigator.pop();
                          _addExerciseToWorkout(newEx.id);
                        },
                        child: const Text('Oluştur ve Antrenmana Ekle'),
                      ),
                    ),
                  ],
                ),
              );
            } else if (selectedCategory == null) {
              return Container(
                padding: const EdgeInsets.all(24),
                height: 550,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kategori Seçin',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkText : AppTheme.textDark,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.05,
                        children: categories.map((cat) {
                          Color catBg;
                          IconData catIcon;
                          switch (cat) {
                            case 'Göğüs': catBg = isDark ? AppTheme.darkAccent.withValues(alpha: 0.2) : AppTheme.accentLight; catIcon = Icons.fitness_center; break;
                            case 'Bacak': catBg = isDark ? AppTheme.secondary.withValues(alpha: 0.2) : AppTheme.secondaryLight; catIcon = Icons.accessibility_new; break;
                            case 'Sırt': catBg = isDark ? AppTheme.darkPrimary.withValues(alpha: 0.2) : AppTheme.primaryLight; catIcon = Icons.boy; break;
                            case 'Biceps': catBg = isDark ? AppTheme.warningDark.withValues(alpha: 0.25) : AppTheme.warning.withValues(alpha: 0.25); catIcon = Icons.star_border; break;
                            case 'Triceps': catBg = isDark ? AppTheme.infoDark.withValues(alpha: 0.25) : AppTheme.info.withValues(alpha: 0.25); catIcon = Icons.wb_sunny_outlined; break;
                            case 'Omuz': catBg = isDark ? AppTheme.darkPrimary.withValues(alpha: 0.25) : AppTheme.primaryLight.withValues(alpha: 0.4); catIcon = Icons.adjust; break;
                            case 'Bilek': catBg = isDark ? AppTheme.darkAccent.withValues(alpha: 0.25) : AppTheme.accentLight.withValues(alpha: 0.4); catIcon = Icons.gesture; break;
                            default: catBg = isDark ? AppTheme.darkSurface : AppTheme.background; catIcon = Icons.fitness_center;
                          }

                          return InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedCategory = cat;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: catBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(catIcon, size: 26, color: isDark ? AppTheme.darkText : AppTheme.textDark),
                                  const SizedBox(height: 6),
                                  Text(
                                    cat,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isDark ? AppTheme.darkText : AppTheme.textDark,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final filteredList = _exerciseLibrary.where((e) => e.muscleGroup == selectedCategory).toList();

              return Container(
                padding: const EdgeInsets.all(24),
                height: 550,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => setModalState(() => selectedCategory = null),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$selectedCategory Egzersizleri',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkText : AppTheme.textDark,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(child: Text('Bu kategoride henüz hareket bulunmuyor.'))
                          : ListView.builder(
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final exercise = filteredList[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  color: isDark ? AppTheme.darkSurface : AppTheme.background,
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        color: isDark ? Colors.black26 : Colors.white,
                                        width: 50,
                                        height: 50,
                                        child: Image.asset(
                                          exercise.imagePath,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.fitness_center,
                                              color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      exercise.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppTheme.darkText : AppTheme.textDark,
                                      ),
                                    ),
                                    subtitle: Text(
                                      exercise.muscleGroup,
                                      style: TextStyle(
                                        color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.add_circle,
                                      color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _addExerciseToWorkout(exercise.id);
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        customNameController.clear();
                        setModalState(() {
                          creatingCustom = true;
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Bu Kategoriye Özel Hareket Ekle'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                        side: BorderSide(color: (isDark ? AppTheme.darkPrimary : AppTheme.primary).withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

  void _addExerciseToWorkout(String exerciseId) {
    final workout = _getWorkoutForDate(_selectedDate);
    final exists = workout.sessions.any((s) => s.exerciseId == exerciseId);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu egzersiz zaten bugünkü antrenmana eklenmiş!'),
          backgroundColor: AppTheme.accent,
        ),
      );
      return;
    }

    workout.sessions.add(
      ExerciseSession(
        exerciseId: exerciseId,
        sets: [
          ExerciseSet(weight: 0.0, reps: 0),
        ],
      ),
    );
    _updateWorkout(workout);
  }

  void _removeExerciseFromWorkout(int index) {
    final workout = _getWorkoutForDate(_selectedDate);
    workout.sessions.removeAt(index);
    _updateWorkout(workout);
  }

  void _addSet(ExerciseSession session) {
    double lastWeight = 0.0;
    int lastReps = 0;
    if (session.sets.isNotEmpty) {
      lastWeight = session.sets.last.weight;
      lastReps = session.sets.last.reps;
    }
    session.sets.add(ExerciseSet(weight: lastWeight, reps: lastReps));
    _updateWorkout(_getWorkoutForDate(_selectedDate));
  }

  void _removeSet(ExerciseSession session, int index) {
    if (session.sets.length > 1) {
      session.sets.removeAt(index);
    } else {
      final workout = _getWorkoutForDate(_selectedDate);
      workout.sessions.removeWhere((s) => s.exerciseId == session.exerciseId);
    }
    _updateWorkout(_getWorkoutForDate(_selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workout = _getWorkoutForDate(_selectedDate);
    final userProfile = StorageService.getProfile() ?? UserProfile.defaultProfile;
    final workoutSummary = WorkoutCalorieCalculator.calculateWorkoutSummary(
      workout: workout,
      exerciseLibrary: _exerciseLibrary,
      userWeightKg: userProfile.weight,
    );

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.background,
      body: Column(
        children: [
          // Date & Quick Tools Selector Panel
          Container(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                        });
                      },
                      icon: const Icon(Icons.arrow_back_ios, size: 18),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy, EEE', 'tr_TR').format(_selectedDate),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkText : AppTheme.textDark,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(const Duration(days: 1));
                        });
                      },
                      icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    ),
                  ],
                ),
                // Plate Calculator Tool Button
                OutlinedButton.icon(
                  onPressed: _showPlateCalculatorDialog,
                  icon: const Icon(Icons.fitness_center, size: 16),
                  label: const Text('Plaka', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                    side: BorderSide(color: (isDark ? AppTheme.darkPrimary : AppTheme.primary).withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),

          // ⏱️ Modular Rest Timer Dock
          RestTimerDock(
            secondsRemaining: _restSecondsRemaining,
            totalDuration: _totalRestDuration,
            isActive: _isRestTimerActive || _restSecondsRemaining > 0,
            isRunning: _restTimer?.isActive == true,
            onStartTimer: _startRestTimer,
            onPauseResume: _pauseOrResumeTimer,
            onCancel: _cancelRestTimer,
          ),

          // 🔥 Antrenman Özeti ve Yakılan Kalori Bannerı
          if (workout.sessions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF2D1810), const Color(0xFF1E1E24)]
                        : [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFFF9F1C).withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9F1C).withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Yakılan Kalori
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9F1C).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.local_fire_department, color: Color(0xFFFF9F1C), size: 20),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${workoutSummary.caloriesInt} kcal',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFFF9F1C) : const Color(0xFFE65100),
                              ),
                            ),
                            Text(
                              'Yakılan Kalori',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Container(
                      height: 28,
                      width: 1,
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                    ),

                    // Toplam Hacim (Tonaj)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: (isDark ? AppTheme.darkPrimary : AppTheme.primary).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.fitness_center,
                            color: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${workoutSummary.volumeInt} kg',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkText : AppTheme.textDark,
                              ),
                            ),
                            Text(
                              'Toplam Hacim',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Container(
                      height: 28,
                      width: 1,
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                    ),

                    // Setler
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${workoutSummary.completedSets}/${workoutSummary.totalSets}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkText : AppTheme.textDark,
                          ),
                        ),
                        Text(
                          'Set Tamam',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          // Egzersiz Ekleme butonu veya Egzersiz listesi
          Expanded(
            child: workout.sessions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center_outlined,
                          size: 64,
                          color: isDark ? AppTheme.darkPrimary.withValues(alpha: 0.4) : AppTheme.primaryLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bugün için antrenman girilmemiş.',
                          style: TextStyle(
                            color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showAddExerciseDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Egzersiz Ekle'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: workout.sessions.length,
                    itemBuilder: (context, index) {
                      final session = workout.sessions[index];
                      final exercise = _exerciseLibrary.firstWhere(
                        (e) => e.id == session.exerciseId,
                        orElse: () => Exercise(id: 'unknown', name: 'Bilinmeyen Egzersiz', muscleGroup: '-', imagePath: ''),
                      );

                      final sessionSummary = WorkoutCalorieCalculator.calculateSessionSummary(
                        session: session,
                        muscleGroup: exercise.muscleGroup,
                        userWeightKg: userProfile.weight,
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Exercise Title & Header
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      color: isDark ? Colors.black26 : AppTheme.background,
                                      width: 60,
                                      height: 60,
                                      child: Image.asset(
                                        exercise.imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.fitness_center,
                                            color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise.name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppTheme.darkText : AppTheme.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? AppTheme.secondary.withValues(alpha: 0.2)
                                                    : AppTheme.secondaryLight,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              child: Text(
                                                exercise.muscleGroup,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark ? AppTheme.secondary : AppTheme.secondaryDark,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            if (sessionSummary.completedSets > 0) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFF9F1C).withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                child: Text(
                                                  '🔥 ${sessionSummary.caloriesInt} kcal',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFFFF9F1C),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: (isDark ? AppTheme.darkPrimary : AppTheme.primary).withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                child: Text(
                                                  '🏋️ ${sessionSummary.volumeInt} kg',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeExerciseFromWorkout(index),
                                    icon: const Icon(Icons.delete_outline, color: AppTheme.accent),
                                  ),
                                ],
                              ),
                              Divider(
                                height: 24,
                                color: isDark ? AppTheme.darkBorder : AppTheme.border,
                              ),
                              
                              // Table Header for sets
                              Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      'Set',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Kilo (kg)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Tekrar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: Center(
                                      child: Text(
                                        'Bitti',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 40),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // List of sets
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: session.sets.length,
                                itemBuilder: (context, setIndex) {
                                  final set = session.sets[setIndex];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        // Set Number
                                        SizedBox(
                                          width: 40,
                                          child: Text(
                                            '${setIndex + 1}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? AppTheme.darkText : AppTheme.textDark,
                                            ),
                                          ),
                                        ),
                                        // Weight Input
                                        Expanded(
                                          child: Container(
                                            height: 40,
                                            margin: const EdgeInsets.only(right: 8),
                                            child: TextFormField(
                                              initialValue: set.weight > 0 ? set.weight.toString() : '',
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                                              ],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isDark ? AppTheme.darkText : AppTheme.textDark,
                                              ),
                                              decoration: const InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              ),
                                              onChanged: (val) {
                                                final cleanVal = val.replaceAll(',', '.');
                                                set.weight = double.tryParse(cleanVal) ?? 0.0;
                                                _updateWorkout(workout);
                                              },
                                            ),
                                          ),
                                        ),
                                        // Reps Input
                                        Expanded(
                                          child: Container(
                                            height: 40,
                                            margin: const EdgeInsets.only(right: 8),
                                            child: TextFormField(
                                              initialValue: set.reps > 0 ? set.reps.toString() : '',
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,
                                              ],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isDark ? AppTheme.darkText : AppTheme.textDark,
                                              ),
                                              decoration: const InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              ),
                                              onChanged: (val) {
                                                set.reps = int.tryParse(val) ?? 0;
                                                _updateWorkout(workout);
                                              },
                                            ),
                                          ),
                                        ),
                                        // IsCompleted Checkbox
                                        SizedBox(
                                          width: 50,
                                          child: Checkbox(
                                            value: set.isCompleted,
                                            activeColor: isDark ? AppTheme.darkSecondary : AppTheme.secondary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            onChanged: (val) {
                                              final isFinished = val ?? false;
                                              set.isCompleted = isFinished;
                                              _updateWorkout(workout);

                                              if (isFinished) {
                                                _checkForPR(session.exerciseId, set.weight, set.reps);
                                                // Auto-start rest timer
                                                if (!_isRestTimerActive) {
                                                  _startRestTimer(60);
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                        // Remove Set
                                        SizedBox(
                                          width: 40,
                                          child: IconButton(
                                            onPressed: () => _removeSet(session, setIndex),
                                            icon: const Icon(Icons.remove_circle_outline, size: 20, color: AppTheme.accent),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              
                              // Add set button
                              OutlinedButton.icon(
                                onPressed: () => _addSet(session),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Set Ekle', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  side: BorderSide(color: (isDark ? AppTheme.darkPrimary : AppTheme.primary).withValues(alpha: 0.5)),
                                  foregroundColor: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: workout.sessions.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddExerciseDialog,
              backgroundColor: isDark ? AppTheme.darkPrimary : AppTheme.primary,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
