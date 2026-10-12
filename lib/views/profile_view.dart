import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../services/backup_helper.dart' as backup;
import 'widgets/widgets.dart';

class ProfileView extends StatefulWidget {
  final UserProfile? initialProfile;
  final bool isDarkMode;
  final ValueChanged<bool> onToggleTheme;
  final Function(UserProfile) onProfileSaved;
  final VoidCallback onDataReset;
  final VoidCallback onDataRestored;

  const ProfileView({
    super.key,
    this.initialProfile,
    this.isDarkMode = false,
    required this.onToggleTheme,
    required this.onProfileSaved,
    required this.onDataReset,
    required this.onDataRestored,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  late TextEditingController _waterGoalController;
  late TextEditingController _proteinGoalController;
  late TextEditingController _calorieGoalController;
  
  String _selectedGender = 'Erkek';
  String _selectedGoal = 'Kas Kazanımı';
  double _selectedActivityMultiplier = 1.375;
  late List<NutritionReminder> _reminders;
  late List<PersonalRecord> _personalRecords;

  final Map<double, String> _activityLevels = AppConstants.activityLevels;

  final List<Map<String, dynamic>> _goalOptions = [
    {
      'id': 'Kas Kazanımı',
      'title': 'Kas Kazanımı & Hacim',
      'icon': '🏋️‍♂️',
      'multiplierText': '1.8 g/kg',
      'desc': 'Kas gelişimi ve hipertrofi için yüksek protein ve hafif kalori fazlası.',
    },
    {
      'id': 'Kilo Verme',
      'title': 'Kilo Verme & Yağ Yakımı',
      'icon': '🔥',
      'multiplierText': '1.5 g/kg',
      'desc': 'Kas kütlesini korurken kalori açığıyla etkili yağ yakımı.',
    },
    {
      'id': 'Form Koruma',
      'title': 'Form Koruma & Sağlıklı Yaşam',
      'icon': '🌿',
      'multiplierText': '1.1 g/kg',
      'desc': 'Mevcut kiloyu korumak ve genel zindelik için dengeli beslenme.',
    },
    {
      'id': 'Hafif Egzersiz',
      'title': 'Hafif Egzersiz & Fitness',
      'icon': '⚡',
      'multiplierText': '1.4 g/kg',
      'desc': 'Haftada 2-3 gün hafif spor/kardiyo yapanlar için ideal destek.',
    },
  ];

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    
    _heightController = TextEditingController(text: profile?.height.toInt().toString() ?? '175');
    final w = profile?.weight.toInt() ?? 75;
    _weightController = TextEditingController(text: w.toString());
    _ageController = TextEditingController(text: profile?.age.toString() ?? '25');
    _waterGoalController = TextEditingController(text: profile?.dailyWaterGoal.toInt().toString() ?? (w * 35).toString());
    
    _selectedGoal = profile?.goal ?? 'Kas Kazanımı';
    _proteinGoalController = TextEditingController(
      text: profile?.dailyProteinGoal.toInt().toString() ?? UserProfile.calculateProteinForGoal(w.toDouble(), _selectedGoal).toInt().toString(),
    );
    _calorieGoalController = TextEditingController(
      text: profile?.dailyCalorieGoal.toInt().toString() ?? '2400',
    );
    
    if (profile != null) {
      _selectedGender = profile.gender;
      _selectedActivityMultiplier = profile.activityLevelMultiplier;
    }

    _reminders = StorageService.getReminders();
    _personalRecords = StorageService.calculatePersonalRecords();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _waterGoalController.dispose();
    _proteinGoalController.dispose();
    _calorieGoalController.dispose();
    super.dispose();
  }

  void _recalculateGoals({bool notify = true}) {
    final height = double.tryParse(_heightController.text.replaceAll(',', '.')) ?? 175.0;
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 75.0;
    final age = int.tryParse(_ageController.text) ?? 25;

    final recommendedProtein = UserProfile.calculateProteinForGoal(weight, _selectedGoal);
    final recommendedCalories = UserProfile.calculateCaloriesForGoal(
      weight,
      height,
      age,
      _selectedGender,
      _selectedActivityMultiplier,
      _selectedGoal,
    );
    final recommendedWater = (weight * 35).roundToDouble();

    _proteinGoalController.text = recommendedProtein.toInt().toString();
    _calorieGoalController.text = recommendedCalories.toInt().toString();
    _waterGoalController.text = recommendedWater.toInt().toString();

    if (notify) {
      setState(() {});
    }
  }

  void _exportBackup() {
    final String backupJson = StorageService.getBackupJson();
    backup.saveFileToUser(backupJson, "fitclass_yedek_${DateTime.now().millisecondsSinceEpoch}.json");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yedek dosyası başarıyla indirildi!'),
        backgroundColor: AppTheme.secondaryDark,
      ),
    );
  }

  Future<void> _importBackup() async {
    final messenger = ScaffoldMessenger.of(context);
    final String? fileContent = await backup.pickFileFromUser();
    if (fileContent == null) return;
    
    final bool success = await StorageService.restoreBackupJson(fileContent);
    if (success) {
      widget.onDataRestored();
      setState(() {
        _reminders = StorageService.getReminders();
        _personalRecords = StorageService.calculatePersonalRecords();
        final profile = StorageService.getProfile();
        if (profile != null) {
          _heightController.text = profile.height.toInt().toString();
          _weightController.text = profile.weight.toInt().toString();
          _ageController.text = profile.age.toString();
          _waterGoalController.text = profile.dailyWaterGoal.toInt().toString();
          _selectedGender = profile.gender;
          _selectedGoal = profile.goal;
          _selectedActivityMultiplier = profile.activityLevelMultiplier;
          _proteinGoalController.text = profile.dailyProteinGoal.toInt().toString();
          _calorieGoalController.text = profile.dailyCalorieGoal.toInt().toString();
        }
      });
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Yedek başarıyla geri yüklendi!'),
          backgroundColor: AppTheme.secondaryDark,
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Geçersiz yedek dosyası!'),
          backgroundColor: AppTheme.accent,
        ),
      );
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final heightStr = _heightController.text.replaceAll(',', '.');
      final weightStr = _weightController.text.replaceAll(',', '.');
      final ageStr = _ageController.text;
      final waterStr = _waterGoalController.text;
      final proteinStr = _proteinGoalController.text;
      final calorieStr = _calorieGoalController.text;

      final height = double.tryParse(heightStr) ?? 175.0;
      final weight = double.tryParse(weightStr) ?? 75.0;
      final age = int.tryParse(ageStr) ?? 25;
      final waterGoal = double.tryParse(waterStr) ?? (weight * 35);
      final proteinGoal = double.tryParse(proteinStr) ?? UserProfile.calculateProteinForGoal(weight, _selectedGoal);
      final calorieGoal = double.tryParse(calorieStr) ?? UserProfile.calculateCaloriesForGoal(weight, height, age, _selectedGender, _selectedActivityMultiplier, _selectedGoal);

      final newProfile = UserProfile(
        height: height,
        weight: weight,
        age: age,
        gender: _selectedGender,
        activityLevelMultiplier: _selectedActivityMultiplier,
        goal: _selectedGoal,
        dailyProteinGoal: proteinGoal,
        dailyCalorieGoal: calorieGoal,
        dailyWaterGoal: waterGoal,
      );

      widget.onProfileSaved(newProfile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil ve hedefleriniz başarıyla kaydedildi!'),
          backgroundColor: AppTheme.secondaryDark,
        ),
      );
    }
  }

  // --- Add Body Measurement Dialog ---
  void _showAddMeasurementDialog() {
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 75.0;
    BodyMeasurementDialog.show(
      context,
      initialWeight: weight,
      onSaved: () => setState(() {}),
    );
  }

  // --- Add Progress Photo Dialog ---
  void _showAddPhotoDialog() {
    ProgressPhotoDialog.show(
      context,
      onSaved: () => setState(() {}),
    );
  }

  Future<void> _addReminder() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _reminders.add(
          NutritionReminder(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            hour: picked.hour,
            minute: picked.minute,
          ),
        );
      });
      await StorageService.saveReminders(_reminders);
    }
  }

  Future<void> _deleteReminder(int index) async {
    setState(() {
      _reminders.removeAt(index);
    });
    await StorageService.saveReminders(_reminders);
  }

  Future<void> _toggleReminder(int index, bool val) async {
    setState(() {
      _reminders[index].isEnabled = val;
    });
    await StorageService.saveReminders(_reminders);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final photos = StorageService.getProgressPhotos();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Mode Quick Toggle Card
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (isDark ? AppTheme.darkPrimary : AppTheme.primary).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isDark ? Icons.dark_mode : Icons.light_mode,
                            color: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Karanlık Mod (Dark Mode)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? AppTheme.darkText : AppTheme.textDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                isDark ? 'OLED Koyu Tema Açık' : 'Açık Tema Aktif',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: widget.isDarkMode,
                    activeThumbColor: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                    onChanged: (val) => widget.onToggleTheme(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🏆 Kişisel Rekorlar (PR Vitrini)
            Container(
              width: double.infinity,
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF70A6).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('🏆', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Kişisel Rekorlarım (PR)',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkText : AppTheme.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _personalRecords.isEmpty
                      ? Text(
                          'Henüz tamamlanmış set kaydı bulunmuyor. Ağırlık kaldırdıkça burada en iyi dereceleriniz listelenecek!',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                          ),
                        )
                      : Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _personalRecords.map((pr) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.darkPrimary.withValues(alpha: 0.12)
                                    : AppTheme.primaryLight.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: (isDark ? AppTheme.darkPrimary : AppTheme.primary).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pr.exerciseName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isDark ? AppTheme.darkText : AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${pr.maxWeight.toInt()} kg',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '(${pr.reps} tekrar)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 📏 Vücut Ölçüleri & Fotoğraflar Hızlı Giriş Kartı
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.secondary.withValues(alpha: 0.2) : AppTheme.secondaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.straighten,
                          color: isDark ? AppTheme.secondary : AppTheme.secondaryDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Vücut Gelişimi Takibi',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkText : AppTheme.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showAddMeasurementDialog,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Ölçü Kaydet'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? AppTheme.secondary : AppTheme.secondaryDark,
                            side: BorderSide(
                              color: (isDark ? AppTheme.secondary : AppTheme.secondary).withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showAddPhotoDialog,
                          icon: const Icon(Icons.camera_alt, size: 18),
                          label: const Text('Form Fotoğrafı'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (photos.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Son Form Fotoğrafları',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: photos.length,
                        itemBuilder: (context, index) {
                          final p = photos[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 120,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkBackground : AppTheme.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('dd MMM yyyy').format(p.date),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: isDark ? AppTheme.darkText : AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  p.note,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Form Cards
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
                      Expanded(
                        child: Text(
                          'Kişisel Bilgiler & Hedefler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkText : AppTheme.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _recalculateGoals(notify: true),
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: const Text('Otomatik Hesapla', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 🎯 Hedef Seçimi (Fitness Goal Selection)
                  Text(
                    '🎯 Fitness Hedefiniz',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? AppTheme.darkText : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Seçtiğiniz hedefe göre günlük protein ve kalori ihtiyacınız otomatik optimize edilir.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Goal Cards Grid
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _goalOptions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final goal = _goalOptions[index];
                      final isSelected = _selectedGoal == goal['id'];

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedGoal = goal['id'] as String;
                          });
                          _recalculateGoals(notify: true);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? AppTheme.darkPrimary.withValues(alpha: 0.18)
                                    : AppTheme.primaryLight.withValues(alpha: 0.45))
                                : (isDark ? AppTheme.darkBackground : AppTheme.background),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? AppTheme.darkPrimary : AppTheme.primary)
                                  : (isDark ? AppTheme.darkBorder : AppTheme.border),
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(goal['icon'] as String, style: const TextStyle(fontSize: 26)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            goal['title'] as String,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: isSelected
                                                  ? (isDark ? AppTheme.darkPrimary : AppTheme.primaryDark)
                                                  : (isDark ? AppTheme.darkText : AppTheme.textDark),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? (isDark ? AppTheme.darkPrimary : AppTheme.primary)
                                                : (isDark ? Colors.white12 : Colors.grey.shade200),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            goal['multiplierText'] as String,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? (isDark ? Colors.black : Colors.white)
                                                  : (isDark ? AppTheme.darkTextLight : AppTheme.textLight),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      goal['desc'] as String,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Body Metrics Row: Boy & Kilo
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Boy (cm)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (val) => val == null || val.isEmpty ? 'Boy giriniz' : null,
                              onChanged: (_) => _recalculateGoals(notify: false),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kilo (kg)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _weightController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                              validator: (val) => val == null || val.isEmpty ? 'Kilo giriniz' : null,
                              onChanged: (_) => _recalculateGoals(notify: false),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Age & Gender Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yaş',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (val) => val == null || val.isEmpty ? 'Yaş giriniz' : null,
                              onChanged: (_) => _recalculateGoals(notify: false),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cinsiyet',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedGender,
                              dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                              items: const [
                                DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                                DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedGender = val);
                                  _recalculateGoals(notify: true);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Activity level dropdown
                  Text(
                    'Aktivite Seviyesi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<double>(
                    initialValue: _selectedActivityMultiplier,
                    isExpanded: true,
                    dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                    items: _activityLevels.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedActivityMultiplier = val);
                        _recalculateGoals(notify: true);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // 📊 Optimize Edilmiş Günlük Hedefler Başlığı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '📊 Günlük Beslenme Hedefleri',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkText : AppTheme.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDark ? AppTheme.secondary : AppTheme.secondary).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Hedefe Uygun',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.secondary : AppTheme.secondaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Daily Protein Goal Input
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Günlük Protein Hedefi (g)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _proteinGoalController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (val) => val == null || val.isEmpty ? 'Protein hedefi giriniz' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Günlük Kalori Hedefi (kcal)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _calorieGoalController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (val) => val == null || val.isEmpty ? 'Kalori hedefi giriniz' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Daily Water Goal input
                  Text(
                    'Günlük Su Hedefi (ml) [Kilo × 35 ml]',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _waterGoalController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (val) => val == null || val.isEmpty ? 'Su hedefi boş olamaz' : null,
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Hedefleri Kaydet ve Güncelle'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Reminders Card
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
                      Expanded(
                        child: Text(
                          'Akıllı Protein Alarmları',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkText : AppTheme.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addReminder,
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belirttiğiniz bu saatlerde protein alımınız hedeflenen eşiğin altındaysa akıllı uyarı bildirimi alacaksınız.',
                    style: TextStyle(
                      color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _reminders.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'Hatırlatıcı tanımlanmamış.',
                              style: TextStyle(
                                color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _reminders.length,
                          itemBuilder: (context, index) {
                            final rem = _reminders[index];
                            final timeStr = '${rem.hour.toString().padLeft(2, '0')}:${rem.minute.toString().padLeft(2, '0')}';
                            
                            return Card(
                              color: isDark ? AppTheme.darkBackground : AppTheme.background,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: Icon(Icons.alarm, color: isDark ? AppTheme.darkPrimary : AppTheme.primary),
                                title: Text(
                                  timeStr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark ? AppTheme.darkText : AppTheme.textDark,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Switch(
                                      value: rem.isEnabled,
                                      activeThumbColor: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                                      onChanged: (val) => _toggleReminder(index, val),
                                    ),
                                    IconButton(
                                      onPressed: () => _deleteReminder(index),
                                      icon: const Icon(Icons.delete_outline, color: AppTheme.accent),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Data Management Card (Backup & Restore)
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
                    'Veri Yönetimi (Yedekleme)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkText : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tüm antrenman geçmişinizi, PR rekorlarınızı, vücut ölçülerinizi ve yemek kayıtlarınızı cihazınıza yedekleyin.',
                    style: TextStyle(
                      color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _exportBackup,
                          icon: const Icon(Icons.download),
                          label: const Text('Yedekle (JSON)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppTheme.secondary : AppTheme.secondaryDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _importBackup,
                          icon: const Icon(Icons.upload),
                          label: const Text('Yükle'),
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
              ),
            ),
            const SizedBox(height: 24),
            
            // Database Reset Card
            Center(
              child: TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
                      title: const Text('Verileri Sıfırla?'),
                      content: const Text('Tüm antrenman, ölçü ve yemek geçmişiniz silinecektir. Bu işlem geri alınamaz.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onDataReset();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tüm veriler sıfırlandı.')),
                            );
                          },
                          child: const Text('Evet, Sıfırla', style: TextStyle(color: AppTheme.accent)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.restart_alt, color: AppTheme.accent),
                label: const Text('Verileri Sıfırla', style: TextStyle(color: AppTheme.accent)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
