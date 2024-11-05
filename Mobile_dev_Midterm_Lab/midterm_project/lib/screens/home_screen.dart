import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date and time
import '../database/database_helper.dart';
import '../models/task_model.dart';

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

    return showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    setState(() {
                      dueDate = selectedDate;
                    });
                  },
                  child: Text(dueDate == null ? 'Select Due Date' : 'Due Date: ${DateFormat.yMd().format(dueDate!)}'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    setState(() {
                      dueTime = selectedTime;
                    });
                  },
                  child: Text(dueTime == null ? 'Select Due Time' : 'Due Time: ${dueTime!.format(context)}'),
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
                if (titleController.text.isNotEmpty && dueDate != null && dueTime != null) {
                  final formattedTime = dueTime!.format(context); // Save time in 24-hour format
                  Task newTask = Task(
                    title: titleController.text,
                    description: descriptionController.text,
                    dueDate: dueDate!,
                    dueTime: formattedTime, // Ensure dueTime is set here
                    isCompleted: false,
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
            subtitle: Text('${task.description}\nDue: ${DateFormat.yMd().format(task.dueDate)} at ${task.dueTime}'),
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
