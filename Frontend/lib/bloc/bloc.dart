import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:hr_monitor/models/admin/users_data.dart';
import 'package:hr_monitor/models/resume_list.dart';
import 'package:hr_monitor/pages/create_resume_page.dart';
import 'package:hr_monitor/pages/info_resume_page.dart';
import 'package:hr_monitor/types/resume_statistics.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/resume.dart';
import '../models/statistics/statistics.dart';
import '../resources/api_routes.dart';
import '../resources/roles.dart';
import '../types/full_resume.dart';
import 'admin.dart';

class Bloc {
  final usernameControllerSubject = BehaviorSubject<String>.seeded('');
  final passwordControllerSubject = BehaviorSubject<String>.seeded('');
  final userTokenSubject = BehaviorSubject<String>();
  final roleSubject = BehaviorSubject<Role>();

  Stream<Role> observeRoleSubject() => roleSubject;

  final resumeVacancyControllerSubject = BehaviorSubject<String>.seeded("");
  final resumeAgeControllerSubject = BehaviorSubject<String>.seeded("");
  final resumeCommentsControllerSubject = BehaviorSubject<String>.seeded("");
  final resumeStatusControllerSubject = BehaviorSubject<String>.seeded("");
  final resumeNameControllerSubject = BehaviorSubject<String>.seeded("");
  final resumeSourceControllerSubject = BehaviorSubject<String>.seeded('');
  final resumeIdControllerSubject = BehaviorSubject<int>.seeded(-1);
  final resumeArchivControllerSubject = BehaviorSubject<int>.seeded(-1);
  final resumeHrNameControllerSubject = BehaviorSubject<String>.seeded("");
  final resumeFromDateTimeSubject = BehaviorSubject<DateTime?>.seeded(null);
  final resumeToDateTimeSubject = BehaviorSubject<DateTime?>.seeded(null);

  Stream<int> observeResumeIdSubject() => resumeIdControllerSubject;

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

