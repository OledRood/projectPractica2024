import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hr_monitor/models/resume_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../bloc/bloc.dart';
import '../resources/app_colors.dart';
import '../resources/status.dart';
import '../types/full_resume.dart';

bool open = true;
// String nameController ='';
// String searchTextController ='';
// String vacancyController ='';
// String sourceController ='';
// String ageController ='';

final nameController = TextEditingController();
final searchTextController = TextEditingController();
String archivController = "";
final vacancyController = TextEditingController();
String statusController = "Любой";
String hrController = 'Любой';
final sourceController = TextEditingController();
final ageController = TextEditingController();
DateTime? fromDataTimeController;
DateTime? toDataTimeController;

const double minStatisticsDisplayWidth = 934;

final class ResumeSearchPage extends StatefulWidget {
  const ResumeSearchPage({super.key});

  @override
  State<ResumeSearchPage> createState() => _ResumeSearchPageState();
}

class _ResumeSearchPageState extends State<ResumeSearchPage> {
  final double heigthAppBar = 60;

  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: true);
    clear(bloc);
    searchTextController.text = "";
    return LayoutBuilder(builder: (context, constraint) {
      return Scaffold(
          backgroundColor: AppColors.color100,
          body: Stack(
            children: [
              //Список полученных результатов
              ContentListWidget(
                displayWidth: constraint.maxWidth,
              ),
              //Поиск и фильтры
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: LayoutBuilder(builder: (context, constraint) {
                  print(constraint.maxWidth);
                  return Column(
                    children: [
                      ContentAppBar(
                          onTapFilteresButton: () {
                            setState(() {
                              open = !open;
                            });
                          },
                          open: open,
                          heigthAppBar: heigthAppBar),
                      FiltersWidget(
                        open: open,
                        displayWidth: constraint.maxWidth,
                      )
                    ],
                  );
                }),
              ),
            ],
          ));
    });
  }

  void clear(Bloc bloc) {
    bloc.cleanResumeControllers();
    //Используем для очистки при перезаходе на страницу иначе срабатывает даже без нажатий
    statusController = "Любой";
    hrController = 'Любой';
    archivController = "";
    fromDataTimeController = null;
    toDataTimeController = null;
  }
}

class ContentListWidget extends StatelessWidget {
  final double displayWidth;

  const ContentListWidget({super.key, required this.displayWidth});

  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: true);
    print('width: ${displayWidth - 120}');
    return StreamBuilder<StateRequest>(
        stream: bloc.stateSearchListWidget,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return SizedBox.shrink();
          }
          // final data = StateSearchList.result;
          switch (snapshot.data) {
            case StateRequest.none:
              return const SizedBox.shrink();
            case StateRequest.error:
              return Center(
                  child: Text(
                "Что-то сломалось...",
                style: TextStyle(
                    color: AppColors.color300,
                    fontSize: 80,
                    fontWeight: FontWeight.w900),
              ));

            case StateRequest.loading:
              return Center(child: CircularProgressIndicator());
            case StateRequest.good:
              return Padding(

                padding: (displayWidth >= minStatisticsDisplayWidth)
                    ? EdgeInsets.only(left: 102, right: displayWidth - 903)
                    // : EdgeInsets.symmetric(horizontal: (displayWidth + 20 - 200)),
                    : EdgeInsets.symmetric(horizontal: (20)),
                child: ListWidget(open: open),
              );
            case StateRequest.nothingFound:
              return Container(
                  child: Center(
                child: Text(
                  'Ничего не найдено',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.color50),
                ),
              ));
            default:
              return Container();
          }
        });
  }
}

class ListWidget extends StatefulWidget {
  final bool open;

  const ListWidget({super.key, required this.open});

  @override
  State<ListWidget> createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: true);
    return StreamBuilder<List<FullResumeInfo>>(
        stream: bloc.observeSearchedResume(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return SizedBox.shrink();
          }
          return ListView.separated(
            itemCount: (snapshot.data!.length + 1),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return open
                    ? SizedBox(height: 250)
                    : SizedBox(
                        height: 70,
                      );
              }
              final content = snapshot.data![index - 1];
              return Container(
                  alignment: Alignment.centerLeft,
                  child: ResumeWidget(content: content));
            },
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: 20,
              );
            },
          );
          return Container(
            height: 70,
            width: 100,
            color: Colors.black,
          );
        });
  }
}

