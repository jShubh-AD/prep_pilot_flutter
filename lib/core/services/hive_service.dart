import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static final String sessionBoxName = 'session_box';

  static Future<void> hiveInit() async{
    await Hive.initFlutter();
    await Hive.openBox(sessionBoxName);
  }

  static Box get sessionBox => Hive.box(sessionBoxName);
}