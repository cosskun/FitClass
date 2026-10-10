import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  AudioPlayer? _player;
  bool _isInitialized = false;

  Future<void> _initPlayer() async {
    if (_isInitialized) return;
    try {
      _player = AudioPlayer();
      await _player?.setReleaseMode(ReleaseMode.stop);
      _isInitialized = true;
    } catch (e) {
      debugPrint('SoundService: Failed to initialize AudioPlayer: $e');
    }
  }

  /// Plays the workout rest timer completion sound accompanied by haptic feedback.
  Future<void> playTimerComplete() async {
    // 1. Trigger energetic haptic feedback pattern
    try {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 250), () => HapticFeedback.heavyImpact());
      Future.delayed(const Duration(milliseconds: 500), () => HapticFeedback.vibrate());
    } catch (e) {
      debugPrint('SoundService: Haptic error: $e');
    }

    // 2. Play the synthesized multi-tone chime
    try {
      if (!_isInitialized) {
        await _initPlayer();
      }

      if (_player != null) {
        await _player?.stop();
        await _player?.play(AssetSource('sounds/timer_complete.wav'));
        return;
      }
    } catch (e) {
      debugPrint('SoundService: AudioPlayer play error: $e. Falling back to SystemSound.');
    }

    // 3. Fallback: Native OS Alert Sound
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      debugPrint('SoundService: SystemSound error: $e');
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
    _isInitialized = false;
  }
}
