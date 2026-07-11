import 'package:dio/dio.dart';

import 'api_constants.dart';

class DioClient {
  DioClient._();

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(minutes: ApiConstants.timeOut),
      receiveTimeout: null,
      sendTimeout: const Duration(minutes: ApiConstants.timeOut),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
}