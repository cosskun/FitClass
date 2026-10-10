import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RestTimerDock extends StatelessWidget {
  final int secondsRemaining;
  final int totalDuration;
  final bool isActive;
  final bool isRunning;
  final Function(int seconds) onStartTimer;
  final VoidCallback onPauseResume;
  final VoidCallback onCancel;

  const RestTimerDock({
    super.key,
    required this.secondsRemaining,
    required this.totalDuration,
    required this.isActive,
    required this.isRunning,
    required this.onStartTimer,
    required this.onPauseResume,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Active Timer Banner (Floating Dock)
        if (isActive)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFF1F5F9), Colors.white],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.darkPrimary.withValues(alpha: 0.5) : AppTheme.primaryLight,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: totalDuration > 0 ? (secondsRemaining / totalDuration) : 0,
                        strokeWidth: 4,
                        backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppTheme.darkPrimary : AppTheme.primary,
                        ),
                      ),
                      Center(
                        child: Text(
                          '$secondsRemaining',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkText : AppTheme.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '⏱️ Dinlenme Süresi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? AppTheme.darkText : AppTheme.textDark,
                        ),
                      ),
                      Text(
                        isRunning ? 'Geri sayım sürüyor...' : 'Duraklatıldı',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onPauseResume,
                  icon: Icon(
                    isRunning ? Icons.pause_circle_outline : Icons.play_circle_outline,
                    color: isDark ? AppTheme.darkPrimary : AppTheme.primary,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close, size: 20, color: AppTheme.accent),
                ),
              ],
            ),
          ),

        // Quick Timer Buttons Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Sayaç:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextLight : AppTheme.textLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [30, 60, 90, 120, 180].map((s) {
                      final isSelected = totalDuration == s && isActive;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => onStartTimer(s),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? AppTheme.darkPrimary : AppTheme.primary)
                                  : (isDark ? AppTheme.darkSurface : Colors.white),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? AppTheme.darkBorder : AppTheme.border,
                              ),
                            ),
                            child: Text(
                              '${s}s',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? (isDark ? Colors.black : Colors.white)
                                    : (isDark ? AppTheme.darkText : AppTheme.textDark),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
