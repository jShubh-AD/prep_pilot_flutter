import 'dart:async';
import 'dart:convert';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/token_event_model.dart';
import '../models/done_event_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<ChatStreamEvent> querySubject({
    required String query,
    required int subjectId,
    String format = "text",
  }) {
    return remoteDataSource
        .querySubject(
          query: query,
          subjectId: subjectId,
          format: format,
        )
        .transform<ChatStreamEvent>(
          StreamTransformer<SSEModel, ChatStreamEvent>.fromHandlers(
            handleData: (event, sink) {
              try {
                if (event.event == 'token') {
                  final dataStr = event.data;
                  if (dataStr != null) {
                    final decoded = jsonDecode(dataStr) as Map<String, dynamic>;
                    final token = TokenEventModel.fromJson(decoded);
                    sink.add(ChatStreamToken(token));
                  }
                } else if (event.event == 'done') {
                  final dataStr = event.data;
                  if (dataStr != null) {
                    final decoded = jsonDecode(dataStr) as Map<String, dynamic>;
                    final done = DoneEventModel.fromJson(decoded);
                    sink.add(ChatStreamDone(done));
                  }
                }
              } catch (e) {
                sink.addError(e);
              }
            },
            handleError: (error, stackTrace, sink) {
              sink.addError(error, stackTrace);
            },
          ),
        );
  }
}
