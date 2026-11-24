
import 'package:hive/hive.dart';

import '../models/task.dart';
import 'repository.dart';

class HiveTaskRepository implements Repository<Task> {
  final Box<Task> box;

  HiveTaskRepository(this.box);

  @override
  Future<Task> insert(Task task) async {
    final key = await box.add(task);

    final savedTask = task.copyWith(id: key);

    await box.put(key, savedTask);

    return savedTask;
  }

  @override
  Future<List<Task>> getAll() async {
    return box.values.toList();
  }

  @override
  Future<Task?> getById(int id) async {
    return box.get(id);
  }

  @override
  Future<void> update(Task task) async {
    if (task.id != null) {
      await box.put(task.id, task);
    }
  }

  @override
  Future<void> delete(int id) async {
    await box.delete(id);
  }

  @override
  Future<void> deleteAll() async {
    await box.clear();
  }

  @override
  Future<int> count() async {
    return box.length;
  }
}
