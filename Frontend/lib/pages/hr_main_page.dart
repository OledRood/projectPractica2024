import 'package:flutter/material.dart';
import 'package:hr_monitor/bloc/entrance_bloc.dart';
import 'package:hr_monitor/bloc/main_bloc.dart';
import 'package:hr_monitor/resources/app_colors.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainBloc mainBloc;

  @override
  void initState() {
    super.initState();
    // выдавать ошибку при перезагрузке
    // html.window.onBeforeUnload.listen((event) {
    //   // Создаем предупреждающее сообщение
    //   event.preventDefault();
    //   // event.returnValue = ''; // Необходимо для работы диалога в некоторых браузерах
    // });
    mainBloc = MainBloc();

    // Обработчик для события "Назад"

  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(value: mainBloc, child: HrMainPage());
  }
}

class HrMainPage extends StatelessWidget {
  const HrMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color50,
      body: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  //список текущих резюме
                  Container(height: 500, width: 500, color: AppColors.color200),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      //Выход
                      ExitWidget(),
                      SizedBox(
                        width: 10,
                      ),
                      // Резюме из архивов
                      Container(
                          width: 420, height: 70, color: AppColors.color200),
                    ],
                  )
                ],
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                children: [
                  // Начать поиск по резюме
                  Container(height: 75, width: 300, color: AppColors.color200),
                  SizedBox(
                    height: 20,
                  ),
                  // Добавить резюме
                  CreateResumeWidget(onTap: () {
                    Navigator.pushNamed(context, '/MainPage/CreateResumePage');
                  }),
                  SizedBox(
                    height: 20,
                  ),
                  // Сообщегния от HR
                  Container(height: 400, width: 300, color: AppColors.color200),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

class CreateResumeWidget extends StatelessWidget {
  final VoidCallback onTap;

  const CreateResumeWidget({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 75,
          width: 300,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppColors.color200,
              borderRadius: BorderRadius.circular(20)),
          child: Text('Создать резюме'),
        ));
  }
}

class ExitWidget extends StatelessWidget {
  const ExitWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final MainBloc mainBloc = Provider.of<MainBloc>(context, listen: false);
    return GestureDetector(
      onTap: () {
        mainBloc.exit();
        Navigator.pop(context);
      },
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: AppColors.color200, borderRadius: BorderRadius.circular(20)),
        child: Text('Выход'),
      ),
    );
  }
}
