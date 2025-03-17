#!/bin/bash
# копирует все файлы из ru_RU в /usr/share/svxlink/sounds
rsync -r -az ../../ru_RU vladimir@192.168.40.83:/usr/share/svxlink/sounds