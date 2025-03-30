#!/bin/bash

# Проверка наличия аргумента
if [ $# -lt 1 ]; then
    echo "Использование: $0 [-r] [-t] /path/to/directory"
    echo "  -r  рекурсивный поиск"
    echo "  -t  тестовый режим (показать файлы без удаления)"
    exit 1
fi

recursive=0
test_mode=0
path=""

# Обработка аргументов
while [[ $# -gt 0 ]]; do
    case "$1" in
        -r)
            recursive=1
            shift
            ;;
        -t)
            test_mode=1
            shift
            ;;
        *)
            path="$1"
            shift
            ;;
    esac
done

# Проверка существования директории
if [ ! -d "$path" ]; then
    echo "Ошибка: Каталог '$path' не существует."
    exit 1
fi

# Функция для получения размера файла (кросс-платформенная)
get_file_size() {
    local file="$1"
    # Для Linux (GNU)
    if stat --version &>/dev/null; then
        stat -c%s "$file"
    # Для macOS (BSD)
    else
        stat -f%z "$file"
    fi
}

# Функция для обработки пустых .txt файлов
process_empty_txt() {
    local dir="$1"
    local find_cmd="find \"$dir\" -maxdepth 1 -type f -name \"*.txt\" -size 0"
    
    if [ "$recursive" -eq 1 ]; then
        find_cmd="find \"$dir\" -type f -name \"*.txt\" -size 0"
    fi

    echo "Поиск пустых .txt файлов в каталоге: $dir"
    eval "$find_cmd" | while read -r file; do
        if [ "$test_mode" -eq 1 ]; then
            # Тестовый режим: выводим имя и размер файла
            size=$(get_file_size "$file")
            echo "Найден: $file (Size: ${size} bytes)"
        else
            # Режим удаления
            echo "Удаляется: $file"
            rm -f "$file"
        fi
    done
}

# Запуск
process_empty_txt "$path"
echo "Готово."