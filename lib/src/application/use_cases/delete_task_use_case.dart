import 'package:lab5_clean_architecture/src/domain/repositories/task_repository.dart';

/// Сценарій «видалити завдання».
class DeleteTaskUseCase {
  const DeleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  /// Видаляє завдання з ідентифікатором [id].
  ///
  /// Кидає `TaskNotFoundException`, якщо завдання не існує.
  Future<void> call(String id) => _repository.delete(id);
}
