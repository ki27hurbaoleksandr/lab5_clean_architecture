import 'package:lab5_clean_architecture/src/application/use_cases/complete_task_use_case.dart';
import 'package:lab5_clean_architecture/src/application/use_cases/create_task_use_case.dart';
import 'package:lab5_clean_architecture/src/application/use_cases/delete_task_use_case.dart';
import 'package:lab5_clean_architecture/src/application/use_cases/list_tasks_use_case.dart';
import 'package:lab5_clean_architecture/src/domain/entities/task_item.dart';
import 'package:lab5_clean_architecture/src/domain/exceptions/domain_exception.dart';
import 'package:lab5_clean_architecture/src/infrastructure/repositories/in_memory_task_repository.dart';
import 'package:test/test.dart';

void main() {
  late InMemoryTaskRepository repository;
  late CreateTaskUseCase createTask;
  late ListTasksUseCase listTasks;
  late CompleteTaskUseCase completeTask;
  late DeleteTaskUseCase deleteTask;

  setUp(() {
    repository = InMemoryTaskRepository();
    createTask = CreateTaskUseCase(repository);
    listTasks = ListTasksUseCase(repository);
    completeTask = CompleteTaskUseCase(repository);
    deleteTask = DeleteTaskUseCase(repository);
  });

  group('TaskItem', () {
    test('обрізає пробіли в заголовку', () {
      expect(TaskItem.create(title: '  Купити хліб ').title, 'Купити хліб');
    });

    test('генерує різні ідентифікатори', () {
      final ids = {
        for (var i = 0; i < 100; i++) TaskItem.create(title: 'a').id,
      };
      expect(ids, hasLength(100));
    });
  });

  group('CreateTaskUseCase', () {
    test('зберігає нове незавершене завдання', () async {
      final task = await createTask('Написати звіт');

      expect(task.isCompleted, isFalse);
      expect(await repository.getById(task.id), task);
    });

    test('відхиляє порожній заголовок', () {
      expect(
        () => createTask('   '),
        throwsA(isA<InvalidTaskTitleException>()),
      );
    });
  });

  group('ListTasksUseCase', () {
    test('повертає порожній список для порожнього сховища', () async {
      expect(await listTasks(), isEmpty);
    });

    test('повертає завдання за часом створення та незмінний список', () async {
      final older = TaskItem.create(
        title: 'Старе',
        createdAt: DateTime(2026, 1, 1),
      );
      final newer = TaskItem.create(
        title: 'Нове',
        createdAt: DateTime(2026, 2, 1),
      );
      await repository.add(newer);
      await repository.add(older);

      final tasks = await listTasks();

      expect(tasks.map((t) => t.title), ['Старе', 'Нове']);
      expect(() => tasks.add(older), throwsUnsupportedError);
    });
  });

  group('CompleteTaskUseCase', () {
    test('завершує завдання і зберігає зміну', () async {
      final task = await createTask('Задача');

      final completed = await completeTask(task.id);

      expect(completed.isCompleted, isTrue);
      expect((await repository.getById(task.id))!.isCompleted, isTrue);
    });

    test('не дозволяє завершити завдання двічі', () async {
      final task = await createTask('Задача');
      await completeTask(task.id);

      expect(
        () => completeTask(task.id),
        throwsA(isA<TaskAlreadyCompletedException>()),
      );
    });

    test('кидає виняток для неіснуючого завдання', () {
      expect(
        () => completeTask('missing'),
        throwsA(isA<TaskNotFoundException>()),
      );
    });
  });

  group('DeleteTaskUseCase', () {
    test('видаляє існуюче завдання', () async {
      final task = await createTask('Задача');

      await deleteTask(task.id);

      expect(await repository.getById(task.id), isNull);
      expect(await listTasks(), isEmpty);
    });

    test('кидає виняток для неіснуючого завдання', () {
      expect(
        () => deleteTask('missing'),
        throwsA(isA<TaskNotFoundException>()),
      );
    });
  });
}