class ResumeWidget extends StatefulWidget {
  final FullResumeInfo content;

  const ResumeWidget({
    super.key,
    required this.content,
  });


  @override
  State<ResumeWidget> createState() => _ResumeWidgetState();
}

class _ResumeWidgetState extends State<ResumeWidget> {
  final double title = 20;

  final double textFontSize = 19;

  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: true);

    return GestureDetector(
      onTap: () {
        bloc.resumeIdControllerSubject.add(widget.content.resumeId);
        Navigator.pushNamed(context, '/MainPage/InfoResumePage');
      },
      child: Container(
        // width: 900,
        // height: 120,
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5, top: 10),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
            color: AppColors.color900, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  widget.content.fullName,
                  style: TextStyle(
                      color: AppColors.color100,
                      fontSize: title,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Container(height: 0.5, width: 200, color: Colors.white),
          SizedBox(height: 15),
          Row(
            children: [
              TextWidget(
                text: 'Вакансия: ${widget.content.vacancy}',
                textFontSize: textFontSize,
              ),
              const SeparateWidget(),
              TextWidget(
                  text: 'Источник:  ${widget.content.source}',
                  textFontSize: textFontSize),
              const SeparateWidget(),
              TextWidget(
                  text: "Статус: ${widget.content.status}",
                  textFontSize: textFontSize),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              TextWidget(
                  text: "Возраст: ${widget.content.age}", textFontSize: textFontSize),
              const SeparateWidget(),
              TextWidget(
                  text:
                      'Состояние: ${(widget.content.archiv == 1) ? 'В архиве' : 'Активно'}',
                  textFontSize: textFontSize),
              StreamBuilder<Role>(
                  stream: bloc.observeRoleSubject(),
                  builder: (context, roleSnapshot) {
                    if (roleSnapshot.data == Role.hr_lead) {
                      return Row(
                        children: [
                          const SeparateWidget(),
                          TextWidget(
                              text: 'Hr:  ${widget.content.hrName}',
                              textFontSize: textFontSize),
                        ],
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  }),
            ],
          ),
        ]),
      ),
    );
  }
}

class SeparateWidget extends StatelessWidget {
  const SeparateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      height: 20,
      width: 0.5,
      color: Colors.white,
    );
  }
}

class TextWidget extends StatelessWidget {
  const TextWidget({super.key, required this.text, required this.textFontSize});

  final text;
  final textFontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.color200,
        fontSize: textFontSize,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class ContentAppBar extends StatelessWidget {
  final VoidCallback onTapFilteresButton;
  final bool open;
  final double heigthAppBar;

  const ContentAppBar(
      {super.key,
      required this.onTapFilteresButton,
      required this.open,
      required this.heigthAppBar});

  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: true);

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButtonWidget(
            icon: Icons.logout,
            onPress: () {
              bloc.searchWithFiltersSubscription?.cancel();
              bloc.resumeToSearchResultSubject.add([]);
              Navigator.pop(context);
            }),
        const SizedBox(width: 10),
        IconButtonWidget(
            icon: open
                ? Icons.circle_outlined
                : Icons.arrow_drop_down_circle_outlined,
            onPress: onTapFilteresButton),
        const SizedBox(width: 10),
        Expanded(
          child: SearchWidget(
            heightAppBar: heigthAppBar,
          ),
        ),
        const SizedBox(width: 10),
        IconButtonWidget(
            icon: Icons.search,
            onPress: () {
              request(bloc);
            }),
      ],
    );
  }

  void request(Bloc bloc) {
    bloc.resumeStatusControllerSubject.add(statusController);
    bloc.addArchivContollerWhenSearch(archivController);
    bloc.searchTextControllerSubject.add(searchTextController.text);
    bloc.resumeHrNameControllerSubject.add(hrController);
    bloc.resumeFromDateTimeSubject.add(fromDataTimeController);
    bloc.resumeToDateTimeSubject.add(toDataTimeController);
    print('request');
    bloc.sendResumeToSearchWithFilters();
  }
}

class IconButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPress;

  const IconButtonWidget({
    super.key,
    required this.icon,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPress,
      icon: Icon(icon),
      constraints: BoxConstraints(
        minWidth: 60.0,
        minHeight: 60.0,
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
              return AppColors.color50;
            }
            return AppColors.color50.withOpacity(0.9);
          },
        ),
      ),
    );
  }
}

class FiltersWidget extends StatefulWidget {
  final double displayWidth;
  final bool open;

  const FiltersWidget(
      {super.key, required this.open, required this.displayWidth});

  @override
  State<FiltersWidget> createState() => _FiltersWidgetState();
}

class _FiltersWidgetState extends State<FiltersWidget> {
  final fromSalaryController = TextEditingController();
  final toSalaryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: true);
    if (widget.open) {
      return Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: AppColors.color50.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Тень
                  offset: Offset(0, 0),
                  blurRadius: 4,
                  spreadRadius: 2, // Радиус распространения тени
                ),
              ],
            ),
            height: 150,
            margin: (widget.displayWidth > minStatisticsDisplayWidth)
                ? EdgeInsets.symmetric(horizontal: 70)
                : EdgeInsets.zero,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 5),
                    Row(
                      children: [
                        ItemWidget(
                            text: "Имя",
                            width: 200,
                            controller: nameController),
                        SizedBox(width: 20),
                        ItemWidget(
                            text: 'Источник',
                            width: 100,
                            controller: sourceController),
                        SizedBox(width: 20),
                        DropdownExample(
                          text: 'Статус',
                          width: 200,
                          listOfValue: ["Любой"] + Status.getAllStatuses(),
                          isArchiv: false,
                        ),
                        SizedBox(width: 20),
                        StreamBuilder<ResumeList>(
                            stream: bloc.observeResumeListSubject(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.data == null ||
                                  bloc.roleSubject.value != Role.hr_lead) {
                                return SizedBox.shrink();
                              }
                              return DropdownExample(
                                text: 'Hr',
                                width: 200,
                                listOfValue: ["Любой"] + snapshot.data!.hrList,
                                isArchiv: false,
                              );
                            })
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(children: [
                      ItemWidget(
                          text: 'Вакансия',
                          width: 200,
                          controller: vacancyController),
                      SizedBox(width: 20),
                      ItemWidget(
                          text: 'Возраст',
                          width: 70,
                          controller: ageController),
                      const SizedBox(width: 20),
                      DropdownExample(
                        text: 'Состояние',
                        width: 100,
                        listOfValue: [
                          'Не важно',
                          'Активно',
                          'В архиве',
                        ],
                        isArchiv: true,
                      ),
                      SizedBox(width: 23),
                      Text("Дата:",
                          style: TextStyle(
                              fontSize: 16, color: AppColors.color900)),
                      SizedBox(width: 10),
                      TimeFilterWidget(label: 'От'),
                      SizedBox(width: 20),
                      TimeFilterWidget(label: 'До'),
                    ]),
                    const SizedBox(height: 5)
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // bloc.nameControllerSubject.add('');
      // bloc.regionControllerSubject.add('');
      // bloc.salaryControllerSubject.add('');
      return const SizedBox.shrink();
    }
  }
}

class TimeFilterWidget extends StatelessWidget {
  final String label;

  const TimeFilterWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      width: 230,
      padding: EdgeInsets.only(right: 5, top: 2, left: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.5, color: AppColors.color600)),
      child: DateTimeFormField(
        padding: EdgeInsets.only(top: 2, right: 2),
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),

        dateFormat: DateFormat('dd.MM.yyyy HH:mm'),
        // Настройка формата
        lastDate: DateTime.now(),

        onChanged: (DateTime? value) {
          if (label == 'От') {
            fromDataTimeController = value;
          } else {
            toDataTimeController = value;
          }
        },
      ),
    );
  }
}

class SearchWidget extends StatelessWidget {
  final double heightAppBar;

