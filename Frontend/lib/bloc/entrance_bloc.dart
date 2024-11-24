// import 'dart:async';
// import 'dart:convert';
//
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:http/http.dart' as http;
// import 'package:rxdart/rxdart.dart';
//
// import '../resources/roles.dart';
// import 'bloc.dart';
// import 'main_bloc.dart';
//
// class EntranceBloc {
//
//
//   //
//   // final  statePageSubject = BehaviorSubject<StatePage>();
//   //
//   // Stream<StatePage> observeStatePage() => statePageSubject;
//   //
//
//
//   final BehaviorSubject<StateContentRequest> stateLogInSubject =
//       BehaviorSubject.seeded(StateContentRequest.none);
//   final usernameControllerSubject = BehaviorSubject<String>.seeded('');
//   final passwordControllerSubject = BehaviorSubject<String>.seeded('');
//   final roleSubject = BehaviorSubject<Role?>();
//
//   final BehaviorSubject<String> userIdSubject = BehaviorSubject.seeded("");
//
//   // // Храним здесь то, что получили от сервера (Есть ли данная учетная запись)
//   // final searchResultSubject = BehaviorSubject<bool>();
//   Stream observeId() => userIdSubject;
//
//   Stream<StateContentRequest> observeRequest() => stateLogInSubject;
//
//   StreamSubscription? userSubscription;
//   StreamSubscription? searchSubscriprion;
//
//   EntranceBloc() {
//     print('Запустилось');
//     getId();
//   }
//
//   Future sendPassWordAndLogin() async {
//     final username = usernameControllerSubject.value;
//     final password = passwordControllerSubject.value;
//     userSubscription?.cancel();
//     userSubscription = requestEntrance(username: username, password: password)
//         .asStream()
//         .listen(
//       (searchResult) {
//         print(searchResult);
//
//         switch (searchResult) {
//           case RequestStatus.connectError:
//             stateLogInSubject.add(StateContentRequest.errorConnection);
//           case RequestStatus.serverError:
//             stateLogInSubject.add(StateContentRequest.serverError);
//           case RequestStatus.somethingWrong:
//             stateLogInSubject.add(StateContentRequest.denied);
//           case RequestStatus.allowed:
//             stateLogInSubject.add(StateContentRequest.nextPage);
//           case RequestStatus.denied:
//             stateLogInSubject.add(StateContentRequest.denied);
//           default:
//             stateLogInSubject.add(StateContentRequest.denied);
//         }
//       },
//       onError: (error, stackTrace) {
//         print("SearchError");
//         print(error);
//         stateLogInSubject.add(StateContentRequest.denied);
//       },
//     );
//   }
//
//
//   Future requestEntrance({
//     required String username,
//     required String password,
//   }) async {
//     try {
//       var headers = {'Content-Type': 'application/json'};
//       var request =
//           http.Request('POST', Uri.parse('http://127.0.0.1:5000/user/login'));
//       request.body =
//           json.encode({"username": "$username", "password": "$password"});
//       request.headers.addAll(headers);
//
//       http.StreamedResponse response = await request.send();
//       final found = await response.stream.bytesToString();
//
//       if (response.statusCode == 400) {
//         return RequestStatus.connectError;
//       }
//       if (response.statusCode >= 500 && response.statusCode <= 600) {
//         print("Server Error");
//         return RequestStatus.serverError;
//       }
//       if (response.statusCode == 200) {
//         final decodedFound = json.decode(found);
//         bool result = decodedFound['result'] ?? false;
//         if (result) {
//           userIdSubject.add(decodedFound['id'].toString());
//           roleSubject.add(Roles.getRole(decodedFound['role'].toString())!);
//           saveUserData(
//               decodedFound['id'].toString(), decodedFound['role'].toString());
//           return RequestStatus.allowed;
//         }
//         return RequestStatus.denied;
//       }
//       return RequestStatus.somethingWrong;
//     } catch (e) {
//       return RequestStatus.serverError;
//     }
//   }
//
//   Future<String?> getRole() async {
//     final prefs = await SharedPreferences.getInstance();
//     final decodedData = prefs.getString('role');
//
//     if (decodedData != null) {
//       final encodeData = json.decode(decodedData!);
//       final role = encodeData['role'];
//       return role;
//     }
//     return null;
//   }
//
//   Future addRoleInSubjectMainBloc(MainBloc mainBloc) async {
//     String? roleState = await getRole();
//     if (roleState != null) {
//       final role = Roles.getRole(roleState);
//       print('Роль запихнута: $role');
//       // mainBloc.roleSubject.add(role!);
//     } else {
//       final role = roleSubject.valueOrNull;
//       if (role != null) {
//         print('Роль запихнута: $role');
//         mainBloc.roleSubject.add(role!);
//       }
//     }
//   }
//
//   Future<void> saveUserData(String id, String role) async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = jsonEncode({"user_id": id, "role": role});
//     await prefs.setString(
//         "data", data); // Сохраняем значение 'id' с ключом 'user_id'
//   }
//
//   Future<void> getId() async {
//     final prefs = await SharedPreferences.getInstance();
//     final decodedData = prefs.getString('data');
//
//     if (decodedData != null) {
//       final encodeData = json.decode(decodedData!);
//       final userId = encodeData['user_id'];
//       final role = Roles.getRole(encodeData['role']);
//       if (userId != "") {
//         // roleSubject.add(role!);
//         stateLogInSubject.add(StateContentRequest.nextPage);
//       }
//       userIdSubject.add(userId!);
//     }
//   }
//
//   void dispose() {
//     stateLogInSubject.close();
//     usernameControllerSubject.close();
//     passwordControllerSubject.close();
//     roleSubject.close();
//     userIdSubject.close();
//     userSubscription?.cancel();
//     searchSubscriprion?.cancel();
//   }
// }
//
// class UserInfo {
//   final username;
//   final password;
//   final position;
//
//   UserInfo(
//       {required this.username, required this.password, required this.position});
//
//   @override
//   String toString() =>
//       'FiltersInfo(username: $username, password: $password, position: $position)';
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is UserInfo &&
//           runtimeType == other.runtimeType &&
//           username == other.username &&
//           position == other.position &&
//           password == other.password;
//
//   @override
//   int get hashCode => username.hashCode ^ password.hashCode ^ position.hashCode;
// }
//
// // enum Role { hr, hr_lead, admin }
//
// enum StateContentRequest {
//   none,
//   loading,
//   serverError,
//   errorConnection,
//   denied,
//   nextPage
// }
//
// enum RequestStatus {
//   connectError,
//   serverError,
//   somethingWrong,
//   allowed,
//   denied
// }
//
// enum StatePage{
//   entrance,
//   main
// }