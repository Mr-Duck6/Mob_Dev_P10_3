
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';
import 'repository.dart';

class SQLiteTaskRepository implements Repository<Task> {
  final Database db;

  SQLiteTaskRepository(this.db);

  @override
  Future<Task> insert(Task task) async {
    final id = await db.insert(
      'tasks',
      task.toMap(),
    );

    return task.copyWith(id: id);
  }

  @override
  Future<List<Task>> getAll() async {
    final maps = await db.query(
      'tasks',
      orderBy: 'id DESC',
    );

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  @override
  Future<Task?> getById(int id) async {
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    return Task.fromMap(maps.first);
  }

  @override
  Future<void> update(Task task) async {
    if (task.id == null) return;

    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteAll() async {
    await db.delete('tasks');
  }

  @override
  Future<int> count() async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM tasks',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
