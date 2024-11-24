import '../bloc/bloc.dart';

class Roles {
  const Roles._();

  static final list = {
    Role.hr: "Hr",
    Role.hr_lead: "Hr_lead",
    Role.admin: "Admin"
  };

  static String getStringRole(Role role){
    return list[role]!;
  }

  static Role? getRole(String? value){
    if(value == ""){
      return null;
    }
    final Role role = list.entries
        .firstWhere((entry) => entry.value == value)
        .key;
    return role;
  }

}