    stateLogInPageContentSubject.add(StateRequest.loading);
    stateLogInSubject.add(StateRequest.loading);
    entranceRequestSubscription?.cancel();
    entranceRequestSubscription =
        requestEntrance(username: username, password: password)
            .asStream()
            .listen(
      (searchResult) {
        if (searchResult[1] == 200) {
          if (searchResult[0]['result'] == true) {
            userTokenSubject.add(searchResult[0]['token']);

            roleSubject.add(Roles.getRole(searchResult[0]['role'])!);
            sendGetResumeList();
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
        } else if (searchResult[1] >= 500 && searchResult[1] <= 600) {
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
    try {
      var headers = Routes.headers;
      var request = http.Request('POST', Uri.parse(Routes.loginRequest));
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
    final String userToken = userTokenSubject.value;
    final String userName = usernameControllerSubject.value;
    final String password = passwordControllerSubject.value;

    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(
        {"userToken": userToken, "password": password, 'user_name': userName});
    await prefs.setString(
        "data", data); // Сохраняем значение 'id' с ключом 'user_id'
  }

  Future tryFastEntrance() async {
    final prefs = await SharedPreferences.getInstance();

    final String? jsonData = prefs.getString("data");

    if (jsonData != null) {
      final Map<String, dynamic> data = jsonDecode(jsonData);
      final String userToken = data["userToken"] ?? "";
      final String userName = data["user_name"] ?? "";
      final String password = data["password"] ?? "";

      if (userToken != -1 && userName != '' && password != '') {
        // Выводим значения или используем их
        passwordControllerSubject.add(password);
        usernameControllerSubject.add(userName);
        userTokenSubject.add(userToken);
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
      if (error == 'token error') {
        resumeMainPageListStateSubject.add(StateRequest.tokenError);
      }
      resumeMainPageListStateSubject.add(StateRequest.error);
      print('OnError getAllResumeToMainPage: $error');
    });
  }

  // Future<List<FullResumeInfo>> requestToGetHrResume(bool isArchiv) async {

  Future<List<FullResumeInfo>> requestToGetAllResumesToMainPage() async {
    final userToken = userTokenSubject.value;
    final body = json.encode({"token": userToken});
    final headers = Routes.headers;
    var response = await http.post(Uri.parse(Routes.getResumeToMainPage),
        headers: headers, body: body);
    if (response.statusCode == 200) {
      final List<dynamic> result = json.decode(response.body);
      if (result[0]['resume_id'] != null &&
          result[0]['resume_id'] == 'token error') {
        throw Exception('token error');
      }
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
    String userToken = userTokenSubject.value;
    final resumeData = getResumeInfoFromSubject();
    requestToUpdateSubscription?.cancel();
    requestToUpdateSubscription = requestToUpdateResume(
            vacancy: resumeData.vacancy,
            age: resumeData.age,
            source: resumeData.source,
            fullName: resumeData.fullName,
            resumeId: resumeData.resumeId,
            comments: resumeData.comments,
            archiv: resumeData.archiv,
            status: resumeData.status,
            hrName: resumeData.hrName,
            userToken: userToken)
        .asStream()
        .listen((createAnswer) {
      if (createAnswer == "good") {
        getAllResumeToMainPage();
        stateUpdateRequest.add(StateRequest.good);
      } else if (createAnswer == 'token error') {
        stateUpdateRequest.add(StateRequest.tokenError);
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
    required String hrName,
    required String userToken,
  }) async {
    var headers = Routes.headers;
    var request = http.Request('POST', Uri.parse(Routes.updateResume));
    request.body = json.encode({
      "vacancy": vacancy,
      "age": age,
      "name": fullName,
      "source": source,
      "resume_id": resumeId,
      'comments': comments,
      "archiv": archiv,
      "status": status,
      'hr_name': hrName,
      'token': userToken
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
    final String hrName = resumeHrNameControllerSubject.value ?? "Любой";
    final int intAge = (age == "") ? -1 : int.parse(age);

    return FullResumeInfo(
        archiv: archiv,
        date_last_changes: null,
        hrName: hrName,
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
    stateSearchListWidget.add(StateRequest.loading);
    final resume = getResumeInfoFromSubject();
    final age = (resume.age == -1) ? "" : resume.age.toString();
    final String status = (resume.status == 'Любой') ? "" : resume.status;
    final userToken = userTokenSubject.value;
    final String hrName = (resume.hrName == "Любой") ? '' : resume.hrName;
    final searchText = searchTextControllerSubject.value;
    final fromDateText = resumeFromDateTimeSubject.value == null
        ? ""
        : resumeFromDateTimeSubject.value.toString();
    final toDateText = resumeToDateTimeSubject.value == null
        ? ""
        : resumeToDateTimeSubject.value.toString();
    searchWithFiltersSubscription?.cancel();

    searchWithFiltersSubscription = requestToSearchWithFilters(
      vacancy: resume.vacancy ?? "",
      age: age,
      name: resume.fullName ?? "",
      source: resume.source ?? "",
      archiv: resume.archiv ?? "",
      status: status,
      searchText: searchText ?? "",
      userToken: userToken,
      hrName: hrName,
      fromDateText: fromDateText,
      toDateText: toDateText,
    ).asStream().listen((resultValue) {
      if (resultValue[1] == 200) {
        if (resultValue[0] == []) {
          stateSearchListWidget.add(StateRequest.nothingFound);
        } else {
          stateSearchListWidget.add(StateRequest.good);
          resumeToSearchResultSubject.add(resultValue[0]);
        }
      } else if (resultValue[1] == 401) {
        stateSearchListWidget.add(StateRequest.tokenError);
      } else {
        stateSearchListWidget.add(StateRequest.error);
      }
    }
        // stateUpgrateResumeRequestSubject.add(StateRequest.error);

        );
  }

  Future requestToSearchWithFilters(
      {required String vacancy,
      required String age,
      required String source,
      required String name,
      required int archiv,
      required String status,
      required String searchText,
      required String userToken,
      required String hrName,
      required fromDateText,
      required toDateText}) async {
    final body = json.encode({
      "search_text": searchText,
      "vacancy": vacancy,
      "age": age,
      "name": name,
      "source": source,
      "archiv": archiv,
      "status": status,
      'token': userToken,
      'hr_name': hrName,
      "from_date": fromDateText,
      'to_date': toDateText,
    });
    final headers = {'Content-Type': 'application/json'};
    var response = await http.post(Uri.parse(Routes.searchResume),
        headers: headers, body: body);
    if (response.statusCode == 200) {
      final List<dynamic> result = json.decode(response.body);

      if (result[0]['resume_id'] != null &&
          result[0]['resume_id'] == 'token error') {
        return ['token error', 401];
      }
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

    final userToken = userTokenSubject.value;
    if (userToken != -1 && resumeData.age != -1) {
      stateCreateButtonSubject.add(StateRequest.loading);
      resumeToCreateSubscription?.cancel();
      resumeToCreateSubscription = requestToCreateResume(
              vacancy: resumeData.vacancy,
              age: resumeData.age,
              source: resumeData.source,
              name: resumeData.fullName,
              userToken: userToken,
              hrName: resumeData.hrName,
              comments: resumeData.comments)
          .asStream()
          .listen((searchResult) {
        if (searchResult == 'good') {
          stateCreateButtonSubject.add(StateRequest.good);
        } else if (searchResult == "token error") {
          stateCreateButtonSubject.add(StateRequest.tokenError);
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
    required String userToken,
    required String hrName,
    required String comments,
  }) async {
    var request = http.Request('POST', Uri.parse(Routes.createResume));
    request.body = json.encode({
      "vacancy": vacancy,
      "age": "$age",
      "name": name,
      "source": source,
      "token": userToken,
      'comments': comments,
      'hr_name': hrName,
    });
    request.headers.addAll(Routes.headers);

    http.StreamedResponse response = await request.send();
    String responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(responseData);
      return jsonData['response'];
    }
  }

  final resumeListSubject = BehaviorSubject<ResumeList>();

  Stream<ResumeList> observeResumeListSubject() => resumeListSubject;
  StreamSubscription? getResumeListSubscription;

  void sendGetResumeList() {
    final String userToken = userTokenSubject.value;
    getResumeListSubscription?.cancel();
    getResumeListSubscription =
        requestGetResumeLists(userToken).asStream().listen((result) {
      if (result != null) {
        resumeListSubject.add(result);
      } else {
        resumeListSubject.add(ResumeList());
      }

      //Ковертируем jsArray в list<string>
      // List<String> result =
      //     List<String>.from(hrList.map((item) => item.toString()));
    }, onError: (error) {
      resumeListSubject.add(ResumeList());
      print('Error in sendGetResumeList: $error');
    });
  }

  Future<ResumeList?> requestGetResumeLists(String userToken) async {
    final body = json.encode({"token": userToken});
    final headers = Routes.headers;
    var response = await http.post(Uri.parse(Routes.getLists),
        headers: headers, body: body);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result["vacancy"] == "token error") {
        print('error token in search with filters');
        return null;
      }
      // final List<Statistics> resumeStat = result.values.map((rawResume) {
      //   return Statistics.fromJson(rawResume);
      // }).toList();
      final ResumeList found = ResumeList.fromJson(result);
      return found;
    }
    return null;
  }

  void cancelCreateSubscription() {
    stateCreateButtonSubject.add(StateRequest.none);
    resumeToCreateSubscription?.cancel();
  }

//TODO StatisticPage-------------------------------------------------------------------------------
  final stateStatisticRequest =
      BehaviorSubject<StateRequest>.seeded(StateRequest.none);
  final statisticsSubject = BehaviorSubject<List<ResumeStatistic>>();

  Stream<StateRequest> observeStateStatisticsRequest() => stateStatisticRequest;

  Stream<List<ResumeStatistic>> observeStatistics() => statisticsSubject;
  StreamSubscription? statisticSubscription;

  void getStatistic() {
    statisticSubscription?.cancel();
    statisticSubscription = statisticsRequest().asStream().listen(
      (value) {
        if (value.isEmpty) {
          print('statistics.isEmpty');
          statisticsSubject.add([]);
          stateStatisticRequest.add(StateRequest.error);
        }
        statisticsSubject.add(value);
        stateStatisticRequest.add(StateRequest.good);
      },
      //     onError: (error, stackTrace) {
      //   stateStatisticRequest.add(StateRequest.error);
      //   print('OnError getStatistics: $error');
      // }
    );
  }

  Future statisticsRequest() async {
    final userToken = userTokenSubject.value;
    final body = json.encode({"token": userToken});
    final headers = Routes.headers;
    var response = await http.post(Uri.parse(Routes.getStatistic),
        headers: headers, body: body);
    if (response.statusCode == 200) {
      final Map<String, dynamic> result = json.decode(response.body);
      if (result["name"] == 'token error') {
        throw Exception('token error');
      }

      final List<Statistics> resumeStat = result.values.map((rawResume) {
        return Statistics.fromJson(rawResume);
      }).toList();
      final List<ResumeStatistic> found = resumeStat.map((statistics) {
        return ResumeStatistic(
            vacancy: statistics.vacancy,
            source: statistics.source,
            averageTime: statistics.averageTime,
            status: statistics.status,
            name: statistics.name);
      }).toList();
      return found;
    }
    throw Exception('something error in search');
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
    resumeHrNameControllerSubject.add('');
  }

  Future<void> deleteUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode({"userToken": -1, "role": "", 'password': ""});
    await prefs.setString("data", data);
  }

//TODO CreateUserPage-------------------------------------------------------------------------------
  StreamSubscription? userToCreateSubscription;
  final createUsernameSubject = BehaviorSubject.seeded('');
  final createUserRoleSubject = BehaviorSubject.seeded('');
  final createUserPasswordSuject = BehaviorSubject.seeded('');
  final createUsersHrLeadSuject = BehaviorSubject.seeded('');
  final stateCreateUserButtonSubject =
      BehaviorSubject<StateRequest>.seeded(StateRequest.none);

  Future sendUserToCreate() async {
    if (userTokenSubject.value != "") {
      stateCreateButtonSubject.add(StateRequest.loading);
      userToCreateSubscription?.cancel();
      userToCreateSubscription = Admin()
          .requestToCreateUser(
              username: createUsernameSubject.value,
              userRole: createUserRoleSubject.value,
              userToken: userTokenSubject.value,
              userPassword: createUserPasswordSuject.value,
              hrLead: createUsersHrLeadSuject.value)
          .asStream()
          .listen((searchResult) {
        if (searchResult == 'good') {
          stateCreateButtonSubject.add(StateRequest.good);
        } else {
          stateCreateButtonSubject.add(StateRequest.error);
        }
      }, onError: (e) {
        print('Error in Create Resume: $e');
        if (e == 'Token error') {
          stateCreateButtonSubject.add(StateRequest.error);
        } else {
          stateCreateButtonSubject.add(StateRequest.error);
        }
      });
    }
  }

  void cleanUsersController() {
    createUsernameSubject.add('');
    createUserRoleSubject.add('');
    createUserPasswordSuject.add('');
  }

  StreamSubscription? getUsersListSubject;
  final usersListSubject = BehaviorSubject<List<UserTable>>();
  final usersListState =
      BehaviorSubject<StateRequest>.seeded(StateRequest.none);

  Stream<StateRequest> observeUsersListState() => usersListState;
  Stream<List<UserTable>> observeUsersList() => usersListSubject;

  void sendGetUsersList() {
    usersListState.add(StateRequest.loading);
    getUsersListSubject?.cancel();
    getUsersListSubject = Admin()
        .requestGetUsersList(userTokenSubject.value)
        .asStream()
        .listen((result) {
      if (result != null) {
        // print('data in sendGetUsersList: ${result.map((data) => UserTable.fromJson(data)).toList()}');

        usersListSubject.add(result.map((data) => UserTable.fromJson(data)).toList());
        usersListState.add(StateRequest.good);
      } else {
        usersListSubject.add([]);
        usersListState.add(StateRequest.nothingFound);
      }
    }, onError: (error) {
      usersListSubject.add([]);
      print('Error in sendGetUsersList: $error');
      usersListState.add(StateRequest.serverError);
    });
  }

//TODO AdminsTableData

  StreamSubscription? hrLeadListSubscription;
  final hrLeadListSubject = BehaviorSubject<List<String>>();

  Stream<List<String>> observeHrLeadList() => hrLeadListSubject;

  void sendGetHrLeadList() {
    hrLeadListSubscription?.cancel();
    hrLeadListSubscription = Admin()
        .requestGetLists(userTokenSubject.value, Routes.getHrLeadList)
        .asStream()
        .listen((result) {
      if (result != null) {
        hrLeadListSubject.add(result as List<String>);
      } else {
        hrLeadListSubject.add([]);
      }
    }, onError: (error) {
      hrLeadListSubject.add([]);
      print('Error in sendGetHrLeadList: $error');
    });
  }

  StreamSubscription? userDatabaseSubscription;
  final userDatabaseSubject = BehaviorSubject<UsersData>();

  Stream<UsersData> observeUserData() => userDatabaseSubject;

  void sendGetUserDataBase() {
    userDatabaseSubscription?.cancel();
    userDatabaseSubscription = Admin()
        .requestGetUserDatabase(userTokenSubject.value)
        .asStream()
        .listen((restult) {
      userDatabaseSubject.add(restult);
    }, onError: (error) {
      print("Error in sendGetUserDataBase, $error");
    });
  }

  dispose() {
    usernameControllerSubject.close();
    passwordControllerSubject.close();
    userTokenSubject.close();
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
    getResumeListSubscription?.cancel();
    statisticSubscription?.cancel();
    stateStatisticRequest.close();
    statisticsSubject.close();
    createUsernameSubject.close();
    createUserRoleSubject.close();
    createUserPasswordSuject.close();
    stateCreateUserButtonSubject.close();
    getUsersListSubject?.cancel();
    usersListSubject.close();
    createUsersHrLeadSuject.close();
  }
}

enum StateRequest {
  none,
  loading,
  serverError,
  errorConnection,
  bad,
  good,
  error,
  nothingFound,
  tokenError,
}

enum Role { hr, hr_lead, admin }
