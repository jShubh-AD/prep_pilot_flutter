import 'dart:convert';

import 'package:flutter_sound/flutter_sound.dart';
import 'dart:typed_data';

class AudioPlayerService {
  AudioPlayerService._();
  static final AudioPlayerService instance = AudioPlayerService._();
  factory AudioPlayerService() => instance;

  FlutterSoundPlayer? _player;

  bool get isPlaying => _player?.isPlaying ?? false;

  Future<void> initAudioPlayer() async {
    if (_player != null) return;
    _player = FlutterSoundPlayer();
    await _player!.openPlayer();
  }

  Future<void> startStream() async {
    if (_player == null) return;

    if (_player!.isPlaying) {
      await _player!.stopPlayer();
    }

    await _player!.startPlayerFromStream(
      codec: Codec.pcm16,
      sampleRate: 24000,
      numChannels: 1,
      interleaved: false,
      bufferSize: 8192,
    );
  }

  Future<void> playChunk(String base64Audio) async {
    final bytes = base64Decode(base64Audio);
    final pcm = Int16List.view(
      bytes.buffer,
      bytes.offsetInBytes,
      bytes.lengthInBytes ~/ 2,
    );
    _player?.int16Sink?.add([pcm]);
  }

  Future<void> stopStream() async {
    if (_player?.isPlaying ?? false) {
      await _player!.stopPlayer();
    }
  }


  Future<void> dispose() async {
    await _player?.closePlayer();
    _player = null;
  }

}
