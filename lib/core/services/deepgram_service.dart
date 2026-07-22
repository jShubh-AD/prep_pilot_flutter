import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:mobile/core/network/api_constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class DeepgramService {
  DeepgramService._();
  static final instance = DeepgramService._();
  factory DeepgramService() => instance;

  WebSocketChannel? _socket;
  StreamSubscription? _socketSubscription;

  StreamSubscription<Uint8List>? _micSubscription;

  final _transcriptController = StreamController<String>.broadcast();
  Stream<String> get transcriptStream => _transcriptController.stream;

  Future<void> initDg() async{
    await connect();
  }

  Future<void> connect() async {
    if (_socket != null) return;

    final uri = Uri.parse(
      "wss://api.deepgram.com/v1/listen"
          "?model=nova-3"
          "&language=multi"
          "&encoding=linear16"
          "&sample_rate=16000"
          "&channels=1"
          "&interim_results=true"
          "&punctuate=true",
    );
    final headers = {"Authorization": "Token ${ApiConstants.deepgramKey}"};
    _socket = IOWebSocketChannel.connect(uri, headers: headers);
    String _finalTranscript = "";
    String _interimTranscript = "";

    _socketSubscription = _socket!.stream.listen(
          (message) {
        final json = jsonDecode(message);
        final isFinal = json["is_final"] ?? false;
        final transcript = json["channel"]?["alternatives"]?[0]?["transcript"];
        if (transcript.isEmpty) return;
        log(transcript, name: 'DG Transcript');
        if (isFinal) {
          _finalTranscript = _finalTranscript.isEmpty
              ? transcript
              : "$_finalTranscript $transcript";
          _interimTranscript = "";
        } else {
          _interimTranscript = transcript;
        }
        final display = _interimTranscript.isEmpty
            ? _finalTranscript
            : "${_finalTranscript.isEmpty ? "" : "$_finalTranscript "}"
            "$_interimTranscript";

        if (transcript is String) _transcriptController.add(display);
      },
      onError: (error) {
        print("ERROR:$error");
        _transcriptController.addError(error);
      },
      onDone: () {
        print("WebSocket closed");
        print("Close code: ${_socket?.closeCode}");
        print("Close reason: ${_socket?.closeReason}");
        disconnect();
      },
    );
  }

  Future<void> startStreaming(Stream<Uint8List> microphone) async {
    if (_socket == null) {
      log("Connecting with DG.");
      await connect();
    }
    if (_micSubscription != null){
      await _micSubscription!.cancel();
      _micSubscription = null;
    }

    _micSubscription = microphone.listen((chunk){
      _socket!.sink.add(chunk);
    },
      onError: (e)=>  _transcriptController.addError(e),
      cancelOnError: true
    );

  }

  Future<void> stopStreaming() async {
    //  deepgram connection & subscriptions
    await _socket?.sink.close();
    await _socketSubscription?.cancel();
    _socketSubscription = null;
    // mic subscription
    await _micSubscription?.cancel();
    _micSubscription = null;
  }

  Future<void> disconnect() async {
    await stopStreaming();
    await _socketSubscription?.cancel();
    _socketSubscription = null;
    await _socket?.sink.close();
    _socket = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _transcriptController.close();
  }
}