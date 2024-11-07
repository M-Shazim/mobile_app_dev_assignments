// task_constants.dart

class TaskConstants {
  static const String minutely = "minutely";
  static const String daily = "daily";
  static const String weekly = "weekly";
  static const String monthly = "monthly";
  static const String yearly = "yearly";

  static const Duration checkFrequency = Duration(minutes: 1);

  // You can also define a list if you need it for dropdowns or other UI elements
  static const List<String> intervals = [minutely, daily, weekly, monthly, yearly];
}
