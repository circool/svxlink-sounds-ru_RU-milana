#!/bin/bash
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


scp ./ru_RU_yandex/events.d/local/ReflectorLogic.tcl root@$ip_svxlink:/usr/share/svxlink/sounds/ru_RU_yandex/events.d/local/
scp ./ru_RU_yandex/Core/*.wav root@$ip_svxlink:/usr/share/svxlink/sounds/ru_RU_yandex/Core/
scp ./ru_RU_yandex/Default/*.wav root@$ip_svxlink:/usr/share/svxlink/sounds/ru_RU_yandex/Default/
