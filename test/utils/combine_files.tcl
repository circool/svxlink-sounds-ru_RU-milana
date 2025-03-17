#!/usr/bin/env tclsh

# сливает файлы, соответствующие маске, в один выходной файл, для подготовки аудио-файлов

proc combine_files {mask output_file} {
	# Открываем выходной файл для записи
	set out_fh [open $output_file w]

	# Получаем список файлов, соответствующих маске
	set files [glob -nocomplain $mask]

	# Перебираем каждый файл
	foreach file $files {
		# Открываем текущий файл для чтения
		set in_fh [open $file r]

		# Читаем и записываем содержимое файла в выходной файл
		puts -nonewline $out_fh [read $in_fh]

		# Добавляем пробел (или пустую строку) после содержимого файла
		puts $out_fh ""

		# Закрываем текущий файл
		close $in_fh
	}

	# Закрываем выходной файл
	close $out_fh
}

# Проверяем аргументы командной строки
if { $argc != 2 } {
	puts "получено неверное количество аргументов $argc"
	puts "Использование: combine_files.tcl '<маска>' <выходной_файл>"
	exit 1
}

# Получаем аргументы
set mask [lindex $argv 0]
set output_file [lindex $argv 1]

# Вызываем процедуру
combine_files $mask $output_file