import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/home_screen.dart';
import 'screens/task_detail_screen.dart';
import 'models/task_model.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'database/database_helper.dart';
import '../repeation/task_constants.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions(); // Request notification permissions
  Workmanager().initialize(callbackDispatcher);
  runApp(TaskManagerApp());
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

Future<void> checkForOverdueTasks() async {
  final dbHelper = DatabaseHelper();
  final tasks = await dbHelper.fetchTasks();

  for (var task in tasks) {
    if (!task.isCompleted && task.dueDate.isBefore(DateTime.now())) {
      await _notifyUser(task, "Your task \"${task.title}\" is overdue!");

      if (task.isRepeating) {
        task.dueDate = getNextDueDate(task.dueDate, task.repeatInterval);
        task.isCompleted = false;
        await dbHelper.updateTask(task);

        // Schedule the next check based on repeat interval
        final nextCheckDuration = task.dueDate.difference(DateTime.now());
        Workmanager().registerOneOffTask(
          'overdueCheck_${task.id}',
          'checkForOverdueTasks',
          initialDelay: nextCheckDuration,
          inputData: {'taskId': task.id},
        );
      }
    }
  }
}

Future<void> checkTaskOverdue(int taskId) async {
  final dbHelper = DatabaseHelper();
  final task = await dbHelper.getTaskById(taskId); // Implement `getTaskById` in your `DatabaseHelper`

  if (task != null && !task.isCompleted && task.dueDate.isBefore(DateTime.now())) {
    await _notifyUser(task, "Your task \"${task.title}\" is overdue!");

    if (task.isRepeating) {
      task.dueDate = getNextDueDate(task.dueDate, task.repeatInterval);
      task.isCompleted = false;
      await dbHelper.updateTask(task);

      // Schedule next check based on repeat interval
      final nextCheckDuration = task.dueDate.difference(DateTime.now());
      Workmanager().registerOneOffTask(
        'overdueCheck_${task.id}',
        'checkForOverdueTasks',
        initialDelay: nextCheckDuration,
        inputData: {'taskId': task.id},
      );
    }
  }
}


void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final taskId = inputData?['taskId'] as int?;
    if (taskId != null) {
      await checkTaskOverdue(taskId);
    } else {
      await checkForOverdueTasks(); // Check all tasks on startup
    }
    return Future.value(true);
  });
}





Future<void> _notifyUser(Task task, String message) async {
  if (task.id == null) return; // Check if the task ID is null before proceeding

  const androidDetails = AndroidNotificationDetails(
    'task_channel', 'Task Notifications',
    channelDescription: 'Notifications for task reminders',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const platformDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    task.id!, // Task ID is guaranteed to be non-null here
    'Task Reminder',
    message,
    platformDetails,
    payload: task.id.toString(),
  );
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

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/taskDetail') {
          final task = settings.arguments as Task;
          return MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task));
        }
        return MaterialPageRoute(builder: (context) => HomeScreen());
      },
    );
  }
}
