import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';

class ProgressPhotoDialog extends StatefulWidget {
  final VoidCallback? onSaved;

  const ProgressPhotoDialog({
    super.key,
    this.onSaved,
  });

  static Future<void> show(BuildContext context, {VoidCallback? onSaved}) {
    return showDialog(
      context: context,
      builder: (context) => ProgressPhotoDialog(onSaved: onSaved),
    );
  }

  @override
  State<ProgressPhotoDialog> createState() => _ProgressPhotoDialogState();
}

class _ProgressPhotoDialogState extends State<ProgressPhotoDialog> {
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _savePhoto() async {
    final photo = ProgressPhoto(
      id: 'photo_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      imagePath: 'assets/images/exercises/bench_press.png',
      note: _noteCtrl.text.trim().isEmpty ? 'Form Güncellemesi' : _noteCtrl.text.trim(),
    );

    await StorageService.addProgressPhoto(photo);
    if (mounted) {
      widget.onSaved?.call();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form fotoğrafı kaydedildi!')),
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
        'Form Fotoğrafı Ekle',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? AppTheme.darkText : AppTheme.textDark,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkBackground : AppTheme.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo_outlined,
                  size: 40,
                  color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Kamera veya Galeriden Seç',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(labelText: 'Fotoğraf Notu (Örn: 1. Ay Sonu - 80kg)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _savePhoto,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
