#!/bin/bash

# Проверяем, задан ли каталог как параметр
if [ -z "$1" ]; then
  echo "Укажите каталог с wav-файлами как параметр!"
  exit 1
fi

# Каталог с wav-файлами из параметра командной строки
DIR="$1"

# Проверяем, существует ли каталог
if [ ! -d "$DIR" ]; then
  echo "Каталог $DIR не найден!"
  exit 1
fi

# Временный файл для сбора данных
TMP_FILE=$(mktemp /tmp/wav_volumes.XXXXXX)

# Ищем все wav-файлы в каталоге и анализируем их громкость с помощью afinfo
find "$DIR" -type f -name "*.wav" -exec afinfo {} \; | \
  awk '
    /File:/ { filename=$2 }
    /estimated peak volume:/ { 
      peak_volume=$4; 
      gsub(/[a-zA-Z]/,"",peak_volume); # Удаляем единицы измерения (dB)
      print filename ": " peak_volume 
    }
  ' | sort -t ':' -k 2 -n > "$TMP_FILE"

# Выводим результаты в итоговый текстовый файл (wav_volumes_report.txt в текущем каталоге)
echo "Уровень громкости wav-файлов в каталоге $DIR:" > wav_volumes_report.txt
echo "-----------------------------------------------" >> wav_volumes_report.txt
cat "$TMP_FILE" >> wav_volumes_report.txt
echo "-----------------------------------------------" >> wav_volumes_report.txt

# Удаляем временный файл
rm "$TMP_FILE"

echo "Отчет сформирован: wav_volumes_report.txt"
