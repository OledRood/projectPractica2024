import 'package:flutter/material.dart';
import 'package:hr_monitor/widgets/users_list_widget.dart';
import 'package:provider/provider.dart';

import '../../bloc/bloc.dart';
import '../../resources/theme/theme.dart';
import '../main_page.dart';

class AdminPageContent extends StatelessWidget {
  const AdminPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    bloc.sendGetUserDataBase();
    bloc.sendGetUsersList();
    return Scaffold(
      backgroundColor: palette.color50,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonWidget(
                  text: 'Добавить пользователя',
                  displayWidth: 1000,
                  onPress: () {
                    Navigator.of(context).pushNamed("/MainPage/CreateUserPage");
                  },
                ),
                SizedBox(height: 20),
                ButtonWidget(
                  text: "Просмотреть таблицы",
                  displayWidth: 1000,
                  onPress: () {
                    Navigator.of(context).pushNamed("/MainPage/UserTablePage");

                  },
                ),
                SizedBox(height: 20),
                ButtonWidget(
                  text: "Выход",
                  displayWidth: 1000,
                  onPress: () {
                    bloc.exit();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      "/Entrance",
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            ),
            SizedBox(width: 20),
            ListOfUsersWidget(),
          ],
        ),
      ),
    );
  }
}
