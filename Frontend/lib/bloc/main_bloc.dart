import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:hr_monitor/bloc/entrance_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MainBloc {
  EntranceBloc entranceBloc = EntranceBloc();

  final vacancyControllerSubject = BehaviorSubject<String>.seeded("");
  final ageControllerSubject = BehaviorSubject<int>.seeded(0);

  // final statusControllerSubject = BehaviorSubject<String>.seeded("");
  final nameControllerSubject = BehaviorSubject<String>.seeded("");
  final sourceControllerSubject = BehaviorSubject<String>.seeded('');
  final BehaviorSubject<StateRequest> stateButtonLoading =
      BehaviorSubject.seeded(StateRequest.none);
  StreamSubscription? requestSubscription;
  final userIdSubject = BehaviorSubject<String>.seeded('');

  Stream<StateRequest> observePageState() => stateButtonLoading;

  MainBloc() {
    getId();
    requestSubscription = Rx.combineLatest4(
        vacancyControllerSubject,
        ageControllerSubject,
        sourceControllerSubject,
        nameControllerSubject,
        (vacancy, age, source, name) => ResumeInfo(
            vacancy: vacancy,
            age: age,
            source: source,
            name: name,
            )).listen((value) {
      print(value);
      getId();
      final idhnik = userIdSubject.value;
      if (value.vacancy != '' &&
          value.name != '' &&
          value.source != '' &&
          idhnik != '' && value.age != 0) {
        stateButtonLoading.add(StateRequest.loading);
        sendResumeToCreate(
            vacancy: value.vacancy,
            age: value.age,
            name: value.name,
            source: value.source,
            id: idhnik);

      }

    });
  }

  void sendResumeToCreate({
    required String vacancy,
    required int age,
    required String source,
    required String id,
    required String name,
  }) {
    if (id != "") {
      stateButtonLoading.add(StateRequest.loading);
      requestSubscription?.cancel();
      requestSubscription = requestToCreateResume(
              vacancy: vacancy,
              age: age,
              source: source,
              name: name,
              id: int.parse(id))
          .asStream()
          .listen(
        (searchResult) {
          print("Good");

          if (searchResult == "" || searchResult == "not created") {
            stateButtonLoading.add(StateRequest.error);
          } else if (searchResult == "created") {
            stateButtonLoading.add(StateRequest.good);
          }
        },
        onError: (error, stackTrace) {
          print("SearchError");
          print(error);
          stateButtonLoading.add(StateRequest.error);
        },
      );
    } else {
      stateButtonLoading.add(StateRequest.idError);
    }
  }

  Future requestToCreateResume({
    required String vacancy,
    required int age,
    required String source,
    required String name,
    required int id,
  }) async {
    var headers = {'Content-Type': 'application/json'};
    var request =
        http.Request('POST', Uri.parse('http://127.0.0.1:5000/resume/create'));
    request.body = json.encode({
      "vacancy": vacancy,
      "age": age,
      "name": name,
      "source": source,
      "id": id
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // vacancyControllerSubject.add('');
      // ageControllerSubject.add(0);
      // sourceControllerSubject.add('');
      // nameControllerSubject.add('');
      stateButtonLoading.add(StateRequest.good);
    } else {
      stateButtonLoading.add(StateRequest.error);
    }
  }

  Future<void> getId() async {
    final prefs = await SharedPreferences.getInstance();
    final decodedData = prefs.getString('data');

    if (decodedData != null) {
      final encodeData = json.decode(decodedData!);
      final userId = encodeData['user_id'];

      userIdSubject.add(userId!);
    }
  }

  void exit() {
    print("Exit");
    deleteUserData();
    entranceBloc.stateRequest.add(StateContentRequest.none);
  }

  Future<void> deleteUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode({"user_id": "", "role": ""});
    await prefs.setString("data", data);
  }
}

class ResumeInfo {
  final vacancy;
  final age;
  final name;

  final source;

  ResumeInfo(
      {required this.vacancy,
      required this.name,
      required this.age,
      required this.source});

  @override
  String toString() =>
      'FiltersInfo(vacancy: $vacancy, age: $age, source: $source, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeInfo &&
          runtimeType == other.runtimeType &&
          vacancy == other.vacancy &&
          age == other.age &&
          name == other.name &&
          source == other.source;

  @override
  int get hashCode =>
      vacancy.hashCode ^
      age.hashCode ^
      name.hashCode ^
      source.hashCode;
}

enum StateRequest {
  none,
  loading,
  error,
  idError,
  good,
}
