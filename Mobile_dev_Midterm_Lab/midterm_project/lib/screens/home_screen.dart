import 'package:flutter/material.dart';
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
            subtitle: Text(task.description),
            trailing: Checkbox(
              value: task.isCompleted,
              onChanged: (value) async {
                task.isCompleted = value!;
                await _dbHelper.updateTask(task);
                _loadTasks(); // Refresh tasks
              },
            ),
            onTap: () {
              // Navigate to TaskDetailScreen with the task object as argument
              Navigator.pushNamed(
                context,
                '/taskDetail',
                arguments: task, // Pass the Task object here
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Code to add new task
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
