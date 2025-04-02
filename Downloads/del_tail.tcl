#!/usr/bin/env tclsh
# Очищает перенос строки в конце файлов, если он состоит из одной строки


# Функция для рекурсивного поиска файлов
proc findFiles {baseDir pattern recursive} {
	set files {}
	if {[file isdirectory $baseDir]} {
		set dirContent [glob -nocomplain -directory $baseDir *]
		foreach item $dirContent {
			if {[file isdirectory $item] && $recursive} {
				set files [concat $files [findFiles $item $pattern $recursive]]
			} elseif {[file isfile $item] && [string match $pattern $item]} {
				lappend files $item
			}
		}
	}
	return $files
}

# Функция для удаления переноса строки в конце файла, если он состоит из одной строки
proc correctFile {filePath} {
	set f [open $filePath r]
	set content [read $f]
	close $f

	# Проверяем, что файл состоит из одной строки и содержит \n в конце
	if {[string match "*\n" $content] && ![string match "*\n*" [string range $content 0 end-1]]} {
		set content [string trimright $content "\n"]
		set f [open $filePath w]
		puts -nonewline $f $content
		close $f
		puts "Исправлен файл: $filePath"
	}
}

# Основной код программы
if {[llength $argv] < 1} {
	puts "Использование: del_tail.tcl \[-r\] <имя_каталога>"
	exit 1
}

set recursive 0
set dirIndex 0

if {[lindex $argv 0] eq "-r"} {
	set recursive 1
	set dirIndex 1
}

set targetDir [lindex $argv $dirIndex]

if {![file isdirectory $targetDir]} {
	puts "Ошибка: $targetDir не является каталогом."
	exit 1
}

set txtFiles [findFiles $targetDir *.txt $recursive]

foreach file $txtFiles {
	correctFile $file
}

puts "Обработка завершена."