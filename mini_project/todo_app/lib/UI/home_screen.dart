import 'package:flutter/material.dart';
import 'package:todo_app/core/theme/app_color.dart';
import 'package:todo_app/models/task.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController taskController = TextEditingController();

  final List<Task> tasks = [];

  @override
void initState() {
  super.initState();
  loadTasks();
}

Future<void> loadTasks() async {
  final prefs = await SharedPreferences.getInstance();
  final savedTasks = prefs.getString('tasks');

  if (savedTasks != null) {
    final List<dynamic> decodedTasks = jsonDecode(savedTasks);

    if (!mounted) return;

    setState(() {
      tasks.clear();
      tasks.addAll(
        decodedTasks.map(
          (task) => Task(
            title: task['title'],
            isDone: task['isDone'],
          ),
        ),
      );
    });
  }
}

Future<void> saveTasks() async {
  final prefs = await SharedPreferences.getInstance();

  final encodedTasks = jsonEncode(
    tasks.map((task) => {
      'title': task.title,
      'isDone': task.isDone,
    }).toList(),
  );

  await prefs.setString('tasks', encodedTasks);
}

  void addTask() {
    final String taskTitle = taskController.text.trim();

    if (taskTitle.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a task first'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      return;
    }

    setState(() {
      tasks.add(
        Task(
          title: taskTitle,
          isDone: false,
        ),
      );
    });

saveTasks();

    taskController.clear();
    FocusScope.of(context).unfocus();
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index].isDone = !tasks[index].isDone;
    });
    saveTasks(); 
  }

 void deleteTask(int index) {
  setState(() {
    tasks.removeAt(index);
  });

  saveTasks();
}

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        toolbarHeight: 85,
        title: const ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'To-Do List',
            style: TextStyle(
              color: AppColors.background,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Small steps, big progress ✨',
            style: TextStyle(
              color: AppColors.background,
              fontSize: 13,
            ),
          ),
        ),
        actions: const [
          Icon(
            Icons.more_vert,
            color: AppColors.background,
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAddTaskSection(),
            Expanded(
              child: tasks.isEmpty
                  ? _buildEmptyState()
                  : _buildTasksList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTaskSection() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: taskController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              addTask();
            },
            decoration: InputDecoration(
              hintText: 'Add a new task...',
              hintStyle: const TextStyle(
                color: AppColors.grey,
                fontSize: 15,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.grey.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.grey.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: addTask,
            icon: const Icon(
              Icons.add,
              color: AppColors.background,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/todo.jpg',
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            const Text(
              'No tasks yet!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first task to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 20),
      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final Task task = tasks[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            leading: Checkbox(
              value: task.isDone,
              activeColor: AppColors.primary,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (_) {
                toggleTask(index);
              },
            ),
            title: Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: task.isDone
                    ? AppColors.grey
                    : AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                decoration: task.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationThickness: 2,
              ),
            ),
            trailing: IconButton(
              onPressed: () {
                deleteTask(index);
              },
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 27,
              ),
            ),
          ),
        );
      },
    );
  }
}