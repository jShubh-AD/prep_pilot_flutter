import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';

class MicrophoneService {
  MicrophoneService._();
  static final instance = MicrophoneService._();
  factory MicrophoneService() => instance;

  final AudioRecorder _recorder = AudioRecorder();
  Stream<Uint8List>? _audioStream; // this holds audio received from mic.
  Stream<Uint8List>? get audioStream => _audioStream; // getter for audioStream

  final _amplitudeController = StreamController<double>.broadcast();
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  Timer? _amplitudeTimer;

  Future<void> startListeningMicrophone() async {
    if (!await _recorder.hasPermission()) {
      throw "Microphone permission denied.";
    }
    final config = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
    );
    _audioStream = await _recorder.startStream(config);
    _startAmplitudeStream();
  }

  void _startAmplitudeStream() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(
      const Duration(milliseconds: 50), (_) async {
        final amplitude = await _recorder.getAmplitude();
        // Convert dB to a usable animation scale.
        final scale = ((amplitude.current + 60) / 60).clamp(0.0, 1.0);
        _amplitudeController.add(scale);
      },
    );
  }

  Future<void> stopListeningMicrophone() async {
    await _recorder.stop();
    _amplitudeTimer = null;
    _audioStream = null;
  }

  Future<void> dispose() async {
    await stopListeningMicrophone();
    await _amplitudeController.close();
    await _recorder.dispose();
  }
}
