import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../bloc/bloc.dart';
import '../resources/app_colors.dart';
import '../resources/status.dart';
import '../types/full_resume.dart';
import '../widgets/buttonRedWidget.dart';

var vacancyController = TextEditingController();
var ageController = TextEditingController();
var sourceController = TextEditingController();
var nameController = TextEditingController();
var commentsController = TextEditingController();
String hrController = "";
String statusController = '';
int archivController = 0;

class InfoResumePage extends StatefulWidget {
  const InfoResumePage({
    super.key,
  });

  @override
  State<InfoResumePage> createState() => _InfoResumePageState();
}

class _InfoResumePageState extends State<InfoResumePage> {
  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: true);
    return Scaffold(
        backgroundColor: AppColors.color50,
        body: StreamBuilder(
            stream: bloc.observeResumeIdSubject(),
            builder: (context, resumeId) {
              if (!resumeId.hasData || resumeId.data == -1) {
                return Center(
                    child: Text(
                        'Причина поломки: Состояние id резюме = ${resumeId.data}'));
              }
              return StreamBuilder<List<FullResumeInfo>>(
                  stream: bloc.observeResultListResume(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Center(
                          child: Text('Something Wrong ${snapshot.data}'));
                    }
                    final FullResumeInfo resume = snapshot.data!.firstWhere(
                      (resume) => resume.resumeId == resumeId.data!,
                      orElse: () => FullResumeInfo(
                          resumeId: null,
                          fullName: '',
                          archiv: null,
                          date_last_changes: null,
                          hrName: null,
                          status: null,
                          vacancy: null,
                          age: null,
                          source: null,
                          comments: null), // Возвращаем объект по умолчанию
                    );
                    // хи хи ха ха милый похож на тюленя хи хи ха ха а его любит милая
                    if (resume.resumeId == null) {
                      return Center(child: Text('Something Wrong With Resume'));
                    } else {
                      setDataInController(resume);
                    }
                    // if (firstStartPage) {
                    //   setDataInController(resume);
                    // }
                    return Row(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              height: 50,
                            ),
                            Row(
                              children: [
                                Text("Резюме",
                                    style: TextStyle(
                                        color: AppColors.color900,
                                        fontSize: 40,
                                        fontWeight: FontWeight.w900)),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: StreamBuilder<StateRequest>(
                                      stream: bloc.stateUpdateRequest,
                                      builder: (context, snapshot) {
                                        if (snapshot.data ==
                                            StateRequest.none) {
                                          return const SizedBox.shrink();
                                        } else if (snapshot.data ==
                                            StateRequest.loading) {
                                          return CircularProgressIndicator(
                                              color: AppColors.color900);
                                        } else if (snapshot.data ==
                                            StateRequest.good) {
                                          bloc.resetStateUpgrateResumeRequestSubject();
                                          return Icon(Icons.check,
                                              color: AppColors.color900);
                                        } else {
                                          return Icon(
                                              Icons.error_outline_outlined,
                                              color: AppColors.color900);
                                        }
                                      }),
                                )
                              ],
                            ),
                            // Row(children: [Text("Создание резюме")],),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ResumeTextInputWidget(
                                      text: "Имя",
                                      width: 300,
                                      controller: nameController,
                                    ),
                                    const SizedBox(height: 20),
                                    ResumeTextInputWidget(
                                      text: "Вакансия",
                                      width: 200,
                                      controller: vacancyController,
                                    ),
                                    const SizedBox(height: 20),
                                    ResumeTextInputWidget(
                                      text: "Возраст",
                                      width: 60,
                                      controller: ageController,
                                    ),
                                    const SizedBox(height: 20),
                                    ResumeTextInputWidget(
                                      text: "Источник",
                                      width: 200,
                                      controller: sourceController,
                                    ),
                                    const SizedBox(height: 20),
                                    ArchivWidget(),
                                    const SizedBox(height: 20),
                                    StreamBuilder(
                                        stream: bloc.observeRoleSubject(),
                                        builder: (context, snapshot) {
                                          if (snapshot.data == Role.hr_lead) {
                                            return HrDropDownWidget();
                                          }
                                          return SizedBox.shrink();
                                        }),
                                  ],
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Комментарий",
                                          style: TextStyle(
                                              color: AppColors.color900,
                                              fontSize: 20),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          alignment: Alignment.topLeft,
                                          width: 350,
                                          height: 200,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: AppColors.color50,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.05),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 4))
                                            ],
                                            border: Border.all(
                                                //Todo поменять на ошибку
                                                color: AppColors.color900,
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(9),
                                          ),
                                          child: TextField(
                                            maxLines: null,
                                            controller: commentsController,
                                            // onTap: () {},
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                suffixIcon: null),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    StatusWidget(
                                      status: resume.status,
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    ResumeTextWidget(
                                      text: "Дата последнего изменения:",
                                      resumeInfo: resume.date_last_changes,
                                      width: 200.0,
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      width: 493,
                                      // color: Colors.black,
                                    ),
                                  ],
                                )
                              ],
                            ),

                            SizedBox(height: 20),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                RedButtonWidget(
                                  text: "Выход",
                                  height: 50,
                                  focus: false,
                                  onTap: () {
                                    //TODO сделать проверку на изменения
                                    if (true) {
                                      // firstStartPage = true;
                                      Navigator.pop(context);
                                    }
                                  },
                                  width: 100,
                                ),
                                SizedBox(width: 445),
                                RedButtonWidget(
                                  text: "Сохранить",
                                  height: 50,
                                  width: 100,
                                  focus: false,
                                  onTap: () {
                                    print('сохранить');
                                    savedInSubject(bloc, resume);
                                  },

                                ),
                                SizedBox(width: 20),

                                RedButtonWidget(
                                  text: "Отменить изменения",
                                  height: 50,
                                  width: 200,
                                  focus: false,
                                  onTap: () {
                                    setDataInController(resume);
                                    setState(() {});
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    );
                  });
            }));
  }

  void setDataInController(resume) {
    vacancyController.text = resume.vacancy.toString();
    ageController.text = resume.age.toString();
    sourceController.text = resume.source.toString();
    nameController.text = resume.fullName.toString();
    commentsController.text = resume.comments;
    statusController = resume.status.toString();
    archivController = resume.archiv;
    hrController = resume.hrName;

    // firstStartPage = false;
  }

  void savedInSubject(Bloc bloc, resume) {
    bloc.resumeVacancyControllerSubject.add(vacancyController.text);

    bloc.resumeAgeControllerSubject.add(ageController.text.toString());
    bloc.resumeSourceControllerSubject.add(sourceController.text);
    bloc.resumeNameControllerSubject.add(nameController.text);
    bloc.resumeCommentsControllerSubject
        .add(commentsController.text.toString());
    bloc.resumeStatusControllerSubject.add(statusController);
    bloc.resumeIdControllerSubject.add(resume.resumeId);
    bloc.resumeArchivControllerSubject.add(archivController);
    bloc.resumeHrNameControllerSubject.add(hrController);
    bloc.sendResumeToUpdate();
    // mainBloc.getAllResumeToMainPage((archivController == 1));

    print('saved');
  }
}

