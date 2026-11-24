
import '../models/task.dart';
import 'repository.dart';

class InMemoryTaskRepository implements Repository<Task> {
  final Map<int, Task> _storage = {};

  int _nextId = 1;

  @override
  Future<Task> insert(Task task) async {
    final newTask = task.copyWith(id: _nextId++);

    _storage[newTask.id!] = newTask;

    return newTask;
  }

  @override
  Future<List<Task>> getAll() async {
    return _storage.values.toList();
  }

  @override
  Future<Task?> getById(int id) async {
    return _storage[id];
  }

  @override
  Future<void> update(Task task) async {
    if (task.id != null &&
        _storage.containsKey(task.id)) {
      _storage[task.id!] = task;
    }
  }

  @override
  Future<void> delete(int id) async {
    _storage.remove(id);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }

  @override
  Future<int> count() async {
    return _storage.length;
  }
}
