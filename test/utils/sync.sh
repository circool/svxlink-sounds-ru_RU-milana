#!/bin/bash

source creditians
# Проверяем, была ли загружена переменная ip_svxlink
if [ -z "$ip_svxlink" ]; then
    echo "Ошибка: переменная ip_svxlink не найдена в файле creditians."
    exit 1
fi


# копирует все файлы из ru_RU в /usr/share/svxlink/sounds
rsync -r -az ../../ru_RU root@$ip_svxlink:/usr/share/svxlink/sounds
