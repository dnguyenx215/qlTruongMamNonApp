import 'package:example_app/screens/ClassroomScreen.dart';
import 'package:example_app/screens/StudentScreen.dart';
import 'package:example_app/screens/grade_management.dart';
import 'package:example_app/screens/home.dart';
import 'package:flutter/material.dart';
import 'screens/login.dart'; // Import màn hình đăng nhập
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: "lib/assets/.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trường Mầm non',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        'home': (context) => const HomeScreen(),
        'class': (context) => ClassroomScreen(),
        'grade': (context) => const GradeScreen(),
        'students': (context) => const StudentScreen(),
        'tuition': (context) => const StudentScreen(),
        // TODO: Thêm các route khác tại đây
      },
    );
  }
}
