import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Model for a single to-do item
class TodoItem {
  String title;
  bool isDone;

  TodoItem({required this.title, this.isDone = false});

  // Convert a TodoItem instance to a Map
  Map<String, dynamic> toJson() => {'title': title, 'isDone': isDone};

  // Create a TodoItem instance from a Map
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      title: json['title'],
      isDone: json['isDone'],
    );
  }
}

/// A card widget displaying a simple to-do list.
class TodoListCard extends StatefulWidget {
  const TodoListCard({super.key});

  @override
  State<TodoListCard> createState() => _TodoListCardState();
}

class _TodoListCardState extends State<TodoListCard> {
  final List<TodoItem> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  static const String _prefsKey = 'todoListTasks';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  // Load tasks from local storage
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString(_prefsKey);
    if (tasksString != null) {
      final List<dynamic> taskJson = json.decode(tasksString);
      if (mounted) {
        setState(() {
          _tasks.clear();
          _tasks.addAll(taskJson.map((json) => TodoItem.fromJson(json)).toList());
        });
      }
    }
  }

  // Save tasks to local storage
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksString = json.encode(_tasks.map((task) => task.toJson()).toList());
    await prefs.setString(_prefsKey, tasksString);
  }

  // Add a new task to the list
  void _addTask(String title) {
    if (title.trim().isNotEmpty) {
      setState(() {
        _tasks.add(TodoItem(title: title.trim()));
      });
      _saveTasks();
      _taskController.clear();
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  // Toggle the completion status of a task
  void _toggleTaskStatus(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
    _saveTasks();
  }

  // Remove a task from the list
  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  // Show a dialog to add a new task
  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: const Text('Add New Task'),
          content: TextField(
            controller: _taskController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'e.g., Buy groceries'),
            onSubmitted: (value) => _addTask(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => _addTask(_taskController.text),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Tasks',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline_rounded, color: colorScheme.primary),
                  onPressed: _showAddTaskDialog,
                  tooltip: 'Add Task',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Task List or Empty State
            _tasks.isEmpty
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'No tasks yet. Add one!',
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return CheckboxListTile(
                  value: task.isDone,
                  onChanged: (bool? value) => _toggleTaskStatus(index),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                      color: task.isDone ? colorScheme.onSurface.withOpacity(0.5) : colorScheme.onSurface,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  secondary: IconButton(
                    icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
                    onPressed: () => _removeTask(index),
                  ),
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
