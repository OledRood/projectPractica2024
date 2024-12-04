import 'package:hr_monitor/models/statistics/time.dart';

// •	“изучена” → “reviewed”
// •	“интервью” → “interview”
// •	“открыто” → “open”
// •	“оффер” → “offer”
// •	“пройдено техническое собеседование” → “passed technical interview”
// •	“прошли интервью” → “completed interview”
// •	“техническое собеседование” → “technical interview”

class AverageTime {
  final Time reviewed;
  final Time interview;
  final Time open;
  final Time offer;
  final Time passedTechnicalInterview;
  final Time completedInterview;
  final Time technicalInterview;

  // AverageTime.fromJson(json['Изучено'], json['Интервью'], json['Открыто'],json['Оффер'],json['Пройдено техническое собеседование'],json['Прошли интервью'],json['Техническое собеседование'])

  factory AverageTime.fromJson(final Map<String, dynamic> json) => AverageTime(
      reviewed: Time.fromJson(json['Изучено']),
      interview: Time.fromJson(json["Интервью"]),
      open: Time.fromJson(json['Открыто']),
      offer: Time.fromJson(json['Оффер']),
      passedTechnicalInterview: Time.fromJson(json['Пройдено техническое собеседование']),
      completedInterview: Time.fromJson(json['Прошли интервью']),
      technicalInterview: Time.fromJson(json['Техническое собеседование']));

  AverageTime(
      {required this.reviewed,
      required this.interview,
      required this.open,
      required this.offer,
      required this.passedTechnicalInterview,
      required this.completedInterview,
      required this.technicalInterview});

  List<Time> getSortedListByStatus(){
    return [open, reviewed, interview, completedInterview, technicalInterview, passedTechnicalInterview, offer];
  }
}
