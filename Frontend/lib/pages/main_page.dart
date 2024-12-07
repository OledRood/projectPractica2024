import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../bloc/bloc.dart';
import '../resources/app_colors.dart';
import '../widgets/resume_list_widget.dart';

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
              bloc.getAllResumeToMainPage();
              return MainPageContent(role: Role.hr);
            case Role.hr_lead:
              bloc.getAllResumeToMainPage();
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
                    ),
                  ])));
            // TODO: Handle this case.
          }
        });
  }
}

class MainPageContent extends StatefulWidget {
  final Role role;

  const MainPageContent({super.key, required this.role});

  @override
  State<MainPageContent> createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    bloc.sendGetResumeList();
    return Scaffold(
      backgroundColor: AppColors.color50,
      body: LayoutBuilder(builder: (context, constraint) {
        print(constraint.maxWidth);
        return Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Начать поиск по резюме
                    ButtonWidget(
                      text: "Поиск по резюме",
                      onPress: () {
                        bloc.sendGetResumeList();
                        Navigator.pushNamed(
                            context, '/MainPage/SearchResumePage');
                      },
                      displayWidth: constraint.maxWidth,
                    ),

                    SizedBox(
                      height: 20,
                    ),
                    // Добавить резюме
                    ButtonWidget(
                      text: "Создать резюме",
                      onPress: () {
                        Navigator.pushNamed(
                            context, '/MainPage/CreateResumePage');
                      },
                      displayWidth: constraint.maxWidth,

                    ),
                    SizedBox(height: 20),
                    //Статистика
                    ButtonWidget(
                      text: 'Статистика',
                      onPress: () {
                        bloc.getStatistic();
                        Navigator.pushNamed(
                            context, '/MainPage/StatisticsPage');
                      },
                      displayWidth: constraint.maxWidth,

                    ),
                    SizedBox(height: 20),
                    //Выход
                    ButtonWidget(
                      text: "Выход",
                      onPress: () {
                        bloc.exit();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          "/Entrance",
                          (Route<dynamic> route) => false,
                        );
                      },
                      displayWidth: constraint.maxWidth,

                    ),
                    // SizedBox(height: 357)
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                (constraint.maxWidth >= 738) ? Column(
                  children: [
                    //список текущих резюме
                     ListOfResumeWidget() ,
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ) : SizedBox.shrink(),
                SizedBox(
                  width: 1,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
          ],
        );
      }),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  final VoidCallback onPress;
  final String text;
  final double displayWidth;
  const ButtonWidget({
    super.key,
    required this.onPress,
    required this.text, required this.displayWidth,
  });

  @override
  Widget build(BuildContext context) {
    TextButtonState textButtonState = getTextWidgetState(displayWidth);
    return TextButton(
        onPressed: onPress,
        style: ButtonStyle(
          alignment: Alignment.center,
          // maximumSize: WidgetStatePropertyAll(Size(300, 75)),
          // minimumSize: WidgetStatePropertyAll((Size(150, 75))),
          fixedSize: WidgetStatePropertyAll(getSizeByState(textButtonState, displayWidth)),
          shadowColor: WidgetStatePropertyAll(Colors.black),
          elevation: WidgetStatePropertyAll(2),
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return AppColors.color900.withOpacity(0.3);
              }
              return null;
            },
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.hovered)) {
                return AppColors.color300;
              }
              // else if (states.contains(WidgetState.pressed)) {
              //   return AppColors.color900;}
              else if (states.contains(WidgetState.focused)) {
                return AppColors.color300;
              }
              return AppColors.color100;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.hovered)) {
                return Colors.white;
              } else if (states.contains(WidgetState.focused)) {
                return Colors.white;
              }
              return Colors.black;
            },
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        child: Text(text));
  }
  Size getSizeByState(TextButtonState textButtonState, double displayWidth){
    switch(textButtonState){
      case TextButtonState.big:
        return Size(300, 75);
      case TextButtonState.adaptive:
        return Size(displayWidth - 600, 75);
      case TextButtonState.small:
        return Size(300, 75);
    }
  }

  TextButtonState getTextWidgetState(double displayWidth) {
    if (displayWidth > 888) {
      return TextButtonState.big;
    } else if (displayWidth < 888 && displayWidth >= 738) {
     return TextButtonState.adaptive;
    } else {
      return TextButtonState.small;
    }
  }
}

enum TextButtonState { big, adaptive, small }
