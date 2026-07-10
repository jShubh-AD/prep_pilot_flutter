import 'dart:convert';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_constants.dart';

abstract class ChatRemoteDataSource {
  Stream<SSEModel> querySubject({
    required String query,
    required int subjectId,
    String? sessionId,
    String format = "text",
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client _client;

  ChatRemoteDataSourceImpl(this._client);

  @override
  Stream<SSEModel> querySubject({
    required String query,
    required int subjectId,
    String? sessionId,
    String format = "text",
  }) async* {
    final request = http.Request(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/chats/query'),
    );
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
    });
    request.body = jsonEncode({
      'query': query,
      'subject_id': subjectId,
      'session_id': sessionId,
      'format': format,
    });

    final streamedResponse = await _client.send(request);

    // Check status BEFORE treating the body as an SSE stream
    if (streamedResponse.statusCode != 200) {
      final errorBody = await streamedResponse.stream.bytesToString();
      String message;
      try {
        final decoded = jsonDecode(errorBody);
        message = decoded['detail'] ?? decoded['message'] ?? errorBody;
      } catch (_) {
        message = errorBody;
      }
      throw Exception(message);
    }

    // Only now do we parse it as SSE
    String buffer = '';
    await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
      buffer += chunk;
      final lines = buffer.split('\n');
      buffer = lines.removeLast(); // keep incomplete line in buffer

      String? event;
      String? data;
      for (final line in lines) {
        if (line.startsWith('event:')) {
          event = line.substring(6).trim();
        } else if (line.startsWith('data:')) {
          data = line.substring(5).trim();
        } else if (line.isEmpty && data != null) {
          yield SSEModel(event: event ?? 'message', data: data);
          event = null;
          data = null;
        }
      }
    }
  }
}
