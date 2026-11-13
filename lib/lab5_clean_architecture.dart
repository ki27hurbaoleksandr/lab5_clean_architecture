/// Публічний API пакета: експорт шарів архітектури.
library;

export 'src/application/use_cases/complete_task_use_case.dart';
export 'src/application/use_cases/create_task_use_case.dart';
export 'src/application/use_cases/delete_task_use_case.dart';
export 'src/application/use_cases/list_tasks_use_case.dart';
export 'src/domain/entities/task_item.dart';
export 'src/domain/exceptions/domain_exception.dart';
export 'src/domain/repositories/task_repository.dart';
export 'src/infrastructure/repositories/in_memory_task_repository.dart';
export 'src/infrastructure/repositories/json_task_repository.dart';
export 'src/presentation/cli/cli_app.dart';
