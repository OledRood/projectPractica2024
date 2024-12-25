import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bloc/bloc.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import '../pages/main_page.dart';
import '../resources/theme/theme.dart';
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
    final palette = Provider.of<AppTheme>(context).palette;
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    return Container(
      alignment: Alignment.center,
      height: 600,
      width: 550,
      // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: BoxDecoration(
          color: palette.color200, borderRadius: BorderRadius.circular(20)),
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
                color: palette.color900.withOpacity(0.2),
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
                  //       color: palette.color900,
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
    final palette = Provider.of<AppTheme>(context).palette;
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
        color: palette.color900,
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
                return palette.color200;
              }
              return palette.color100.withOpacity(0.9);
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
    final palette = Provider.of<AppTheme>(context).palette;
    final Bloc mainBloc = Provider.of<Bloc>(context, listen: false);
    return StreamBuilder<StateRequest>(
        stream: mainBloc.resumeMainPageListStateSubject,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('Что-то совсем сломалось',
                style: Theme.of(context).textTheme.bodyMedium);
          }

          switch (snapshot.data) {
            case StateRequest.loading:
              return Center(
                child: CircularProgressIndicator(
                  color: palette.color900,
                ),
              );
            case null:
            case StateRequest.error:
              return Text('Error',
                  style: Theme.of(context).textTheme.bodyMedium);
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
                                color: palette.color50,
                                borderRadius: BorderRadius.circular(10),
                                border: widget.isActiveResume
                                    ? null
                                    : Border.all(
                                        width: 1, color: palette.color900)),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    TextWidget(
                                      text: 'ФИО: ',
                                      isHeadLine: true,
                                    ),
                                    TextWidget(
                                      text: resume.fullName,
                                      isHeadLine: false,
                                    ),
                                    Expanded(
                                      child: SizedBox(),
                                    ),
                                    TextWidget(
                                      text: 'Возраст: ',
                                      isHeadLine: true,
                                    ),
                                    TextWidget(
                                      text: resume.age,
                                      isHeadLine: false,
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
                                      isHeadLine: true,
                                    ),
                                    TextWidget(
                                      text: resume.vacancy,
                                      isHeadLine: false,
                                    ),
                                    Expanded(
                                      child: SizedBox(),
                                    ),
                                    TextWidget(
                                      text: 'Статус: ',
                                      isHeadLine: true,
                                    ),
                                    TextWidget(
                                      text: resume.status,
                                      isHeadLine: false,
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
                                                  isHeadLine: true,
                                                ),
                                                TextWidget(
                                                  text: resume.hrName,
                                                  isHeadLine: false,
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
  final text;
  final bool isHeadLine;

  const TextWidget({
    super.key,
    required this.text,
    required this.isHeadLine,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text.toString(),
        style: isHeadLine
            ? Theme.of(context).textTheme.headlineSmall
            : Theme.of(context).textTheme.bodyMedium
        // style: TextStyle(color: color, fontSize: size),
        );
  }
}

class ToggleWidget extends StatelessWidget {
  final onChange;

  const ToggleWidget({super.key, this.onChange});

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: LiteRollingSwitch(
        //initial value

        width: 135,
        value: true,
        textOn: 'Активные',
        textOnColor: palette.color900,
        textOff: 'Архивные',
        textOffColor: palette.color50,
        colorOn:  palette.color200,
        colorOff: palette.color900,
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
