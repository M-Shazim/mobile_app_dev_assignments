import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/home_screen.dart';
import 'screens/task_detail_screen.dart';
import 'models/task_model.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'database/database_helper.dart';
import '../repeation/task_constants.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'screens/theme_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'database/database_helper.dart';
import 'screens/home_screen.dart';
import 'screens/task_list_provider.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Initialize the timezone package
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Karachi')); // Set the timezone

  final androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  final initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  //////////////////////////////////////
  /////////////////////////////////////

  Timer.periodic(Duration(minutes: 1), (timer) async {
    print("timerrrrrrrrrrr");
    await checkForOverdueTasks();
  });
  runApp(TaskManagerApp());
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: TaskManagerApp(),
    ),
  );

  // runApp(
  //   MultiProvider(
  //     providers: [
  //       ChangeNotifierProvider(create: (context) => ThemeProvider()),
  //       ChangeNotifierProvider(create: (context) => TaskListProvider()),
  //     ],
  //     child: TaskManagerApp(),
  //   ),
  // );
}

///////////////////////////




////////////////////////////



Future<void> showNotification(String title, String body, int id) async {
  const androidDetails = AndroidNotificationDetails(
    'task_channel',
    'Task Notifications',
    channelDescription: 'Notifications for task reminders',
    importance: Importance.max,
    priority: Priority.high,
  );
  const notificationDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    notificationDetails,
  );
}

Future<void> _requestPermissions() async {
  final androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  final initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  if (Platform.isAndroid && await Permission.notification.isDenied) {
    await Permission.notification.request();
  } else if (Platform.isIOS) {
    final iosPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }
}

Future<void> scheduleOverdueNotification(Task task) async {
  final androidDetails = AndroidNotificationDetails(
    'task_channel',
    'Task Notifications',
    channelDescription: 'Notifications for task reminders',
    importance: Importance.max,
    priority: Priority.high,
  );

  final notificationDetails = NotificationDetails(android: androidDetails);

  // Schedule notification for the task's due date
  final notificationTime = tz.TZDateTime.from(task.dueDate, tz.local);
  await flutterLocalNotificationsPlugin.zonedSchedule(
    task.id!,
    'Task Overdue',
    'Your task "${task.title}" is overdue!',
    notificationTime,
    notificationDetails,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    payload: task.id.toString(),
  );
}



Future<void> handleTaskOverdueReschedule(Task task) async {
  bool tasksUpdated = false;
  if (task.isRepeating) {
    final DatabaseHelper _dbHelper = DatabaseHelper();

    // Update the task's due date to the next interval
    task.dueDate = getNextDueDate(DateTime.now(), task.repeatInterval);
    print("new due date: ");
    print(task.dueTime);
    task.isCompleted = false;  // Reset to incomplete for the new interval
    await _dbHelper.updateTask(task);
    tasksUpdated = true;

    // Show "Task Rescheduled" notification
    await showNotification(
      "Task Rescheduled",
      "Task '${task.title}' is rescheduled for ${task.dueDate}.",
      task.id!,
    );

    // Schedule the new overdue notification for the updated due date
    await scheduleOverdueNotification(task);
  }
  // Refresh the UI only if tasks were updated
  if (tasksUpdated) {
      // Reload tasks to reflect any changes
    print("Tasks are updated");

  }
}




Future<void> checkForOverdueTasks() async {
  final dbHelper = DatabaseHelper();
  final tasks = await dbHelper.fetchTasks();

  for (var task in tasks) {
    if (!task.isCompleted && DateTime.now().isAfter(task.dueDate)) {
      // Show "Task Overdue" notification
      await showNotification(
        "Task Overdue",
        "Your task '${task.title}' is overdue!",
        task.id!,
      );

      // If the task has a repeat interval, handle rescheduling
      if (task.isRepeating) {

        await handleTaskOverdueReschedule(task);
      }
    }
  }
}


DateTime getNextDueDate(DateTime dueDate, String? interval) {
  switch (interval) {
    case TaskConstants.minutely:
      return dueDate.add(Duration(minutes: 1));
    case TaskConstants.daily:
      return dueDate.add(Duration(days: 1));
    case TaskConstants.weekly:
      return dueDate.add(Duration(days: 7));
    case TaskConstants.monthly:
      return DateTime(dueDate.year, dueDate.month + 1, dueDate.day);
    case TaskConstants.yearly:
      return DateTime(dueDate.year + 1, dueDate.month, dueDate.day);
    default:
      return dueDate;
  }
}

class TaskManagerApp extends StatefulWidget {
  @override
  _TaskManagerAppState createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/taskDetail') {
          final task = settings.arguments as Task;
          return MaterialPageRoute(
            builder: (context) => TaskDetailScreen(task: task),
          );
        }
        return MaterialPageRoute(
          builder: (context) => HomeScreen(),
        );
      },
    );
  }
}



