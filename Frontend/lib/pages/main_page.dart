import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hr_monitor/pages/main_page_content.dart';
import 'package:provider/provider.dart';

import '../bloc/bloc.dart';
import '../bloc/entrance_bloc.dart';
import '../bloc/hr_main_bloc.dart';
import '../resources/app_colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);

    return StreamBuilder<Role?>(
        stream: bloc.observeRoleSubject(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            print('роль не прошла полуаается');
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.color900,
              ),
            );
          }
          print("Snapshot: ${snapshot.data}");
          switch (snapshot.data) {
            case null:
              return Scaffold(
                  body: Center(
                      child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Что-то сломалось попробуйте снова",
                    style: TextStyle(color: AppColors.color900),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      bloc.exit();


                      Navigator.of(context).pushNamedAndRemoveUntil(
                        "/Entrance",
                        (Route<dynamic> route) => false,
                      );

                    },
                    child: Container(
                      height: 70,
                      width: 100,
                      color: AppColors.color900,
                      child: Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              )));
            case Role.hr:
              return MainPageContent(role: Role.hr);
            case Role.hr_lead:
              return MainPageContent(role: Role.hr_lead);
            case Role.admin:
              return Scaffold(
                  body: Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Страница admin'а",
                              style: TextStyle(color: AppColors.color900),
                            ),])));
            // TODO: Handle this case.
          }
        });
  }
}
