
class FullResumeInfo {
  final archiv;
  final date_last_changes;
  final hrName;
  final resumeId;
  final status;
  final vacancy;
  final age;
  final fullName;
  final source;
  final comments;

  FullResumeInfo({
    required this.archiv,
    required this.date_last_changes,
    required this.hrName,
    required this.resumeId,
    required this.status,
    required this.vacancy,
    required this.fullName,
    required this.age,
    required this.source,
    required this.comments,
  });

  @override
  String toString() {
    return 'FullResumeInfo{archiv: $archiv, date_last_changes: $date_last_changes, hr_id: $hrName, resume_id: $resumeId, status: $status}, vacancy: $vacancy, age: $age, source: $source, full_name: $fullName, comment: $comments)}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          super == other &&
              other is FullResumeInfo &&
              runtimeType == other.runtimeType &&
              fullName == other.fullName &&
              archiv == other.archiv &&
              vacancy == other.vacancy &&
              age == other.age &&
              source == other.source &&
              date_last_changes == other.date_last_changes &&
              hrName == other.hrName &&
              comments == other.comments &&
              resumeId == other.resumeId &&
              status == other.status;

  @override
  int get hashCode =>
      super.hashCode ^
      archiv.hashCode ^
      date_last_changes.hashCode ^
      hrName.hashCode ^
      resumeId.hashCode ^
      vacancy.hashCode ^
      fullName.hashCode ^
      age.hashCode ^
      source.hashCode ^
      comments.hashCode ^
      status.hashCode;
}
