import 'package:flutter/material.dart';
import 'package:hr_monitor/pages/main_page_content.dart';
import 'package:provider/provider.dart';

import '../bloc/bloc.dart';
import '../resources/app_colors.dart';

class ListOfResumeWidget extends StatefulWidget {
  final bool isActiveResume;
  const ListOfResumeWidget({super.key, required this.isActiveResume});

  @override
  State<ListOfResumeWidget> createState() => _ListOfResumeWidgetState();
}

class _ListOfResumeWidgetState extends State<ListOfResumeWidget> {
  @override
  Widget build(BuildContext context) {
    final Bloc bloc = Provider.of<Bloc>(context, listen: false);
    bloc.getAllResumeToMainPage();
    return Container(
      alignment: Alignment.center,
      height: 600,
      width: 550,
      // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: BoxDecoration(
          color: AppColors.color200, borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Container(
              height: 600,
              width: 550,
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: ResumesListWidgetInside(isActiveResume: widget.isActiveResume,)),
          Container(
            alignment: Alignment.center,
            height: 40,
            width: 550,
            decoration: BoxDecoration(
              color: AppColors.color900.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), // Скругление только для верхнего левого угла
                topRight: Radius.circular(20),
              ),
            ),
            child: Text(widget.isActiveResume ? 'Активные' : 'Архивные', style: TextStyle(color: AppColors.color900, fontSize: 20, fontWeight: FontWeight.w600),)
          ),
          GestureDetector(
            onTap: () {
              bloc.getAllResumeToMainPage();
            },
            child: const RestartWidget(),
          )
        ],
      ),
    );
  }
}

class RestartWidget extends StatelessWidget {
  const RestartWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SizedBox()),
        Container(
          width: 30,
          height: 30,
          margin: EdgeInsets.all(5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppColors.color200,
              borderRadius: BorderRadius.circular(13)),
          child: Icon(Icons.restart_alt, color: AppColors.color900,),
        ),
      ],
    );
  }
}

class ResumesListWidgetInside extends StatefulWidget {
  final bool isActiveResume;
  const ResumesListWidgetInside({
    super.key, required this.isActiveResume,
  });

  @override
  State<ResumesListWidgetInside> createState() =>
      _ResumesListWidgetInsideState();
}

class _ResumesListWidgetInsideState extends State<ResumesListWidgetInside> {
  @override
  Widget build(BuildContext context) {
    final Bloc mainBloc = Provider.of<Bloc>(context, listen: false);
    return StreamBuilder<StateRequest>(
        stream: mainBloc.resumeMainPageListStateSubject,
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return Text('Что-то совсем сломалось');
          }

          switch (snapshot.data) {
            case StateRequest.loading:
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.color900,
                ),
              );
            case null:
            case StateRequest.error:
              return Text('Error');
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
                    var listFiltersResumes = listResumes.where((resume) => (resume.archiv == archivStatus)).toList();
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
                            mainBloc.resumeIdControllerSubject.add(resume.resumeId);
                            Navigator.pushNamed(context, '/MainPage/InfoResumePage');
                          },
                          child: Container(
                            // height: 100,
                            width: 100,
                            padding: const EdgeInsets.only(
                                top: 5, bottom: 5, right: 20, left: 10),
                            decoration: BoxDecoration(
                              color: AppColors.color50,
                              borderRadius: BorderRadius.circular(10),
                              border: widget.isActiveResume ? null : Border.all(width: 2, color: AppColors.color900)
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    TextWidget(
                                      text: 'ФИО: ',
                                      color: AppColors.color900,
                                      size: 16,
                                    ),
                                    TextWidget(
                                      text: resume.fullName,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                    Expanded(
                                      child: SizedBox(),
                                    ),
                                    TextWidget(
                                      text: 'Возраст: ',
                                      color: AppColors.color900,
                                      size: 16,
                                    ),
                                    TextWidget(
                                      text: resume.age,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                // Expanded(child: SizedBox()),
                                SizedBox(height: 5,),

                                Row(
                                  children: [
                                    TextWidget(
                                      text: "Вакансия: ",
                                      color: AppColors.color900,
                                      size: 16,
                                    ),
                                    TextWidget(
                                      text: resume.vacancy,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                    Expanded(
                                      child: SizedBox(),
                                    ),
                                    TextWidget(
                                      text: 'Статус: ',
                                      color: AppColors.color900,
                                      size: 16,
                                    ),
                                    TextWidget(
                                      text: resume.status,
                                      color: Colors.black,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                StreamBuilder(stream: mainBloc.observeRoleSubject(), builder: (context, snapshot){
                                  if(snapshot.hasData && snapshot.data == Role.hr_lead){
                                    return Column(children: [SizedBox(height: 4), Row(
                                      children: [
                                        TextWidget(text: 'HR: ', color: AppColors.color900, size: 16,),
                                        TextWidget(
                                          text: resume.hrName,
                                          color: Colors.black,
                                          size: 16,
                                        ),
                                      ],
                                    )],);
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
  final Color color;
  final text;
  final double size;

  const TextWidget({
    super.key,
    required this.text,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toString(),
      style: TextStyle(color: color, fontSize: size),
    );
  }
}
