/// Базовий виняток предметної області.
///
/// Усі порушення бізнес-правил описуються нащадками цього класу,
/// щоб зовнішні шари могли відрізнити їх від технічних помилок.
class DomainException implements Exception {
  const DomainException(this.message);

  final String message;

  @override
  String toString() => 'DomainException: $message';
}

/// Заголовок завдання порожній або складається лише з пробілів.
class InvalidTaskTitleException extends DomainException {
  const InvalidTaskTitleException()
    : super('Заголовок завдання не може бути порожнім.');
}

/// Спроба завершити завдання, яке вже завершене.
class TaskAlreadyCompletedException extends DomainException {
  TaskAlreadyCompletedException(String id)
    : super('Завдання "$id" уже завершене.');
}

/// Завдання з указаним ідентифікатором не існує.
class TaskNotFoundException extends DomainException {
  TaskNotFoundException(String id) : super('Завдання "$id" не знайдене.');
}
