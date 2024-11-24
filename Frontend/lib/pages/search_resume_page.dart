import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../bloc/bloc.dart';
import '../resources/app_colors.dart';
import '../resources/status.dart';

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
final sourceController = TextEditingController();
final ageController = TextEditingController();

class ResumeSearchPage extends StatefulWidget {
  const ResumeSearchPage({super.key});

  @override
  State<ResumeSearchPage> createState() => _ResumeSearchPageState();
}

class _ResumeSearchPageState extends State<ResumeSearchPage> {
  final double heigthAppBar = 60;

  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: true);
    bloc.cleanResumeControllers();
    return Scaffold(
        backgroundColor: AppColors.color100,
        body: Stack(
          children: [
            StreamBuilder<StateRequest>(
                stream: bloc.stateSearchListWidget,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return SizedBox.shrink();
                  }
                  // final data = StateSearchList.result;
                  switch (snapshot.data) {
                    // switch (data) {
                    case null:
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
                      return CircularProgressIndicator();
                    case StateRequest.good:
                      return ContentListWidget(open: open);
                    case StateRequest.nothingFound:
                      return Container(
                          child: Center(
                        child: Text(
                          'Ничего не найдено',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.color50),
                        ),
                      ));
                    default:
                      return Container();
                  }
                }),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  ContentAppBar(
                      onTapFilteresButton: () {
                        setState(() {
                          open = !open;
                        });
                      },
                      open: open,
                      heigthAppBar: heigthAppBar),
                  FiltersWidget(open: open),
                ],
              ),
            ),
          ],
        ));
  }
}

class ContentListWidget extends StatefulWidget {
  final bool open;

  const ContentListWidget({super.key, required this.open});

  @override
  State<ContentListWidget> createState() => _ContentListWidgetState();
}

class _ContentListWidgetState extends State<ContentListWidget> {
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 120),
                child: Container(
                    alignment: Alignment.centerLeft,
                    child: ResumeWidget(content: content)),
              );
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

class ResumeWidget extends StatelessWidget {
  const ResumeWidget({
    super.key,
    required this.content,
  });

  final FullResumeInfo content;
  final double title = 20;
  final double textFontSize = 19;

  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: true);

    return GestureDetector(
        onTap: () {
          bloc.resumeIdControllerSubject.add(content.resumeId);
          Navigator.pushNamed(context, '/MainPage/InfoResumePage');
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 100),
          child: Container(
            // width: 900,
            // height: 120,
            padding:
                const EdgeInsets.only(left: 20, right: 20, bottom: 5, top: 10),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: AppColors.color900,
                borderRadius: BorderRadius.circular(20)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      content.fullName,
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
                    text: 'Вакансия: ${content.vacancy}',
                    textFontSize: textFontSize,
                  ),
                  const SeparateWidget(),
                  TextWidget(
                      text: 'Источник:  ${content.source}',
                      textFontSize: textFontSize),
                  const SeparateWidget(),
                  TextWidget(
                      text: "Status ${content.status}",
                      textFontSize: textFontSize),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  TextWidget(
                      text: "Возраст: ${content.age}",
                      textFontSize: textFontSize),
                  const SeparateWidget(),
                  TextWidget(
                      text: 'Состояние: ${(content.archiv == 1) ? 'В архиве' : 'Активно'}',
                      textFontSize: textFontSize),
                  StreamBuilder<Role>(
                      stream: bloc.observeRoleSubject(),
                      builder: (context, roleSnapshot) {
                        if (roleSnapshot.data == Role.hr_lead) {
                          return Row(
                            children: [
                              const SeparateWidget(),
                              TextWidget(
                                  text: 'Hr:  ${content.hrName}',
                                  textFontSize: textFontSize),
                            ],
                          );
                        }
                        else{
                          return SizedBox.shrink();
                        }
                      })
                ],
              )
            ]),
          ),
        ));
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
      style: TextStyle(color: AppColors.color200, fontSize: textFontSize),
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
        GestureDetector(
          onTap: () {
            bloc.searchWithFiltersSubscription?.cancel();
            bloc.resumeToSearchResultSubject.add([]);
            Navigator.pop(context);
          },
          child: Container(
            height: heigthAppBar,
            width: 60,
            decoration: BoxDecoration(
                color: AppColors.color50.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25)),
            child: Icon(
              Icons.logout,
              color: AppColors.color900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onTapFilteresButton,
          child: Container(
            height: heigthAppBar,
            width: 60,
            decoration: BoxDecoration(
                color: AppColors.color50.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25)),
            child: Icon(
              open
                  ? Icons.circle_outlined
                  : Icons.arrow_drop_down_circle_outlined,
              color: AppColors.color900,
              size: 25,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SearchWidget(
            heightAppBar: heigthAppBar,
          ),
        ),
        const SizedBox(width: 10),
        SearchButton(
          heigthAppBar: heigthAppBar,
          onTap: () {
            request(bloc);
          },
        ),
      ],
    );
  }

  void request(Bloc bloc) {
    bloc.resumeStatusControllerSubject.add(statusController);
    bloc.addArchivContollerWhenSearch(archivController);
    bloc.searchTextControllerSubject.add(searchTextController.text);
    bloc.sendResumeToSearchWithFilters();
  }
}

class SearchButton extends StatelessWidget {
  final VoidCallback onTap;
  final double heigthAppBar;

  const SearchButton({
    super.key,
    required this.heigthAppBar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: heigthAppBar,
        width: 60,
        decoration: BoxDecoration(
            color: AppColors.color50.withOpacity(0.9),
            borderRadius: BorderRadius.circular(25)),
        child: Icon(
          color: AppColors.color900,
          Icons.search,
          size: 25,
        ),
      ),
    );
  }
}

class FiltersWidget extends StatefulWidget {
  final bool open;

  const FiltersWidget({super.key, required this.open});

  @override
  State<FiltersWidget> createState() => _FiltersWidgetState();
}

class _FiltersWidgetState extends State<FiltersWidget> {
  final fromSalaryController = TextEditingController();
  final toSalaryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.open) {
      return Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: AppColors.color50.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30)),
            height: 150,
            margin: const EdgeInsets.only(left: 70, right: 70),
            child: Stack(
              children: [
                Row(
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
                              listOfValue: ["Любое"] + Status.getAllStatuses(),
                              isArchiv: false,
                            ),
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
                          SizedBox(width: 20),
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
                        ]),
                        SizedBox(height: 5)
                      ],
                    ),
                  ],
                ),
                //Подпись об очистке фильтров
                // Align(
                //   alignment: Alignment.bottomRight,
                //   child: Padding(
                //     padding: const EdgeInsets.only(right: 10),
                //     child: Text('if closed – the filters will be reset',
                //         style: TextStyle(
                //             fontSize: 10,
                //             color: AppColors.color900,
                //             fontWeight: FontWeight.w900)),
                //   ),
                // )
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
        ),
        child: TextField(
          autofocus: true,
          // onSubmitted: (value) {
          //   // bloc.updateText(value);
          // },
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
                      addInBlocController(widget.text, bloc,
                          widget.controller.text.toString());
                      if (value == '') check = false;
                    });
                  },
                  onChanged: (value) {
                    if (check) {
                      addInBlocController(widget.text, bloc,
                          widget.controller.text.toString());
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
                      widget.isArchiv
                          ? archivController = selectedValue!
                          : statusController = selectedValue!;
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
