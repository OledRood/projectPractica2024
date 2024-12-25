const String path = 'http://localhost:8080';

class Routes{
  const Routes._();

  static Map<String, String> headers = {'Content-Type': 'application/json'};
  static String createResume = '$path/resume/create';
  static String searchResume = '$path/resume/search';
  static String getResumeToMainPage = '$path/resume/getResume';
  static String loginRequest = '$path/user/login';
  static String updateResume = '$path/resume/update';
  static String getHrList = '$path/hr_lead/getHrList';
  static String getLists = '$path/resume/getListsVacancyHrSource';
  static String getStatistic = '$path/resume/getStatistic';
  static String createUser = '$path/admin/registration';
  static String getUsersList = '$path/admin/getUsersList';
  static String getHrLeadList = '$path/admin/getHrLeadList';
  static String getUserDatabase = '$path/admin/getAllTables';



}