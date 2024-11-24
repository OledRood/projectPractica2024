import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:hr_monitor/pages/create_resume_page.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/resume.dart';
import '../resources/api_routes.dart';
import '../resources/roles.dart';

class Bloc {
  final usernameControllerSubject = BehaviorSubject<String>.seeded('');
  final passwordControllerSubject = BehaviorSubject<String>.seeded('');
  final userIdSubject = BehaviorSubject<int>();
  final roleSubject = BehaviorSubject<Role>();

  Stream<Role> observeRoleSubject() => roleSubject;

  final resumeVacancyControllerSubject = BehaviorSubject<String>.seeded("");
  final resumeAgeControllerSubject = BehaviorSubject<String>.seeded("");
  final resumeCommentsControllerSubject = BehaviorSubject<String>.seeded("");
  final resumeStatusControllerSubject = BehaviorSubject<String>.seeded("");
  final resumeNameControllerSubject = BehaviorSubject<String>.seeded("");
  final resumeSourceControllerSubject = BehaviorSubject<String>.seeded('');
  final resumeIdControllerSubject = BehaviorSubject<int>.seeded(-1);

  Stream<int> observeResumeIdSubject() => resumeIdControllerSubject;

  final resumeArchivControllerSubject = BehaviorSubject<int>.seeded(-1);

  Bloc() {
    tryFastEntrance();
  }

// TODO LogInRequest
// ----------------------------------------------------------------------------------------------------

  final BehaviorSubject<StateRequest> stateLogInSubject =
      BehaviorSubject.seeded(StateRequest.none);

  final BehaviorSubject<StateRequest> stateLogInPageContentSubject =
      BehaviorSubject.seeded(StateRequest.none);

  Stream<StateRequest> observeStateLogInPageContent() =>
      stateLogInPageContentSubject;

  Stream<StateRequest> observeStateLogInSubject() => stateLogInSubject;

  StreamSubscription? entranceRequestSubscription;

  Future sendPassWordAndLogin() async {
    final username = usernameControllerSubject.value;
    final password = passwordControllerSubject.value;

    print("sendPasswordAndLogin: name: $username, pass: $password");
    stateLogInPageContentSubject.add(StateRequest.loading);
    stateLogInSubject.add(StateRequest.loading);
    entranceRequestSubscription?.cancel();
    entranceRequestSubscription =
        requestEntrance(username: username, password: password)
            .asStream()
            .listen(
      (searchResult) {
        print(searchResult);
        if (searchResult[1] == 200) {
          if (searchResult[0]['result'] == true) {
            userIdSubject.add(searchResult[0]['id']);

            roleSubject.add(Roles.getRole(searchResult[0]['role'])!);
            saveUserData();
            stateLogInSubject.add(StateRequest.good);
            stateLogInPageContentSubject.add(StateRequest.good);
          } else {
            stateLogInSubject.add(StateRequest.bad);
            stateLogInPageContentSubject.add(StateRequest.bad);
          }
        } else if (searchResult[1] == 400) {
          stateLogInSubject.add(StateRequest.errorConnection);
          stateLogInPageContentSubject.add(StateRequest.errorConnection);
        } else if (searchResult['result'] >= 500 && searchResult[1] <= 600) {
          stateLogInSubject.add(StateRequest.serverError);
          stateLogInPageContentSubject.add(StateRequest.serverError);
        } else {
          stateLogInSubject.add(StateRequest.bad);
          stateLogInPageContentSubject.add(StateRequest.bad);
        }
      },
      onError: (error, stackTrace) {
        print("sendPassWordAndLogin: $error");
        stateLogInSubject.add(StateRequest.bad);
        stateLogInPageContentSubject.add(StateRequest.bad);
      },
    );
  }

  Future requestEntrance({
    required String username,
    required String password,
  }) async {
    print('requestEntrance: $username, $password');
    try {
      var headers = Routes.headers;
      var request =
          http.Request('POST', Uri.parse(Routes.loginRequest));
      request.body =
          json.encode({"username": "$username", "password": "$password"});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        var found = jsonDecode(responseData);
        return [found, 200];
      } else {
        return [{}, response.statusCode];
      }
    } catch (e) {
      return [{}, 400];
    }
  }

  Future saveUserData() async {
    print('Сохранилось');
    final int userId = userIdSubject.value;
    final String userName = usernameControllerSubject.value;
    final String password = passwordControllerSubject.value;

    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(
        {"user_id": userId, "password": password, 'user_name': userName});
    await prefs.setString(
        "data", data); // Сохраняем значение 'id' с ключом 'user_id'
  }

  Future tryFastEntrance() async {
    print('Start tryFastEntrance');
    final prefs = await SharedPreferences.getInstance();

    final String? jsonData = prefs.getString("data");

    if (jsonData != null) {
      final Map<String, dynamic> data = jsonDecode(jsonData);
      final int userId = data["user_id"] ?? "";
      print(userId);
      final String userName = data["user_name"] ?? "";
      print(userName);
      final String password = data["password"] ?? "";

      if (userId != -1 && userName != '' && password != '') {
        // Выводим значения или используем их
        print("User ID: $userId");
        print("password: $password");
        passwordControllerSubject.add(password);
        usernameControllerSubject.add(userName);
        userIdSubject.add(userId);
        sendPassWordAndLogin();
      }
    }
  }

