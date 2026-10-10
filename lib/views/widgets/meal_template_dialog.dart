import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';

class MealTemplateDialog extends StatefulWidget {
  const MealTemplateDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const MealTemplateDialog(),
    );
  }

  @override
  State<MealTemplateDialog> createState() => _MealTemplateDialogState();
}

class _MealTemplateDialogState extends State<MealTemplateDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _calController = TextEditingController();
  final _protController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _calController.dispose();
    _protController.dispose();
    super.dispose();
  }

  Future<void> _saveTemplate() async {
    final title = _titleController.text.trim();
    final cal = double.tryParse(_calController.text.trim()) ?? 0;
    final prot = double.tryParse(_protController.text.trim()) ?? 0;

    if (title.isEmpty) return;

    final newTmpl = MealTemplate(
      id: 'tmpl_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: _descController.text.trim(),
      calories: cal,
      protein: prot,
    );

    await StorageService.addMealTemplate(newTmpl);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Öğün şablonu başarıyla kaydedildi!')),
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
        'Yeni Öğün Şablonu',
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
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Şablon Başlığı (Örn: Klasik Kahvaltım)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Açıklama / İçerik (İsteğe bağlı)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _calController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Toplam Kalori (kcal)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _protController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Toplam Protein (g)'),
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
          onPressed: _saveTemplate,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
