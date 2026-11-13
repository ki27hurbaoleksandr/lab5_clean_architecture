import 'dart:convert';
import 'dart:io';

import 'package:lab5_clean_architecture/src/application/use_cases/complete_task_use_case.dart';
import 'package:lab5_clean_architecture/src/application/use_cases/create_task_use_case.dart';
import 'package:lab5_clean_architecture/src/application/use_cases/delete_task_use_case.dart';
import 'package:lab5_clean_architecture/src/application/use_cases/list_tasks_use_case.dart';
import 'package:lab5_clean_architecture/src/domain/repositories/task_repository.dart';
import 'package:lab5_clean_architecture/src/infrastructure/repositories/in_memory_task_repository.dart';
import 'package:lab5_clean_architecture/src/infrastructure/repositories/json_task_repository.dart';
import 'package:lab5_clean_architecture/src/presentation/cli/cli_app.dart';

const _defaultSettingsPath = 'config/settings.json';

/// Composition root: єдине місце, де збираються залежності
/// (Dependency Injection).
Future<void> main(List<String> arguments) async {
  final settingsPath =
      arguments.isNotEmpty ? arguments.first : _defaultSettingsPath;
  final settings = _readSettings(settingsPath);

  // 1. Обираємо реалізацію TaskRepository за налаштуванням storage.type.
  final repository =
      _createRepository(settings['storage'] as Map<String, dynamic>);

  // 2. Передаємо репозиторій у use cases через конструктор.
  // 3. Передаємо use cases у CliApp.
  final app = CliApp(
    createTask: CreateTaskUseCase(repository),
    listTasks: ListTasksUseCase(repository),
    completeTask: CompleteTaskUseCase(repository),
    deleteTask: DeleteTaskUseCase(repository),
  );

  await app.run();
}

Map<String, dynamic> _readSettings(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('Файл налаштувань не знайдено: $path');
    exit(1);
  }
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

TaskRepository _createRepository(Map<String, dynamic> storage) {
  final type = storage['type'];
  switch (type) {
    case 'memory':
      return InMemoryTaskRepository();
    case 'json':
      return JsonTaskRepository(storage['path'] as String);
    default:
      stderr.writeln(
        'Невідомий storage.type: "$type" (очікується memory або json).',
      );
      exit(1);
  }
}
