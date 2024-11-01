// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/task_detail_screen.dart';
import 'models/task_model.dart';

void main() {
  runApp(TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/taskDetail') {
          final task = settings.arguments as Task;
          return MaterialPageRoute(
            builder: (context) {
              return TaskDetailScreen(task: task);
            },
          );
        }
        return MaterialPageRoute(builder: (context) => HomeScreen());
      },
    );
  }
}
