// import 'package:flutter/services.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mobile/main.dart';
//
// void main() {
//   setUpAll(() async {
//     TestWidgetsFlutterBinding.ensureInitialized();
//
//     // Mock path_provider channel for Hive
//     TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
//         .setMockMethodCallHandler(
//       const MethodChannel('plugins.flutter.io/path_provider'),
//       (MethodCall methodCall) async {
//         return '.'; // Return current directory for temporary path
//       },
//     );
//
//     await di.init();
//   });
//
//   testWidgets('Dashboard basic smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(const MyApp());
//
//     // Verify that the title "PrepPilot" is present.
//     expect(find.text('PrepPilot'), findsOneWidget);
//
//     // Verify that the subtitle is present.
//     expect(find.text('Your AI Exam Prep Companion'), findsOneWidget);
//   });
// }
