import 'package:lab5_clean_architecture/src/domain/entities/task_item.dart';
import 'package:lab5_clean_architecture/src/domain/repositories/task_repository.dart';

/// Сценарій «створити завдання».
class CreateTaskUseCase {
  const CreateTaskUseCase(this._repository);

  final TaskRepository _repository;

  /// Створює завдання із заголовком [title] і зберігає його.
  ///
  /// Кидає `InvalidTaskTitleException`, якщо заголовок порожній.
  Future<TaskItem> call(String title) async {
    final task = TaskItem.create(title: title);
    await _repository.add(task);
    return task;
  }
}
