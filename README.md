# lab5_clean_architecture

Навчальний консольний застосунок обліку завдань (TaskItem) на Dart із шаровою (чистою) архітектурою.

## Політика гілок

- `main` — стабільний код; потрапляє лише через реліз (злиття з `develop`), на коміти ставляться теги версій.
- `develop` — інтеграційна гілка; в неї зливаються всі завершені функціональні гілки через pull request.
- `feature/*` — короткоживучі гілки під окремі задачі (`feature/domain-layer`, `feature/application-layer` тощо); створюються від `develop` і зливаються назад у `develop`.

Повідомлення комітів — українською, за Conventional Commits (`feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `merge`).