class ArchivWidget extends StatefulWidget {
  const ArchivWidget({super.key});

  @override
  State<ArchivWidget> createState() => _ArchivWidgetState();
}

class _ArchivWidgetState extends State<ArchivWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ResumeTextWidget(
          text: "Состояние",
          resumeInfo: archivController == 0 ? "Активно" : "В архиве",
          width: 160,
        ),
        SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: () {
            print(archivController);
            setState(() {
              archivController = (archivController == 0) ? 1 : 0;
            });
          },
          child: Container(
            alignment: Alignment.center,
            height: 40,
            width: 40,
            // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: false ? AppColors.color800 : AppColors.color900,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              (archivController == 0)
                  ? Icons.archive_outlined
                  : Icons.check_box_outlined,
              color: AppColors.color50,
            ),
          ),
        )
      ],
    );
  }
}


class ResumeTextInputWidget extends StatelessWidget {
  final String text;
  final double width;
  final TextEditingController controller;

  const ResumeTextInputWidget({
    super.key,
    required this.text,
    required this.width,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(color: AppColors.color900, fontSize: 20),
        ),
        SizedBox(
          width: 10,
        ),
        Container(
          alignment: Alignment.topCenter,
          // width: width,
          height: 40,
          width: width,
          padding: EdgeInsets.only(left: 10, right: 20, bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.color50,
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  blurRadius: 4,
                  offset: Offset(0, 4))
            ],
            border: Border.all(color: AppColors.color900, width: 1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixIcon: null,
              contentPadding: EdgeInsets.only(bottom: 12.0), // Отступ снизу
            ),
            inputFormatters: (text == 'Возраст')
                ? [
                    FilteringTextInputFormatter.digitsOnly
                  ] // Только цифры, если isAge = true
                : [],
          ),
        ),
      ],
    );
  }
}

