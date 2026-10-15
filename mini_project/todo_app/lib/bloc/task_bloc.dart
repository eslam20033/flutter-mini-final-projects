import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task_model.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(const TaskState()) {
    on<AddTaskEvent>(_onAddTask);
    on<ToggleTaskEvent>(_onToggleTask);
    on<DeleteTaskEvent>(_onDeleteTask);
  }

  void _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) {
    if (event.title.trim().isEmpty) return;

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: event.title.trim(),
    );

    final updatedTasks = List<Task>.from(state.tasks)..add(newTask);
    emit(state.copyWith(tasks: updatedTasks));
  }

  void _onToggleTask(ToggleTaskEvent event, Emitter<TaskState> emit) {
    final updatedTasks = state.tasks.map((task) {
      if (task.id == event.id) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();

    emit(state.copyWith(tasks: updatedTasks));
  }

  void _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) {
    final updatedTasks = state.tasks.where((task) => task.id != event.id).toList();
    emit(state.copyWith(tasks: updatedTasks));
  }
}
