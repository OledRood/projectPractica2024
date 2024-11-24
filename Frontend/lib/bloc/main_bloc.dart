// import 'dart:async';
// import 'dart:convert';
//
// import 'package:hr_monitor/bloc/entrance_bloc.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import '../models/resume.dart';
// import '../resources/api_routes.dart';
// import 'bloc.dart';
//
// class MainBloc {
//   // EntranceBloc entranceBloc = EntranceBloc();
//   final userIdSubject = BehaviorSubject<String>.seeded('');
//
//   Stream<int> observeResumeIdSubject() => resumeIdControllerSubject;
//
//   final resumeVacancyControllerSubject = BehaviorSubject<String>.seeded("");
//   final ageControllerSubject = BehaviorSubject<String>.seeded("");
//   final commentsControllerSubject = BehaviorSubject<String>.seeded("");
//   final statusControllerSubject = BehaviorSubject<String>.seeded("");
//   final nameControllerSubject = BehaviorSubject<String>.seeded("");
//   final sourceControllerSubject = BehaviorSubject<String>.seeded('');
//   final resumeIdControllerSubject = BehaviorSubject<int>.seeded(-1);
//   final archivControllerSubject = BehaviorSubject<int>.seeded(-1);
//
//   final roleSubject = BehaviorSubject<Role>();
//
//   Stream<Role> observeRoleSubject() => roleSubject;
//
//   final resumeMainPageListStateSubject = BehaviorSubject<StateWidget>();
//   final resultResumeListToMainPageSubject =
//       BehaviorSubject<List<FullResumeInfo>>();
//
//   StreamSubscription? getAllResumeToMainPageSubscription;
//
//   Stream<List<FullResumeInfo>> observeResultListResume() =>
//       resultResumeListToMainPageSubject;
//
//   // void getAllResumesToHr(final bool isArchiv) {
//   void getAllResumeToMainPage(final bool isArchiv) {
//     resumeMainPageListStateSubject.add(StateWidget.loading);
//     getAllResumeToMainPageSubscription?.cancel();
//     getAllResumeToMainPageSubscription =
//         requestToGetAllResumesToMainPage(isArchiv).asStream().listen((resumes) {
//       if (resumes.isEmpty) {
//         print('resume.isEmpty');
//         resultResumeListToMainPageSubject.add([]);
//         resumeMainPageListStateSubject.add(StateWidget.error);
//       }
//       resultResumeListToMainPageSubject.add(resumes);
//       resumeMainPageListStateSubject.add(StateWidget.result);
//     }, onError: (error, stackTrace) {
//       resumeMainPageListStateSubject.add(StateWidget.error);
//       print('OnError getAllResumeToMainPage: $error');
//     });
//   }
//
//   // Future<List<FullResumeInfo>> requestToGetHrResume(bool isArchiv) async {
//
//   Future<List<FullResumeInfo>> requestToGetAllResumesToMainPage(
//       bool isArchiv) async {
//     await getId();
//     final userId = userIdSubject.value;
//     final body = json.encode({"user_id": userId, "is_archiv": isArchiv});
//     final headers = {'Content-Type': 'application/json'};
//     var response = await http.post(
//         Uri.parse('http://127.0.0.1:5000/resume/getHrResume'),
//         headers: headers,
//         body: body);
//     if (response.statusCode == 200) {
//       final List<dynamic> result = json.decode(response.body);
//
//       //Здесь мы декодируем полученный json в Map<String, dynamic> каждую строчку
//       final List<Resume> resumes = result.map((rawResume) {
//         return Resume.fromJson(rawResume);
//       }).toList();
//       final List<FullResumeInfo> found = resumes.map((resume) {
//         return FullResumeInfo(
//             vacancy: resume.vacancy,
//             fullName: resume.fullName,
//             age: resume.age,
//             source: resume.source,
//             archiv: resume.archiv,
//             date_last_changes: resume.dateLastChanges,
//             hrName: resume.hrName,
//             resumeId: resume.resumeId,
//             status: resume.status,
//             comments: resume.comments);
//       }).toList();
//       return found;
//     }
//     throw Exception('something error in search');
//   }
//
//   final stateCreateButtonSubject =
//       BehaviorSubject<StateRequest>.seeded(StateRequest.none);
//   StreamSubscription? resumeToCreateSubscription;
//
//   Stream<StateRequest> observeStateCreateButton() => stateCreateButtonSubject;
//
//   Future sendResumeToCreate() async {
//     final String vacancy = resumeVacancyControllerSubject.value;
//     final String age = ageControllerSubject.value;
//     final String source = sourceControllerSubject.value;
//     final String id = userIdSubject.value;
//     final String name = nameControllerSubject.value;
//     final String comments = commentsControllerSubject.value;
//
//     if (id != '' && age != '') {
//       stateCreateButtonSubject.add(StateRequest.loading);
//       resumeToCreateSubscription?.cancel();
//       resumeToCreateSubscription = requestToCreateResume(
//               vacancy: vacancy,
//               age: int.parse(age),
//               source: source,
//               name: name,
//               id: int.parse(id),
//               comments: comments)
//           .asStream()
//           .listen((searchResult) {
//         if (searchResult == 'good') {
//           print('Получили гуд');
//           stateCreateButtonSubject.add(StateRequest.good);
//         } else {
//           stateCreateButtonSubject.add(StateRequest.error);
//         }
//       }, onError: (e) {
//         print('Error in Create Resume: $e');
//         stateCreateButtonSubject.add(StateRequest.error);
//       });
//     }
//   }
//
//   Future requestToCreateResume({
//     required String vacancy,
//     required int age,
//     required String source,
//     required String name,
//     required int id,
//     required String comments,
//   }) async {
//     var request = http.Request('POST', Uri.parse(Routes.createResume));
//     request.body = json.encode({
//       "vacancy": vacancy,
//       "age": age,
//       "name": name,
//       "source": source,
//       "id": id,
//       'comments': comments
//     });
//     request.headers.addAll(Routes.headers);
//
//     http.StreamedResponse response = await request.send();
//     String responseData = await response.stream.bytesToString();
//
//     if (response.statusCode == 200) {
//       var jsonData = jsonDecode(responseData);
//       return jsonData['response'];
//     }
//   }
//
//   void cancelCreateSubscription() {
//     stateCreateButtonSubject.add(StateRequest.none);
//     resumeToCreateSubscription?.cancel();
//   }
//
// //TODO Отправка резюме для его обновления
//
//   final stateUpdateRequest =
//       BehaviorSubject<StateRequest>.seeded(StateRequest.none);
//
//   Stream<StateRequest> observeStateUpdateRequest() => stateUpdateRequest;
//
//   StreamSubscription? requestToUpdateSubscription;
//
//   void sendResumeToUpdate() {
//     stateUpdateRequest.add(StateRequest.loading);
//     final resumeData = getResumeInfoFromSubject();
//     requestToUpdateSubscription?.cancel();
//     print("Итак комментарий равен = ${resumeData.comments.runtimeType}");
//     requestToUpdateSubscription = requestToUpdateResume(
//             vacancy: resumeData.vacancy,
//             age: resumeData.age,
//             source: resumeData.source,
//             fullName: resumeData.fullName,
//             resumeId: resumeData.resumeId,
//             comments: resumeData.comments,
//             archiv: resumeData.archiv,
//             status: resumeData.status)
//         .asStream()
//         .listen((createAnswer) {
//       print('createAnswer: $createAnswer');
//       if (createAnswer == "good") {
//         getAllResumeToMainPage(resumeData.archiv == 1);
//         stateUpdateRequest.add(StateRequest.good);
//       } else {
//         stateUpdateRequest.add(StateRequest.error);
//       }
//     }, onError: (e) {
//       print('Ошибка в sendResumeToUpdate: ${e}');
//       stateUpdateRequest.add(StateRequest.error);
//     });
//   }
//
//   Future requestToUpdateResume({
//     required String vacancy,
//     required int age,
//     required String source,
//     required String fullName,
//     required int resumeId,
//     required String comments,
//     required int archiv,
//     required String status,
//   }) async {
//     print('requestToUpdateResume start');
//     var headers = {'Content-Type': 'application/json'};
//     var request =
//         http.Request('POST', Uri.parse('http://127.0.0.1:5000/resume/update'));
//     request.body = json.encode({
//       "vacancy": vacancy,
//       "age": age,
//       "name": fullName,
//       "source": source,
//       "resume_id": resumeId,
//       'comments': comments,
//       "archiv": archiv,
//       "status": status,
//     });
//     request.headers.addAll(headers);
//
//     http.StreamedResponse response = await request.send();
//     String responseData = await response.stream.bytesToString();
//
//     if (response.statusCode == 200) {
//       var jsonData = jsonDecode(responseData);
//       return jsonData['response'];
//     } else {
//       // return null;
//     }
//   }
//
//   Future resetStateUpgrateResumeRequestSubject() async {
//     await Future.delayed(Duration(seconds: 1));
//     stateUpdateRequest.add(StateRequest.none);
//   }
//
//   FullResumeInfo getResumeInfoFromSubject() {
//     final String vacancy = resumeVacancyControllerSubject.value;
//     final String age = ageControllerSubject.value;
//     final String source = sourceControllerSubject.value;
//     final String name = nameControllerSubject.value;
//     final String comments = commentsControllerSubject.value;
//     final int archiv = archivControllerSubject.value;
//     final String status = statusControllerSubject.value;
//     final int resumeId = resumeIdControllerSubject.value;
//
//     return FullResumeInfo(
//         archiv: archiv,
//         date_last_changes: null,
//         hrName: null,
//         resumeId: resumeId,
//         status: status,
//         vacancy: vacancy,
//         fullName: name,
//         age: int.parse(age),
//         source: source,
//         comments: comments);
//   }
//
//   void exit() {
//     print("Exit");
//     deleteUserData();
//     // entranceBloc.stateRequest.add(StateContentRequest.none);
//   }
//
//   Future<void> deleteUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = jsonEncode({"user_id": "", "role": ""});
//     await prefs.setString("data", data);
//   }
//
//   Future<void> getId() async {
//     final prefs = await SharedPreferences.getInstance();
//     final decodedData = prefs.getString('data');
//
//     if (decodedData != null) {
//       final encodeData = json.decode(decodedData!);
//       final userId = encodeData['user_id'];
//       userIdSubject.add(userId!);
//     }
//   }
// }
//
// class ResumeInfo {
//   final vacancy;
//   final age;
//   final fullName;
//   final source;
//   final comments;
//
//   ResumeInfo(
//       {required this.vacancy,
//       required this.fullName,
//       required this.age,
//       required this.source,
//       required this.comments});
//
//   @override
//   String toString() =>
//       'FiltersInfo(vacancy: $vacancy, age: $age, source: $source, full_name: $fullName, comment: $comments)';
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is ResumeInfo &&
//           runtimeType == other.runtimeType &&
//           vacancy == other.vacancy &&
//           age == other.age &&
//           fullName == other.fullName &&
//           comments == other.comments &&
//           source == other.source;
//
//   @override
//   int get hashCode =>
//       vacancy.hashCode ^
//       age.hashCode ^
//       fullName.hashCode ^
//       comments.hashCode ^
//       source.hashCode;
// }
// //
// // class FullResumeInfo extends ResumeInfo {
// //   final archiv;
// //   final date_last_changes;
// //   final hrName;
// //   final resumeId;
// //   final status;
// //
// //   FullResumeInfo({
// //     required this.archiv,
// //     required this.date_last_changes,
// //     required this.hrName,
// //     required this.resumeId,
// //     required this.status,
// //     required super.vacancy,
// //     required super.fullName,
// //     required super.age,
// //     required super.source,
// //     required super.comments,
// //   });
// //
// //   @override
// //   String toString() {
// //     return 'FullResumeInfo{archiv: $archiv, date_last_changes: $date_last_changes, hr_id: $hrName, resume_id: $resumeId, status: $status}, vacancy: $vacancy, age: $age, source: $source, full_name: $fullName, comment: $comments)}';
// //   }
// //
// //   @override
// //   bool operator ==(Object other) =>
// //       identical(this, other) ||
// //       super == other &&
// //           other is FullResumeInfo &&
// //           runtimeType == other.runtimeType &&
// //           fullName == other.fullName &&
// //           archiv == other.archiv &&
// //           vacancy == other.vacancy &&
// //           age == other.age &&
// //           source == other.source &&
// //           date_last_changes == other.date_last_changes &&
// //           hrName == other.hrName &&
// //           comments == other.comments &&
// //           resumeId == other.resumeId &&
// //           status == other.status;
// //
// //   @override
// //   int get hashCode =>
// //       super.hashCode ^
// //       archiv.hashCode ^
// //       date_last_changes.hashCode ^
// //       hrName.hashCode ^
// //       resumeId.hashCode ^
// //       vacancy.hashCode ^
// //       fullName.hashCode ^
// //       age.hashCode ^
// //       source.hashCode ^
// //       comments.hashCode ^
// //       status.hashCode;
// // }
//
// enum StateRequest {
//   none,
//   loading,
//   error,
//   good,
// }
//
// enum StateWidget {
//   loading,
//   error,
//   result,
// }
