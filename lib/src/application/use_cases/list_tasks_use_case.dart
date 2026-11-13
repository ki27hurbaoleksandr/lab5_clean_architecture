import 'package:lab5_clean_architecture/src/domain/entities/task_item.dart';
import 'package:lab5_clean_architecture/src/domain/repositories/task_repository.dart';

/// Сценарій «отримати список завдань».
class ListTasksUseCase {
  const ListTasksUseCase(this._repository);

  final TaskRepository _repository;

  /// Повертає незмінний список завдань, відсортований за часом створення.
  Future<List<TaskItem>> call() async {
    final tasks = [...await _repository.getAll()]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return List.unmodifiable(tasks);
  }
}
