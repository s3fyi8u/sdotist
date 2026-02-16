class ApiConstants {
  static const String baseUrl = "https://api.sdotist.org"; // Production Server
  // static const String baseUrl = "http://127.0.0.1:8000"; // For iOS Simulator
  // static const String baseUrl = "http://10.0.2.2:8000"; // For Android Emulator
  
  static const String login = "/auth/login";
  static const String register = "/users/";
  static const String registerWithDoc = "/register";
  static const String me = "/users/me";
  static const String myBarcode = "/users/me/barcode";
  static const String news = "/news/";
  static const String offices = "/offices/";
  static const String representatives = "/representatives/";
  static const String notifications = "/notifications/";
  static const String changePassword = "/users/me/password";
  static const String deleteAccount = "/users/me";
  static const String pendingRegistrations = "/admin/pending-registrations";
  static String approveRegistration(int userId) => "/admin/registrations/$userId/approve";
  static String rejectRegistration(int userId) => "/admin/registrations/$userId/reject";
}
