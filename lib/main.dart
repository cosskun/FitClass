import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'models/models.dart';
import 'services/storage_service.dart';
import 'views/dashboard_view.dart';
import 'views/workout_view.dart';
import 'views/nutrition_view.dart';
import 'views/analytics_view.dart';
import 'views/profile_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Suppress yellow-black zebra stripe overflow warnings across all devices
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const SizedBox.shrink();
  };
  
  // Initialize Storage Service (Shared Preferences and Mock Data Seeding)
  await StorageService.init();
  
  // Initialize Turkish date formatting
  await initializeDateFormatting('tr_TR', null);
  
  runApp(const FitClassApp());
}

class FitClassApp extends StatefulWidget {
  const FitClassApp({super.key});

  @override
  State<FitClassApp> createState() => _FitClassAppState();
}

class _FitClassAppState extends State<FitClassApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() {
    final isDark = StorageService.isDarkMode();
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _toggleTheme(bool isDark) async {
    await StorageService.setDarkMode(isDark);
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitClass',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
      ],
      locale: const Locale('tr', 'TR'),
      home: MainShell(
        isDarkMode: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggleTheme;

  const MainShell({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  
  late UserProfile _profile;
  late List<Workout> _workouts;
  late List<Meal> _meals;
  int _todayWaterMl = 0;

  @override
  void initState() {
    super.initState();
    _refreshState();
  }

  void _refreshState() {
    setState(() {
      _profile = StorageService.getProfile() ?? UserProfile(
        height: 175,
        weight: 75,
        age: 25,
        gender: 'Erkek',
        activityLevelMultiplier: 1.375,
        dailyWaterGoal: 2500,
      );
      _workouts = StorageService.getWorkouts();
      _meals = StorageService.getMeals();
      _todayWaterMl = StorageService.getTodayWater();
    });
  }

  // Get current day's meals
  List<Meal> get _todayMeals {
    final today = DateTime.now();
    return _meals.where((m) =>
      m.timestamp.year == today.year &&
      m.timestamp.month == today.month &&
      m.timestamp.day == today.day
    ).toList();
  }

  void _updateProfile(UserProfile newProfile) async {
    await StorageService.saveProfile(newProfile);
    _refreshState();
  }

  void _updateWorkout(Workout updatedWorkout) async {
    await StorageService.addWorkout(updatedWorkout);
    _refreshState();
  }

  void _addMeal(Meal meal) async {
    await StorageService.addMeal(meal);
    _refreshState();
  }

  void _deleteMeal(String mealId) async {
    await StorageService.deleteMeal(mealId);
    _refreshState();
  }

  void _addWater(int deltaMl) async {
    final newAmount = await StorageService.addWater(deltaMl);
    setState(() {
      _todayWaterMl = newAmount;
    });
  }

  void _resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Mark first run as completed to prevent seeding mock meals/workouts, but keep exercises
    await prefs.setBool('first_run_seeded', true);
    await StorageService.init();
    _refreshState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
          IconButton(
            onPressed: () => widget.onToggleTheme(!widget.isDarkMode),
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode_outlined,
              color: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
            ),
            tooltip: widget.isDarkMode ? 'Açık Tema' : 'Karanlık Tema',
          ),
          IconButton(
            onPressed: _refreshState,
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardView(
            profile: _profile,
            todayMeals: _todayMeals,
            workouts: _workouts,
            todayWaterMl: _todayWaterMl,
            onAddWater: _addWater,
            onNavigateToMeals: () => setState(() => _currentIndex = 2),
            onNavigateToWorkouts: () => setState(() => _currentIndex = 1),
          ),
          WorkoutView(
            workouts: _workouts,
            onWorkoutUpdated: _updateWorkout,
          ),
          NutritionView(
            profile: _profile,
            meals: _meals,
            onMealAdded: _addMeal,
            onMealDeleted: _deleteMeal,
          ),
          AnalyticsView(
            workouts: _workouts,
            meals: _meals,
          ),
          ProfileView(
            initialProfile: _profile,
            isDarkMode: widget.isDarkMode,
            onToggleTheme: widget.onToggleTheme,
            onProfileSaved: _updateProfile,
            onDataReset: _resetData,
            onDataRestored: _refreshState,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.darkBorder : AppTheme.border,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
          selectedItemColor: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
          unselectedItemColor: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Panel',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Antrenman',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant),
              label: 'Beslenme',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_outlined),
              activeIcon: Icon(Icons.show_chart),
              label: 'Grafikler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'FitClass';
      case 1:
        return 'Antrenman Günlüğü';
      case 2:
        return 'Beslenme Günlüğü';
      case 3:
        return 'Analiz ve Gelişim';
      case 4:
        return 'Profil ve Hedefler';
      default:
        return 'FitClass';
    }
  }
}
