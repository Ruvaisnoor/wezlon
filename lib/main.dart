import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/splash.dart';
import 'models/student.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final directory = await getApplicationDocumentsDirectory();

    Hive.init(directory.path);

    Hive.registerAdapter(StudentAdapter());

    await Hive.openBox('userBox');
    await Hive.openBox<Student>('studentsBox');

    runApp(const MyApp());
  } catch (e) {
    print("Error initializing Hive: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Management',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Splashscreen(),
    );
  }
}
