import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';

class BodyMeasurementDialog extends StatefulWidget {
  final double initialWeight;
  final VoidCallback? onSaved;

  const BodyMeasurementDialog({
    super.key,
    required this.initialWeight,
    this.onSaved,
  });

  static Future<void> show(BuildContext context, {required double initialWeight, VoidCallback? onSaved}) {
    return showDialog(
      context: context,
      builder: (context) => BodyMeasurementDialog(
        initialWeight: initialWeight,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<BodyMeasurementDialog> createState() => _BodyMeasurementDialogState();
}

class _BodyMeasurementDialogState extends State<BodyMeasurementDialog> {
  late final TextEditingController _wCtrl;
  final _armCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _shoulderCtrl = TextEditingController();
  final _legCtrl = TextEditingController();
  final _hipCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _wCtrl = TextEditingController(
      text: widget.initialWeight > 0 ? widget.initialWeight.toInt().toString() : '',
    );
  }

  @override
  void dispose() {
    _wCtrl.dispose();
    _armCtrl.dispose();
    _waistCtrl.dispose();
    _chestCtrl.dispose();
    _shoulderCtrl.dispose();
    _legCtrl.dispose();
    _hipCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveMeasurement() async {
    final m = BodyMeasurement(
      date: DateTime.now(),
      weight: double.tryParse(_wCtrl.text.replaceAll(',', '.')),
      waist: double.tryParse(_waistCtrl.text.replaceAll(',', '.')),
      arm: double.tryParse(_armCtrl.text.replaceAll(',', '.')),
      chest: double.tryParse(_chestCtrl.text.replaceAll(',', '.')),
      shoulder: double.tryParse(_shoulderCtrl.text.replaceAll(',', '.')),
      leg: double.tryParse(_legCtrl.text.replaceAll(',', '.')),
      hip: double.tryParse(_hipCtrl.text.replaceAll(',', '.')),
    );

    await StorageService.addBodyMeasurement(m);
    if (mounted) {
      widget.onSaved?.call();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vücut ölçüleri günlüğe kaydedildi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Vücut Ölçüsü Ekle',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? AppTheme.darkText : AppTheme.textDark,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _wCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Kilo (kg)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _waistCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Bel Çevresi (cm)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _armCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Kol / Pazu (cm)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _chestCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Göğüs (cm)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _shoulderCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Omuz (cm)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _legCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Bacak / Üst Bacak (cm)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _hipCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Kalça (cm)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveMeasurement,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
