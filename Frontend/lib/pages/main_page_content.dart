
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc/bloc.dart';
import '../resources/app_colors.dart';
import '../widgets/resume_list_widget.dart';

bool isActiveResume = true;


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
    bloc.getAllResumeToMainPage();

    return Scaffold(
      backgroundColor: AppColors.color50,
      body: Column(
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
                  GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, '/MainPage/SearchResumePage');
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 75,
                      width: 300,
                      decoration: BoxDecoration(
                          color: AppColors.color200,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('Поиск по резюме'),
                    ),
                  ),
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
                  Row(
                    children: [
                      //Выход
                      ExitWidget(),
                      SizedBox(
                        width: 10,
                      ),
                      // Резюме из архивов
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isActiveResume = !isActiveResume;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 220,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.color200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                              child: Text(isActiveResume
                                  ? 'Архивные резюме'
                                  : "Активные резюме")),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 357)
                ],
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                children: [
                  //список текущих резюме
                  ListOfResumeWidget(
                    isActiveResume: isActiveResume,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
              SizedBox(
                width: 1,
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
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    return GestureDetector(
      onTap: () {
        bloc.exit();
        Navigator.of(context).pushNamedAndRemoveUntil(
          "/Entrance",
              (Route<dynamic> route) => false,
        );
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