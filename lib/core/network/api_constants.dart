import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // static const String baseUrl = "http://13.201.69.169:8000";
  static const String baseUrl = "http://192.168.1.22:8000";
  static final deepgramKey = dotenv.env['DEEPGRAM_KEY'] ?? '';
  static const int timeOut = 2;
}