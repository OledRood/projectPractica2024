


import 'package:flutter/material.dart';
import 'package:hr_monitor/pages/create_resume_page.dart';
import 'package:hr_monitor/pages/entrance_page.dart';
import 'package:hr_monitor/pages/search_resume_page.dart';
import 'package:hr_monitor/pages/main_page.dart';
import 'package:hr_monitor/pages/resume_info_page.dart';
import 'package:provider/provider.dart';

import 'bloc/bloc.dart';
import 'bloc/entrance_bloc.dart';
import 'bloc/hr_main_bloc.dart';
import 'bloc/main_bloc.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<Bloc>(create: (_) => Bloc()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (RouteSettings settings) {
        // if (settings.name == '/MainPage/HrInfoResumePage') {
        //   final resumeId = settings.arguments as int;
        //   return MaterialPageRoute(
        //     builder: (context) => HrInfoResumePage(
        //       resumeId: resumeId,
        //     ),
        //   );
        // }
        if (settings.name == '/Entrance') {
          return MaterialPageRoute(builder: (context) => EntrancePage());
        }

        if (settings.name == '/MainPage') {
          return MaterialPageRoute(builder: (context) => MainPage());
        }
        if (settings.name == '/MainPage/InfoResumePage') {
          return MaterialPageRoute(builder: (context) => InfoResumePage());
        }
        if (settings.name == '/MainPage/CreateResumePage') {
          return MaterialPageRoute(builder: (context) => CreateResumePage());
        }
        if (settings.name == '/MainPage/SearchResumePage') {
          return MaterialPageRoute(builder: (context) => ResumeSearchPage());
        }
        return null; // Возвращает null, если маршрут не найден
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
