#!/bin/bash

# Загружает рабочие файлы на сервер
# Параметры:
# -t       - загружать моки
# -debug   - режим отладки (имитация действий)
# <исходный_каталог> - обязательный параметр

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Загрузка учетных данных
CREDENTIALS_FILE="$PROJECT_ROOT/creditians"
if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "Ошибка: файл $CREDENTIALS_FILE не найден."
    exit 1
fi
source "$CREDENTIALS_FILE"

if [ -z "$ip_svxlink" ]; then
    echo "Ошибка: переменная ip_svxlink не найдена."
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Использование: $0 [-t] [-debug] <исходный_каталог>"
    exit 1
fi

# Парсинг параметров
UPLOAD_MOCKS=0
DEBUG_MODE=0
while getopts "td" opt; do
    case $opt in
        t) UPLOAD_MOCKS=1 ;;
        d) DEBUG_MODE=1 ;;
        *) echo "Использование: $0 [-t] [-debug] <исходный_каталог>"; exit 1 ;;
    esac
done
shift $((OPTIND-1))

SOURCE_DIR="$1"
TARGET_SOUNDS_DIR="/usr/share/svxlink/sounds/$SOURCE_DIR"
EVENTS_D_DIR="$TARGET_SOUNDS_DIR/events.d"
LOCAL_EVENTS_DIR="$EVENTS_D_DIR/local"
TEST_EVENTS_DIR="$LOCAL_EVENTS_DIR/test"
CONFIG_FILE="/etc/svxlink/svxlink.conf"

# Проверка исходного каталога
if [ ! -d "$PROJECT_ROOT/$SOURCE_DIR" ]; then
    echo "Ошибка: каталог '$PROJECT_ROOT/$SOURCE_DIR' не найден."
    exit 1
fi

execute_command() {
    local cmd="$1"
    local description="$2"
    
    echo "Выполняется: $description"
    
    if [ $DEBUG_MODE -eq 1 ]; then
        echo "[DEBUG] $cmd"
        return 0
    fi
    
    if ! eval "$cmd"; then
        echo "Ошибка: $description"
        exit 1
    fi
    echo "Успешно: $description"
}

update_default_lang() {
    echo "Проверка DEFAULT_LANG в $CONFIG_FILE"
    
    # Измененный grep для извлечения только значения
    local check_cmd="ssh root@$ip_svxlink \"grep -Po '^[[:space:]]*DEFAULT_LANG[[:space:]]*=[[:space:]]*\\K[^[:space:];#]*' '$CONFIG_FILE' 2>/dev/null | head -1\""
    local current_lang=$(eval "$check_cmd")
    
    if [ -z "$current_lang" ]; then
        echo "Предупреждение: DEFAULT_LANG не найден, добавляем новую строку"
        local add_cmd="ssh root@$ip_svxlink \"echo 'DEFAULT_LANG=$SOURCE_DIR' >> '$CONFIG_FILE'\""
        execute_command "$add_cmd" "Добавление DEFAULT_LANG в конфиг"
        return 0
    fi
    
    if [ "$current_lang" == "$SOURCE_DIR" ]; then
        echo "DEFAULT_LANG уже установлен в '$SOURCE_DIR'"
        return 0
    fi
    
    # Замена с учетом возможных пробелов
    local replace_cmd="ssh root@$ip_svxlink \"sed -i -E 's/^[[:space:]]*DEFAULT_LANG[[:space:]]*=[[:space:]]*.*/DEFAULT_LANG=$SOURCE_DIR/' '$CONFIG_FILE'\""
    
    execute_command "$replace_cmd" "Обновление DEFAULT_LANG в конфиге"
    
    # Проверка изменения (теперь получаем только значение)
    local updated_lang=$(eval "$check_cmd")
    if [ "$updated_lang" != "$SOURCE_DIR" ]; then
        echo "Ошибка: не удалось обновить DEFAULT_LANG (ожидалось '$SOURCE_DIR', получено '$updated_lang')"
        exit 1
    fi
    
    echo "DEFAULT_LANG успешно обновлен на '$SOURCE_DIR'"
}

# Основной процесс
if [ $DEBUG_MODE -eq 1 ]; then
    echo "=== РЕЖИМ ОТЛАДКИ ==="
fi

# Копирование звуковых файлов
execute_command \
    "scp -r \"$PROJECT_ROOT/$SOURCE_DIR/\"* \"root@$ip_svxlink:$TARGET_SOUNDS_DIR/\"" \
    "Копирование звуков в $TARGET_SOUNDS_DIR"

# Обновление конфига
update_default_lang

# Обработка тестовых файлов
if [ $UPLOAD_MOCKS -eq 0 ]; then
    execute_command \
        "ssh root@$ip_svxlink 'rm -rf \"$TEST_EVENTS_DIR\" \"$LOCAL_EVENTS_DIR/test_mode_select.tcl\" 2>/dev/null'" \
        "Удаление тестовых файлов"
else
    # Создание структуры каталогов
    execute_command \
        "ssh root@$ip_svxlink 'mkdir -p \"$TEST_EVENTS_DIR\"'" \
        "Создание тестового каталога"
    
    # Копирование тестовых файлов
    execute_command \
        "scp \"$PROJECT_ROOT/test/dict.tcl\" \"root@$ip_svxlink:$TEST_EVENTS_DIR/\"" \
        "Копирование dict.tcl"
    
    execute_command \
        "scp \"$PROJECT_ROOT/test/mocks.tcl\" \"root@$ip_svxlink:$TEST_EVENTS_DIR/\"" \
        "Копирование mocks.tcl"
    
    execute_command \
        "scp \"$PROJECT_ROOT/test/test_mode_select.tcl\" \"root@$ip_svxlink:$LOCAL_EVENTS_DIR/\"" \
        "Копирование test_mode_select.tcl в $LOCAL_EVENTS_DIR"
fi

echo "Скрипт успешно выполнен!"
[ $DEBUG_MODE -eq 1 ] && echo "=== РЕЖИМ ОТЛАДКИ ==="
exit 0