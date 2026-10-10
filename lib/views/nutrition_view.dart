import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'widgets/widgets.dart';

class NutritionView extends StatefulWidget {
  final UserProfile profile;
  final List<Meal> meals;
  final Function(Meal) onMealAdded;
  final Function(String) onMealDeleted;

  const NutritionView({
    super.key,
    required this.profile,
    required this.meals,
    required this.onMealAdded,
    required this.onMealDeleted,
  });

  @override
  State<NutritionView> createState() => _NutritionViewState();
}

class _NutritionViewState extends State<NutritionView> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedFoodCategory;

  // List of meals matching selected date
  List<Meal> get _filteredMeals {
    return widget.meals.where((m) => 
      m.timestamp.year == _selectedDate.year && 
      m.timestamp.month == _selectedDate.month && 
      m.timestamp.day == _selectedDate.day
    ).toList();
  }

  void _addMeal(String name, double protein, double calories, [String? imagePath]) {
    final newMeal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      calories: calories,
      protein: protein,
      timestamp: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
      ),
      imagePath: imagePath,
    );
    widget.onMealAdded(newMeal);
    setState(() {});
  }

  void _showAddMealBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _selectedFoodCategory = null;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DefaultTabController(
          length: 3,
          child: Container(
            padding: const EdgeInsets.all(24),
            height: 560,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Besin Ekle',
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
                TabBar(
                  labelColor: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                  unselectedLabelColor: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                  indicatorColor: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                  tabs: const [
                    Tab(icon: Icon(Icons.list_alt), text: 'Veritabanı'),
                    Tab(icon: Icon(Icons.bookmark_border), text: 'Şablonlarım'),
                    Tab(icon: Icon(Icons.camera_alt), text: 'Fotoğraf (AI)'),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    children: [
                      // 1. Tab: Database with categories
                      StatefulBuilder(
                        builder: (context, setModalState) {
                          if (_selectedFoodCategory == null) {
                            final categories = [
                              {'name': 'Protein Kaynakları', 'icon': Icons.kebab_dining_outlined, 'color': isDark ? AppTheme.darkPrimary.withValues(alpha: 0.15) : AppTheme.primaryLight, 'textColor': isDark ? AppTheme.darkPrimary : AppTheme.primaryDark},
                              {'name': 'Karbonhidrat & Tahıl', 'icon': Icons.breakfast_dining_outlined, 'color': isDark ? AppTheme.secondary.withValues(alpha: 0.15) : AppTheme.secondaryLight, 'textColor': isDark ? AppTheme.secondary : AppTheme.secondaryDark},
                              {'name': 'Türk Mutfağı / Yemekler', 'icon': Icons.restaurant_menu, 'color': isDark ? Colors.orange.withValues(alpha: 0.15) : Colors.orange.shade50, 'textColor': Colors.orange},
                              {'name': 'Meyve & Atıştırmalık', 'icon': Icons.apple_outlined, 'color': isDark ? AppTheme.darkAccent.withValues(alpha: 0.15) : AppTheme.accentLight, 'textColor': isDark ? AppTheme.darkAccent : AppTheme.accent},
                              {'name': 'İçecekler', 'icon': Icons.local_cafe_outlined, 'color': isDark ? Colors.blue.withValues(alpha: 0.15) : Colors.blue.shade50, 'textColor': Colors.blue},
                            ];

                            return ListView.builder(
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final cat = categories[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  color: cat['color'] as Color,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: ListTile(
                                    leading: Icon(cat['icon'] as IconData, color: cat['textColor'] as Color, size: 28),
                                    title: Text(
                                      cat['name'] as String,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: cat['textColor'] as Color, fontSize: 16),
                                    ),
                                    trailing: Icon(Icons.arrow_forward_ios, color: cat['textColor'] as Color, size: 16),
                                    onTap: () {
                                      setModalState(() {
                                        _selectedFoodCategory = cat['name'] as String;
                                      });
                                    },
                                  ),
                                );
                              },
                            );
                          } else {
                            final foods = AppConstants.foodDatabase.where((f) => f['category'] == _selectedFoodCategory).toList();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setModalState(() {
                                          _selectedFoodCategory = null;
                                        });
                                      },
                                      icon: Icon(Icons.arrow_back, color: isDark ? AppTheme.darkText : AppTheme.textDark),
                                    ),
                                    Text(
                                      _selectedFoodCategory!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDark ? AppTheme.darkText : AppTheme.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: foods.length,
                                    itemBuilder: (context, index) {
                                      final food = foods[index];
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        color: isDark ? AppTheme.darkSurface : AppTheme.background,
                                        child: ListTile(
                                          title: Text(
                                            food['name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? AppTheme.darkText : AppTheme.textDark,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${food['calories'].toInt()} kcal | ${food['protein']}g Protein',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                            ),
                                          ),
                                          trailing: Icon(
                                            Icons.add_circle,
                                            color: isDark ? AppTheme.secondary : AppTheme.secondaryDark,
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _addMeal(food['name'], food['protein'], food['calories']);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),

                      // 2. Tab: Meal Templates (Öğün Şablonlarım)
                      _buildTemplatesTab(isDark),

                      // 3. Tab: Photo upload simulator
                      _buildPhotoUploadTab(isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Meal Templates Tab View
  Widget _buildTemplatesTab(bool isDark) {
    final templates = StorageService.getMealTemplates();

    return Column(
      children: [
        Expanded(
          child: templates.isEmpty
              ? Center(
                  child: Text(
                    'Henüz kayıtlı öğün şablonunuz yok.',
                    style: TextStyle(color: isDark ? AppTheme.darkTextLight : AppTheme.textLight),
                  ),
                )
              : ListView.builder(
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final tmpl = templates[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isDark ? AppTheme.darkSurface : AppTheme.background,
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkPrimary.withValues(alpha: 0.2) : AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.restaurant,
                            color: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                          ),
                        ),
                        title: Text(
                          tmpl.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkText : AppTheme.textDark,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tmpl.description.isNotEmpty)
                              Text(
                                tmpl.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                ),
                              ),
                            Text(
                              '${tmpl.calories.toInt()} kcal | ${tmpl.protein.toInt()}g Protein',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.secondary : AppTheme.secondaryDark,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async {
                                await StorageService.deleteMealTemplate(tmpl.id);
                                setState(() {});
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  _showAddMealBottomSheet();
                                }
                              },
                              icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.accent),
                            ),
                            Icon(
                              Icons.add_circle,
                              color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _addMeal(tmpl.title, tmpl.protein, tmpl.calories);
                        },
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            _showCreateTemplateDialog();
          },
          icon: const Icon(Icons.add),
          label: const Text('Yeni Öğün Şablonu Oluştur'),
          style: OutlinedButton.styleFrom(
            foregroundColor: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
            side: BorderSide(color: (isDark ? AppTheme.darkPrimary : AppTheme.primary).withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
      ],
    );
  }

  void _showCreateTemplateDialog() {
    MealTemplateDialog.show(context);
  }

  // Simulated AI photo analysis
  Widget _buildPhotoUploadTab(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.photo_camera_outlined,
          size: 64,
          color: (isDark ? AppTheme.darkPrimary : AppTheme.primary).withValues(alpha: 0.5),
        ),
        const SizedBox(height: 12),
        Text(
          'Yemeğinizin fotoğrafını çekin veya yükleyin.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkText : AppTheme.textDark,
          ),
        ),
        Text(
          'Yapay Zekamız besin değerlerini otomatik hesaplayacaktır.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _simulateAIOpticalAnalysis(isCamera: true);
                },
                icon: const Icon(Icons.photo_camera),
                label: const Text('Fotoğraf Çek'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _simulateAIOpticalAnalysis(isCamera: false);
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeriden Seç'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                  side: BorderSide(color: (isDark ? AppTheme.darkPrimary : AppTheme.primary).withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _simulateAIOpticalAnalysis({required bool isCamera}) {
    AIScanDialog.show(
      context,
      isCamera: isCamera,
      onAnalysisCompleted: (String foodName, double protein, double calories) {
        _addMeal(foodName, protein, calories, 'assets/images/exercises/bench_press.png');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yapay Zeka Tespiti Başarılı: $foodName eklendi!'),
            backgroundColor: AppTheme.secondaryDark,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredMeals;
    final double totalCalories = filtered.fold(0, (sum, item) => sum + item.calories);
    final double totalProtein = filtered.fold(0, (sum, item) => sum + item.protein);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Date Selector Header
          Container(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                    });
                  },
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                ),
                Text(
                  DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(_selectedDate),
                  style: TextStyle(
                    fontSize: 16,
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
                  icon: const Icon(Icons.arrow_forward_ios, size: 20),
                ),
              ],
            ),
          ),
          
          // Header summary card
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Toplam Kalori',
                          style: TextStyle(
                            color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${totalCalories.toInt()} kcal',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.secondary : AppTheme.secondaryDark,
                          ),
                        ),
                        Text(
                          '/ ${widget.profile.dailyCalorieGoal.toInt()} kcal',
                          style: TextStyle(
                            color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: isDark ? AppTheme.darkBorder : AppTheme.border,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Toplam Protein',
                          style: TextStyle(
                            color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${totalProtein.toInt()} g',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                          ),
                        ),
                        Text(
                          '/ ${widget.profile.dailyProteinGoal.toInt()} g',
                          style: TextStyle(
                            color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Meal List or Empty State
          filtered.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu_outlined,
                          size: 64,
                          color: isDark ? AppTheme.secondary.withValues(alpha: 0.3) : AppTheme.secondaryLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bugün henüz besin girişi yapılmamış.',
                          style: TextStyle(
                            color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _showAddMealBottomSheet,
                          icon: const Icon(Icons.add),
                          label: const Text('Öğün Ekle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final meal = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isDark ? AppTheme.darkSurface : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.secondary.withValues(alpha: 0.15) : AppTheme.secondaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.restaurant,
                                color: isDark ? AppTheme.secondary : AppTheme.secondaryDark,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDark ? AppTheme.darkText : AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${meal.calories.toInt()} kcal  •  ${meal.protein}g Protein',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('HH:mm').format(meal.timestamp),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppTheme.darkTextLight.withValues(alpha: 0.7) : AppTheme.textLight.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => widget.onMealDeleted(meal.id),
                              icon: const Icon(Icons.delete_outline, color: AppTheme.accent),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMealBottomSheet,
        backgroundColor: isDark ? AppTheme.secondary : AppTheme.secondaryDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
