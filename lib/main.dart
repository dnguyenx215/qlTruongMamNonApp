// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/grade_management.dart';
import 'screens/student/student_list_screen.dart';
import 'screens/student/student_detail_screen.dart';
import 'screens/ClassroomScreen.dart';

void main() async {
  // Đảm bảo widgets đã được init trước khi thực hiện các operations như loads
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: "lib/assets/.env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trường Mầm non',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Dynamic routes with parameters
        final uri = Uri.parse(settings.name ?? '/');

        // Handle student detail route with ID
        if (uri.pathSegments.length == 2 &&
            uri.pathSegments[0] == 'students' &&
            uri.pathSegments[1].isNotEmpty) {
          final studentId = int.tryParse(uri.pathSegments[1]);
          if (studentId != null) {
            return MaterialPageRoute(
              builder: (context) => StudentDetailScreen(studentId: studentId),
            );
          }
        }

        // Handle normal routes
        return null;
      },
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/class': (context) => const ClassroomScreen(),
        '/grade': (context) => const GradeScreen(),
        '/students': (context) => const StudentListScreen(),
      },
    );
  }
}
