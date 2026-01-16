# Frappe Framework Docker

Docker окружение для разработки на Frappe Framework (Windows/Linux/Mac).

## Требования

- Docker Desktop
- Git

## Быстрый старт

```bash
# Клонировать репозиторий
git clone https://github.com/VladislavBly/frappe-init.git
cd frappe-init

# Запустить контейнеры
docker-compose up -d

# Войти в контейнер
docker exec -it frappe-bench bash

# Инициализировать Frappe (внутри контейнера)
bash /scripts/setup.sh

# Запустить сервер разработки (внутри контейнера)
cd /workspace/frappe-bench && bench start
```

## Доступ

После инициализации:

- **URL:** http://localhost:8000
- **Логин:** Administrator
- **Пароль:** admin

## Сервисы

| Сервис | Порт | Описание |
|--------|------|----------|
| Frappe | 8000 | Web-сервер |
| MariaDB | 3307 | База данных |
| Redis Cache | - | Кэш |
| Redis Queue | - | Очередь задач |

## Команды

```bash
# Войти в контейнер
docker exec -it frappe-bench bash

# Остановить
docker-compose down

# Полный сброс (удаление данных)
docker-compose down -v
```

## Работа с Frappe (внутри контейнера)

```bash
# Создать новое приложение
bench new-app my_app

# Установить приложение на сайт
bench --site dev.localhost install-app my_app

# Очистить кэш
bench --site dev.localhost clear-cache

# Миграция базы данных
bench --site dev.localhost migrate
```

## Конфигурация

Переменные окружения в `.env`:

| Переменная | По умолчанию | Описание |
|------------|--------------|----------|
| DB_ROOT_PASSWORD | admin | Пароль root MariaDB |
| FRAPPE_BRANCH | version-15 | Версия Frappe |
| SITE_NAME | dev.localhost | Имя сайта |
