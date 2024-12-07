import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hr_monitor/models/resume_list.dart';
import 'package:hr_monitor/widgets/buttonRedWidget.dart';
import 'package:provider/provider.dart';

import '../bloc/bloc.dart';
import '../resources/app_colors.dart';

var alert = false;

var vacancyController = TextEditingController();
var ageController = TextEditingController();
var sourceController = TextEditingController();
var nameController = TextEditingController();
var commentsController = TextEditingController();
String hrController = '';

class CreateResumePage extends StatelessWidget {
  const CreateResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);

    vacancyController.text = (bloc.resumeListSubject.value.vacancy != [])
        ? bloc.resumeListSubject.value.vacancy[0]
        : '';
    ageController.text = '';
    sourceController.text = (bloc.resumeListSubject.value.source != [])
        ? bloc.resumeListSubject.value.source[0]
        : '';
    nameController.text = '';
    commentsController.text = '';
    bloc.cleanResumeControllers();
    return CreateResumePageContent();
  }
}

class CreateResumePageContent extends StatefulWidget {
  const CreateResumePageContent({
    super.key,
  });

  @override
  State<CreateResumePageContent> createState() =>
      _CreateResumePageContentState();
}

class _CreateResumePageContentState extends State<CreateResumePageContent> {
  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);

    return LayoutBuilder(
      builder: (context, constraint) {
        print(constraint.maxWidth);
        bool isMinimum = constraint.maxWidth < 510;
        return Scaffold(
          backgroundColor: AppColors.color50,
          body: alert
              ? AlertDialogWidget(
                  ExitTap: () {
                    ExitVoid(bloc, context);
                  },
                  onTapStay: () {
                    setState(() {
                      alert = false;
                    });
                  },
                )
              : Stack(
                  children: [
                    (isMinimum) ? SizedBox.shrink() :ExitButton(
                      onPress: () {
                        if (ageController.text != '' ||
                            nameController.text != "" ||
                            vacancyController.text != "" ||
                            sourceController.text != "") {
                          setState(() {
                            alert = true;
                          });
                        } else {
                          ExitVoid(bloc, context);
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const SizedBox(height: 15),
                            // Row(children: [Text("Создание резюме")],),
                            TextStateWidget(),
                            const SizedBox(height: 20),
                            InputTextWidget(
                              text: "ФИО",
                              controller: nameController,
                              isAge: false,
                            ),
                            StreamBuilder(
                                stream: bloc.observeRoleSubject(),
                                builder: (contex, snapshot) {
                                  if (snapshot.data == Role.hr_lead) {
                                    return Column(children: [
                                      const SizedBox(height: 20),
                                      HrListWidget(),
                                    ]);
                                  }
                                  return SizedBox.shrink();
                                }),

                            const SizedBox(height: 20),
                            ResumeListWidget(
                              text: 'Вакансия',
                              controller: vacancyController,
                            ),
                            const SizedBox(height: 20),
                            InputTextWidget(
                                text: "Возраст",
                                controller: ageController,
                                isAge: true),
                            const SizedBox(height: 20),
                            ResumeListWidget(
                                text: "Источник", controller: sourceController),
                            const SizedBox(height: 20),
                            CommentsInputWidget(),
                            const SizedBox(height: 20),
                            SendResumeButton(),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
        );
      }
    );
  }

  void ExitVoid(Bloc bloc, context) {
    ageController.clear();
    sourceController.clear();
    vacancyController.clear();
    nameController.clear();
    commentsController.clear();
    bloc.cancelCreateSubscription();
    alert = false;
    hrController = '';
    Navigator.pop(context);
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
    return StreamBuilder<ResumeList>(
        stream: bloc.observeResumeListSubject(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return SizedBox.shrink();
          }
          late List<String> resumeList;
          if (widget.text == 'Вакансия') {
            resumeList = snapshot.data!.vacancy;
          } else if (widget.text == 'Источник') {
            resumeList = snapshot.data!.source;
          }

          return ValueListenableBuilder(
              valueListenable: widget.controller,
              builder: (context, value, child) {
                if (!resumeList.contains(value.text)) {
                  print(resumeList);
                  if (resumeList.isEmpty) {
                    print("inputTExtWidget");
                    return InputTextWidget(
                        text: widget.text,
                        controller: widget.controller,
                        isAge: false);
                  }
                  return InputTextWithSuffixWidget(
                    text: widget.text,
                    controller: widget.controller,
                    resumeList: resumeList,
                  );
                }
                return DropdownWidget(
                    text: widget.text,
                    width: 200,
                    listOfValue: resumeList + ['Добавить'],
                    isArchiv: false);
              });
        });
  }
}

class AlertDialogWidget extends StatelessWidget {
  final VoidCallback ExitTap;
  final VoidCallback onTapStay;

  const AlertDialogWidget({
    super.key,
    required this.onTapStay,
    required this.ExitTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      height: 150,
      width: 300,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: AppColors.color200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 40,
          ),
          Center(
              child: Text(
            'Данные не сохраняться!',
            style: TextStyle(color: AppColors.color50),
          )),
          const Expanded(child: SizedBox()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                  onTap: ExitTap, child: ButtonOnAlertDialog(text: "Выйти")),
              GestureDetector(
                onTap: onTapStay,
                child: ButtonOnAlertDialog(text: "Остаться"),
              )
            ],
          ),
        ],
      ),
    ));
  }
}

