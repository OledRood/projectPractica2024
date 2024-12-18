import '../models/statistics/status_model.dart';

class Status {
  const Status._();

  static final code = {
    0: "Открыто",
    1: "Изучено",
    2: "Интервью",
    3: "Прошли интервью",
    4: "Техническое собеседование",
    5: "Пройдено техническое собеседование",
    6: "Оффер",
  };

  static String update(String todo, String statusString) {
    print('upgrare');
    var statusCode = Status.code.entries
        .firstWhere((entry) => entry.value == statusString)
        .key;
    print("Ошибки не произошло");
    if (todo == "up" && statusCode < 6) {
      return code[statusCode + 1]!;
    }
    if (todo == 'down' && statusCode > 0) {
      return code[statusCode - 1]!;
    }
    return code[statusCode]!;
  }

  static List<String> getAllStatuses() {
    return code.values.toList();
  }

  static String getShortName(int statusCode) {
    switch (statusCode) {
      case 3:
        return "Пройдено инт";
      case 4:
        return "Тех собес";
      case 5:
        return "Пройден тех собес";
      default:
        return code[statusCode]!;
    }
  }
}
