import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart';

class EntranceBloc {
  final BehaviorSubject<StateContentRequest> stateRequest =
  BehaviorSubject.seeded(StateContentRequest.none);
  final usernameControllerSubject = BehaviorSubject<String>.seeded('');
  final passwordControllerSubject = BehaviorSubject<String>.seeded('');


  final roleSubject = BehaviorSubject();

  //TODO подумать над другой реализацией
  final positionSubject = BehaviorSubject<String>.seeded('');

  // Храним текущее состояние результатов поиска
  final stateSubject = BehaviorSubject.seeded(false);
  final BehaviorSubject<String> userIdSubject = BehaviorSubject.seeded("");

  // // Храним здесь то, что получили от сервера (Есть ли данная учетная запись)
  // final searchResultSubject = BehaviorSubject<bool>();
  Stream observeId() => userIdSubject;

  Stream<StateContentRequest> observeRequest() => stateRequest;

  StreamSubscription? userSubscription;
  StreamSubscription? searchSubscriprion;

  EntranceBloc() {
    getId();
    userSubscription = Rx.combineLatest3(
      // positionSubject.debounceTime(Duration(seconds: 3)),
        positionSubject.distinct(),
        usernameControllerSubject.distinct(),
        passwordControllerSubject.distinct(),
            (position, username, password) =>
            UserInfo(
                username: username,
                password: password,
                position: position)).listen((value) {
      if (value.username != "" &&
          value.password != "" &&
          value.position == "DOWN") {
        print("Search started");
        print('password ${value.password}');
        searchForResultWithFilters(
          username: value.username,
          password: value.password,
        );
      }
    });
  }


  void searchForResultWithFilters(
      {required String username, required String password}) {
    stateRequest.add(StateContentRequest.loading);
    searchSubscriprion?.cancel();
    searchSubscriprion =
        searchWithFilters(username: username, password: password)
            .asStream()
            .listen(
              (searchResult) {
            // searchResultSubject.add(searchResult);
            print("Good");

            switch (searchResult) {
              case RequestStatus.connectError:
                stateRequest.add(StateContentRequest.errorConnection);
              case RequestStatus.serverError:
                stateRequest.add(StateContentRequest.serverError);
              case RequestStatus.somethingWrong:
                stateRequest.add(StateContentRequest.denied);
              case RequestStatus.allowed:
                stateRequest.add(StateContentRequest.nextPage);
              case RequestStatus.denied:
                stateRequest.add(StateContentRequest.denied);
              default:
                stateRequest.add(StateContentRequest.denied);
            }
          },
          onError: (error, stackTrace) {
            print("SearchError");
            print(error);
            stateRequest.add(StateContentRequest.denied);
          },
        );
  }

  //Здесь пока обдумывается
  void combineUserPassword(String position) {
    // print(position);
    positionSubject.add(position);
  }

  Future searchWithFilters({
    required String username,
    required String password,
  }) async {
    try {
      var headers = {'Content-Type': 'application/json'};

      var request =
          http.Request('POST', Uri.parse('http://127.0.0.1:5000/user/login'));
      request.body =
          json.encode({"username": "$username", "password": "$password"});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final found = await response.stream.bytesToString();

      print("found: ${found}");
      if (response.statusCode == 400) {
        return RequestStatus.connectError;
      }
      if (response.statusCode >= 500 && response.statusCode <= 600) {
        print("Server Error");
        return RequestStatus.serverError;
      }
      if (response.statusCode == 200) {
        final decodedFound = json.decode(found);
        bool result = decodedFound['result'] ?? false;

        if (result) {

          userIdSubject.add(decodedFound['id'].toString());
          saveUserData(
              decodedFound['id'].toString(), decodedFound['role'].toString());
          return RequestStatus.allowed;
        }
        return RequestStatus.denied;
      }
      return RequestStatus.somethingWrong;
    }
    catch(e){
      return RequestStatus.serverError;
    }
  }


  Future<void> saveUserData(String id, String role) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode({"user_id": id, "role": role});
    await prefs.setString(
        "data", data); // Сохраняем значение 'id' с ключом 'user_id'
    print("DATA SAVED: $data");
  }


  Future<void> getId() async {
    final prefs = await SharedPreferences.getInstance();
    final decodedData = prefs.getString('data');

    if (decodedData != null) {
      final encodeData = json.decode(decodedData!);
      final userId = encodeData['user_id'];
      if (userId != "") {
        stateRequest.add(StateContentRequest.nextPage);
      }
      userIdSubject.add(userId!);
    }
  }
  void dispose() {
    stateRequest.close();
    usernameControllerSubject.close();
    passwordControllerSubject.close();
    roleSubject.close();
    positionSubject.close();
    stateSubject.close();
    userIdSubject.close();
    userSubscription?.cancel();
    searchSubscriprion?.cancel();

  }

}

class UserInfo {
  final username;
  final password;
  final position;

  UserInfo(
      {required this.username, required this.password, required this.position});

  @override
  String toString() =>
      'FiltersInfo(username: $username, password: $password, position: $position)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserInfo &&
              runtimeType == other.runtimeType &&
              username == other.username &&
              position == other.position &&
              password == other.password;

  @override
  int get hashCode => username.hashCode ^ password.hashCode ^ position.hashCode;


}


enum Role {
  hr,
  hr_lead,
  admin
}
enum StateContentRequest {
  none,
  loading,
  serverError,
  errorConnection,
  denied,
  nextPage
}

enum RequestStatus {
  connectError,
  serverError,
  somethingWrong,
  allowed,
  denied
}
