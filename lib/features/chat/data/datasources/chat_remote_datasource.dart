import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
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
  @override
  Stream<SSEModel> querySubject({
    required String query,
    required int subjectId,
    String? sessionId,
    String format = "text",
  }) {
    return SSEClient.subscribeToSSE(
      method: SSERequestType.POST,
      url: '${ApiConstants.baseUrl}/chats/query',
      header: {
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      },

      body: {
        'query': query,
        'subject_id': subjectId,
        'session_id': sessionId,
        'format': format,
      },
    );
  }
}
