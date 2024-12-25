import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/bloc.dart';
import '../../models/admin/users_data.dart';
import '../../resources/theme/theme.dart';

class ChangeAndDeleteUserPage extends StatelessWidget {
  final UserTable user;

  const ChangeAndDeleteUserPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    return Scaffold(
      backgroundColor: palette.color50,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text('Пользователь'),
              Container(child: Row(
                children: [
                  Text('Имя'),
                  Text(user.username),
                ],
              ),),
              Container(child: Row(
                children: [
                  Text('Роль'),
                  Text(user.role),
                ],
              ),),

            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(children: [SizedBox(height: 20),Text("=>")],),
          ),
          Column(children: [
            Text('Измененные парметры'),
            Container(height: 200, width: 200, color: Colors.yellow,)],)
        ],
      ),
    );
  }
}
