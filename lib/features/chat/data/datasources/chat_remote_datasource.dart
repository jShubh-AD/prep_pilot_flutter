import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/core/services/hive_service.dart';
import 'package:sse_stream/sse_stream.dart';
import '../../../../core/network/api_constants.dart';
import '../models/done_event_model.dart';

class ChatRemoteDataSource {
  final dio = DioClient.instance;
  final _sessionBox = HiveService.sessionBox;
  Stream<SseEvent> sendSubjectQuery({
    required String query,
    required int subjectId,
    String? sessionId,
    String format = "text",
  }) async* {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}/chats/query',
        data: {
          'query': query,
          'subject_id': subjectId,
          'session_id': sessionId,
          'format': format,
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
          },
        ),
      );

      final responseBody = response.data as ResponseBody;

      await for (final event in responseBody.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const SseEventTransformer())) {
        yield event;
      }
    } on DioException catch (e, st) {
      log(
        "",
        name: "Error",
        error: e,
        stackTrace: st,
      );

      final statusCode = e.response?.statusCode ?? 500;
      String message = e.message ?? "Unknown error";

      if (e.response?.data is ResponseBody) {
        try {
          final responseBody = e.response!.data as ResponseBody;

          final body = await responseBody.stream
              .cast<List<int>>()
              .transform(utf8.decoder)
              .join();

          final json = jsonDecode(body);
          message = json["detail"] ?? message;
        } catch (_) {
          // Keep the default message.
        }
      }

      if (statusCode == 503) {
        throw ExceededFreeLimit(
          statusCode: statusCode,
          message: message,
        );
      }

      throw ServerFailure(
        statusCode: statusCode,
        message: message,
      );
    } catch (e, st) {
      log(
        "",
        name: "Error",
        error: e,
        stackTrace: st,
      );

      throw Exception(e.toString());
    }
  }

  Future<void> saveSession({
    required String sessionId,
    required int tokensUsed,
    required int tokensAvailable,
    required double totalTime,
  }) async {
    await _sessionBox.put(sessionId, {
      'session_id': sessionId,
      'tokens_used': tokensUsed,
      'tokens_available': tokensAvailable,
      'total_time': totalTime,
    });
  }

  Future<DoneEventModel?> getLastSession() async {
    if (_sessionBox.isEmpty) return null;
    final lastEntry = _sessionBox.values.last;
    if (lastEntry is Map) {
      final Map<String, dynamic> json = Map<String, dynamic>.from(lastEntry);
      json['total_time'] ??= 0.0;
      return DoneEventModel.fromJson(json);
    }
    return null;
  }
}
