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

    Navigator.pop(context, true); // Return `true` to indicate an update
  }

  void _editTask() async {
    final TextEditingController titleController = TextEditingController(text: widget.task.title);
    final TextEditingController descriptionController = TextEditingController(text: widget.task.description);
    DateTime? dueDate = widget.task.dueDate;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
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
                      setState(() {
                        dueDate = selectedDate;
                      });
                    }
                  },
                  child: Text(dueDate == null ? 'Select Due Date' : 'Due Date: ${dueDate!.toLocal()}'),
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
                // Update the task details
                widget.task.title = titleController.text;
                widget.task.description = descriptionController.text;
                widget.task.dueDate = dueDate!;

                await _dbHelper.updateTask(widget.task);
                setState(() {}); // Refresh the details in TaskDetailScreen

                // Close the edit dialog and return to TaskDetailScreen
                Navigator.of(context).pop();

                // Pop TaskDetailScreen and pass `true` to HomeScreen to refresh
                Navigator.pop(context, true);
              },
              child: Text('Save'),
            ),
          ],
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
