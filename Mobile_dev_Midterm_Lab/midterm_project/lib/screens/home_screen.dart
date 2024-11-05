import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/task_model.dart';
import '../repeation/task_constants.dart'; // Import the task constants

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
    DateTime? dueDate;
    TimeOfDay? dueTime;
    bool isRepeating = false; // Add repeat toggle
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
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            dueDate = selectedDate;
                          });
                        }
                      },
                      child: Text(dueDate == null
                          ? 'Select Due Date'
                          : 'Due Date: ${DateFormat.yMd().format(dueDate!)}'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (selectedTime != null) {
                          setState(() {
                            dueTime = selectedTime;
                          });
                        }
                      },
                      child: Text(dueTime == null
                          ? 'Select Due Time'
                          : 'Due Time: ${dueTime!.format(context)}'),
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
                            setState(() {
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
                            setState(() {
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
                    if (titleController.text.isNotEmpty &&
                        dueDate != null &&
                        dueTime != null) {
                      final formattedTime = dueTime!.format(context); // Save time in 24-hour format
                      Task newTask = Task(
                        title: titleController.text,
                        description: descriptionController.text,
                        dueDate: dueDate!,
                        dueTime: formattedTime, // Ensure dueTime is set here
                        isCompleted: false,
                        isRepeating: isRepeating, // Add repeat property
                        repeatInterval: repeatInterval, // Save the repeat interval
                      );
                      await _dbHelper.addTask(newTask);
                      _loadTasks(); // Refresh task list
                      Navigator.of(context).pop();
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