  const SearchWidget({super.key, required this.heightAppBar});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        alignment: Alignment.center,
        height: heightAppBar,
        decoration: BoxDecoration(
          color: AppColors.color50.withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Тень
              offset: Offset(0, 0),
              blurRadius: 4,
              spreadRadius: 2, // Радиус распространения тени
            ),
          ],
        ),
        child: TextField(
          autofocus: true,
          controller: searchTextController,
          style: TextStyle(
            color: AppColors.color900,
            fontSize: 18,
          ),
        ));
  }
}

class ItemWidget extends StatefulWidget {
  final String text;
  final double width;
  final TextEditingController controller;

  const ItemWidget(
      {super.key,
      required this.text,
      required this.width,
      required this.controller});

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  bool check = false;

  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: true);
    return Row(
      children: [
        Text(
          "${widget.text}:",
          style: TextStyle(fontSize: 16, color: AppColors.color900),
        ),
        SizedBox(
          width: 16,
        ),
        Container(
          // padding: EdgeInsets.symmetric(horizontal: 19, vertical: 7),
          padding: EdgeInsets.only(left: 19, right: 5, top: 7, bottom: 7),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(width: 0.5, color: AppColors.color600)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                // padding: EdgeInsets.only(bottom: 14),
                alignment: Alignment.center,
                width: widget.width,
                height: 30,

                // color: AppColors.color700,
                child: TextField(
                  style: TextStyle(fontSize: 16, color: AppColors.color900),
                  controller: widget.controller,
                  onSubmitted: (value) {
                    setState(() {
                      check = true;
                      addInBlocController(
                          widget.text, bloc, widget.controller.text.toString());
                      if (value == '') check = false;
                    });
                  },
                  onChanged: (value) {
                    if (check) {
                      addInBlocController(
                          widget.text, bloc, widget.controller.text.toString());
                    }
                  },

                  // inputFormatters: [LengthLimitingTextInputFormatter(25)],
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    // contentPadding: EdgeInsets.only(bottom: 21),
                  ),
                  inputFormatters: (widget.text == 'Возраст')
                      ? [
                          FilteringTextInputFormatter.digitsOnly
                        ] // Только цифры, если isAge = true
                      : [],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    check = !check;
                    check
                        ? addInBlocController(widget.text, bloc,
                            widget.controller.text.toString())
                        : addInBlocController(widget.text, bloc, "");
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: AppColors.color900,
                      borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.center,
                  height: 25,
                  width: 25,
                  child: Icon(
                    check ? Icons.check : Icons.close,
                    size: 17,
                    color: AppColors.color50,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void addInBlocController(String text, Bloc bloc, String controllerText) {
    switch (text) {
      case "Имя":
        bloc.resumeNameControllerSubject.add(controllerText);
      case "Источник":
        bloc.resumeSourceControllerSubject.add(controllerText);
      case "Вакансия":
        bloc.resumeVacancyControllerSubject.add(controllerText);
      case "Возраст":
        bloc.resumeAgeControllerSubject.add(controllerText);
    }
  }
}

class DropdownExample extends StatefulWidget {
  final String text;
  final double width;
  final List<String> listOfValue;
  final bool isArchiv;

  // final

  const DropdownExample(
      {Key? key,
      required this.text,
      required this.width,
      required this.listOfValue,
      required this.isArchiv})
      : super(key: key);

  @override
  _DropdownExampleState createState() => _DropdownExampleState();
}

class _DropdownExampleState extends State<DropdownExample> {
  String? selectedValue;

  // Список вариантов для выпадающего меню

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "${widget.text}:",
          style: TextStyle(fontSize: 16, color: AppColors.color900),
        ),
        SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 0.5, color: AppColors.color600),
          ),
          child: Row(
            children: [
              Container(
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
                        style:
                            TextStyle(fontSize: 16, color: AppColors.color900),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedValue = newValue;
                      switch (widget.text) {
                        case 'Hr':
                          hrController = selectedValue!;
                        case 'Статус':
                          statusController = selectedValue!;
                        case 'Состояние':
                          archivController = selectedValue!;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
