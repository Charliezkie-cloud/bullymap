import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:bullymap/features/home/data/models/navigation_step.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NavigationVoiceService {
  // Constants
  static const Map<String, Map<String, String>> _voiceFolders = {
    'david': {
      'turn-right': 'assets/audio/english/david/turn_right/',
      'turn-left': 'assets/audio/english/david/turn_left/',
      'arrive': 'assets/audio/english/david/destination_arrived/',
      'wrong-turn': 'assets/audio/english/david/wrong_turns/',
      'comments': 'assets/audio/english/david/comments/',
    },
    'yas': {
      'turn-right': 'assets/audio/english/yas/turn_right/',
      'arrive': 'assets/audio/english/yas/destination_arrived/',
      'wrong-turn': 'assets/audio/english/yas/wrong_turns/',
      'comments': 'assets/audio/english/yas/comments/',
      'start': 'assets/audio/english/yas/just_got_in_car/',
    },
  };

  // Notifiers
  static final ValueNotifier<bool> isMuted = ValueNotifier(false);

  // States
  static String _voice = 'david';
  static final Map<String, List<String>> _folderAssets = {};
  static final Map<String, String> _lastPlayed = {};
  static final AudioPlayer _player = AudioPlayer();
  static final Random _random = Random();
  static const Duration _maxPlaybackWait = Duration(seconds: 8);
  static const Duration _commentaryGap = Duration(seconds: 45);
  static const Duration _commentaryJitter = Duration(seconds: 15);
  static const Duration _guidanceCooldown = Duration(seconds: 3);
  static Timer? _commentaryTimer;
  static bool _commentaryEnabled = false;
  static bool _isCommentaryPlaying = false;
  static DateTime? _lastGuidanceAt;

  // Methods
  static void setVoice(String voice) {
    _voice = voice;
  }

  static Future<void> toggleMute() async {
    isMuted.value = !isMuted.value;
    if (!isMuted.value) return;

    _isCommentaryPlaying = false;
    await _player.stop();
  }

  static Future<String?> pickAssetPath(NavigationStep step) async {
    final folders = _voiceFolders[_voice];
    if (folders == null) return null;

    final category = _categoryOf(step);
    final folder = category == null ? null : folders[category];
    if (folder == null) return null;

    final assets = await _assetsIn(folder);
    return _pickUnrepeated(folder, assets);
  }

  static Future<String?> pickWrongTurnAsset(String? modifier) async {
    final folder = _voiceFolders[_voice]?['wrong-turn'];
    if (folder == null) return null;

    final assets = await _assetsIn(folder);
    final turn = _turnOf(modifier);
    // Most lines scold a specific direction, so drop the ones naming the
    // opposite turn; the directionless lines stay usable either way.
    final candidates = turn == null
        ? assets
        : assets
              .where((asset) => !asset.contains(_oppositeTurn(turn)))
              .toList();
    return _pickUnrepeated(folder, candidates);
  }

  static String? _pickUnrepeated(String folder, List<String> candidates) {
    if (candidates.isEmpty) return null;

    // Never play the same line twice in a row, so repeats still sound random.
    final lastPlayed = _lastPlayed[folder];
    final pool = candidates.length > 1 && candidates.contains(lastPlayed)
        ? candidates.where((asset) => asset != lastPlayed).toList()
        : candidates;
    final picked = pool[_random.nextInt(pool.length)];
    _lastPlayed[folder] = picked;
    return picked;
  }

  static Future<String?> pickCommentaryAsset() async {
    final folder = _voiceFolders[_voice]?['comments'];
    if (folder == null) return null;

    final assets = await _assetsIn(folder);
    return _pickUnrepeated(folder, assets);
  }

  static void startCommentary() {
    _commentaryTimer?.cancel();
    _commentaryEnabled = true;
    unawaited(_playStartLine());
    _scheduleCommentary();
  }

  static Future<void> stopCommentary() async {
    _commentaryEnabled = false;
    _commentaryTimer?.cancel();
    _commentaryTimer = null;

    if (_isCommentaryPlaying && _player.state == PlayerState.playing) {
      await _player.stop();
      _isCommentaryPlaying = false;
    }
  }

  static Future<void> _playStartLine() async {
    if (isMuted.value) return;

    final folder = _voiceFolders[_voice]?['start'];
    if (folder == null) return;

    final assets = await _assetsIn(folder);
    if (assets.isEmpty || !_commentaryEnabled) return;
    if (_player.state == PlayerState.playing) return;

    _isCommentaryPlaying = true;
    try {
      final assetPath = assets[_random.nextInt(assets.length)];
      await _player.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (error) {
      _isCommentaryPlaying = false;
      debugPrint('[Voice Guidance] start commentary ($error)');
    }
  }

  static void _scheduleCommentary() {
    final jitter = Duration(
      seconds: _random.nextInt(_commentaryJitter.inSeconds),
    );
    _commentaryTimer = Timer(_commentaryGap + jitter, () async {
      await _playCommentaryIfIdle();
      if (_commentaryEnabled) _scheduleCommentary();
    });
  }

  static Future<void> _playCommentaryIfIdle() async {
    if (isMuted.value) return;

    // Turn prompts own the shared player while they play, so commentary skips
    // instead of talking over them.
    if (_player.state == PlayerState.playing) return;

    final lastGuidanceAt = _lastGuidanceAt;
    if (lastGuidanceAt != null &&
        DateTime.now().difference(lastGuidanceAt) < _guidanceCooldown) {
      return;
    }

    final assetPath = await pickCommentaryAsset();
    if (assetPath == null) return;

    // A turn prompt may have started while the asset list was loading.
    if (_player.state == PlayerState.playing) return;

    _isCommentaryPlaying = true;
    try {
      await _player.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (error) {
      _isCommentaryPlaying = false;
      debugPrint('[Voice Guidance] commentary ($error)');
    }
  }

  static Future<void> play(String assetPath, String fallbackText) async {
    if (isMuted.value) return;

    _lastGuidanceAt = DateTime.now();
    _isCommentaryPlaying = false;
    try {
      // This also cuts off a commentary line, so guidance always wins.
      await _player.stop();
      await _player.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (error) {
      debugPrint('[Voice Guidance] $fallbackText ($error)');
    }
  }

  static Future<void> playAndWait(String assetPath, String fallbackText) async {
    if (isMuted.value) return;

    _lastGuidanceAt = DateTime.now();
    _isCommentaryPlaying = false;
    try {
      await _player.stop();
      final completed = _player.onPlayerComplete.first;
      await _player.play(AssetSource(assetPath.replaceFirst('assets/', '')));
      await completed.timeout(_maxPlaybackWait);
    } catch (error) {
      debugPrint('[Voice Guidance] $fallbackText ($error)');
    }
  }

  static String? _categoryOf(NavigationStep step) {
    final type = step.type?.toLowerCase() ?? '';

    if (type == 'arrive') return 'arrive';

    final turn = _turnOf(step.modifier);
    if (turn == 'right') return 'turn-right';
    if (turn == 'left') return 'turn-left';
    return null;
  }

  static String? _turnOf(String? modifier) {
    final value = modifier?.toLowerCase() ?? '';
    if (value.contains('right')) return 'right';
    if (value.contains('left')) return 'left';
    return null;
  }

  static String _oppositeTurn(String turn) => turn == 'left' ? 'right' : 'left';

  static Future<List<String>> _assetsIn(String folder) async {
    final cached = _folderAssets[folder];
    if (cached != null) return cached;

    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets =
        manifest
            .listAssets()
            .where(
              (asset) => asset.startsWith(folder) && asset.endsWith('.mp3'),
            )
            .toList()
          ..sort();
    _folderAssets[folder] = assets;
    return assets;
  }
}
