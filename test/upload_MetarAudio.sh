#!/bin/bash

source creditians
# Проверяем, была ли загружена переменная ip_svxlink
if [ -z "$ip_svxlink" ]; then
    echo "Ошибка: переменная ip_svxlink не найдена в файле creditians."
    exit 1
fi

# выгружает рабочие файлы на сервер
scp ../ru_RU_yandex_Jain/MetarInfo/*.wav root@$ip_svxlink:/usr/share/svxlink/sounds/ru_RU/MetarInfo

