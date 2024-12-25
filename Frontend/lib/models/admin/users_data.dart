class UsersData {
  final List<UserTable> userTable;
  final List<HrLeadTable> hrLeadTable;
  final List<HrTable> hrTable;

  UsersData(
      {required this.userTable,
      required this.hrLeadTable,
      required this.hrTable});

  factory UsersData.fromJson(final Map<String, dynamic> json) => UsersData(
        userTable: (json["user_table"] as List<dynamic>)
            .map((data) => UserTable.fromJson(data))
            .toList(),
        hrLeadTable: (json["hr_lead_table"] as List<dynamic>)
            .map((data) => HrLeadTable.fromJson(data))
            .toList(),
        hrTable: (json["hr_table"] as List<dynamic>)
            .map((data) => HrTable.fromJson(data))
            .toList(),
      );
}

class UserTable {
  final int userId;
  final String username;
  final String role;
  final String password;

  UserTable(
      {required this.userId,
      required this.username,
      required this.role,
      required this.password});

  factory UserTable.fromJson(final Map<String, dynamic> json) => UserTable(
      userId: json['user_id'],
      username: json['username'],
      role: json['role'] ?? '',
      password: json['password'] ?? '');
}

class HrLeadTable {
  final int hr_lead_id;
  final String sla;

  HrLeadTable(this.sla, {required this.hr_lead_id});

  factory HrLeadTable.fromJson(final Map<String, dynamic> json) =>
      HrLeadTable(json['sla'] ?? "", hr_lead_id: json["hr_lead_id"]);
}

class HrTable {
  final int hrId;
  final int hr_lead_id;

  HrTable({required this.hrId, required this.hr_lead_id});

  factory HrTable.fromJson(final Map<String, dynamic> json) =>
      HrTable(hrId: json["hr_id"], hr_lead_id: json["hr_lead_id"]);
}
