import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../database/database_helper.dart';

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
              'Due Date: ${widget.task.dueDate.toLocal()}',
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(widget.task.isCompleted ? 'Task marked as complete!' : 'Task marked as incomplete!'),
    ));
  }

  void _editTask() {
    // Navigate to a task edit screen or display an edit dialog
    // Example: Navigator.pushNamed(context, '/editTask', arguments: widget.task);
  }

  void _deleteTask() async {
    await _dbHelper.deleteTask(widget.task.id!);
    Navigator.pop(context); // Return to the previous screen
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Task deleted successfully!'),
    ));
  }
}
