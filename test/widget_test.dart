import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:task_manager_repository/repositories/repository.dart';
import 'package:task_manager_repository/models/task.dart';
import 'package:task_manager_repository/repositories/in_memory_task_repository.dart';

class MockTaskRepository extends Mock implements Repository<Task> {}

void main() {
  group('InMemoryTaskRepository tests', () {
    late InMemoryTaskRepository repository;

    setUp(() {
      repository = InMemoryTaskRepository();
    });

    test('Insert and retrieve task', () async {
      final task = Task(title: 'Test Task');

      final inserted = await repository.insert(task);

      final retrieved = await repository.getById(inserted.id!);

      expect(inserted.id, isNotNull);
      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Test Task');
    });

    test('Update task', () async {
      final task = await repository.insert(Task(title: 'Original'));

      final updated = task.copyWith(title: 'Updated');

      await repository.update(updated);

      final retrieved = await repository.getById(task.id!);

      expect(retrieved!.title, 'Updated');
    });

    test('Delete task', () async {
      final task = await repository.insert(Task(title: 'To Delete'));

      await repository.delete(task.id!);

      final retrieved = await repository.getById(task.id!);

      expect(retrieved, isNull);
    });

    test('Delete all tasks', () async {
      await repository.insert(Task(title: 'One'));
      await repository.insert(Task(title: 'Two'));

      await repository.deleteAll();

      expect(await repository.count(), 0);
      expect(await repository.getAll(), isEmpty);
    });

    test('Count tasks', () async {
      await repository.insert(Task(title: 'One'));
      await repository.insert(Task(title: 'Two'));

      expect(await repository.count(), 2);
    });
  });

  test('Mock repository test', () async {
    final mockRepository = MockTaskRepository();

    when(() => mockRepository.getAll()).thenAnswer((_) async => []);

    when(() => mockRepository.count()).thenAnswer((_) async => 0);

    expect(await mockRepository.getAll(), isEmpty);
    expect(await mockRepository.count(), 0);

    verify(() => mockRepository.getAll()).called(1);
    verify(() => mockRepository.count()).called(1);
  });
}
