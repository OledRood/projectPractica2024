import 'package:flutter/material.dart';
import 'package:hr_monitor/pages/create_resume_page.dart';
import 'package:hr_monitor/pages/entrance_page.dart';
import 'package:hr_monitor/pages/hr_main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/Registration': (BuildContext context) => EntrancePage(),
        '/MainPage': (BuildContext context) => MainPage(),
        '/MainPage/CreateResumePage': (BuildContext context) => CreateResumePage(),
      },
      title: 'Practica',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: EntrancePage(),
    );
  }
}
