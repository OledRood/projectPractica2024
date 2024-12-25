import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr_monitor/pages/admin/change_and_delete_user_page.dart';
import 'package:hr_monitor/pages/admin/create_user_page.dart';
import 'package:hr_monitor/pages/change_color_page.dart';
import 'package:hr_monitor/pages/create_resume_page.dart';
import 'package:hr_monitor/pages/entrance_page.dart';
import 'package:hr_monitor/pages/search_resume_page.dart';
import 'package:hr_monitor/pages/main_page.dart';
import 'package:hr_monitor/pages/info_resume_page.dart';
import 'package:hr_monitor/pages/statistics_page.dart';
import 'package:hr_monitor/resources/theme/theme.dart';
import 'package:provider/provider.dart';

import 'bloc/bloc.dart';
import 'models/admin/users_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appTheme = AppTheme();
  await appTheme.loadTheme(); // Загрузка сохранённой темы

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppTheme>.value(value: appTheme),
        // Передача существующего экземпляра
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
    final theme = Provider.of<AppTheme>(context);
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
        switch (settings.name) {
          case '/Entrance':
            return MaterialPageRoute(builder: (context) => EntrancePage());
          case '/MainPage':
            return MaterialPageRoute(builder: (context) => MainPage());
          case '/MainPage/InfoResumePage':
            return MaterialPageRoute(builder: (context) => InfoResumePage());
          case '/MainPage/CreateResumePage':
            return MaterialPageRoute(builder: (context) => CreateResumePage());
          case '/MainPage/SearchResumePage':
            return MaterialPageRoute(builder: (context) => ResumeSearchPage());
          case '/MainPage/StatisticsPage':
            return MaterialPageRoute(builder: (context) => StatisticsPage());
          case '/MainPage/ChangeColorPage':
            return MaterialPageRoute(builder: (context) => ChangeColorPage());
          case '/MainPage/CreateUserPage':
            return MaterialPageRoute(builder: (context) => CreateUserPage());
            case '/MainPage/ChangeAndDeleteUser':
              final user = settings.arguments as UserTable;
              return MaterialPageRoute(builder: (context) => ChangeAndDeleteUserPage(user: user));
          // case '/MainPage/UserTablePage':
          //   return MaterialPageRoute(builder: (context) => UsersTablesPage());
          default:
            return null;
        }
      },
      title: 'Practica',
      theme: ThemeData(
          textTheme: TextTheme(
              bodyMedium:
                  TextStyle(color: theme.palette.colorText, fontSize: 16),
              headlineSmall: TextStyle(
                color: theme.palette.color900,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              headlineMedium:
                  TextStyle(color: theme.palette.color900, fontSize: 20),
              headlineLarge: TextStyle(
                color: theme.palette.color900,
                fontWeight: FontWeight.w900,
                fontSize: 40,
              )),
          primaryColor: theme.palette.color50,
          fontFamily: GoogleFonts.kurale().fontFamily,
          useMaterial3: true,

          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                (states) {
                  if (states.contains(WidgetState.hovered)) {
                    return theme.palette.colorSelectedText;
                  } else if (states.contains(WidgetState.focused)) {
                    return theme.palette.colorSelectedText;
                  }
                  return theme.palette.colorText;
                },
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            // iconColor: Colors.yellow,
            suffixIconColor: theme.palette.colorText,
            hintStyle: TextStyle(
              color: theme.palette.colorText,
            ),
            labelStyle: TextStyle(
              color: theme.palette.color900,
            ),
            prefixIconColor: theme.palette.colorText,
            contentPadding: EdgeInsets.only(bottom: 12),
            border: InputBorder.none,
          )),
      home: EntrancePage(),
    );
  }
}
