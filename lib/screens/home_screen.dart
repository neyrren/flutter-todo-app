import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Active', 'Completed'];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _storageService.loadTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load tasks');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _addTask(String title) async {
    if (title.trim().isEmpty) return;

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      createdAt: DateTime.now(),
    );

    setState(() => _tasks.add(newTask));
    await _storageService.addTask(newTask);
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    setState(() {
      task.isCompleted = !task.isCompleted;
      task.completedAt = task.isCompleted ? DateTime.now() : null;
    });
    await _storageService.updateTask(task);
  }

  Future<void> _deleteTask(Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() => _tasks.remove(task));
      await _storageService.deleteTask(task.id);
    }
  }

  List<Task> get _filteredTasks {
    switch (_selectedFilter) {
      case 'Active':
        return _tasks.where((task) => !task.isCompleted).toList();
      case 'Completed':
        return _tasks.where((task) => task.isCompleted).toList();
      default:
        return _tasks;
    }
  }

  int get _completedCount => _tasks.where((task) => task.isCompleted).length;
  int get _activeCount => _tasks.where((task) => !task.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskMaster Pro'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _filters.map((filter) {
                return FilterChip(
                  label: Text(filter),
                  selected: _selectedFilter == filter,
                  onSelected: (selected) {
                    setState(() => _selectedFilter = filter);
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(
                    color: _selectedFilter == filter ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildStatsBar(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = _filteredTasks[index];
                          return TaskCard(
                            task: task,
                            onToggle: () => _toggleTaskCompletion(task),
                            onDelete: () => _deleteTask(task),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AddTaskDialog(onAddTask: _addTask),
        ),
        label: const Text('Add Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first task',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total Tasks',
            _tasks.length.toString(),
            Icons.list_alt,
            Colors.blue,
          ),
          _buildStatItem(
            'Active',
            _activeCount.toString(),
            Icons.pending_actions,
            Colors.orange,
          ),
          _buildStatItem(
            'Completed',
            _completedCount.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}