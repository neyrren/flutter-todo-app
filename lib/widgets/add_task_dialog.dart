import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(String) onAddTask;

  const AddTaskDialog({super.key, required this.onAddTask});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Task'),
      content: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Enter task title...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          prefixIcon: const Icon(Icons.task_alt),
        ),
        onSubmitted: (_) => _addTask(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Task'),
        ),
      ],
    );
  }

  void _addTask() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onAddTask(_controller.text.trim());
      Navigator.pop(context);
    }
  }
}