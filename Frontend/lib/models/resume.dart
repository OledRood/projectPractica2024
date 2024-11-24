
import '../resources/status.dart';

class Resume {
  final int archiv;
  final String dateLastChanges;
  final String hrName;
  final int resumeId;
  final String status;
  final String vacancy;
  final String fullName;
  final int age;
  final String source;
  final String comments;

  // Это без сериализации

  Resume(this.archiv, this.dateLastChanges, this.hrName, this.resumeId, this.status, this.vacancy, this.fullName, this.age, this.source, this.comments);


  factory Resume.fromJson(final Map<String, dynamic> json) => Resume(
    json["archiv"],
    json["date_last_changes"],
    json["hr_name"],
    json["resume_id"],
    json["status"],
    json["vacancy"],
    json["name"],
    json["age"],
    json["source"] ?? "",
    json["comments"] ?? "",
  );}



