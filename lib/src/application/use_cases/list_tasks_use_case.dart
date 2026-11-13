import 'package:lab5_clean_architecture/src/domain/entities/task_item.dart';
import 'package:lab5_clean_architecture/src/domain/repositories/task_repository.dart';

/// Сценарій «отримати список завдань».
class ListTasksUseCase {
  const ListTasksUseCase(this._repository);

  final TaskRepository _repository;

  Future<List<TaskItem>> call() => _repository.getAll();
}
