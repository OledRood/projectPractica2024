import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../bloc/bloc.dart';
import '../models/resume_list.dart';
import '../resources/status.dart';
import '../resources/theme/theme.dart';
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
late String startVacacnyController;
late String startSourceController;

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
    final palette = Provider.of<AppTheme>(context).palette;
    return Scaffold(
        backgroundColor: palette.color50,
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
                                  style: Theme.of(context).textTheme.headlineLarge,
                                ),
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
                                              color: palette.color900);
                                        } else if (snapshot.data ==
                                            StateRequest.good) {
                                          bloc.resetStateUpgrateResumeRequestSubject();
                                          return Icon(Icons.check,
                                              color: palette.color900);
                                        } else {
                                          return Icon(
                                              Icons.error_outline_outlined,
                                              color: palette.color900);
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
                                    StreamBuilder<ResumeList>(
                                        stream: bloc.resumeListSubject,
                                        builder: (context, snapshot) {
                                          return ResumeListWidget(
                                              text: "Вакансия",
                                              controller: vacancyController);
                                        }),
                                    const SizedBox(height: 20),
                                    ResumeTextInputWidget(
                                      text: "Возраст",
                                      width: 60,
                                      controller: ageController,
                                    ),
                                    const SizedBox(height: 20),
                                    ResumeListWidget(
                                      text: "Источник",
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
                                          style: Theme.of(context).textTheme.headlineMedium,
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
                                            color: palette.color50,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.05),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 4))
                                            ],
                                            border: Border.all(
                                                //Todo поменять на ошибку
                                                color: palette.color900,
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(9),
                                          ),
                                          child: TextField(
                                            maxLines: null,
                                            controller: commentsController,
                                            // onTap: () {},
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
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
                                    InputTextWidget(
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
    startVacacnyController = resume.vacancy.toString();
    startSourceController = resume.source.toString();

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
    final palette = Provider.of<AppTheme>(context).palette;

    return Row(
      children: [
        InputTextWidget(
          text: "Состояние",
          resumeInfo: archivController == 0 ? "Активно" : "В архиве",
          width: 160,
        ),
        SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: () {
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
              color: false ? palette.color800 : palette.color900,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              (archivController == 0)
                  ? Icons.archive_outlined
                  : Icons.check_box_outlined,
              color: palette.color50,
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
    final palette = Provider.of<AppTheme>(context).palette;

    return Row(
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.headlineMedium,
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
            color: palette.color50,
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  blurRadius: 4,
                  offset: Offset(0, 4))
            ],
            border: Border.all(color: palette.color900, width: 1),
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

class InputTextWidget extends StatelessWidget {
  final String text;
  final dynamic resumeInfo;
  final double width;

  const InputTextWidget({
    super.key,
    required this.text,
    required this.resumeInfo,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;

    return Row(
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.headlineMedium,
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
            color: palette.color50,
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  blurRadius: 4,
                  offset: Offset(0, 4))
            ],
            border: Border.all(color: palette.color900, width: 1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            resumeInfo.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
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
    final palette = Provider.of<AppTheme>(context).palette;
    return Row(
      children: [
        Text(
          "Статус",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(
          width: 80,
        ),
        Stack(
          children: [
            MoveStatus(
              icon: Icons.chevron_left,
              onTap: () {
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
            color: palette.color50,
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  blurRadius: 4,
                  offset: Offset(0, 4))
            ],
            border: Border.all(color: palette.color900, width: 1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            statusController,
            style: Theme.of(context).textTheme.bodyMedium,
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
    final palette = Provider.of<AppTheme>(context).palette;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 60,
        width: 40,
        decoration: BoxDecoration(
          color: palette.color900,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          icon,
          color: palette.color50,
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

class DropdownWidget extends StatefulWidget {
  final String valueController;
  final String text;
  final double width;
  final List<String> listOfValue;

  // final

  const DropdownWidget(
      {Key? key,
      required this.text,
      required this.width,
      required this.listOfValue,
      required this.valueController})
      : super(key: key);

  @override
  _DropdownWidgetState createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  // String? selectedValue = widget.valueController;

  // Список вариантов для выпадающего меню

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;
    String? selectedValue = widget.valueController;
    return Container(
      width: widget.width,
      height: 40,
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: palette.color50,
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 4,
              offset: Offset(0, 4))
        ],
        border: Border.all(
            //Todo поменять на ошибку
            color: false ? Color.fromRGBO(255, 51, 51, 0.50) : palette.color900,
            width: false ? 2 : 1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Container(
        // height: 48,
        width: widget.width,
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(
            widget.valueController,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          isExpanded: true,
          underline: SizedBox(),
          items: widget.listOfValue.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(fontSize: 16, color: palette.color900),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedValue = newValue;
              if (selectedValue == 'Добавить') {
                selectedValue = '';
              }
              switch (widget.text) {
                case 'Вакансия':
                  vacancyController.text = selectedValue!;
                case "Hr":
                  hrController = selectedValue!;
                case "Источник":
                  sourceController.text = selectedValue!;
              }
            });
          },
        ),
      ),
    );
  }
}

class _HrDropDownWidgetState extends State<HrDropDownWidget> {
  // Список вариантов для выпадающего меню

  @override
  Widget build(BuildContext context) {
    String selectedHr = hrController;
    final palette = Provider.of<AppTheme>(context).palette;
    final Bloc bloc = Provider.of<Bloc>(context, listen: true);

    // List<String> valueList = [
    //   "hr",
    //   "Иванов Иван Иванович",
    //   "Клюшка Лариса Борисовна"
    // ];
    return Row(
      children: [
        Text(
          "Hr:",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: palette.color50,
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  blurRadius: 4,
                  offset: Offset(0, 4))
            ],
            border: Border.all(color: palette.color900, width: 1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              SizedBox(
                height: 48,
                width: 300,
                child: StreamBuilder(
                    stream: bloc.observeResumeListSubject(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.data == null ||
                          !snapshot.data!.hrList.contains(selectedHr)) {
                        return SizedBox.shrink();
                      }
                      List<String> hrList = snapshot.data!.hrList;
                      return DropdownButton<String>(
                        value: selectedHr,
                        hint: Text(
                          selectedHr,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        isExpanded: true,
                        underline: SizedBox(),
                        items: hrList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedHr = newValue!;
                            hrController = selectedHr!;
                          });
                        },
                      );
                    }),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class ResumeListWidget extends StatefulWidget {
  final TextEditingController controller;
  final String text;

  const ResumeListWidget(
      {super.key, required this.controller, required this.text});

  @override
  State<ResumeListWidget> createState() => _ResumeListWidgetState();
}

class _ResumeListWidgetState extends State<ResumeListWidget> {
  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    final palette = Provider.of<AppTheme>(context).palette;

    return Row(
      children: [
        Text(widget.text,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(width: 10),
        StreamBuilder<ResumeList>(
            stream: bloc.observeResumeListSubject(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return SizedBox.shrink();
              }
              late List<String> resumeList;
              double width = 0;
              if (widget.text == 'Вакансия') {
                resumeList = snapshot.data!.vacancy;
                width = 250;
              } else if (widget.text == 'Источник') {
                resumeList = snapshot.data!.source;
                width = 250;
              }

              return ValueListenableBuilder(
                  valueListenable: widget.controller,
                  builder: (context, value, child) {
                    if (!resumeList.contains(value.text)) {
                      // if (resumeList.isEmpty) {
                      //   print("inputTExtWidget");
                      //   return InputTextWidget(
                      //       text: widget.text,
                      //       controller: widget.controller,
                      //       isAge: false);
                      // }
                      return InputTextWithSuffixWidget(
                        text: widget.text,
                        controller: widget.controller,
                        width: width,
                        resumeList: resumeList,
                      );
                    }
                    return DropdownWidget(
                        valueController: value.text,
                        text: widget.text,
                        width: width,
                        listOfValue: resumeList + ['Добавить']);
                  });
            }),
      ],
    );
  }
}

class InputTextWithSuffixWidget extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final double width;
  final resumeList;

  const InputTextWithSuffixWidget(
      {super.key,
      required this.text,
      required this.controller,
      required this.resumeList,
      required this.width});

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;

    return Container(
      width: width,
      height: 40,
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: palette.color50,
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 4,
              offset: Offset(0, 4))
        ],
        border: Border.all(
            //Todo поменять на ошибку
            color: false ? Color.fromRGBO(255, 51, 51, 0.50) : palette.color900,
            width: false ? 2 : 1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: TextField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyMedium,

        decoration: InputDecoration(
          hintText: "",
          label: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            // color: palette.color900,
            onPressed: () {
              switch (text) {
                case 'Вакансия':
                  vacancyController.text = startVacacnyController;
                case 'Источник':
                  sourceController.text = startSourceController;
                //Доделать источник и добавить эту кнопку в вакансию
              }
            },
          ),
        ),
      ),
    );
  }
}
