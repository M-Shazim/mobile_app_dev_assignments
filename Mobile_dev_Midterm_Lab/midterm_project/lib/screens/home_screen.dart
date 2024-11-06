import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/task_model.dart';
import '../repeation/task_constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

// Import the task constants

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _dbHelper.fetchTasks();
    setState(() {
      _tasks = tasks;
    });
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
                        dueTime: '${selectedTime!.hour}:${selectedTime!.minute}', // Save in 24-hour format
                        isRepeating: isRepeating,
                        repeatInterval: repeatInterval,
                      );

                      final taskId = await _dbHelper.addTask(newTask);
                      newTask.id = taskId;

                      await _notifyUser(newTask, "Task added: ${newTask.title}");

                      // Schedule a one-time check for overdue status
                      final overdueDuration = dueDateTime.difference(DateTime.now()).isNegative
                          ? Duration.zero  // If time has already passed, run immediately
                          : dueDateTime.difference(DateTime.now());

                      Workmanager().registerOneOffTask(
                        'overdueCheck_${newTask.id}', // Unique task ID
                        'checkForOverdueTasks',
                        initialDelay: overdueDuration, // Schedule for exact time of dueDateTime
                        inputData: {'taskId': newTask.id},
                      );

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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Manager')),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text(
              '${task.description}\nDue: ${DateFormat.yMd().format(task.dueDate)} at ${task.dueTime}${task.isRepeating ? ' (Repeats: ${task.repeatInterval})' : ''}',
            ),
            trailing: Checkbox(
              value: task.isCompleted,
              onChanged: (value) async {
                task.isCompleted = value!;
                await _dbHelper.updateTask(task);
                _loadTasks(); // Refresh tasks
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


