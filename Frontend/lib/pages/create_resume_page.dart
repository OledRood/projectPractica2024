import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../bloc/main_bloc.dart';
import '../resources/app_colors.dart';

var alert = true;

var vacancyController = TextEditingController();
var ageController = TextEditingController();
var sourceController = TextEditingController();
var nameController = TextEditingController();

class CreateResumePage extends StatefulWidget {
  const CreateResumePage({super.key});

  @override
  State<CreateResumePage> createState() => _CreateResumePageState();
}

class _CreateResumePageState extends State<CreateResumePage> {
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
    return Provider.value(value: mainBloc, child: PageContent());
  }
}

class PageContent extends StatefulWidget {
  const PageContent({
    super.key,
  });

  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color50,
      body: alert
          ? AlertDialogWidget(
              onTapStay: () {
                setState(() {
                  alert = false;
                });
              },
            )
          : Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          height: 317,
                        ),
                        ExitWidget(
                          onTap: () {
                            if (ageController.text != '' ||
                                nameController.text != "" ||
                                vacancyController.text != "" ||
                                sourceController.text != "") {
                              setState(() {
                                alert = true;
                              });
                            } else {
                              ageController.clear();
                              sourceController.clear();
                              vacancyController.clear();
                              nameController.clear();
                              alert = false;
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(width: 430)
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Row(children: [Text("Создание резюме")],),
                        TextStateWidget(),
                        const SizedBox(height: 20),
                        InputTextWidget(
                          text: "Имя",
                          controller: nameController,
                          isAge: false,
                        ),
                        const SizedBox(height: 20),
                        InputTextWidget(
                          text: "Вакансия",
                          controller: vacancyController,
                          isAge: false,
                        ),
                        const SizedBox(height: 20),
                        InputTextWidget(
                            text: "Возраст",
                            controller: ageController,
                            isAge: true),
                        const SizedBox(height: 20),
                        InputTextWidget(
                            text: "Источник",
                            controller: sourceController,
                            isAge: false),
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
}

class AlertDialogWidget extends StatelessWidget {
  final VoidCallback onTapStay;

  const AlertDialogWidget({
    super.key,
    required this.onTapStay,
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
                  onTap: () {
                    ageController.clear();
                    sourceController.clear();
                    vacancyController.clear();
                    nameController.clear();
                    alert = false;
                    Navigator.pop(context);
                  },
                  child: ButtonOnAlertDialog(text: "Выйти")),
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
        // child: Text(
        //   'Выход',
        //   style: TextStyle(
        //     color: Colors.white,
        //   ),
        // ),
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
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder(
        stream: bloc.stateButtonLoading,
        builder: (context, snapshot) {
          switch (snapshot.data) {
            case null:
            case StateRequest.none:
              return MainTextWidget(text: "Добавить резюме");
            case StateRequest.loading:
              return MainTextWidget(text: 'Загруза резюме');
            case StateRequest.error:
              return MainTextWidget(text: "Ошибка");
            case StateRequest.idError:
              return MainTextWidget(text: "Перезайдите");
            case StateRequest.good:
              return MainTextWidget(text: "Резюме добавлено");
          }
          return MainTextWidget(text: "Добавить резюме");
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

class SendResumeButtonView extends StatefulWidget {
  const SendResumeButtonView({super.key});

  @override
  State<SendResumeButtonView> createState() => _SendResumeButtonViewState();
}

class _SendResumeButtonViewState extends State<SendResumeButtonView> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class SendResumeButton extends StatelessWidget {
  const SendResumeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);

    return StreamBuilder<StateRequest>(
        stream: bloc.stateButtonLoading,
        builder: (context, snapshot) {
          if (snapshot.data == StateRequest.loading ||
              snapshot.data == StateRequest.idError) {
            return ButtonWidget(onTap: () {}, color: AppColors.color100);
          }

          if (snapshot.data == StateRequest.good) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ageController.clear();
              sourceController.clear();
              vacancyController.clear();
              nameController.clear();
            });
          }
          return ButtonWidget(
            onTap: () {
              if (ageController.text != "") {
                bloc.vacancyControllerSubject.add(vacancyController.text);
                bloc.nameControllerSubject.add(nameController.text);
                bloc.ageControllerSubject.add(int.parse(ageController.text));
                bloc.sourceControllerSubject.add(sourceController.text);
              }
            },
            color: AppColors.color900,
          );
        });
  }
}

class ButtonWidget extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;

  const ButtonWidget({
    super.key,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: 350,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text("Добавить",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400)),
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
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
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
            ? [FilteringTextInputFormatter.digitsOnly] // Только цифры, если isAge = true
            : [],
      ),
    );
  }
}
