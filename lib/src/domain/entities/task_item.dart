import 'dart:math';

import 'package:lab5_clean_architecture/src/domain/exceptions/domain_exception.dart';

/// Сутність «завдання».
///
/// Об'єкт незмінний: операції, що змінюють стан, повертають нову копію.
/// Бізнес-правила:
///  * заголовок не може бути порожнім;
///  * завершене завдання не можна завершити вдруге.
class TaskItem {
  TaskItem({
    required this.id,
    required String title,
    required this.createdAt,
    this.isCompleted = false,
  }) : title = _validateTitle(title);

  /// Створює нове незавершене завдання зі згенерованим ідентифікатором.
  factory TaskItem.create({required String title, DateTime? createdAt}) {
    final now = createdAt ?? DateTime.now();
    return TaskItem(id: generateId(now), title: title, createdAt: now);
  }

  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  /// Повертає завершену копію завдання.
  ///
  /// Кидає [TaskAlreadyCompletedException], якщо завдання вже завершене.
  TaskItem complete() {
    if (isCompleted) {
      throw TaskAlreadyCompletedException(id);
    }
    return TaskItem(
      id: id,
      title: title,
      createdAt: createdAt,
      isCompleted: true,
    );
  }

  static final Random _random = Random.secure();

  /// Генерує унікальний ідентифікатор без зовнішніх пакетів:
  /// час у мікросекундах + випадкове число (обидва у системі base36).
  static String generateId(DateTime now) {
    final time = now.microsecondsSinceEpoch.toRadixString(36);
    final salt = _random.nextInt(1 << 32).toRadixString(36);
    return '$time-$salt';
  }

  static String _validateTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw const InvalidTaskTitleException();
    }
    return trimmed;
  }

  @override
  bool operator ==(Object other) =>
      other is TaskItem &&
      other.id == id &&
      other.title == title &&
      other.isCompleted == isCompleted &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, title, isCompleted, createdAt);

  @override
  String toString() =>
      'TaskItem(id: $id, title: $title, isCompleted: $isCompleted)';
}