class ButtonOnAlertDialog extends StatelessWidget {
  final String text;

  const ButtonOnAlertDialog({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: 40,
        width: 150,
        decoration: BoxDecoration(
            // color: AppColors.color800,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: AppColors.color50, width: 0.5)),
        child: Text(
          text,
          style: TextStyle(color: AppColors.color50),
        ));
  }
}

class ExitWidget extends StatelessWidget {
  final VoidCallback onTap;

  const ExitWidget({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: AppColors.color900, borderRadius: BorderRadius.circular(10)),
        child: Icon(
          Icons.logout,
          color: Colors.white,
        ),
      ),
    );
  }
}

class TextStateWidget extends StatelessWidget {
  const TextStateWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    return StreamBuilder(
        stream: bloc.observeStateCreateButton(),
        builder: (context, snapshot) {
          switch (snapshot.data) {
            case null:
            case StateRequest.none:
              return MainTextWidget(text: "Добавить резюме");
            case StateRequest.loading:
              return MainTextWidget(text: 'Загруза резюме');
            case StateRequest.error:
              return MainTextWidget(text: "Ошибка");
            // case StateRequest.idError:
            //   return MainTextWidget(text: "Перезайдите");
            case StateRequest.good:
              return MainTextWidget(text: "Резюме добавлено");
            default:
              return MainTextWidget(text: "Добавить резюме");
          }
        });
  }
}

class MainTextWidget extends StatelessWidget {
  final String text;

  const MainTextWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            color: AppColors.color900,
            fontSize: 40,
            fontWeight: FontWeight.w900));
  }
}

class InputTextWithSuffixWidget extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final resumeList;

  const InputTextWithSuffixWidget(
      {super.key,
      required this.text,
      required this.controller,
      required this.resumeList});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 40,
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: AppColors.color50,
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 4,
              offset: Offset(0, 4))
        ],
        border: Border.all(
            //Todo поменять на ошибку
            color:
                false ? Color.fromRGBO(255, 51, 51, 0.50) : AppColors.color900,
            width: false ? 2 : 1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: "",
          label: Text(
            text,
            style: TextStyle(color: AppColors.color900),
          ),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            color: AppColors.color900,
            onPressed: () {
              switch (text) {
                case 'Вакансия':
                  vacancyController.text = resumeList[0];
                case 'Источник':
                  sourceController.text = resumeList[0];
                //Доделать источник и добавить эту кнопку в вакансию
              }
            },
          ),
        ),
      ),
    );
  }
}

class InputTextWidget extends StatefulWidget {
  final String text;
  final TextEditingController controller;
  final isAge;

  const InputTextWidget({
    super.key,
    required this.text,
    required this.controller,
    required this.isAge,
  });

  @override
  State<InputTextWidget> createState() => _InputTextWidgetState();
}

class _InputTextWidgetState extends State<InputTextWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 40,
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: AppColors.color50,
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 4,
              offset: Offset(0, 4))
        ],
        border: Border.all(
            //Todo поменять на ошибку
            color:
                false ? Color.fromRGBO(255, 51, 51, 0.50) : AppColors.color900,
            width: false ? 2 : 1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: TextField(
        controller: widget.controller,
        onTap: () {
          setState(() {
            // usernameError = false;
          });
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
            hintText: "",
            label: Text(
              widget.text,
              style: TextStyle(color: AppColors.color900),
            ),
            border: InputBorder.none,
            suffixIcon: null),
        inputFormatters: widget.isAge
            ? [
                FilteringTextInputFormatter.digitsOnly
              ] // Только цифры, если isAge = true
            : [],
      ),
    );
  }
}

