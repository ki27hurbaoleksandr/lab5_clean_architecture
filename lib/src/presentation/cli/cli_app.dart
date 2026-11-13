import 'dart:convert';
import 'dart:io';

import 'package:lab5_clean_architecture/src/application/use_cases/complete_task_use_case.dart';
import 'package:lab5_clean_architecture/src/application/use_cases/create_task_use_case.dart';
import 'package:lab5_clean_architecture/src/application/use_cases/delete_task_use_case.dart';
import 'package:lab5_clean_architecture/src/application/use_cases/list_tasks_use_case.dart';
import 'package:lab5_clean_architecture/src/domain/entities/task_item.dart';
import 'package:lab5_clean_architecture/src/domain/exceptions/domain_exception.dart';

/// Консольний інтерфейс користувача.
///
/// Лише зчитує команди, викликає use cases і виводить результат;
/// бізнес-логіки тут немає. Введення/виведення можна підмінити (для тестів).
class CliApp {
  CliApp({
    required CreateTaskUseCase createTask,
    required ListTasksUseCase listTasks,
    required CompleteTaskUseCase completeTask,
    required DeleteTaskUseCase deleteTask,
    String? Function()? readLine,
    void Function(String)? writeLine,
  })  : _createTask = createTask,
        _listTasks = listTasks,
        _completeTask = completeTask,
        _deleteTask = deleteTask,
        _readLine = readLine ?? (() => stdin.readLineSync(encoding: utf8)),
        _writeLine = writeLine ?? print;

  final CreateTaskUseCase _createTask;
  final ListTasksUseCase _listTasks;
  final CompleteTaskUseCase _completeTask;
  final DeleteTaskUseCase _deleteTask;
  final String? Function() _readLine;
  final void Function(String) _writeLine;

  /// Головний цикл меню. Завершується за пунктом «0» або наприкінці введення.
  Future<void> run() async {
    while (true) {
      _printMenu();
      final choice = _prompt('Ваш вибір:');
      if (choice == null || choice == '0') {
        _writeLine('До побачення!');
        return;
      }
      try {
        switch (choice) {
          case '1':
            await _create();
          case '2':
            await _list();
          case '3':
            await _complete();
          case '4':
            await _delete();
          default:
            _writeLine('Невідомий пункт меню: "$choice".');
        }
      } on DomainException catch (e) {
        _writeLine('Помилка: ${e.message}');
      }
    }
  }

  void _printMenu() {
    _writeLine('');
    _writeLine('=== Облік завдань ===');
    _writeLine('1. Створити завдання');
    _writeLine('2. Показати список завдань');
    _writeLine('3. Завершити завдання');
    _writeLine('4. Видалити завдання');
    _writeLine('0. Вихід');
  }

  String? _prompt(String message) {
    _writeLine(message);
    return _readLine()?.trim();
  }

  Future<void> _create() async {
    final title = _prompt('Заголовок завдання:') ?? '';
    final task = await _createTask(title);
    _writeLine('Створено: "${task.title}".');
  }

  Future<void> _list() async {
    final tasks = await _listTasks();
    if (tasks.isEmpty) {
      _writeLine('Список порожній.');
      return;
    }
    _printTasks(tasks);
  }

  Future<void> _complete() async {
    final task = await _selectTask('Номер завдання для завершення:');
    if (task == null) return;
    final completed = await _completeTask(task.id);
    _writeLine('Завершено: "${completed.title}".');
  }

  Future<void> _delete() async {
    final task = await _selectTask('Номер завдання для видалення:');
    if (task == null) return;
    await _deleteTask(task.id);
    _writeLine('Видалено: "${task.title}".');
  }

  /// Показує список і повертає завдання, вибране користувачем за номером.
  Future<TaskItem?> _selectTask(String message) async {
    final tasks = await _listTasks();
    if (tasks.isEmpty) {
      _writeLine('Список порожній.');
      return null;
    }
    _printTasks(tasks);
    final input = _prompt(message);
    final number = int.tryParse(input ?? '');
    if (number == null || number < 1 || number > tasks.length) {
      _writeLine('Некоректний номер: "${input ?? ''}".');
      return null;
    }
    return tasks[number - 1];
  }

  void _printTasks(List<TaskItem> tasks) {
    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final mark = task.isCompleted ? '[x]' : '[ ]';
      _writeLine('${i + 1}. $mark ${task.title}');
    }
  }
}
