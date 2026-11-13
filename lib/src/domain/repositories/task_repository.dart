import 'package:lab5_clean_architecture/src/domain/entities/task_item.dart';

/// Контракт сховища завдань.
///
/// Інтерфейс належить предметній області: шар застосунку залежить від нього,
/// а конкретні реалізації (пам'ять, JSON-файл) живуть в infrastructure.
abstract interface class TaskRepository {
  Future<void> add(TaskItem task);

  Future<TaskItem?> getById(String id);

  Future<List<TaskItem>> getAll();

  Future<void> update(TaskItem task);

  Future<void> delete(String id);
}
