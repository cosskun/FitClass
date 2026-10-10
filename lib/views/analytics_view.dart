import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class AnalyticsView extends StatefulWidget {
  final List<Workout> workouts;
  final List<Meal> meals;

  const AnalyticsView({
    super.key,
    required this.workouts,
    required this.meals,
  });

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedExerciseId = 'bench_press';
  String _selectedBodyMetric = 'Kol'; // Kol, Bel, Göğüs, Omuz, Bacak, Kilo
  late List<Exercise> _exercises;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _exercises = StorageService.getExercises();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Pick Date Range
  Future<void> _selectDateRange(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: isDark ? AppTheme.darkPrimary : AppTheme.primary,
              onPrimary: isDark ? Colors.black : Colors.white,
              surface: isDark ? AppTheme.darkSurface : Colors.white,
              onSurface: isDark ? AppTheme.darkText : AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  // Workout weight spots
  List<FlSpot> _getWorkoutSpots() {
    final List<FlSpot> spots = [];
    final sortedWorkouts = List<Workout>.from(widget.workouts)
      ..sort((a, b) => a.date.compareTo(b.date));

    int index = 0;
    for (var workout in sortedWorkouts) {
      if (workout.date.isAfter(_startDate.subtract(const Duration(seconds: 1))) &&
          workout.date.isBefore(_endDate.add(const Duration(days: 1)))) {
        
        final session = workout.sessions.firstWhere(
          (s) => s.exerciseId == _selectedExerciseId,
          orElse: () => ExerciseSession(exerciseId: '', sets: []),
        );

        if (session.sets.isNotEmpty) {
          final completedSets = session.sets.where((s) => s.isCompleted && s.weight > 0).toList();
          if (completedSets.isNotEmpty) {
            double maxWeight = completedSets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
            spots.add(FlSpot(index.toDouble(), maxWeight));
          }
        }
      }
      index++;
    }
    return spots;
  }

  String _getWorkoutDateLabel(double indexVal) {
    int idx = indexVal.toInt();
    final sortedWorkouts = List<Workout>.from(widget.workouts)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (idx >= 0 && idx < sortedWorkouts.length) {
      return DateFormat('dd/MM').format(sortedWorkouts[idx].date);
    }
    return '';
  }

  // Body Measurements spots
  List<FlSpot> _getBodyMeasurementSpots() {
    final List<FlSpot> spots = [];
    final list = StorageService.getBodyMeasurements();

    int idx = 0;
    for (var m in list) {
      double? val;
      switch (_selectedBodyMetric) {
        case 'Kilo': val = m.weight; break;
        case 'Kol': val = m.arm; break;
        case 'Bel': val = m.waist; break;
        case 'Göğüs': val = m.chest; break;
        case 'Omuz': val = m.shoulder; break;
        case 'Bacak': val = m.leg; break;
        case 'Kalça': val = m.hip; break;
      }

      if (val != null && val > 0) {
        spots.add(FlSpot(idx.toDouble(), val));
        idx++;
      }
    }
    return spots;
  }

  String _getBodyDateLabel(double indexVal) {
    int idx = indexVal.toInt();
    final list = StorageService.getBodyMeasurements();
    if (idx >= 0 && idx < list.length) {
      return DateFormat('dd/MM').format(list[idx].date);
    }
    return '';
  }

  // Water intake spots
  List<FlSpot> _getWaterSpots() {
    final List<FlSpot> spots = [];
    final logs = StorageService.getWaterLogs();
    logs.sort((a, b) => a.date.compareTo(b.date));

    int idx = 0;
    for (var log in logs) {
      if (log.date.isAfter(_startDate.subtract(const Duration(seconds: 1))) &&
          log.date.isBefore(_endDate.add(const Duration(days: 1)))) {
        spots.add(FlSpot(idx.toDouble(), log.amountMl.toDouble()));
        idx++;
      }
    }
    return spots;
  }

  String _getWaterDateLabel(double indexVal) {
    int idx = indexVal.toInt();
    final logs = StorageService.getWaterLogs();
    logs.sort((a, b) => a.date.compareTo(b.date));
    if (idx >= 0 && idx < logs.length) {
      return DateFormat('dd/MM').format(logs[idx].date);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.background,
      body: Column(
        children: [
          // Tab Bar Container
          Container(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              labelColor: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
              unselectedLabelColor: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
              indicatorColor: isDark ? AppTheme.darkPrimary : AppTheme.primary,
              tabs: const [
                Tab(icon: Icon(Icons.fitness_center), text: 'Antrenman'),
                Tab(icon: Icon(Icons.straighten), text: 'Vücut Ölçüleri'),
                Tab(icon: Icon(Icons.water_drop), text: 'Su Trendi'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Tab: Workout Weight Progress
                _buildWorkoutAnalyticsTab(isDark),

                // 2. Tab: Body Measurements Progress
                _buildBodyMeasurementsTab(isDark),

                // 3. Tab: Water Intake Trends
                _buildWaterAnalyticsTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. Workout Tab ---
  Widget _buildWorkoutAnalyticsTab(bool isDark) {
    final spots = _getWorkoutSpots();
    final selectedExercise = _exercises.firstWhere(
      (e) => e.id == _selectedExerciseId,
      orElse: () => Exercise(id: _selectedExerciseId, name: 'Egzersiz', muscleGroup: '', imagePath: ''),
    );

    final rangeWorkouts = widget.workouts.where((w) => 
      w.date.isAfter(_startDate.subtract(const Duration(seconds: 1))) &&
      w.date.isBefore(_endDate.add(const Duration(days: 1)))
    ).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Panel
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tarih Aralığı',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _selectDateRange(context),
                      icon: const Icon(Icons.date_range, size: 16),
                      label: Text(
                        '${DateFormat('dd MMM', 'tr_TR').format(_startDate)} - ${DateFormat('dd MMM', 'tr_TR').format(_endDate)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: isDark ? AppTheme.darkText : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                Divider(height: 20, color: isDark ? AppTheme.darkBorder : AppTheme.border),
                Text(
                  'Egzersiz Seçin',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedExerciseId,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                  items: _exercises.map((e) {
                    return DropdownMenuItem<String>(
                      value: e.id,
                      child: Text(
                        e.name,
                        style: TextStyle(color: isDark ? AppTheme.darkText : AppTheme.textDark),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedExerciseId = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Chart Card
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
                  '${selectedExercise.name} - Ağırlık Gelişimi (kg)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkText : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 24),
                spots.isEmpty
                    ? Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.show_chart,
                              size: 48,
                              color: (isDark ? AppTheme.darkPrimary : AppTheme.primaryLight).withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Seçilen tarih aralığında antrenman verisi bulunamadı.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 220,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        _getWorkoutDateLabel(value),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                  interval: 1,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt()}kg',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                      ),
                                    );
                                  },
                                  reservedSize: 36,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: (isDark ? AppTheme.darkPrimary : AppTheme.primary).withValues(alpha: 0.15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Total Workouts Stat Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkPrimary.withValues(alpha: 0.15) : AppTheme.primaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: (isDark ? AppTheme.darkPrimary : AppTheme.primary).withValues(alpha: 0.3)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.fitness_center, color: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bu Dönemde Yapılan Antrenman',
                      style: TextStyle(
                        color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${rangeWorkouts.length} Gün',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkText : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Body Measurements Tab ---
  Widget _buildBodyMeasurementsTab(bool isDark) {
    final spots = _getBodyMeasurementSpots();
    final metrics = ['Kol', 'Bel', 'Göğüs', 'Omuz', 'Bacak', 'Kilo'];
    final measurements = StorageService.getBodyMeasurements();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metric Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: metrics.map((m) {
                final selected = _selectedBodyMetric == m;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(m == 'Kilo' ? 'Kilo (kg)' : '$m (cm)'),
                    selected: selected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedBodyMetric = m);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Measurement Chart
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
                  '$_selectedBodyMetric Değişim Grafiği (${_selectedBodyMetric == 'Kilo' ? 'kg' : 'cm'})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkText : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 24),
                spots.isEmpty
                    ? Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: Text(
                          'Henüz vücut ölçüsü kaydı bulunmuyor.',
                          style: TextStyle(color: isDark ? AppTheme.darkTextLight : AppTheme.textLight),
                        ),
                      )
                    : SizedBox(
                        height: 220,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        _getBodyDateLabel(value),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                  interval: 1,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt()}${_selectedBodyMetric == 'Kilo' ? 'kg' : 'cm'}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                      ),
                                    );
                                  },
                                  reservedSize: 42,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: isDark ? AppTheme.secondary : AppTheme.secondaryDark,
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: (isDark ? AppTheme.secondary : AppTheme.secondary).withValues(alpha: 0.15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Measurement History List
          Text(
            'Ölçü Geçmişi',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkText : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: measurements.reversed.length,
            itemBuilder: (context, index) {
              final m = measurements.reversed.toList()[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: isDark ? AppTheme.darkSurface : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('dd MMMM yyyy', 'tr_TR').format(m.date),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? AppTheme.darkText : AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kilo: ${m.weight ?? '-'} kg | Bel: ${m.waist ?? '-'} cm | Kol: ${m.arm ?? '-'} cm',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.check_circle_outline, color: isDark ? AppTheme.secondary : AppTheme.secondaryDark),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 3. Water Tab ---
  Widget _buildWaterAnalyticsTab(bool isDark) {
    final spots = _getWaterSpots();
    final logs = StorageService.getWaterLogs();
    final double totalWater = logs.fold(0.0, (sum, l) => sum + l.amountMl);
    final double avgWater = logs.isNotEmpty ? totalWater / logs.length : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Water Chart
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
                    Text(
                      'Günlük Su Tüketimi (ml)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkText : AppTheme.textDark,
                      ),
                    ),
                    const Icon(Icons.water_drop, color: Color(0xFF00B4D8)),
                  ],
                ),
                const SizedBox(height: 24),
                spots.isEmpty
                    ? Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: Text(
                          'Henüz su tüketim kaydı bulunmuyor.',
                          style: TextStyle(color: isDark ? AppTheme.darkTextLight : AppTheme.textLight),
                        ),
                      )
                    : SizedBox(
                        height: 220,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        _getWaterDateLabel(value),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                  interval: 1,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt()}ml',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                      ),
                                    );
                                  },
                                  reservedSize: 42,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: const Color(0xFF00B4D8),
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: const Color(0xFF00B4D8).withValues(alpha: 0.2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Average Water Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF00B4D8).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00B4D8).withValues(alpha: 0.3)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.local_drink, color: Color(0xFF00B4D8), size: 28),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ortalama Günlük Su Tüketimi',
                      style: TextStyle(
                        color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${avgWater.toInt()} ml / gün',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkText : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
