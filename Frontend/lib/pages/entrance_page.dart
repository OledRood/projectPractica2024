import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hr_monitor/widgets/buttonRedWidget.dart';
import 'package:provider/provider.dart';

import '../bloc/bloc.dart';
import '../resources/theme/theme.dart';

var usernameError = false;
var passwordError = false;
String text = 'Вход';
var _passwordController = TextEditingController();
var _usernameController = TextEditingController();

// class EntrancePage extends StatelessWidget {
//   const EntrancePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     usernameError = false;
//     return EntrancePage();
//   }
// }

class EntrancePage extends StatefulWidget {
  const EntrancePage({
    super.key,
  });

  @override
  State<EntrancePage> createState() => _EntrancePageState();
}

class _EntrancePageState extends State<EntrancePage> {
  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    final palette = Provider.of<AppTheme>(context).palette;

    usernameError = false;
    passwordError = false;
    return Scaffold(
        backgroundColor: palette.color50,
        body: StreamBuilder<StateRequest>(
            stream: bloc.observeStateLogInSubject(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                    child: Text(
                  'Программа сломалась :(',
                  style: Theme.of(context).textTheme.bodyMedium,
                ));
              }
              if (snapshot.data == StateRequest.bad) {
                usernameError = true;
                passwordError = true;
              }
              if (snapshot.data == StateRequest.good) {
                Future.microtask(() {
                  _passwordController.clear();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    "/MainPage",
                    (Route<dynamic> route) => false,
                  );
                  // bloc.stateLogInSubject.add(StateContentRequest.none);
                });
              }
              return WindowWidget();
            }));
  }
}

class WindowWidget extends StatefulWidget {
  const WindowWidget({
    super.key,
  });

  @override
  State<WindowWidget> createState() => _WindowWidgetState();
}

class _WindowWidgetState extends State<WindowWidget> {
  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);

    return Center(
      child: Container(
        height: 400,
        width: 400,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(),
        child: Column(
          children: [
            RequestStatusWidget(),
            SizedBox(
              height: 15,
            ),
            UserInputWidget(text: 'Пользователь'),
            SizedBox(
              height: 10,
            ),
            PasswordWidget(text: 'Пароль'),
            const SizedBox(
              height: 10,
            ),
            RedButtonWidget(
              onTap: () {
                if (_usernameController.text == "") {
                  print("username error");
                  usernameError = true;
                }
                if (_passwordController.text == "") {
                  print("password error");
                  passwordError = true;
                }
                if (_usernameController.text != "" &&
                    _passwordController.text != "") {
                  print("TAP");
                  bloc.usernameControllerSubject.add(_usernameController.text);
                  bloc.passwordControllerSubject.add(_passwordController.text);
                  bloc.sendPassWordAndLogin();
                }
                setState(() {});
              },
              text: 'Войти',
              width: 350,
              height: 40,
              focus: true,
            )
            // FocusTraversalGroup(child: LogInWidget()),
          ],
        ),
      ),
    );
  }
}

class RequestStatusWidget extends StatefulWidget {
  const RequestStatusWidget({
    super.key,
  });

  @override
  State<RequestStatusWidget> createState() => _RequestStatusWidgetState();
}

class _RequestStatusWidgetState extends State<RequestStatusWidget> {
  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    final palette = Provider.of<AppTheme>(context).palette;

