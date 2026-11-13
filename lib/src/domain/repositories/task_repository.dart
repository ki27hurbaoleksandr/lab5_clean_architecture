import 'package:lab5_clean_architecture/src/domain/entities/task_item.dart';

/// Контракт сховища завдань.
///
/// Інтерфейс належить предметній області: шар застосунку залежить від нього,
/// а конкретні реалізації (пам'ять, JSON-файл) живуть в infrastructure.
///
/// Єдиний контракт для всіх реалізацій щодо відсутніх даних:
///  * [getById] повертає `null`, якщо завдання не знайдене;
///  * [update] і [delete] кидають `TaskNotFoundException`,
///    якщо завдання з таким ідентифікатором не існує.
abstract interface class TaskRepository {
  /// Додає нове завдання. Ідентифікатор має бути унікальним.
  Future<void> add(TaskItem task);

  /// Повертає завдання за [id] або `null`, якщо його немає.
  Future<TaskItem?> getById(String id);

  /// Повертає всі завдання в порядку додавання.
  Future<List<TaskItem>> getAll();

  /// Замінює збережене завдання з тим самим `id`.
  ///
  /// Кидає `TaskNotFoundException`, якщо завдання не існує.
  Future<void> update(TaskItem task);

  /// Видаляє завдання за [id].
  ///
  /// Кидає `TaskNotFoundException`, якщо завдання не існує.
  Future<void> delete(String id);
}