// TODO MainPage
// ----------------------------------------------------------------------------------------------------

  final resumeMainPageListStateSubject = BehaviorSubject<StateRequest>();
  final resultResumeListToMainPageSubject =
      BehaviorSubject<List<FullResumeInfo>>();

  StreamSubscription? getAllResumeToMainPageSubscription;

  Stream<List<FullResumeInfo>> observeResultListResume() =>
      resultResumeListToMainPageSubject;

// void getAllResumesToHr(final bool isArchiv) {
  void getAllResumeToMainPage() {
    resumeMainPageListStateSubject.add(StateRequest.loading);
    getAllResumeToMainPageSubscription?.cancel();
    getAllResumeToMainPageSubscription =
        requestToGetAllResumesToMainPage().asStream().listen((resumes) {
      if (resumes.isEmpty) {
        print('resume.isEmpty');
        resultResumeListToMainPageSubject.add([]);
        resumeMainPageListStateSubject.add(StateRequest.error);
      }
      resultResumeListToMainPageSubject.add(resumes);
      resumeMainPageListStateSubject.add(StateRequest.good);
    }, onError: (error, stackTrace) {
      resumeMainPageListStateSubject.add(StateRequest.error);
      print('OnError getAllResumeToMainPage: $error');
    });
  }

  // Future<List<FullResumeInfo>> requestToGetHrResume(bool isArchiv) async {

  Future<List<FullResumeInfo>> requestToGetAllResumesToMainPage() async {
    final userId = userIdSubject.value;
    final body = json.encode({"user_id": userId});
    final headers = Routes.headers;
    var response = await http.post(
        Uri.parse(Routes.getResumeToMainPage),
        headers: headers,
        body: body);
    if (response.statusCode == 200) {
      final List<dynamic> result = json.decode(response.body);

      //Здесь мы декодируем полученный json в Map<String, dynamic> каждую строчку
      final List<Resume> resumes = result.map((rawResume) {
        return Resume.fromJson(rawResume);
      }).toList();
      final List<FullResumeInfo> found = resumes.map((resume) {
        return FullResumeInfo(
            vacancy: resume.vacancy,
            fullName: resume.fullName,
            age: resume.age,
            source: resume.source,
            archiv: resume.archiv,
            date_last_changes: resume.dateLastChanges,
            hrName: resume.hrName,
            resumeId: resume.resumeId,
            status: resume.status,
            comments: resume.comments);
      }).toList();
      return found;
    }
    throw Exception('something error in search');
  }

//TODO ResumeInfoPage
// ----------------------------------------------------------------------------------------------------

