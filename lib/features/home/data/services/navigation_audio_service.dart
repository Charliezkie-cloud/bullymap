import 'package:bullymap/features/home/models/navigation_step.dart';
import 'package:flutter/foundation.dart';

class NavigationAudioService {
  static final Map<String, String> _customAssetMap = {};

  static const Map<String, String> defaultAssets = {
    'turn-right': 'assets/audio/turn_right.mp3',
    'turn-left': 'assets/audio/turn_left.mp3',
    'turn-slight-right': 'assets/audio/slight_right.mp3',
    'turn-slight-left': 'assets/audio/slight_left.mp3',
    'turn-sharp-right': 'assets/audio/sharp_right.mp3',
    'turn-sharp-left': 'assets/audio/sharp_left.mp3',
    'uturn': 'assets/audio/uturn.mp3',
    'arrive': 'assets/audio/arrive.mp3',
    'depart': 'assets/audio/depart.mp3',
    'straight': 'assets/audio/straight.mp3',
  };

  static Future<void> Function(String assetPath, String fallbackText)?
  audioPlayerHandler;

  static void registerCustomAudio(String key, String assetPath) {
    _customAssetMap[key] = assetPath;
  }

  static String? getAssetPath(NavigationStep step) {
    final type = step.type?.toLowerCase() ?? '';
    final modifier = step.modifier?.toLowerCase() ?? '';

    String? key;
    if (type == 'arrive' || type == 'depart') {
      key = type;
    } else if (modifier.contains('uturn')) {
      key = 'uturn';
    } else if (modifier.contains('sharp right')) {
      key = 'turn-sharp-right';
    } else if (modifier.contains('sharp left')) {
      key = 'turn-sharp-left';
    } else if (modifier.contains('slight right')) {
      key = 'turn-slight-right';
    } else if (modifier.contains('slight left')) {
      key = 'turn-slight-left';
    } else if (modifier.contains('right')) {
      key = 'turn-right';
    } else if (modifier.contains('left')) {
      key = 'turn-left';
    } else if (modifier.contains('straight')) {
      key = 'straight';
    }

    if (key == null) return null;
    return _customAssetMap[key] ?? defaultAssets[key];
  }

  static Future<void> announce(NavigationStep step) async {
    final assetPath = getAssetPath(step);
    final text = step.instruction;

    if (audioPlayerHandler != null && assetPath != null) {
      await audioPlayerHandler!(assetPath, text);
    } else {
      debugPrint('[Voice Guidance] $text (Asset: $assetPath)');
    }
  }
}
