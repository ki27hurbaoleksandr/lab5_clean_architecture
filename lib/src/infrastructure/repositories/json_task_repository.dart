import 'dart:convert';
import 'dart:io';

import 'package:lab5_clean_architecture/src/domain/entities/task_item.dart';
import 'package:lab5_clean_architecture/src/domain/exceptions/domain_exception.dart';
import 'package:lab5_clean_architecture/src/domain/repositories/task_repository.dart';

/// Реалізація [TaskRepository], що зберігає завдання у JSON-файлі.
///
/// Файл містить масив об'єктів; якщо його немає, сховище вважається порожнім,
/// а файл (і каталоги) створюються під час першого запису.
class JsonTaskRepository implements TaskRepository {
  JsonTaskRepository(this._filePath);

  final String _filePath;

  File get _file => File(_filePath);

  @override
  Future<void> add(TaskItem task) async {
    final tasks = await _read();
    if (tasks.any((t) => t.id == task.id)) {
      throw DomainException('Завдання "${task.id}" уже існує.');
    }
    await _write([...tasks, task]);
  }

  @override
  Future<TaskItem?> getById(String id) async {
    final tasks = await _read();
    for (final task in tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  @override
  Future<List<TaskItem>> getAll() => _read();

  @override
  Future<void> update(TaskItem task) async {
    final tasks = await _read();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index < 0) {
      throw TaskNotFoundException(task.id);
    }
    tasks[index] = task;
    await _write(tasks);
  }

  @override
  Future<void> delete(String id) async {
    final tasks = await _read();
    final index = tasks.indexWhere((t) => t.id == id);
    if (index < 0) {
      throw TaskNotFoundException(id);
    }
    tasks.removeAt(index);
    await _write(tasks);
  }

  Future<List<TaskItem>> _read() async {
    final file = _file;
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    if (content.trim().isEmpty) return [];
    final decoded = jsonDecode(content) as List<dynamic>;
    return [
      for (final item in decoded) _fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<void> _write(List<TaskItem> tasks) async {
    final file = _file;
    await file.parent.create(recursive: true);
    final json = const JsonEncoder.withIndent('  ').convert(
      [for (final task in tasks) _toJson(task)],
    );
    await file.writeAsString(json, flush: true);
  }

  static Map<String, dynamic> _toJson(TaskItem task) => {
        'id': task.id,
        'title': task.title,
        'isCompleted': task.isCompleted,
        'createdAt': task.createdAt.toIso8601String(),
      };

  static TaskItem _fromJson(Map<String, dynamic> json) => TaskItem(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
