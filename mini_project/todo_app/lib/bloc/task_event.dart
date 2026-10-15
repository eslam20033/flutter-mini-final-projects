import 'package:flutter/foundation.dart';

@immutable
abstract class TaskEvent {
  const TaskEvent();
}

class AddTaskEvent extends TaskEvent {
  final String title;

  const AddTaskEvent(this.title);
}

class ToggleTaskEvent extends TaskEvent {
  final String id;

  const ToggleTaskEvent(this.id);
}

class DeleteTaskEvent extends TaskEvent {
  final String id;

  const DeleteTaskEvent(this.id);
}
