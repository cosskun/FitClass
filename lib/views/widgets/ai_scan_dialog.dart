import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AIScanDialog extends StatefulWidget {
  final bool isCamera;
  final Function(String name, double protein, double calories) onAnalysisCompleted;

  const AIScanDialog({
    super.key,
    required this.isCamera,
    required this.onAnalysisCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isCamera,
    required Function(String name, double protein, double calories) onAnalysisCompleted,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AIScanDialog(
        isCamera: isCamera,
        onAnalysisCompleted: onAnalysisCompleted,
      ),
    );
  }

  @override
  State<AIScanDialog> createState() => _AIScanDialogState();
}

class _AIScanDialogState extends State<AIScanDialog> {
  int _currentStep = 0;
  String _statusText = 'Fotoğraf taranıyor ve analiz ediliyor...';

  final List<Map<String, dynamic>> _mockDetections = [
    {
      'name': '1 Adet Lahmacun (120g) + Yeşillik & Limon',
      'protein': 14.0,
      'calories': 260.0,
    },
    {
      'name': 'Izgara Tavuk Göğsü (160g) + Bulgur Pilavı (120g)',
      'protein': 48.0,
      'calories': 420.0,
    },
    {
      'name': 'Adana Kebap (140g) + Közlenmiş Biber & Domates',
      'protein': 30.0,
      'calories': 520.0,
    },
    {
      'name': 'Fıstık Ezmeli Yulaf Lapası (80g Yulaf + 30g Fıstık Ezmesi)',
      'protein': 18.5,
      'calories': 460.0,
    },
  ];

  late Map<String, dynamic> _selectedResult;

  @override
  void initState() {
    super.initState();
    _selectedResult = _mockDetections[Random().nextInt(_mockDetections.length)];
    _runSimulation();
  }

  void _runSimulation() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _currentStep = 1;
      _statusText = 'Yapay Zeka optik nesne ve yemek türlerini ayrıştırıyor...';
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _currentStep = 2;
      _statusText = 'Gramaj ve makro besin değerleri hesaplanıyor...';
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _currentStep = 3;
      _statusText = 'Analiz Tamamlandı!';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentStep < 3) ...[
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppTheme.darkPrimary : AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Yapay Zeka Taraması 🤖',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? AppTheme.darkText : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _statusText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                fontSize: 13,
              ),
            ),
          ] else ...[
            Container(
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.secondary : AppTheme.secondary).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(16),
              child: Icon(
                Icons.check,
                color: isDark ? AppTheme.secondary : AppTheme.secondaryDark,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Yemek Tespit Edildi! ✨',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? AppTheme.darkText : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBackground : AppTheme.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _selectedResult['name'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? AppTheme.darkText : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Kalori',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                            ),
                          ),
                          Text(
                            '${_selectedResult['calories'].toInt()} kcal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? AppTheme.secondary : AppTheme.secondaryDark,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: isDark ? AppTheme.darkBorder : AppTheme.border,
                      ),
                      Column(
                        children: [
                          Text(
                            'Protein',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                            ),
                          ),
                          Text(
                            '${_selectedResult['protein']} g',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('İptal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onAnalysisCompleted(
                        _selectedResult['name'],
                        _selectedResult['protein'],
                        _selectedResult['calories'],
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Öğüne Ekle'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
