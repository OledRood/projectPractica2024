import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bloc/bloc.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import '../models/admin/users_data.dart';
import '../pages/main_page.dart';
import '../resources/theme/theme.dart';
import '../types/full_resume.dart';

bool isActiveResume = true;

class ListOfUsersWidget extends StatefulWidget {
  const ListOfUsersWidget({super.key});

  @override
  State<ListOfUsersWidget> createState() => _ListOfUsersWidgetState();
}

class _ListOfUsersWidgetState extends State<ListOfUsersWidget> {
  double widgetWidth =510;

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<AppTheme>(context).palette;
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    return Container(
      alignment: Alignment.center,
      height: 600,
      width: widgetWidth,
      // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: BoxDecoration(
          color: palette.color200, borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Container(
              height: 600,
              width: widgetWidth,
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: ResumesListWidgetInside(
                isActiveResume: isActiveResume,
              )),
          Container(
              alignment: Alignment.center,
              height: 50,
              width: widgetWidth,
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
                  Expanded(child: SizedBox()),
                  RestartWidget(onPress: () {
                    bloc.sendGetUsersList();
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
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    return StreamBuilder<StateRequest>(
        stream: bloc.observeUsersListState(),
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
              return StreamBuilder<List<UserTable>>(
                  stream: bloc.observeUsersList(),
                  builder: (context, users) {
                    if (!users.hasData ||
                        users.data == null ||
                        users.data == []) {
                      return const SizedBox.shrink();
                    }
                    final List listUsers = users.data ?? [];

                    return ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: ListView.separated(
                        itemCount: listUsers.length + 1,
                        itemBuilder: (build, int index) {
                          if (index == 0) {
                            //TODO высота козырька
                            return SizedBox(
                              height: 40,
                            );
                          }
                          final UserTable user = listUsers[index - 1];
                          return GestureDetector(
                            onTap: () {
                              // mainBloc.resumeIdControllerSubject
                              //     .add(resume.resumeId);
                              Navigator.pushNamed(
                                context,
                                '/MainPage/ChangeAndDeleteUser',
                                arguments: user,
                              );
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
                                        text: 'Имя: ',
                                        isHeadLine: true,
                                      ),
                                      TextWidget(
                                        text: user.username,
                                        isHeadLine: false,
                                      ),
                                      SizedBox(width: 20),
                                      TextWidget(
                                        text: 'Роль: ',
                                        isHeadLine: true,
                                      ),
                                      TextWidget(
                                        text: user.role,
                                        isHeadLine: false,
                                      ),
                                    ],
                                  ),
                                  // Expanded(child: SizedBox()),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  //
                                  // Row(
                                  //   children: [
                                  //     TextWidget(
                                  //       text: "Вакансия: ",
                                  //       isHeadLine: true,
                                  //     ),
                                  //     TextWidget(
                                  //       text: resume.vacancy,
                                  //       isHeadLine: false,
                                  //     ),
                                  //     Expanded(
                                  //       child: SizedBox(),
                                  //     ),
                                  //     TextWidget(
                                  //       text: 'Статус: ',
                                  //       isHeadLine: true,
                                  //     ),
                                  //     TextWidget(
                                  //       text: resume.status,
                                  //       isHeadLine: false,
                                  //     ),
                                  //   ],
                                  // ),
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
                      ),
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
