// import 'dart:async';
// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:hr_monitor/bloc/entrance_bloc.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import '../models/resume.dart';
// import '../resources/roles.dart';
// import '../resources/status.dart';
// import 'bloc.dart';
//
// class MainBlocHr {
//   EntranceBloc entranceBloc = EntranceBloc();
//
//   final vacancyControllerSubject = BehaviorSubject<String>.seeded("");
//   final ageControllerSubject = BehaviorSubject<String>.seeded("");
//   final commentsControllerSubject = BehaviorSubject<String>.seeded("");
//   final statusControllerSubject = BehaviorSubject<String>.seeded("");
//   final nameControllerSubject = BehaviorSubject<String>.seeded("");
//   final sourceControllerSubject = BehaviorSubject<String>.seeded('');
//   final resumeIdControllerSubject = BehaviorSubject<int>.seeded(-1);
//   final archivControllerSubject = BehaviorSubject<int>.seeded(-1);
//   final stateUpgrateResumeRequestSubject =
//       BehaviorSubject<StateRequest>.seeded(StateRequest.none);
//
//
//
//   final userIdSubject = BehaviorSubject<String>.seeded('');
//
//   final BehaviorSubject<StateRequest> stateButtonLoading =
//       BehaviorSubject.seeded(StateRequest.none);
//   StreamSubscription? requestSubscription;
//   StreamSubscription? requestAllResumeSubscription;
//
//   Stream<StateRequest> observePageState() => stateButtonLoading;
//   Stream<Role?> observeRole() => entranceBloc.roleSubject;
//   Stream<int> observeResumeId() => resumeIdControllerSubject;
//
//   //Весь контроль по списку резюме для начального виджета
//   Stream<List<FullResumeInfo>> observeResultListResume() =>
//       resumeListResultSubject;
//
//   Stream<StateResumesListWidget> observeStateResumeListSubject() =>
//       resumeListStateSubject;
//
//   //Состояние виджета списка
//   final resumeListStateSubject = BehaviorSubject<StateResumesListWidget>();
//   StreamSubscription? getAllResumeSubscription;
//   final resumeListResultSubject = BehaviorSubject<List<FullResumeInfo>>();
//
//   void getAllResumesToHr(final bool isArchiv) {
//     resumeListStateSubject.add(StateResumesListWidget.loading);
//     getAllResumeSubscription?.cancel();
//     getAllResumeSubscription =
//         requestToGetHrResume(isArchiv).asStream().listen((resumes) {
//       if (resumes.isEmpty) {
//         print('resume.isEmpty');
//         resumeListResultSubject.add([]);
//         resumeListStateSubject.add(StateResumesListWidget.error);
//       }
//       resumeListResultSubject.add(resumes);
//       resumeListStateSubject.add(StateResumesListWidget.result);
//     }, onError: (error, stackTrace) {
//       resumeListStateSubject.add(StateResumesListWidget.error);
//       print('OnError getAllResumeToHR: $error');
//     });
//   }
//
//   Future<List<FullResumeInfo>> requestToGetHrResume(bool isArchiv) async {
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
//             hrId: resume.hrName,
//             resumeId: resume.resumeId,
//             status: resume.status,
//             comments: resume.comments);
//       }).toList();
//       return found;
//     }
//     throw Exception('something error in search');
//   }
//
//   MainBlocHr() {
//     requestSubscription = Rx.combineLatest5(
//         vacancyControllerSubject,
//         ageControllerSubject,
//         sourceControllerSubject,
//         nameControllerSubject,
//         commentsControllerSubject,
//         (vacancy, age, source, name, comments) => ResumeInfo(
//             vacancy: vacancy,
//             age: age,
//             source: source,
//             fullName: name,
//             comments: comments)).listen((value) {
//       getId();
//       final idhnik = userIdSubject.value;
//       if (value.vacancy != '' &&
//           value.fullName != '' &&
//           value.source != '' &&
//           idhnik != '' &&
//           value.age != 0) {
//         stateButtonLoading.add(StateRequest.loading);
//         sendResumeToCreate(
//             vacancy: value.vacancy,
//             age: value.age,
//             name: value.fullName,
//             source: value.source,
//             id: idhnik,
//             comments: value.comments);
//       }
//     });
//   }
//
//   final stateSearchListWidget =
//       BehaviorSubject<StateSearchList>.seeded(StateSearchList.none);
//   final searchTextControllerSubject = BehaviorSubject<String>.seeded('');
//
//   Stream<StateSearchList> observeSearchListWidgetState() =>
//       stateSearchListWidget;
//   StreamSubscription? searchWithFiltersSubscription;
//   final resumeToSearchResultSubject = BehaviorSubject<List<FullResumeInfo>>();
//
//   Stream<List<FullResumeInfo>> observeResultResumeToSearch() =>
//       resumeToSearchResultSubject;
//
//   void sendResumeToSearchWithFilters() {
//     stateSearchListWidget.add(StateSearchList.loading);
//     searchWithFiltersSubscription?.cancel();
//     searchWithFiltersSubscription = Rx.combineLatest7(
//         vacancyControllerSubject,
//         ageControllerSubject,
//         sourceControllerSubject,
//         nameControllerSubject,
//         statusControllerSubject,
//         archivControllerSubject,
//         searchTextControllerSubject,
//         (vacancy, age, source, name, status, archiv, searchText) => FullResumeInfo(
//             vacancy: vacancy,
//             age: age,
//             source: source,
//             fullName: name,
//             //Использую костыль, чтобы не терять время (comments = search text)
//             comments: searchText,
//             resumeId: null,
//             archiv: archiv,
//             date_last_changes: null,
//             hrName: null,
//             status: status)).listen((value) {
//       final String status = (value.status == 'Любой') ? "" : value.status;
//       requestToSearchWithFilters(
//         vacancy: value.vacancy,
//         age: value.age,
//         name: value.fullName,
//         source: value.source,
//         archiv: value.archiv,
//         status: status,
//         searchText: value.comments,
//       );
//     });
//   }
//
//   Future requestToSearchWithFilters({
//     required String vacancy,
//     required String age,
//     required String source,
//     required String name,
//     required int archiv,
//     required String status,
//     required String searchText,
//   }) async {
//     final body = json.encode({
//       "search_text": searchText,
//       "vacancy": vacancy,
//       "age": age,
//       "name": name,
//       "source": source,
//       "archiv": archiv,
//       "status": status,
//     });
//     final headers = {'Content-Type': 'application/json'};
//     var response = await http.post(
//         Uri.parse('http://127.0.0.1:5000/resume/search'),
//         headers: headers,
//         body: body);
//     if (response.statusCode == 200) {
//       print('statusCode: ${response.statusCode}');
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
//             hrId: resume.hrName,
//             resumeId: resume.resumeId,
//             status: resume.status,
//             comments: resume.comments);
//       }).toList();
//       if (found == []) {
//         stateSearchListWidget.add(StateSearchList.nothingFound);
//       } else {
//         print('state.result');
//         stateSearchListWidget.add(StateSearchList.result);
//       }
//       resumeToSearchResultSubject.add(found);
//     } else {
//       stateSearchListWidget.add(StateSearchList.error);
//       // stateUpgrateResumeRequestSubject.add(StateRequest.error);
//     }
//   }
//
//   void sendResumeToUpdate() {
//     stateUpgrateResumeRequestSubject.add(StateRequest.loading);
//     requestSubscription?.cancel();
//     requestSubscription = Rx.combineLatest8(
//         vacancyControllerSubject,
//         ageControllerSubject,
//         sourceControllerSubject,
//         nameControllerSubject,
//         commentsControllerSubject,
//         resumeIdControllerSubject,
//         statusControllerSubject,
//         archivControllerSubject,
//         (vacancy, age, source, name, comments, resumeId, status, archiv) =>
//             FullResumeInfo(
//                 vacancy: vacancy,
//                 age: age,
//                 source: source,
//                 fullName: name,
//                 comments: comments,
//                 resumeId: resumeId,
//                 archiv: archiv,
//                 date_last_changes: "",
//                 hrId: "",
//                 status: status)).listen((value) {
//       requestToUpdateResume(
//         vacancy: value.vacancy,
//         age: value.age,
//         name: value.fullName,
//         source: value.source,
//         resumeId: value.resumeId,
//         comments: value.comments,
//         archiv: value.archiv,
//         status: value.status,
//       );
//     });
//   }
//
//   Future resetStateUpgrateResumeRequestSubject() async {
//     await Future.delayed(Duration(seconds: 1));
//     stateUpgrateResumeRequestSubject.add(StateRequest.none);
//   }
//
//   Future requestToUpdateResume({
//     required String vacancy,
//     required int age,
//     required String source,
//     required String name,
//     required int resumeId,
//     required String comments,
//     required int archiv,
//     required String status,
//   }) async {
//     var headers = {'Content-Type': 'application/json'};
//     var request =
//         http.Request('POST', Uri.parse('http://127.0.0.1:5000/resume/update'));
//     request.body = json.encode({
//       "vacancy": vacancy,
//       "age": age,
//       "name": name,
//       "source": source,
//       "resume_id": resumeId,
//       'comments': comments,
//       "archiv": archiv,
//       "status": status,
//     });
//     request.headers.addAll(headers);
//
//     http.StreamedResponse response = await request.send();
//
//     if (response.statusCode == 200) {
//       stateUpgrateResumeRequestSubject.add(StateRequest.good);
//     } else {
//       stateUpgrateResumeRequestSubject.add(StateRequest.error);
//     }
//   }
//
//   void sendResumeToCreate(
//       {required String vacancy,
//       required String age,
//       required String source,
//       required String id,
//       required String name,
//       required final String comments}) {
//     if (id != "") {
//       stateButtonLoading.add(StateRequest.loading);
//       requestSubscription?.cancel();
//       requestSubscription = requestToCreateResume(
//               vacancy: vacancy,
//               age: int.parse(age),
//               source: source,
//               name: name,
//               comments: comments,
//               id: int.parse(id))
//           .asStream()
//           .listen(
//         (searchResult) {
//           print("Good");
//
//           if (searchResult == "" || searchResult == "not created") {
//             stateButtonLoading.add(StateRequest.error);
//           } else if (searchResult == "created") {
//             stateButtonLoading.add(StateRequest.good);
//           }
//         },
//         onError: (error, stackTrace) {
//           print("SearchError");
//           print(error);
//           stateButtonLoading.add(StateRequest.error);
//         },
//       );
//     } else {
//       stateButtonLoading.add(StateRequest.idError);
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
//     var headers = {'Content-Type': 'application/json'};
//     var request =
//         http.Request('POST', Uri.parse('http://127.0.0.1:5000/resume/create'));
//     request.body = json.encode({
//       "vacancy": vacancy,
//       "age": age,
//       "name": name,
//       "source": source,
//       "id": id,
//       'comments': comments
//     });
//     request.headers.addAll(headers);
//
//     http.StreamedResponse response = await request.send();
//
//     if (response.statusCode == 200) {
//       stateButtonLoading.add(StateRequest.good);
//     } else {
//       stateButtonLoading.add(StateRequest.error);
//     }
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
//
//   // Future<void> getRole() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final decodedData = prefs.getString('role');
//   //
//   //   if (decodedData != null) {
//   //     final encodeData = json.decode(decodedData!);
//   //     final role = Roles.getRole(encodeData['role']) ;
//   //     print("Роль добавлена");
//   //     roleSubject.add(role!);
//   //   }
//   // }
//
//   void exit() {
//     print("Exit");
//     deleteUserData();
//     entranceBloc.stateLogInSubject.add(StateContentRequest.none);
//   }
//
//   Future<void> deleteUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = jsonEncode({"user_id": "", "role": ""});
//     await prefs.setString("data", data);
//   }
//
//   void addArchivContollerWhenSearch(String archivText) {
//     switch (archivText) {
//       case 'Не важно':
//         archivControllerSubject.add(-1);
//       case 'Активно':
//         archivControllerSubject.add(0);
//       case 'В архиве':
//         archivControllerSubject.add(1);
//     }
//   }
//
//   void cleanResumeControllers() {
//     vacancyControllerSubject.add('');
//     ageControllerSubject.add("");
//     commentsControllerSubject.add('');
//     statusControllerSubject.add('');
//     nameControllerSubject.add('');
//     sourceControllerSubject.add('');
//     // resumeIdControllerSubject.add(-1);
//     archivControllerSubject.add(-1);
//   }
//
//   dispose() {
//     getAllResumeSubscription?.cancel();
//     resumeListStateSubject.close();
//     userIdSubject.close();
//     vacancyControllerSubject.close();
//     ageControllerSubject.close();
//     nameControllerSubject.close();
//     sourceControllerSubject.close();
//     commentsControllerSubject.close();
//     userIdSubject.close();
//     resumeIdControllerSubject.close();
//     searchWithFiltersSubscription?.cancel();
//     stateUpgrateResumeRequestSubject.close();
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
// //   final hrId;
// //   final resumeId;
// //   final status;
// //
// //   FullResumeInfo({
// //     required this.archiv,
// //     required this.date_last_changes,
// //     required this.hrId,
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
// //     return 'FullResumeInfo{archiv: $archiv, date_last_changes: $date_last_changes, hr_id: $hrId, resume_id: $resumeId, status: $status}, vacancy: $vacancy, age: $age, source: $source, full_name: $fullName, comment: $comments)}';
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
// //           hrId == other.hrId &&
// //           comments == other.comments &&
// //           resumeId == other.resumeId &&
// //           status == other.status;
// //
// //   @override
// //   int get hashCode =>
// //       super.hashCode ^
// //       archiv.hashCode ^
// //       date_last_changes.hashCode ^
// //       hrId.hashCode ^
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
//   idError,
//   good,
// }
//
// enum StateResumesListWidget {
//   loading,
//   error,
//   result,
// }
//
// enum StateSearchList { none, error, loading, result, nothingFound }
