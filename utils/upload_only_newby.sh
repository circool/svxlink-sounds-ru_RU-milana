#!/bin/bash

# Парсинг аргументов
DRY_RUN=false
LOCAL_DIR_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
        DRY_RUN=true
        shift
        ;;
        *)
        if [[ -z "$LOCAL_DIR_NAME" ]]; then
            LOCAL_DIR_NAME="$1"
            shift
        else
            echo "Неизвестный аргумент: $1"
            exit 1
        fi
        ;;
    esac
done

if [[ -z "$LOCAL_DIR_NAME" ]]; then
    echo "Ошибка: не указано имя локального каталога"
    echo "Использование: $0 [--dry-run] <имя локального каталога>"
    exit 1
fi

# Проверяем наличие необходимых файлов
if [[ ! -d "./$LOCAL_DIR_NAME" ]]; then
    echo "Ошибка: локальный каталог ./$LOCAL_DIR_NAME не найден"
    exit 1
fi

if [[ ! -f "./creditians" ]]; then
    echo "Ошибка: файл ./creditians не найден"
    exit 1
fi

# Загрузка учетных данных
source "./creditians"

if [[ -z "$ip_svxlink" ]]; then
    echo "Ошибка: переменная ip_svxlink не найдена в creditians"
    exit 1
fi

# Функция для обработки файлов
process_files() {
    # Сначала собираем все уникальные каталоги для создания
    local dirs_to_create=""
    while IFS='|' read -r _ remote_path; do
        remote_dir="${remote_path%/*}"
        if [[ ! "$dirs_to_create" == *"$remote_dir"* ]]; then
            dirs_to_create+="$remote_dir"$'\n'
        fi
    done <<< "$1"
    
    # Создаем каталоги (в dry-run только показываем)
    while IFS= read -r -d '' dir; do
        [[ -z "$dir" ]] && continue
        if $DRY_RUN; then
            echo "[DRY RUN] Создал бы каталог на сервере: $dir"
        else
            ssh root@$ip_svxlink "mkdir -p \"$dir\""
        fi
    done <<< "$dirs_to_create"
    
    # Копируем файлы (в dry-run только показываем)
    while IFS='|' read -r local_file remote_path; do
        if $DRY_RUN; then
            echo "[DRY RUN] Скопировал бы: $local_file -> root@$ip_svxlink:$remote_path"
        else
            echo "Копирование $local_file..."
            scp "$local_file" "root@$ip_svxlink:\"$remote_path\""
            if [[ $? -eq 0 ]]; then
                echo "Файл успешно скопирован в $remote_path"
            else
                echo "Ошибка при копировании файла $local_file"
            fi
        fi
    done <<< "$1"
}

if $DRY_RUN; then
    echo "=== РЕЖИМ ОТЛАДКИ (dry-run) ==="
    echo "Файлы не будут реально копироваться"
fi

# Собираем все файлы для копирования
files_to_copy=""
while IFS= read -r -d '' file; do
    rel_path="${file#./$LOCAL_DIR_NAME/}"
    
    # Определяем целевой путь
    if [[ "$rel_path" == events.d/local/* ]]; then
        remote_path="/usr/share/svxlink/sounds/$LOCAL_DIR_NAME/events.d/local/${rel_path#events.d/local/}"
    else
        remote_path="/usr/share/svxlink/sounds/$LOCAL_DIR_NAME/$rel_path"
    fi
    
    # Добавляем разделитель только если files_to_copy не пуста
    if [[ -n "$files_to_copy" ]]; then
        files_to_copy+=$'\n'
    fi
    files_to_copy+="${file}|${remote_path}"
done < <(find "./$LOCAL_DIR_NAME" -type f -mmin -600 -print0)

if [[ -z "$files_to_copy" ]]; then
    echo "Нет измененных файлов для копирования"
    exit 0
fi

# Обрабатываем все файлы
process_files "$files_to_copy"

echo "Готово."