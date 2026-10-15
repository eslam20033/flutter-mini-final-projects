import 'package:flutter/foundation.dart';
import '../models/task_model.dart';

@immutable
class TaskState {
  final List<Task> tasks;

  const TaskState({this.tasks = const []});

  TaskState copyWith({List<Task>? tasks}) {
    return TaskState(
      tasks: tasks ?? this.tasks,
    );
  }
}