    bool isTextDeffault = (text == 'Вход');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
              color: palette.color900,
              fontSize: 40,
              fontWeight: FontWeight.w900),
        ),
        StreamBuilder(
            stream: bloc.observeStateLogInPageContent(),
            builder: (context, snapshot) {
              switch (snapshot.data) {
                case StateRequest.loading:
                  return Row(
                    children: [
                      text == "Вход" ? SizedBox(width: 220) : SizedBox.shrink(),
                      CircularProgressIndicator(
                        color: palette.color900,
                        strokeWidth: 2.5,
                      ),
                    ],
                  );
                case StateRequest.serverError:
                  return Row(
                    children: [
                      isTextDeffault
                          ? SizedBox(width: 237)
                          : SizedBox(width: 168.5),
                      IconStatusWidget(
                        height: 12,
                        icon: Icons.error_outline_outlined,
                        onTap: () {
                          if (text != "Вход") {
                            setState(() {
                              text = "Вход";
                            });
                          } else {
                            setState(() {
                              text = "Cервера";
                            });
                          }
                        },
                      )
                    ],
                  );
                case StateRequest.errorConnection:
                  return Row(
                    children: [
                      isTextDeffault
                          ? SizedBox(width: 220)
                          : SizedBox(width: 143.8),
                      Column(
                        children: [
                          IconStatusWidget(
                              height: 0,
                              icon: Icons.running_with_errors_outlined,
                              onTap: () {
                                if (text != "Вход") {
                                  setState(() {
                                    text = "Вход";
                                  });
                                } else {
                                  setState(() {
                                    text = "Времени";
                                  });
                                }
                              })
                        ],
                      )
                    ],
                  );
                default:
                  return SizedBox.shrink();
              }
            }),
      ],
    );
  }
}

class IconStatusWidget extends StatefulWidget {
  final VoidCallback onTap;
  final double height;
  final IconData icon;

  const IconStatusWidget(
      {super.key,
      required this.height,
      required this.icon,
      required this.onTap});

  @override
  State<IconStatusWidget> createState() => _IconStatusWidgetState();
}

class _IconStatusWidgetState extends State<IconStatusWidget> {
  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;

    return Tooltip(
      message: "Ошибка...",
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          children: [
            SizedBox(height: widget.height),
            Icon(
              widget.icon,
              color: palette.color900,
            ),
          ],
        ),
      ),
    );
  }
}

class UserInputWidget extends StatefulWidget {
  final String text;

  const UserInputWidget({
    super.key,
    required this.text,
  });

  @override
  State<UserInputWidget> createState() => _UserInputWidgetState();
}

class _UserInputWidgetState extends State<UserInputWidget> {
  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;
    return GestureDetector(
      onTap: () {
        usernameError = false;
      },
      child: Container(
        width: 350,
        height: 40,
        decoration: BoxDecoration(
          color: palette.color50,
          boxShadow: [
            BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 4,
                offset: Offset(0, 4))
          ],
          border: Border.all(
              color: usernameError
                  ? Color.fromRGBO(255, 51, 51, 0.50)
                  : palette.color900,
              width: usernameError ? 1 : 1),
          borderRadius: BorderRadius.circular(9),
        ),
        child: TextField(
          controller: _usernameController,
          textAlignVertical: TextAlignVertical.center,
          onTap: () {
            setState(() {
              usernameError = false;
            });
          },
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
              hintText: widget.text,
              prefixIcon: Icon(Icons.person_outline),
              suffixIcon: null),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}

class PasswordWidget extends StatefulWidget {
  final String text;

  PasswordWidget({
    super.key,
    required this.text,
  });

  @override
  State<PasswordWidget> createState() => _PasswordWidgetState();
}

class _PasswordWidgetState extends State<PasswordWidget> {
  bool hideText = true;

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;
    return GestureDetector(
      onTap: () {
        passwordError = false;
      },
      child: Container(
        width: 350,
        height: 40,
        decoration: BoxDecoration(
          color: palette.color50,
          boxShadow: [
            BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 4,
                offset: Offset(0, 4))
          ],
          border: Border.all(
              color: passwordError
                  ? Color.fromRGBO(255, 51, 51, 0.50)
                  : palette.color900,
              width: passwordError ? 1 : 1),
          borderRadius: BorderRadius.circular(9),
        ),
        // padding: EdgeInsets.only(bottom:1,
        alignment: Alignment.center,
        child: TextField(
          controller: _passwordController,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp("^[\\u0000-\\u007F\\u0410-\\u044F]+\$"))
          ],
          autocorrect: false,
          obscureText: hideText,
          textAlignVertical: TextAlignVertical.center,
          onTap: () {
            setState(() {
              passwordError = false;
            });
          },
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            suffixIcon: GestureDetector(
              child: Icon(hideText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onTap: () => setState(() => hideText = !hideText),
            ),
            hintText: "Пароль",
            contentPadding: EdgeInsets.only(bottom: 12),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
          enableSuggestions: true,
        ),
      ),
    );
  }
}
