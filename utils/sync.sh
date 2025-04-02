#!/bin/bash

# Определяем абсолютный путь к каталогу, где находится скрипт
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Определяем корень проекта (на один уровень выше каталога со скриптом)
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Загружаем файл с учетными данными из корня проекта
CREDENTIALS_FILE="$PROJECT_ROOT/creditians"
if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "Ошибка: файл $CREDENTIALS_FILE не найден."
    exit 1
fi
source "$CREDENTIALS_FILE"

# Проверяем, была ли загружена переменная ip_svxlink
if [ -z "$ip_svxlink" ]; then
    echo "Ошибка: переменная ip_svxlink не найдена в файле creditians."
    exit 1
fi

# Проверяем наличие обязательного параметра исходного каталога
if [ $# -eq 0 ]; then
    echo "Использование: $0 <исходный_каталог>"
    echo "Ошибка: необходимо указать исходный каталог."
    exit 1
fi

SOURCE_DIR="$1"

# Проверяем существование указанного каталога
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Ошибка: исходный каталог '$SOURCE_DIR' не существует."
    exit 1
fi

# Выводим информацию о выполняемой операции
echo "Синхронизация каталога $SOURCE_DIR с сервером $ip_svxlink:/usr/share/svxlink/sounds"

# Копируем все файлы из указанного каталога
rsync -r -az --info=progress2 "$SOURCE_DIR" root@"$ip_svxlink":/usr/share/svxlink/sounds

# Проверяем результат выполнения rsync
if [ $? -eq 0 ]; then
    echo "Синхронизация успешно завершена."
else
    echo "Ошибка при синхронизации."
    exit 1
fi