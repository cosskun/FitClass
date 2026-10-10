import 'package:flutter/material.dart';
import '../../core/utils/plate_calculator.dart';
import '../../theme/app_theme.dart';

class PlateCalculatorDialog extends StatefulWidget {
  const PlateCalculatorDialog({super.key});

  static Future<void> show(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const PlateCalculatorDialog(),
    );
  }

  @override
  State<PlateCalculatorDialog> createState() => _PlateCalculatorDialogState();
}

class _PlateCalculatorDialogState extends State<PlateCalculatorDialog> {
  double _targetWeight = 50.0;
  double _barWeight = 20.0; // Standard Olympic Bar

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = PlateCalculator.calculate(
      targetWeight: _targetWeight,
      barWeight: _barWeight,
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Indicator Bar
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkPrimary.withValues(alpha: 0.2) : AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.calculate_outlined,
                          color: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Bar Plaka Hesaplayıcı',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkText : AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Target Weight Selector
              Text(
                'Hedef Toplam Ağırlık: ${_targetWeight.toInt()} kg',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? AppTheme.darkText : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [40, 50, 60, 70, 80, 90, 100, 120, 140].map((w) {
                  final selected = _targetWeight == w.toDouble();
                  return ChoiceChip(
                    label: Text('$w kg'),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        _targetWeight = w.toDouble();
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Bar Weight Selector
              Text(
                'Bar Tipi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('20 kg (Olimpik)'),
                      selected: _barWeight == 20.0,
                      onSelected: (val) => setState(() => _barWeight = 20.0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('10 kg (EZ Bar)'),
                      selected: _barWeight == 10.0,
                      onSelected: (val) => setState(() => _barWeight = 10.0),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Results Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkPrimary.withValues(alpha: 0.12)
                      : AppTheme.primaryLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: (isDark ? AppTheme.darkPrimary : AppTheme.primary).withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Her Bir Tarafa Takılacak: ${result.weightPerSide.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkPrimary : AppTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    result.platesPerSide.isEmpty
                        ? const Text(
                            'Sadece boş bar yeterli.',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: result.platesPerSide.entries.map((entry) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkSurface : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${entry.value}x ${entry.key} kg',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isDark ? AppTheme.darkText : AppTheme.textDark,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
