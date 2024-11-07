import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../database/database_helper.dart';
import '../repeation/task_constants.dart'; // Import the task constants
import 'package:workmanager/workmanager.dart';
import 'home_screen.dart';
import 'package:midterm_project/main.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';






class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.task.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Due Date: ${widget.task.dueDate.toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(
              'Due Time: ${widget.task.dueTime ?? "Not Set"}',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(
              widget.task.description,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _toggleComplete,
                  child: Text(widget.task.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete'),
                ),
                ElevatedButton(
                  onPressed: _editTask,
                  child: Text('Edit'),
                ),
                ElevatedButton(
                  onPressed: _deleteTask,
                  child: Text('Delete'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleComplete() async {
    setState(() {
      widget.task.isCompleted = !widget.task.isCompleted;
    });
    await _dbHelper.updateTask(widget.task);

    if (widget.task.isCompleted) {
      await showNotification(
        "Task Completed",
        "Task '${widget.task.title}' has been marked as complete.",
        widget.task.id!,
      );

      if (widget.task.isRepeating && DateTime.now().isAfter(widget.task.dueDate)) {
        await handleTaskOverdueReschedule(widget.task);
      }
    } else {
      await scheduleOverdueNotification(widget.task);
    }

    Navigator.pop(context, true); // Indicate task update
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




  Duration _getRepeatDuration(String repeatInterval) {
    switch (repeatInterval) {
      case 'minutely':
        return Duration(minutes: 1);
      case 'daily':
        return Duration(days: 1);
      case 'weekly':
        return Duration(days: 7);
      case 'monthly':
        return Duration(days: 30); // Approximate for monthly
      case 'yearly':
        return Duration(days: 365); // Approximate for yearly
      default:
        throw ArgumentError('Invalid repeat interval: $repeatInterval');
    }
  }


  void _editTask() async {
    final TextEditingController titleController = TextEditingController(text: widget.task.title);
    final TextEditingController descriptionController = TextEditingController(text: widget.task.description);
    DateTime? dueDate = widget.task.dueDate;
    TimeOfDay? dueTime;
    bool isRepeating = widget.task.isRepeating;
    String? repeatInterval = widget.task.repeatInterval;

    // Initialize `dueTime` safely
    if (widget.task.dueTime != null && widget.task.dueTime!.contains(':')) {
      final timeParts = widget.task.dueTime!.split(':');
      dueTime = TimeOfDay(
        hour: int.parse(timeParts[0]),  // No "AM" or "PM" here, only hours and minutes
        minute: int.parse(timeParts[1]),
      );
    }
 else {
      dueTime = TimeOfDay.now(); // Default time if dueTime is not set
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text('Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: 'Task Title'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Task Description'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setDialogState(() {
                            dueDate = selectedDate;
                          });
                        }
                      },
                      child: Text(dueDate == null ? 'Select Due Date' : 'Due Date: ${DateFormat.yMd().format(dueDate!)}'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: dueTime ?? TimeOfDay.now(),
                        );
                        if (selectedTime != null) {
                          setDialogState(() {
                            dueTime = selectedTime;
                          });
                        }
                      },
                      child: Text(dueTime == null ? 'Select Due Time' : 'Due Time: ${dueTime!.format(context)}'),
                    ),
                    SizedBox(height: 10),

                    // Repeat Task Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Repeat Task', style: TextStyle(fontSize: 16)),
                        Switch(
                          value: isRepeating,
                          onChanged: (bool value) {
                            setDialogState(() {
                              isRepeating = value;
                              if (!isRepeating) {
                                repeatInterval = null; // Clear interval if repeating is disabled
                              }
                            });
                          },
                        ),
                      ],
                    ),

                    // Repeat Interval Dropdown
                    if (isRepeating)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: repeatInterval,
                          items: [
                            DropdownMenuItem(value: TaskConstants.minutely, child: Text('Every Minute')),
                            DropdownMenuItem(value: TaskConstants.daily, child: Text('Every Day')),
                            DropdownMenuItem(value: TaskConstants.weekly, child: Text('Every Week')),
                            DropdownMenuItem(value: TaskConstants.monthly, child: Text('Every Month')),
                            DropdownMenuItem(value: TaskConstants.yearly, child: Text('Every Year')),
                          ],
                          onChanged: (String? newValue) {
                            setDialogState(() {
                              repeatInterval = newValue;
                            });
                          },
                          decoration: InputDecoration(labelText: 'Repeat Interval'),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // Update task details
                    widget.task.title = titleController.text;
                    widget.task.description = descriptionController.text;
                    widget.task.dueDate = dueDate!;
                    widget.task.dueTime = dueTime?.format(context); // Save in "HH:mm" format
                    widget.task.isRepeating = isRepeating;
                    widget.task.repeatInterval = repeatInterval;

                    await _dbHelper.updateTask(widget.task);
                    setState(() {}); // Refresh TaskDetailScreen

                    Navigator.of(context).pop(); // Close edit dialog
                    Navigator.pop(context, true); // Signal update to HomeScreen
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _deleteTask() async {
    await _dbHelper.deleteTask(widget.task.id!);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Task deleted successfully!'),
    ));

    Navigator.pop(context, true); // Indicate task deletion
  }
}


