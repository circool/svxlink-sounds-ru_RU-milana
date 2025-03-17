#!/usr/bin/env tclsh
# преобразует файлы в каталоге в формат wav с частотой дискретизации 16000 Гц

proc getAudioInfo {catalog} {
	# Получаем список всех .wav файлов в указанном каталоге
	set wavFiles [glob -directory $catalog *.wav]

	# Перебираем каждый файл
	foreach file $wavFiles {
		# Получаем имя файла
		set fileName [file tail $file]

		# Используем sox для получения информации о частоте дискретизации
		set sampleRate [exec sox --i -r $file]

		# Выводим информацию в консоль
		puts "File: $fileName, Sample Rate: $sampleRate Hz"

		# Если частота дискретизации отличается от 16000 Гц, преобразуем файл
		if {$sampleRate != 16000} {
			puts "Частота дискретизации отличается от 16000 Гц. Преобразуем файл..."

			# Создаем временный файл для преобразования
			set tempFile [file join [file dirname $file] "temp_$fileName"]

			# Используем sox для изменения частоты дискретизации
			exec sox $file -r 16000 $tempFile

			# Заменяем оригинальный файл преобразованным
			file rename -force $tempFile $file

			puts "Файл $fileName успешно преобразован в 16000 Гц."
		} else {
			puts "Файл $fileName уже имеет частоту дискретизации 16000 Гц. Преобразование не требуется."
		}
	}
}

# Разбор аргументов командной строки
if {[llength $argv] == 0} {
	puts "Ошибка: Не указан каталог для проверки."
	puts "Использование: tclsh getAudioInfo.tcl <каталог>"
	exit 1
}

# Получаем каталог из аргументов командной строки
set catalog [lindex $argv 0]

# Проверяем, существует ли указанный каталог
if {![file isdirectory $catalog]} {
	puts "Ошибка: Каталог '$catalog' не существует или не является каталогом."
	exit 1
}

# Вызываем функцию для получения информации о аудиофайлах
getAudioInfo $catalog