import '../agent/models.dart';

export '../agent/models.dart' show Task;

class TaskRepository {
  static final TaskRepository instance = TaskRepository._();
  TaskRepository._();

  final List<Task> _tasks = [
    Task(id: '1', title: 'Buy groceries', description: 'Milk, eggs, bread', completed: false),
    Task(id: '2', title: 'Read a book', description: 'Finish "Clean Code"', completed: false),
    Task(id: '3', title: 'Go for a run', description: '5km around the park', completed: false),
  ];

  List<Task> getAll() => List.unmodifiable(_tasks);

  Task? getById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Task add({required String title, required String description}) {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      completed: false,
    );
    _tasks.add(task);
    _notifyListeners();
    return task;
  }

  bool complete(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return false;
    _tasks[index] = Task(
      id: _tasks[index].id,
      title: _tasks[index].title,
      description: _tasks[index].description,
      completed: true,
    );
    _notifyListeners();
    return true;
  }

  bool delete(String id) {
    final existed = getById(id) != null;
    _tasks.removeWhere((t) => t.id == id);
    if (existed) _notifyListeners();
    return existed;
  }

  final List<void Function()> _listeners = [];
  void addListener(void Function() listener) => _listeners.add(listener);
  void removeListener(void Function() listener) => _listeners.remove(listener);
  void _notifyListeners() {
    for (final l in _listeners) l();
  }
}
