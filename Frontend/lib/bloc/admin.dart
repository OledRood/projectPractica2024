import 'dart:async';
import 'dart:convert';

import 'package:hr_monitor/models/admin/users_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import '../resources/api_routes.dart';
import 'bloc.dart';

class Admin {
  Future requestToCreateUser(
      {required String username,
      required String userRole,
      required String userToken,
      required String userPassword,
      required String hrLead}) async {
    var request = http.Request('POST', Uri.parse(Routes.createUser));
    request.body = json.encode({
      "token": userToken,
      'username': username,
      'role': userRole,
      'password': userPassword,
      'hr_lead_name': hrLead,
    });
    request.headers.addAll(Routes.headers);

    http.StreamedResponse response = await request.send();
    String responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(responseData);
      if (jsonData['response'] == 'Data is recorded') {
        return 'good';
      }
      if (jsonData['response'] == 'token error') {
        throw 'Token error';
      }
      if (jsonData['response'] == "You don't have rights") {
        throw 'Rights error';
      }
    }
  }

  Future<List<dynamic>> requestGetLists(String userToken, String route) async {
    var request = http.Request('POST', Uri.parse(route));

    request.body = json.encode({"token": userToken});
    request.headers.addAll(Routes.headers);
    http.StreamedResponse response = await request.send();
    String responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(responseData);
      if (jsonData['response'] == 'good') {
        List<dynamic> data = jsonData['data'];
        return data.map((item) => item.toString()).toList();
      }
      if (jsonData['response'] == 'token error') {
        throw 'Token error';
      }
    } else {
      throw 'Ошибка на стороне сервера';
    }
    return [];
  }

  Future<List<dynamic>> requestGetUsersList(String userToken) async {
    var request = http.Request('POST', Uri.parse(Routes.getUsersList));

    request.body = json.encode({"token": userToken});
    request.headers.addAll(Routes.headers);
    http.StreamedResponse response = await request.send();
    String responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(responseData);
      if (jsonData['response'] == 'good') {
        List<dynamic> data = jsonData['data'];
        return data;
      }
      if (jsonData['response'] == 'token error') {
        throw 'Token error';
      }
    } else {
      throw 'Ошибка на стороне сервера';
    }
    return [];
  }

  // Future<List<UsersData>> requestGetUserDatabase(String userToken) async {
  //   var request = http.Request('POST', Uri.parse(Routes.getUserDatabase));
  //
  //   request.body = json.encode({"token": userToken});
  //   request.headers.addAll(Routes.headers);
  //   http.StreamedResponse response = await request.send();
  //   String responseData = await response.stream.bytesToString();
  //
  //   if(response.statusCode == 200){
  //     final List<dynamic> data = jsonDecode(responseData);
  //     print("Это дата: $data");
  //     final List<UsersData> tables = data.map((rawResume) {
  //       print('это фромДжейсон: ${UsersData.fromJson(rawResume)}');
  //       return UsersData.fromJson(rawResume);
  //     }).toList();
  //     final List<UsersData> found = tables.map((userdata) {
  //       print("Это таблицы: $userdata");
  //       return userdata;
  //     }).toList();
  //     return found;
  //   }
  //   throw 'Something error in requestGetUserDatabase';
  // }

  Future<UsersData> requestGetUserDatabase(String userToken) async {
    var request = http.Request('POST', Uri.parse(Routes.getUserDatabase));

    request.body = json.encode({"token": userToken});
    request.headers.addAll(Routes.headers);

    http.StreamedResponse response = await request.send();
    String responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(responseData);

      // Проверка наличия ключей в ответе
      if (jsonData.containsKey('user_table') &&
          jsonData.containsKey('hr_lead_table') &&
          jsonData.containsKey('hr_table')) {
        final List<dynamic> userTableData = jsonData['user_table'];
        final List<dynamic> hrLeadTableData = jsonData['hr_lead_table'];
        final List<dynamic> hrTableData = jsonData['hr_table'];

        return UsersData(
          userTable:
              userTableData.map((data) => UserTable.fromJson(data)).toList(),
          hrLeadTable: hrLeadTableData
              .map((data) => HrLeadTable.fromJson(data))
              .toList(),
          hrTable: hrTableData.map((data) => HrTable.fromJson(data)).toList(),
        );
      } else {
        throw 'Отсутствуют необходимые ключи в ответе';
      }
    }
    throw 'Ошибка в запросе requestGetUserDatabase, статус: ${response.statusCode}';
  }
}
