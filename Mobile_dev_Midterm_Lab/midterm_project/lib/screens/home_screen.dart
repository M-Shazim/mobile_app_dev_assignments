import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/task_model.dart';
import '../repeation/task_constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:midterm_project/main.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:midterm_project/screens/theme_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io'; // Import for File
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart';


// Import the task constants

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver{

  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Task> _tasks = [];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Check overdue tasks whenever the app resumes
    if (state == AppLifecycleState.resumed) {
      checkForOverdueTasks();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadTasks();

    // Periodic check every minute
    Timer.periodic(Duration(seconds: 2), (timer) async {
      await checkForOverdueTasks();
      setState(() {
        // This can be a dummy setState call to force the UI to rebuild
      });
    });
  }


  Future<void> _loadTasks() async {
    final tasks = await _dbHelper.fetchTasks();
    print("Fetched tasks: $tasks");
    if (tasks != null && tasks.isNotEmpty) {
      setState(() {
        _tasks = tasks;
        print(_tasks[0].dueDate);
      });
    } else {
      print("No tasks found or the list is empty.");
    }
  }


  Future<void> _showAddTaskDialog() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    bool isRepeating = false;
    String? repeatInterval;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add New Task'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(controller: titleController, decoration: InputDecoration(labelText: 'Task Title')),
                    TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Task Description')),
                    ElevatedButton(
                      onPressed: () async {
                        final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
                        setState(() { selectedDate = date; });
                      },
                      child: Text(selectedDate == null ? 'Select Due Date' : 'Due Date: ${DateFormat.yMd().format(selectedDate!)}'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        setState(() { selectedTime = time; });
                      },
                      child: Text(selectedTime == null ? 'Select Due Time' : 'Due Time: ${selectedTime!.format(context)}'),
                    ),
                    SwitchListTile(
                      title: Text("Repeat Task"),
                      value: isRepeating,
                      onChanged: (val) { setState(() { isRepeating = val; }); },
                    ),
                    if (isRepeating)
                      DropdownButtonFormField<String>(
                        value: repeatInterval,
                        items: TaskConstants.intervals.map((interval) => DropdownMenuItem(value: interval, child: Text("Repeat: $interval"))).toList(),
                        onChanged: (val) { setState(() { repeatInterval = val; }); },
                        decoration: InputDecoration(labelText: "Repeat Interval"),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty && selectedDate != null && selectedTime != null) {
                      final dueDateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime!.hour,
                        selectedTime!.minute,
                      );

                      Task newTask = Task(
                        title: titleController.text,
                        description: descriptionController.text,
                        dueDate: dueDateTime,
                        dueTime: '${selectedTime!.hour}:${selectedTime!.minute}',
                        isRepeating: isRepeating,
                        repeatInterval: repeatInterval,
                      );

                      final taskId = await _dbHelper.addTask(newTask);
                      newTask.id = taskId;

                      // Notify that the task was added
                      await showNotification("Task Added", "Task '${newTask.title}' was added", taskId);

                      // Schedule a one-time notification for the due time
                      await scheduleOverdueNotification(newTask);

                      _loadTasks();
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Add'),
                ),


              ],
            );
          },
        );
      },
    );
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
      await _loadTasks();  // Reload tasks to reflect any changes
    }
  }

  Future<void> checkAndRequestPermission() async {
    // Request storage permission
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      print("Permission granted");
    } else if (status.isDenied) {
      print("Permission denied");
      // You may want to show a dialog asking the user to enable permission manually
    } else if (status.isPermanentlyDenied) {
      print("Permission permanently denied. Please enable it in settings.");
      openAppSettings();  // Opens app settings for the user to manually grant permissions
    }
  }



  Future<void> exportTaskData(BuildContext context) async {
    print("export runs");
    await checkAndRequestPermission();  // Ensure permission is requested
    try {
      final directory = await getExternalStorageDirectory();
      final tasks = await _dbHelper.fetchTasks();

      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get external storage directory')));
        return;
      }

      final filePath = '${directory.path}/tasks_export.csv';  // Save as CSV file

      // Create a list of lists for CSV format
      List<List<dynamic>> rows = [];
      rows.add(['Task Title', 'Description', 'Due Date', 'Repeat Interval', 'Completed']);  // Header row

      for (final task in tasks) {
        rows.add([
          task.title,
          task.description,
          task.dueDate.toString(),  // Ensure you convert any DateTime fields to string
          task.repeatInterval.toString(),  // If repeatInterval is an int or enum, convert it to string
          task.isCompleted ? 'Completed' : 'Pending'
        ]);
      }

      // Convert the list to a CSV string
      String csvData = const ListToCsvConverter().convert(rows);

      // Create and write the CSV data to the file
      final file = File(filePath);
      await file.writeAsString(csvData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tasks exported to $filePath')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error exporting tasks: $e')));
      print(e);
    }
  }









  // bool _isDarkTheme = false;
  ThemeMode _themeMode = ThemeMode.light; // Default to light theme

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Task Manager'),actions: [
        IconButton(
          icon: Icon(Icons.save_alt),
          onPressed: () {
            exportTaskData(context); // Fetch tasks when the refresh button is pressed
            setState(() {
              // This can be a dummy setState call to force the UI to rebuild
            });
            print("moeww");
          },
        ),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            _loadTasks();// Fetch tasks when the refresh button is pressed
            setState(() {
              // This can be a dummy setState call to force the UI to rebuild
            });
            print("moeww");
          },
        ),
        IconButton(
          icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.brightness_3 : Icons.brightness_7),
          onPressed: themeProvider.toggleTheme, // Toggle theme on button press
        ),
      ],),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text(
                //'${task.description}\nDue: ${DateFormat('yMd H:mm').format(task.dueDate)}${task.isRepeating ? ' (Repeats: ${task.repeatInterval})' : ''}'
                '${task.description}\nDue: ${DateFormat('MM/dd/yyyy h:mm a', 'en_US').format(task.dueDate)}${task.isRepeating ? ' (Repeats: ${task.repeatInterval})' : ''}'

              //'${task.description}\nDue: ${DateFormat.yMd().format(task.dueDate)} at ${task.dueTime}${task.isRepeating ? ' (Repeats: ${task.repeatInterval})' : ''}',
            ),
            trailing: Checkbox(
              value: task.isCompleted,
              onChanged: (value) async {
                setState(() {
                  task.isCompleted = value!;

                });

                await _dbHelper.updateTask(task);

                if (task.isCompleted) {
                  await _loadTasks();

                  // Show "Task Completed" notification
                  await showNotification(
                    "Task Completed",
                    "Task '${task.title}' has been marked as complete.",
                    task.id!,
                  );

                  // If task has a repeat interval, reschedule for next interval
                  if (task.isRepeating) {
                    await _loadTasks();
                    await handleTaskOverdueReschedule(task);
                  }
                } else {
                  // If marked incomplete, reset the overdue notification
                  await scheduleOverdueNotification(task);
                }

                _loadTasks(); // Refresh task list
              },
            ),



            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                '/taskDetail',
                arguments: task,
              );
              if (result == true) {
                _loadTasks();
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

DateTime getNextDueDate(DateTime currentDueDate, String? interval) {
  switch (interval) {
    case TaskConstants.minutely:
      return currentDueDate.add(Duration(minutes: 1));
    case TaskConstants.daily:
      return currentDueDate.add(Duration(days: 1));
    case TaskConstants.weekly:
      return currentDueDate.add(Duration(days: 7));
    case TaskConstants.monthly:
      return DateTime(currentDueDate.year, currentDueDate.month + 1, currentDueDate.day);
    case TaskConstants.yearly:
      return DateTime(currentDueDate.year + 1, currentDueDate.month, currentDueDate.day);
    default:
      return currentDueDate;
  }
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

Future<void> checkForOverdueTasks() async {
  final dbHelper = DatabaseHelper();
  final tasks = await dbHelper.fetchTasks();
  bool tasksUpdated = false;

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