class CommentsInputWidget extends StatelessWidget {
  const CommentsInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 150,
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: AppColors.color50,
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 4,
              offset: Offset(0, 4))
        ],
        border: Border.all(
            //Todo поменять на ошибку
            color:
                false ? Color.fromRGBO(255, 51, 51, 0.50) : AppColors.color900,
            width: false ? 2 : 1),
        borderRadius: BorderRadius.circular(9),
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
            hintText: "",
            label: Text(
              "Комментарий",
              style: TextStyle(color: AppColors.color900),
            ),
            border: InputBorder.none,
            suffixIcon: null),
      ),
    );
  }
}

class SendResumeButton extends StatefulWidget {
  const SendResumeButton({
    super.key,
  });

  @override
  State<SendResumeButton> createState() => _SendResumeButtonState();
}

class _SendResumeButtonState extends State<SendResumeButton> {
  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);

    return StreamBuilder<StateRequest>(
        stream: bloc.observeStateCreateButton(),
        builder: (context, snapshot) {
          if (snapshot.data == StateRequest.loading) {
            return RedButtonWidget(
              onTap: () {},
              text: 'Загрузка',
              width: 350,
              height: 40,
              focus: false,
            );
          }

          if (snapshot.data == StateRequest.good) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ageController.clear();
              sourceController.clear();
              vacancyController.clear();
              nameController.clear();
              commentsController.clear();
              hrController = "";
            });
          }
          return RedButtonWidget(
            onTap: () {
              if (ageController.text != "") {
                bloc.resumeVacancyControllerSubject.add(vacancyController.text);
                bloc.resumeNameControllerSubject.add(nameController.text);
                bloc.resumeAgeControllerSubject.add(ageController.text);
                bloc.resumeSourceControllerSubject.add(sourceController.text);
                bloc.resumeCommentsControllerSubject
                    .add(commentsController.text);
                bloc.resumeHrNameControllerSubject.add(hrController);
                bloc.sendResumeToCreate();
              }
            },
            text: 'Добавить',
            width: 350,
            height: 40,
            focus: true,
          );
        });
  }
}

// class ButtonWidget extends StatelessWidget {
//   final VoidCallback onTap;
//   final Color color;
//
//   const ButtonWidget({
//     super.key,
//     required this.onTap,
//     required this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         alignment: Alignment.center,
//         width: 350,
//         height: 40,
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(9),
//         ),
//         child: Text("Добавить",
//             style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w400)),
//       ),
//     );
//   }
// }

class HrListWidget extends StatefulWidget {
  const HrListWidget({super.key});

  @override
  State<HrListWidget> createState() => _HrListWidgetState();
}

class _HrListWidgetState extends State<HrListWidget> {
  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    return StreamBuilder<ResumeList>(
        stream: bloc.observeResumeListSubject(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return SizedBox.shrink();
          }
          hrController = snapshot.data!.hrList[0];
          return DropdownWidget(
            text: 'Hr',
            width: 200,
            listOfValue: snapshot.data!.hrList,
            isArchiv: false,
          );
        });
  }
}

class DropdownWidget extends StatefulWidget {
  final String text;
  final double width;
  final List<String> listOfValue;
  final bool isArchiv;

  // final

  const DropdownWidget(
      {Key? key,
      required this.text,
      required this.width,
      required this.listOfValue,
      required this.isArchiv})
      : super(key: key);

  @override
  _DropdownWidgetState createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  String? selectedValue;

  // Список вариантов для выпадающего меню

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 40,
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: AppColors.color50,
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 4,
              offset: Offset(0, 4))
        ],
        border: Border.all(
            //Todo поменять на ошибку
            color:
                false ? Color.fromRGBO(255, 51, 51, 0.50) : AppColors.color900,
            width: false ? 2 : 1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Container(
        // height: 48,
        width: widget.width,
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(
            widget.listOfValue[0],
            style: TextStyle(fontSize: 16, color: AppColors.color900),
          ),
          isExpanded: true,
          underline: SizedBox(),
          items: widget.listOfValue.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(fontSize: 16, color: AppColors.color900),
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

class ExitButton extends StatelessWidget {
  final VoidCallback onPress;

  const ExitButton({
    super.key,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: IconButton(
        onPressed: onPress,
        icon: Icon(Icons.logout),
        constraints: BoxConstraints(
          minWidth: 70.0,
          minHeight: 70.0,
        ),
        focusNode: FocusNode(skipTraversal: true),
        color: AppColors.color50,
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
                return AppColors.color800;
              }
              return AppColors.color900;
            },
          ),
        ),
      ),
    );
  }
}
