
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';
import '../models/task_adapter.dart';

import '../repositories/repository.dart';
import '../repositories/sqlite_task_repository.dart';
import '../repositories/hive_task_repository.dart';
import '../repositories/in_memory_task_repository.dart';

class TaskRepositoryProvider extends ChangeNotifier {
  Repository<Task>? _repository;

  String _currentType = 'sqlite';

  List<Task> tasks = [];

  Repository<Task> get repository {
    if (_repository == null) {
      throw Exception('Repository not initialized');
    }

    return _repository!;
  }

  String get currentType => _currentType;

  int get completedCount {
    return tasks.where((task) => task.isCompleted).length;
  }

  Future<void> initSQLite() async {
    final dbPath = await getDatabasesPath();

    final db = await openDatabase(
      join(dbPath, 'tasks_repo.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            isCompleted INTEGER NOT NULL
          )
        ''');
      },
    );

    _repository = SQLiteTaskRepository(db);
    _currentType = 'sqlite';

    await refresh();
  }

  Future<void> initHive() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskAdapter());
    }

    final box = await Hive.openBox<Task>('tasks');

    _repository = HiveTaskRepository(box);
    _currentType = 'hive';

    await refresh();
  }

  Future<void> initInMemory() async {
    _repository = InMemoryTaskRepository();
    _currentType = 'memory';

    await refresh();
  }

  Future<void> changeRepository(String type) async {
    if (type == 'sqlite') {
      await initSQLite();
    } else if (type == 'hive') {
      await initHive();
    } else {
      await initInMemory();
    }
  }

  Future<void> refresh() async {
    tasks = await repository.getAll();
    notifyListeners();
  }

  Future<void> addTask(String title) async {
    await repository.insert(
      Task(title: title),
    );

    await refresh();
  }

  Future<void> toggleTask(Task task) async {
    await repository.update(
      task.copyWith(
        isCompleted: !task.isCompleted,
      ),
    );

    await refresh();
  }

  Future<void> removeTask(int id) async {
    await repository.delete(id);
    await refresh();
  }

  Future<void> clearTasks() async {
    await repository.deleteAll();
    await refresh();
  }
}
