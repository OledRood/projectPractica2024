import 'package:hr_monitor/models/statistics/status_model.dart';

import 'average_time.dart';

class Statistics {
  final Map<String, double> vacancy;
  final Map<String, int> source;
  final AverageTime averageTime;
  final StatusModel status;
  final String name;

  Statistics(
      this.vacancy, this.source, this.averageTime, this.status, this.name);

  factory Statistics.fromJson(final Map<String, dynamic> json) => Statistics(
      Map<String, double>.from(json["vacancy"] ?? {}),
      Map<String, int>.from(json["source"] ?? {}),
      AverageTime.fromJson(json['average_time_status']),
      StatusModel.fromJson(json['status']),
      json['name']);
}
