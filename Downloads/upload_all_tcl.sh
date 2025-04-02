#!/bin/bash

source creditians
# Проверяем, была ли загружена переменная ip_svxlink
if [ -z "$ip_svxlink" ]; then
    echo "Ошибка: переменная ip_svxlink не найдена в файле creditians."
    exit 1
fi

# обновляем словарь
.gen_dict.tcl -r ../make_audio/definition
# выгружает рабочие файлы на сервер
scp dict.tcl root@$ip_svxlink:/usr/share/svxlink/sounds/ru_RU/events.d/local/test/
scp mocks.tcl root@$ip_svxlink:/usr/share/svxlink/sounds/ru_RU/events.d/local/test/
scp ./events.d/*.tcl root@$ip_svxlink:/usr/share/svxlink/sounds/ru_RU/events.d/local
