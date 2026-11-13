import 'package:lab5_clean_architecture/src/domain/entities/task_item.dart';
import 'package:lab5_clean_architecture/src/domain/exceptions/domain_exception.dart';
import 'package:lab5_clean_architecture/src/domain/repositories/task_repository.dart';

/// Сценарій «завершити завдання».
class CompleteTaskUseCase {
  const CompleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  /// Завершує завдання з ідентифікатором [id] і повертає оновлений об'єкт.
  ///
  /// Кидає `TaskNotFoundException`, якщо завдання не існує, та
  /// `TaskAlreadyCompletedException`, якщо воно вже завершене.
  Future<TaskItem> call(String id) async {
    final task = await _repository.getById(id);
    if (task == null) {
      throw TaskNotFoundException(id);
    }
    final completed = task.complete();
    await _repository.update(completed);
    return completed;
  }
}
