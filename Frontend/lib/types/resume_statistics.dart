import '../models/statistics/status_model.dart';

class ResumeStatistic{
  final vacancy;
  final source;
  final averageTime;
  final StatusModel status;
  final String name;

  ResumeStatistic( {required this.vacancy, required this.source, required this.averageTime, required this.status, required this.name,});

  @override
  String toString() {
    return 'ResumeStatistic{vacancy: $vacancy, source: $source, averageTime: $averageTime, status: $status, name: $name}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeStatistic &&
          runtimeType == other.runtimeType &&
          vacancy == other.vacancy &&
          source == other.source &&
          averageTime == other.averageTime &&
          status == other.status &&
          name == other.name;

  @override
  int get hashCode =>
      vacancy.hashCode ^
      source.hashCode ^
      averageTime.hashCode ^
      status.hashCode ^
      name.hashCode;
}