#!/bin/bash
# Проверка наличия параметра – каталога
if [ $# -ne 1 ]; then
    echo "Использование: $0 <каталог с WAV-файлами>"
    exit 1
fi

directory="$1"
output_file="result.txt"

# Очищаем (или создаём) выходной файл
echo "Сравнение уровней громкости WAV-файлов в каталоге \"$directory\"" > "$output_file"
echo "---------------------------------------------" >> "$output_file"

# Проходим по файлам с расширением .wav в заданном каталоге
for wav in "$directory"/*.wav; do
    # Проверяем, что файл существует (на случай, если нет подходящих файлов)
    if [ -f "$wav" ]; then
        echo "Обработка файла: $wav"
        # Запуск ffmpeg с фильтром volumedetect.
        # Команда производит анализ и выводит статистику в stderr.
        ffmpeg_output=$(ffmpeg -hide_banner -i "$wav" -af volumedetect -f null /dev/null 2>&1)
        # Извлекаем строку с информацией о максимальном уровне громкости, например:
        # "max_volume: -1.2 dB"
        max_line=$(echo "$ffmpeg_output" | grep "max_volume")
        # Если нужно можно также извлечь и средний уровень: grep "mean_volume"
        # Извлекаем числовое значение уровня
        max_volume=$(echo "$max_line" | sed -n 's/.*max_volume:\s*\(-*[0-9\.]*\).*/\1/p')

        # Записываем результат в выходной файл
        printf "%s: %s dB\n" "$wav" "$max_volume" >> "$output_file"
    fi
done

echo "Результаты записаны в файл: $output_file"
