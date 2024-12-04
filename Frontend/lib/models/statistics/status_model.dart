class StatusModel {
  final double reviewed;
  final double interview;
  final double open;
  final double offer;
  final double passedTechnicalInterview;
  final double completedInterview;
  final double technicalInterview;

  StatusModel({required this.reviewed,
    required this.interview,
    required this.open,
    required this.offer,
    required this.passedTechnicalInterview,
    required this.completedInterview,
    required this.technicalInterview});

  factory StatusModel.fromJson(final Map<String, dynamic> json) =>
      StatusModel(
          reviewed: json['Изучено'],
          interview: json["Интервью"],
          open: json['Открыто'],
          offer: json['Оффер'],
          passedTechnicalInterview: json['Пройдено техническое собеседование'],
          completedInterview: json['Прошли интервью'],
          technicalInterview: json['Техническое собеседование']);


  List<double> getSortedListByStatus(){
    return [open, reviewed, interview, completedInterview, technicalInterview, passedTechnicalInterview, offer];
  }
  double getMaxStatus(){
    List list = getSortedListByStatus();
    list.sort();
    return list.lastOrNull ?? 0 ;
  }

}