const String path = 'http://127.0.0.1:5000';

class Routes{
  const Routes._();

  static Map<String, String> headers = {'Content-Type': 'application/json'};
  static String createResume = '$path/resume/create';
  static String searchResume = '$path/resume/search';
  static String getResumeToMainPage = '$path/resume/getResume';
  static String loginRequest = '$path/user/login';
}