//TODO Отправка резюме для его обновления

  final stateUpdateRequest =
      BehaviorSubject<StateRequest>.seeded(StateRequest.none);

  Stream<StateRequest> observeStateUpdateRequest() => stateUpdateRequest;

  StreamSubscription? requestToUpdateSubscription;

  void sendResumeToUpdate() {
    stateUpdateRequest.add(StateRequest.loading);
    final resumeData = getResumeInfoFromSubject();
    requestToUpdateSubscription?.cancel();
    print("Итак комментарий равен = ${resumeData.comments.runtimeType}");
    requestToUpdateSubscription = requestToUpdateResume(
            vacancy: resumeData.vacancy,
            age: resumeData.age,
            source: resumeData.source,
            fullName: resumeData.fullName,
            resumeId: resumeData.resumeId,
            comments: resumeData.comments,
            archiv: resumeData.archiv,
            status: resumeData.status)
        .asStream()
        .listen((createAnswer) {
      print('createAnswer: $createAnswer');
      if (createAnswer == "good") {
        getAllResumeToMainPage();
        stateUpdateRequest.add(StateRequest.good);
      } else {
        stateUpdateRequest.add(StateRequest.error);
      }
    }, onError: (e) {
      print('Ошибка в sendResumeToUpdate: ${e}');
      stateUpdateRequest.add(StateRequest.error);
    });
  }

  Future requestToUpdateResume({
    required String vacancy,
    required int age,
    required String source,
    required String fullName,
    required int resumeId,
    required String comments,
    required int archiv,
    required String status,
  }) async {
    print('requestToUpdateResume start');
    var headers = {'Content-Type': 'application/json'};
    var request =
        http.Request('POST', Uri.parse('http://127.0.0.1:5000/resume/update'));
    request.body = json.encode({
      "vacancy": vacancy,
      "age": age,
      "name": fullName,
      "source": source,
      "resume_id": resumeId,
      'comments': comments,
      "archiv": archiv,
      "status": status,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    String responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(responseData);
      return jsonData['response'];
    } else {
      // return null;
    }
  }

  Future resetStateUpgrateResumeRequestSubject() async {
    await Future.delayed(Duration(seconds: 1));
    stateUpdateRequest.add(StateRequest.none);
  }

  FullResumeInfo getResumeInfoFromSubject() {
    final String vacancy = resumeVacancyControllerSubject.value;
    final String age = resumeAgeControllerSubject.value;
    final String source = resumeSourceControllerSubject.value;
    final String name = resumeNameControllerSubject.value;
    final String comments = resumeCommentsControllerSubject.value;
    final int archiv = resumeArchivControllerSubject.value;
    final String status = resumeStatusControllerSubject.value;
    final int resumeId = resumeIdControllerSubject.value;

    final int intAge = (age == "") ?  -1 : int.parse(age);

    return FullResumeInfo(
        archiv: archiv,
        date_last_changes: null,
        hrName: null,
        resumeId: resumeId,
        status: status,
        vacancy: vacancy,
        fullName: name,
        age: intAge,
        source: source,
        comments: comments);
  }

// TODO searchPage
// ----------------------------------------------------------------------------------------------------
  final stateSearchListWidget =
      BehaviorSubject<StateRequest>.seeded(StateRequest.none);
  final searchTextControllerSubject = BehaviorSubject<String>.seeded('');
  final resumeToSearchResultSubject = BehaviorSubject<List<FullResumeInfo>>();

  Stream<List<FullResumeInfo>> observeSearchedResume() =>
      resumeToSearchResultSubject;
  StreamSubscription? searchWithFiltersSubscription;

  void sendResumeToSearchWithFilters() {
    print('Send запустилось');
    stateSearchListWidget.add(StateRequest.loading);
    final resume = getResumeInfoFromSubject();
    final age = (resume.age == -1) ? "" : resume.age.toString();
    final String status = (resume.status == 'Любой') ? "" : resume.status;
    final userId = userIdSubject.value;
    print("age: ${resume.age}");
    final searchText = searchTextControllerSubject.value;
    searchWithFiltersSubscription?.cancel();
    searchWithFiltersSubscription = requestToSearchWithFilters(
      vacancy: resume.vacancy ?? "",
      age: age,
      name: resume.fullName ?? "",
      source: resume.source ?? "",
      archiv: resume.archiv ?? "",
      status: status,
      searchText: searchText ?? "",
      userId: userId,
    ).asStream().listen((resultValue) {
      if (resultValue[1] == 200) {
        if (resultValue[0] == []) {
          stateSearchListWidget.add(StateRequest.nothingFound);
        } else {
          print(resultValue[1]);
          stateSearchListWidget.add(StateRequest.good);
          resumeToSearchResultSubject.add(resultValue[0]);
        }
      } else {
        print('state.result');
        stateSearchListWidget.add(StateRequest.error);

      }
    }
        // stateUpgrateResumeRequestSubject.add(StateRequest.error);

        );
  }

  Future requestToSearchWithFilters({
    required String vacancy,
    required String age,
    required String source,
    required String name,
    required int archiv,
    required String status,
    required String searchText,
    required int userId,
  }) async {
    final body = json.encode({
      "search_text": searchText,
      "vacancy": vacancy,
      "age": age,
      "name": name,
      "source": source,
      "archiv": archiv,
      "status": status,
      'user_id': userId,
    });
    final headers = {'Content-Type': 'application/json'};
    var response = await http.post(Uri.parse(Routes.searchResume),
        headers: headers, body: body);
    if (response.statusCode == 200) {
      final List<dynamic> result = json.decode(response.body);

      //Здесь мы декодируем полученный json в Map<String, dynamic> каждую строчку
      final List<Resume> resumes = result.map((rawResume) {
        //Ошибка здесь
        return Resume.fromJson(rawResume);
      }).toList();
      final List<FullResumeInfo> found = resumes.map((resume) {
        return FullResumeInfo(
            vacancy: resume.vacancy,
            fullName: resume.fullName,
            age: resume.age,
            source: resume.source,
            archiv: resume.archiv,
            date_last_changes: resume.dateLastChanges,
            hrName: resume.hrName,
            resumeId: resume.resumeId,
            status: resume.status,
            comments: resume.comments);
      }).toList();
      return [found, 200];
    }
    return [null, response.statusCode];
  }

  void addArchivContollerWhenSearch(String archivText) {
    switch (archivText) {
      case 'Не важно':
        resumeArchivControllerSubject.add(-1);
      case 'Активно':
        resumeArchivControllerSubject.add(0);
      case 'В архиве':
        resumeArchivControllerSubject.add(1);
    }
  }



//TODO CreatePage
//------------------------------------------------------------------------------------------

  final stateCreateButtonSubject =
      BehaviorSubject<StateRequest>.seeded(StateRequest.none);
  StreamSubscription? resumeToCreateSubscription;

  Stream<StateRequest> observeStateCreateButton() => stateCreateButtonSubject;

  Future sendResumeToCreate() async {
    final resumeData = getResumeInfoFromSubject();

    if (resumeData.resumeId != '' && resumeData.age != '') {
      stateCreateButtonSubject.add(StateRequest.loading);
      resumeToCreateSubscription?.cancel();
      resumeToCreateSubscription = requestToCreateResume(
              vacancy: resumeData.vacancy,
              age: int.parse(resumeData.age),
              source: resumeData.source,
              name: resumeData.fullName,
              id: int.parse(resumeData.resumeId),
              comments: resumeData.comments)
          .asStream()
          .listen((searchResult) {
        if (searchResult == 'good') {
          stateCreateButtonSubject.add(StateRequest.good);
        } else {
          stateCreateButtonSubject.add(StateRequest.error);
        }
      }, onError: (e) {
        print('Error in Create Resume: $e');
        stateCreateButtonSubject.add(StateRequest.error);
      });
    }
  }

  Future requestToCreateResume({
    required String vacancy,
    required int age,
    required String source,
    required String name,
    required int id,
    required String comments,
  }) async {
    var request = http.Request('POST', Uri.parse(Routes.createResume));
    request.body = json.encode({
      "vacancy": vacancy,
      "age": age,
      "name": name,
      "source": source,
      "id": id,
      'comments': comments
    });
    request.headers.addAll(Routes.headers);

    http.StreamedResponse response = await request.send();
    String responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(responseData);
      return jsonData['response'];
    }
  }

  void cancelCreateSubscription() {
    stateCreateButtonSubject.add(StateRequest.none);
    resumeToCreateSubscription?.cancel();
  }

  void exit() {
    print("Exit");
    stateLogInPageContentSubject.add(StateRequest.none);
    stateLogInSubject.add(StateRequest.none);
    resumeIdControllerSubject.add(-1);

    //Для того чтобы обнулять данные поиска при выхоже
    stateSearchListWidget.add(StateRequest.none);
    cleanResumeControllers();
    deleteUserData();
  }
  void cleanResumeControllers() {
    resumeVacancyControllerSubject.add('');
    resumeAgeControllerSubject.add("");
    resumeSourceControllerSubject.add('');
    resumeNameControllerSubject.add('');
    resumeCommentsControllerSubject.add('');
    resumeArchivControllerSubject.add(-1);
    resumeStatusControllerSubject.add("");
  }

  Future<void> deleteUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode({"user_id": -1, "role": "", 'password': ""});
    await prefs.setString("data", data);
  }

  dispose() {
    usernameControllerSubject.close();
    passwordControllerSubject.close();
    userIdSubject.close();
    stateLogInSubject.close();
    stateLogInPageContentSubject.close();
    entranceRequestSubscription?.cancel();
    roleSubject.close();
    resumeVacancyControllerSubject.close();
    resumeAgeControllerSubject.close();
    resumeCommentsControllerSubject.close();
    resumeStatusControllerSubject.close();
    resumeNameControllerSubject.close();
    resumeSourceControllerSubject.close();
    resumeIdControllerSubject.close();
    resumeMainPageListStateSubject.close();
    resultResumeListToMainPageSubject.close();
    getAllResumeToMainPageSubscription?.cancel();
    stateUpdateRequest.close();
    requestToUpdateSubscription?.cancel();
    stateSearchListWidget.close();
    stateSearchListWidget.close();
    searchTextControllerSubject.close();
    resumeToSearchResultSubject.close();
    searchWithFiltersSubscription?.cancel();
    stateCreateButtonSubject.close();
    resumeToCreateSubscription?.cancel();
  }
}

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

enum StateRequest {
  none,
  loading,
  serverError,
  errorConnection,
  bad,
  good,
  error,
  nothingFound
}

enum Role { hr, hr_lead, admin }
