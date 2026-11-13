import 'package:lab5_clean_architecture/src/domain/entities/task_item.dart';
import 'package:lab5_clean_architecture/src/domain/exceptions/domain_exception.dart';
import 'package:lab5_clean_architecture/src/domain/repositories/task_repository.dart';

/// Реалізація [TaskRepository], що зберігає завдання в оперативній пам'яті.
///
/// Дані втрачаються після завершення програми; зручна для тестів.
class InMemoryTaskRepository implements TaskRepository {
  // LinkedHashMap (за замовчуванням) зберігає порядок додавання.
  final Map<String, TaskItem> _tasks = {};

  @override
  Future<void> add(TaskItem task) async {
    if (_tasks.containsKey(task.id)) {
      throw DomainException('Завдання "${task.id}" уже існує.');
    }
    _tasks[task.id] = task;
  }

  @override
  Future<TaskItem?> getById(String id) async => _tasks[id];

  @override
  Future<List<TaskItem>> getAll() async => List.of(_tasks.values);

  @override
  Future<void> update(TaskItem task) async {
    if (!_tasks.containsKey(task.id)) {
      throw TaskNotFoundException(task.id);
    }
    _tasks[task.id] = task;
  }

  @override
  Future<void> delete(String id) async {
    if (_tasks.remove(id) == null) {
      throw TaskNotFoundException(id);
    }
  }
}
