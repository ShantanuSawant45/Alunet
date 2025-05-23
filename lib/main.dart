
import 'package:dbms_project/Auth_Screens/signup_screen.dart';
import 'package:dbms_project/screens/home_screen.dart';
import 'package:dbms_project/screens/splash_screen.dart';
import 'package:dbms_project/screens/student_details_screen.dart';
import 'package:dbms_project/screens/Alumni_details_screen.dart';
import 'package:dbms_project/utils/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alunet',
      theme: AppTheme.lightTheme,
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
