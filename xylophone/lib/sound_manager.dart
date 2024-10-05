// lib/sound_manager.dart
import 'package:audioplayers/audioplayers.dart';
class SoundManager {
  final AudioPlayer _player = AudioPlayer();
  void playSound(int soundNumber) {
    _player.play(AssetSource('audio/note$soundNumber.mp3'));
  }
}