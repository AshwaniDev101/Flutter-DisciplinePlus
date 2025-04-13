import 'package:just_audio/just_audio.dart';

// Enum to represent sound effects, including file path
enum SoundEffect {
  success('assets/audio/successed_ting.mp3'),
  error('assets/audio/error_sound_pop.mp3'),        // ← corrected
  notification('assets/audio/chime-sound.mp3');

  final String path;
  const SoundEffect(this.path);
}

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final Map<SoundEffect, AudioPlayer> _players = {};

  // Preload all sounds at startup
  Future<void> init() async {
    for (var sound in SoundEffect.values) {
      final player = AudioPlayer();
      await player.setAsset(sound.path);
      _players[sound] = player;
    }
  }

  // Play a sound
  Future<void> play(SoundEffect effect) async {
    final player = _players[effect];
    if (player != null) {
      await player.seek(Duration.zero);
      await player.play();
    }
  }

  // Clean up
  void dispose() {
    for (var player in _players.values) {
      player.dispose();
    }
  }
}
