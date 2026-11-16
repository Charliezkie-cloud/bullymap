import 'package:bullymap/features/home/data/models/navigation_step.dart';
import 'package:bullymap/features/home/data/services/navigation_voice_service.dart';
import 'package:flutter/foundation.dart';

class NavigationAudioService {
  static Future<void> Function(String assetPath, String fallbackText)? audioPlayerHandler;

  static Future<void> announce(NavigationStep step) async {
    final assetPath = await NavigationVoiceService.pickAssetPath(step);
    if (assetPath == null) {
      debugPrint('[Voice Guidance] ${step.instruction} (no asset)');
      return;
    }

    await (audioPlayerHandler ?? NavigationVoiceService.play)(assetPath, step.instruction);
  }

  static Future<void> announceWrongTurn(NavigationStep? scheduledStep) async {
    final assetPath = await NavigationVoiceService.pickWrongTurnAsset(scheduledStep?.modifier);
    if (assetPath == null) return;

    await (audioPlayerHandler ?? NavigationVoiceService.playAndWait)(
      assetPath,
      'Wrong turn',
    );
  }
}
