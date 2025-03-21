#!/bin/bash

source creditians
# Проверяем, была ли загружена переменная ip_svxlink
if [ -z "$ip_svxlink" ]; then
    echo "Ошибка: переменная ip_svxlink не найдена в файле creditians."
    exit 1
fi


# выгружает рабочие файлы на сервер
scp locale.tcl 		root@$ip_svxlink:/usr/share/svxlink/sounds/ru_RU/events.d/local
scp dict.tcl 		root@$ip_svxlink:/usr/share/svxlink/sounds/ru_RU/events.d/local
scp MetarInfo.tcl 	root@$ip_svxlink:/usr/share/svxlink/sounds/ru_RU/events.d/local
