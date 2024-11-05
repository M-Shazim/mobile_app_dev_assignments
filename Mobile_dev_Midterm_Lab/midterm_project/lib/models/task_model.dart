import '../repeation/task_constants.dart';

class Task {
  int? id;
  String title;
  String description;
  DateTime dueDate;
  String? dueTime; // New field for storing the time as a 24-hour format string
  bool isCompleted;
  bool isRepeating;
  String? repeatInterval; // For tasks repeating weekly/daily


  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.dueTime, // Add dueTime to constructor
    this.isCompleted = false,
    this.isRepeating = false,
    this.repeatInterval,
  });

  // Convert Task to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'dueTime': dueTime, // Include dueTime in the map
      'isCompleted': isCompleted ? 1 : 0,
      'isRepeating': isRepeating ? 1 : 0,
      'repeatInterval': repeatInterval,
    };
  }

  // Convert Map to Task object
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      dueTime: map['dueTime'], // Retrieve dueTime from map
      isCompleted: map['isCompleted'] == 1,
      isRepeating: map['isRepeating'] == 1,
      repeatInterval: map['repeatInterval'],
    );
  }
}
