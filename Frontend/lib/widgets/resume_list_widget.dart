import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bloc/bloc.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import '../pages/main_page.dart';
import '../resources/app_colors.dart';
import '../types/full_resume.dart';

bool isActiveResume = true;

class ListOfResumeWidget extends StatefulWidget {
  const ListOfResumeWidget({super.key});

  @override
  State<ListOfResumeWidget> createState() => _ListOfResumeWidgetState();
}

class _ListOfResumeWidgetState extends State<ListOfResumeWidget> {
  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    return Container(
      alignment: Alignment.center,
      height: 600,
      width: 550,
      // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: BoxDecoration(
          color: AppColors.color200, borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Container(
              height: 600,
              width: 550,
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: ResumesListWidgetInside(
                isActiveResume: isActiveResume,
              )),
          Container(
              alignment: Alignment.center,
              height: 50,
              width: 550,
              decoration: BoxDecoration(
                color: AppColors.color900.withOpacity(0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  // Скругление только для верхнего левого угла
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ToggleWidget(
                    onChange: (bool state) {
                      setState(() {
                        isActiveResume = state;
                      });
                    },
                  ),
                  // Text(
                  //   widget.isActiveResume ? 'Активные' : 'Архивные',
                  //   style: TextStyle(
                  //       color: AppColors.color900,
                  //       fontSize: 20,
                  //       fontWeight: FontWeight.w600),
                  // ),
                  RestartWidget(onPress: () {
                    bloc.getAllResumeToMainPage();
                  })
                ],
              )),
        ],
      ),
    );
  }
}

class RestartWidget extends StatelessWidget {
  final VoidCallback onPress;

  const RestartWidget({
    super.key,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: IconButton(
        onPressed: onPress,
        icon: Icon(Icons.restart_alt),
        constraints: BoxConstraints(
          minWidth: 40.0,
          minHeight: 40.0,
        ),
        focusNode: FocusNode(skipTraversal: true),
        color: AppColors.color900,
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          shadowColor: WidgetStatePropertyAll(Colors.black),
          elevation: WidgetStatePropertyAll(2),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                (states) {
              if (states.contains(WidgetState.hovered)) {
                return AppColors.color200;
              }
              return AppColors.color100.withOpacity(0.9);
            },
          ),
        ),
      ),
    );
  }
}

class ResumesListWidgetInside extends StatefulWidget {
  final bool isActiveResume;

  const ResumesListWidgetInside({
    super.key,
    required this.isActiveResume,
  });

  @override
  State<ResumesListWidgetInside> createState() =>
      _ResumesListWidgetInsideState();
}

class _ResumesListWidgetInsideState extends State<ResumesListWidgetInside> {
  @override
  Widget build(BuildContext context) {
    final Bloc mainBloc = Provider.of<Bloc>(context, listen: false);
    return StreamBuilder<StateRequest>(
        stream: mainBloc.resumeMainPageListStateSubject,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('Что-то совсем сломалось');
          }

          switch (snapshot.data) {
            case StateRequest.loading:
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.color900,
                ),
              );
            case null:
            case StateRequest.error:
              return Text('Error');
            case StateRequest.good:
              return StreamBuilder<List<FullResumeInfo>>(
                  stream: mainBloc.observeResultListResume(),
                  builder: (context, resumes) {
                    if (!resumes.hasData ||
                        resumes.data == null ||
                        resumes.data == []) {
                      return const SizedBox.shrink();
                    }
                    final List<FullResumeInfo> listResumes = resumes.data ?? [];
                    final archivStatus = (isActiveResume == true) ? 0 : 1;
                    var listFiltersResumes = listResumes
                        .where((resume) => (resume.archiv == archivStatus))
                        .toList();
                    return ListView.separated(
                      itemCount: listFiltersResumes.length + 1,
                      itemBuilder: (build, int index) {
                        if (index == 0) {
                          //TODO высота козырька
                          return SizedBox(
                            height: 40,
                          );
                        }
                        final resume = listFiltersResumes[index - 1];
                        return GestureDetector(
                          onTap: () {
                            mainBloc.resumeIdControllerSubject
                                .add(resume.resumeId);
                            Navigator.pushNamed(
                                context, '/MainPage/InfoResumePage');
                          },
                          child: Container(
                            // height: 100,
                            width: 100,
                            padding: const EdgeInsets.only(
                                top: 5, bottom: 5, right: 20, left: 10),
                            decoration: BoxDecoration(
                                color: AppColors.color50,
                                borderRadius: BorderRadius.circular(10),
                                border: widget.isActiveResume
                                    ? null
                                    : Border.all(
                                        width: 1, color: AppColors.color900)),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    TextWidget(
                                      text: 'ФИО: ',
                                      color: AppColors.color900,
                                      size: 16,
                                    ),
                                    TextWidget(
                                      text: resume.fullName,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                    Expanded(
                                      child: SizedBox(),
                                    ),
                                    TextWidget(
                                      text: 'Возраст: ',
                                      color: AppColors.color900,
                                      size: 16,
                                    ),
                                    TextWidget(
                                      text: resume.age,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                // Expanded(child: SizedBox()),
                                SizedBox(
                                  height: 5,
                                ),

                                Row(
                                  children: [
                                    TextWidget(
                                      text: "Вакансия: ",
                                      color: AppColors.color900,
                                      size: 16,
                                    ),
                                    TextWidget(
                                      text: resume.vacancy,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                    Expanded(
                                      child: SizedBox(),
                                    ),
                                    TextWidget(
                                      text: 'Статус: ',
                                      color: AppColors.color900,
                                      size: 16,
                                    ),
                                    TextWidget(
                                      text: resume.status,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                StreamBuilder(
                                    stream: mainBloc.observeRoleSubject(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data == Role.hr_lead) {
                                        return Column(
                                          children: [
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                TextWidget(
                                                  text: 'HR: ',
                                                  color: AppColors.color900,
                                                  size: 16,
                                                ),
                                                TextWidget(
                                                  text: resume.hrName,
                                                  color: Colors.black,
                                                  size: 16,
                                                ),
                                              ],
                                            )
                                          ],
                                        );
                                      } else {
                                        return SizedBox.shrink();
                                      }
                                    })
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (build, context) {
                        return SizedBox(
                          height: 10,
                        );
                      },
                    );
                  });
            default:
              return SizedBox.shrink();
          }
        });
  }
}

class TextWidget extends StatelessWidget {
  final Color color;
  final text;
  final double size;

  const TextWidget({
    super.key,
    required this.text,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toString(),
      style: TextStyle(color: color, fontSize: size),
    );
  }
}

class ToggleWidget extends StatelessWidget {
  final onChange;

  const ToggleWidget({super.key, this.onChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: LiteRollingSwitch(
        //initial value
        width: 135,
        value: true,
        textOn: 'Активные',
        textOff: 'Архивные',
        colorOn: AppColors.color100,
        colorOff: AppColors.color900,
        iconOn: Icons.check_box_outlined,
        iconOff: Icons.archive_outlined,
        textSize: 16.0,
        onChanged: onChange,
        onTap: () {},
        onDoubleTap: () {},
        onSwipe: () {},
      ),
    );
  }
}
