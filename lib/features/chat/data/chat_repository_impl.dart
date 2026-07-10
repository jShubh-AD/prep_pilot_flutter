import 'dart:async';
import 'dart:convert';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import '../domain/chat_repository.dart';
import '../domain/entities/done_event.dart';
import '../domain/repositories/chat_repository.dart';
import 'datasources/chat_remote_datasource.dart';
import 'datasources/chat_local_datasource.dart';
import 'models/token_event_model.dart';
import 'models/done_event_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Stream<ChatStreamEvent> querySubject({
    required String query,
    required int subjectId,
    String? sessionId,
    String format = "text",
  }) {
    return remoteDataSource
        .querySubject(
          query: query,
          subjectId: subjectId,
          sessionId: sessionId,
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

  @override
  Future<void> saveSessionInfo({
    required String sessionId,
    required int tokensUsed,
    required int tokensAvailable,
    required double totalTime,
  }) async {
    await localDataSource.saveSessionInfo(
      sessionId: sessionId,
      tokensUsed: tokensUsed,
      tokensAvailable: tokensAvailable,
      totalTime: totalTime,
    );
  }

  @override
  Future<DoneEvent?> getLatestSession() async {
    return await localDataSource.getLatestSession();
  }
}
