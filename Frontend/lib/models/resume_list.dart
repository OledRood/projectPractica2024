import '../resources/status.dart';

class ResumeList {
  final List<String> vacancy;
  final List<String> hrList;
  final List<String> source;

  factory ResumeList.fromJson(final Map<String, dynamic> json) =>
      ResumeList(
        // ЭТО ДЕЛАЕМ ПОТОМУ ЧТО ПОЛУЧАЕМ ДАННЫЕ ТОЛЬКО В ФОРМАТЕ List<dynamic>
        vacancy:
            List<String>.from(json['vacancy'].map((item) => item.toString())),
        hrList:
            List<String>.from(json["hr_list"].map((item) => item.toString())),
        source:
            List<String>.from(json['source'].map((item) => item.toString())),
      );
  // ResumeList(
  //     {required this.vacancy, required this.hrList, required this.source});
  ResumeList({
    this.vacancy = const ["Error", "Сообщите", 'Пожалуйста', "Админу"], // Значение по умолчанию
    this.hrList = const ["Error", "Сообщите", 'Пожалуйста', "Админу"],  // Значение по умолчанию
    this.source = const ["Error", "Сообщите", 'Пожалуйста', "Админу"],  // Значение по умолчанию
  });
}