class ResumeTextWidget extends StatelessWidget {
  final String text;
  final dynamic resumeInfo;
  final double width;

  const ResumeTextWidget({
    super.key,
    required this.text,
    required this.resumeInfo,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(color: AppColors.color900, fontSize: 20),
        ),
        SizedBox(
          width: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          // width: width,
          height: 40,
          width: width,
          padding: EdgeInsets.only(left: 10, right: 20),
          decoration: BoxDecoration(
            color: AppColors.color50,
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  blurRadius: 4,
                  offset: Offset(0, 4))
            ],
            border: Border.all(color: AppColors.color900, width: 1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            resumeInfo.toString(),
            style: TextStyle(
                // color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 16),
          ),
        ),
      ],
    );
  }
}

class StatusWidget extends StatefulWidget {
  final String status;

  const StatusWidget({super.key, required this.status});

  @override
  State<StatusWidget> createState() => _StatusWidgetState();
}

class _StatusWidgetState extends State<StatusWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Статус",
          style: TextStyle(color: AppColors.color900, fontSize: 20),
        ),
        SizedBox(
          width: 80,
        ),
        Stack(
          children: [
            MoveStatus(
              icon: Icons.chevron_left,
              onTap: () {
                print('Move to left');
                setState(() {
                  statusController = Status.update('down', statusController);
                });
              },
            ),
            if (statusController == Status.code[0]) DisableMoveWidget()
          ],
        ),
        SizedBox(
          width: 5,
        ),
        Container(
          alignment: Alignment.center,
          // width: width,
          height: 60,
          width: 263,
          padding: EdgeInsets.only(left: 10, right: 20),
          decoration: BoxDecoration(
            color: AppColors.color50,
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  blurRadius: 4,
                  offset: Offset(0, 4))
            ],
            border: Border.all(color: AppColors.color900, width: 1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            statusController,
            style: TextStyle(
              // color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Stack(
          children: [
            MoveStatus(
              icon: Icons.chevron_right,
              onTap: () {
                print('Move to Right');
                setState(() {
                  statusController = Status.update('up', statusController);
                });
              },
            ),
            if (statusController == Status.code[6]) DisableMoveWidget()
          ],
        ),
      ],
    );
  }
}

class DisableMoveWidget extends StatelessWidget {
  const DisableMoveWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(9),
      ),
    );
  }
}

class MoveStatus extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const MoveStatus({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 60,
        width: 40,
        decoration: BoxDecoration(
          color: AppColors.color900,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          icon,
          color: AppColors.color50,
        ),
      ),
    );
  }
}

class HrDropDownWidget extends StatefulWidget {
  const HrDropDownWidget({
    Key? key,
  }) : super(key: key);

  @override
  _HrDropDownWidgetState createState() => _HrDropDownWidgetState();
}

class _HrDropDownWidgetState extends State<HrDropDownWidget> {
  // Список вариантов для выпадающего меню

  @override
  Widget build(BuildContext context) {
    String selectedHr = hrController;

    final Bloc bloc = Provider.of<Bloc>(context, listen: true);
    List<String> valueList = bloc.hrListSubject.value;

    // List<String> valueList = [
    //   "hr",
    //   "Иванов Иван Иванович",
    //   "Клюшка Лариса Борисовна"
    // ];
    return Row(
      children: [
        Text(
          "Hr:",
          style: TextStyle(fontSize: 16, color: AppColors.color900),
        ),
        SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.color50,
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  blurRadius: 4,
                  offset: Offset(0, 4))
            ],
            border: Border.all(color: AppColors.color900, width: 1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 300,
                child: DropdownButton<String>(
                  value: selectedHr,
                  hint: Text(
                    selectedHr,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  isExpanded: true,
                  underline: SizedBox(),
                  items:
                      valueList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style:
                            TextStyle(fontSize: 16, color: AppColors.color900),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedHr = newValue!;
                      hrController = selectedHr!;
                    });
                  },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
