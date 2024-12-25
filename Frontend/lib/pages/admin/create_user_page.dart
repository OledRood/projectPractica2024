import 'package:flutter/material.dart';
import 'package:hr_monitor/bloc/admin.dart';
import 'package:provider/provider.dart';

import '../../bloc/bloc.dart';
import '../../resources/roles.dart';
import '../../resources/theme/theme.dart';
import '../../widgets/buttonRedWidget.dart';
import '../create_resume_page.dart';

bool alert = false;

var usernameController = TextEditingController();
var roleController = TextEditingController();
var passwordController = TextEditingController();
var hrLeadController = TextEditingController();

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    final palette = Provider.of<AppTheme>(context).palette;
    entranceVoid(bloc);
    return Scaffold(
      backgroundColor: palette.color50,
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
                ExitButton(
                  onPress: () {
                    if (usernameController.text != '') {
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
                          controller: usernameController,
                          isAge: false,
                        ),

                        const SizedBox(height: 20),
                        InputTextWidget(
                          text: "Пароль",
                          controller: passwordController,
                          isAge: false,
                        ),
                        const SizedBox(height: 20),

                        RoleListWidget(
                          text: 'Роль',
                          controller: roleController,
                        ),
                        const SizedBox(height: 20),
                        HrLeadListWidget(
                            controller: hrLeadController, text: "Hr_lead"),
                        SendUserButton(),
                      ],
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  void entranceVoid(Bloc bloc) {
    usernameController.text = '';
    roleController.text = 'Hr';
    passwordController.text = '';
    bloc.sendGetHrLeadList();
    bloc.cleanUsersController();
  }

  void ExitVoid(Bloc bloc, context) {
    usernameController.text = '';
    roleController.text = '';
    passwordController.text = '';
    hrLeadController.text = '';
    bloc.cleanUsersController();
    alert = false;
    Navigator.pop(context);
    print('exitvoid start');
  }
}

class HrLeadListWidget extends StatefulWidget {
  final TextEditingController controller;
  final String text;

  const HrLeadListWidget(
      {super.key, required this.controller, required this.text});

  @override
  State<HrLeadListWidget> createState() => _HrLeadListWidgetState();
}

class _HrLeadListWidgetState extends State<HrLeadListWidget> {
  String? selectedHrLead;
  bool showHrLeadWidget = true;

  @override
  void initState() {
    super.initState();
    roleController.addListener(_roleControllerListener);
  }

  void _roleControllerListener() {
    if (!mounted) return; // Проверка на существование виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          showHrLeadWidget = roleController.text == 'Hr';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    final palette = Provider.of<AppTheme>(context).palette;
    return showHrLeadWidget
        ? Column(
            children: [
              Container(
                width: 350,
                height: 45,
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
                      color: palette.color900,
                      width: 1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: StreamBuilder<List<String>>(
                    stream: bloc.observeHrLeadList(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return SizedBox.shrink();
                      }
                      List<String> hrLeadList = snapshot.data!;
                      if (snapshot.data == []) {
                        return Center(
                            child:
                                Text("Добавте сначала хотя бы одного hr_lead"));
                      }
                      return DropdownButton<String>(
                        value: selectedHrLead,
                        hint: Text(
                          hrLeadList[0],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        isExpanded: true,
                        underline: SizedBox(),
                        items: hrLeadList
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
                            selectedHrLead = newValue!;
                            hrLeadController.text = selectedHrLead!;
                          });
                        },
                      );
                    }),
              ),
              SizedBox(height: 20),
            ],
          )
        : SizedBox.shrink();
  }

  @override
  void dispose() {
    roleController
        .removeListener(_roleControllerListener); // Удаление слушателя
    super.dispose();
  }
}

class RoleListWidget extends StatefulWidget {
  final TextEditingController controller;
  final String text;

  const RoleListWidget(
      {super.key, required this.controller, required this.text});

  @override
  State<RoleListWidget> createState() => _RoleListWidgetState();
}

class _RoleListWidgetState extends State<RoleListWidget> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    List<String> roleList = Roles.getAllStringRoles();
    final palette = Provider.of<AppTheme>(context).palette;
    return Container(
      width: 350,
      height: 45,
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
            color: palette.color900,
            width: 1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        hint: Text(
          roleList[0],
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        isExpanded: true,
        underline: SizedBox(),
        items: roleList.map<DropdownMenuItem<String>>((String value) {
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
            selectedValue = newValue!;
            roleController.text = selectedValue!;
          });
        },
      ),
    );
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
    final palette = Provider.of<AppTheme>(context).palette;
    return Center(
        child: Container(
      height: 150,
      width: 300,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: palette.color200,
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
            style: Theme.of(context).textTheme.headlineMedium,
          )),
          const Expanded(child: SizedBox()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                  onTap: ExitTap,
                  child: ButtonOnAlertDialog(
                    text: "Выйти",
                  )),
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
    final palette = Provider.of<AppTheme>(context).palette;
    return Container(
        alignment: Alignment.center,
        height: 40,
        width: 150,
        decoration: BoxDecoration(
            // color: palette.color800,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: palette.color50, width: 0.5)),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
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
    final palette = Provider.of<AppTheme>(context).palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: palette.color900, borderRadius: BorderRadius.circular(10)),
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
            case StateRequest.loading:
              return MainTextWidget(text: 'Загруза пользователя');
            case StateRequest.error:
              return MainTextWidget(text: "Ошибка");
            case StateRequest.tokenError:
              return MainTextWidget(text: 'Ошибка токена');
            case StateRequest.good:
              return MainTextWidget(text: "Пользователь создан");
            case null:
            case StateRequest.none:
            default:
              return MainTextWidget(text: "Добавить пользователя");
          }
        });
  }
}

class SendUserButton extends StatefulWidget {
  const SendUserButton({
    super.key,
  });

  @override
  State<SendUserButton> createState() => _SendUserButtonState();
}

class _SendUserButtonState extends State<SendUserButton> {
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
              roleController.clear();
              usernameController.clear();
              passwordController.clear();
            });
          }
          return RedButtonWidget(
            onTap: () {
              if (usernameController.text != "" &&
                  passwordController.text != '') {
                bloc.createUsernameSubject.add(usernameController.text);
                bloc.createUserPasswordSuject.add(passwordController.text);
                bloc.createUserRoleSubject.add(roleController.text);
                bloc.createUsersHrLeadSuject.add(hrLeadController.text);
                bloc.createUsersHrLeadSuject.add(hrLeadController.text == ""
                    ? bloc.hrLeadListSubject.value[0]
                    : hrLeadController.text);

                bloc.sendUserToCreate();
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
