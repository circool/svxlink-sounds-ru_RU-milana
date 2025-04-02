#!/usr/bin/env tclsh
# Формирует словарь из текстовых файлов в каталоге.

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

# Функция для создания словаря
proc createWordMap {dir recursive} {
    set wordMap {}
    set txtFiles [findFiles $dir *.txt $recursive]

    if {[llength $txtFiles] == 0} {
        puts "Внимание: файлы .txt не найдены в директории $dir"
        return $wordMap
    }

    foreach file $txtFiles {
        set dirName [file tail [file dirname $file]]
        set fileName [file rootname [file tail $file]]
        set content [readFile $file]

        if {[llength $content] == 0} {
            puts "Внимание: файл $file пуст или содержит только пустые строки"
        } else {
            dict set wordMap $dirName $fileName $content
        }
    }

    return $wordMap
}

# Функция для чтения содержимого файла
proc readFile {filePath} {
    set content {}
    set f [open $filePath r]
    while {[gets $f line] != -1} {
        if {[string trim $line] ne ""} {
            lappend content $line
        }
    }
    close $f
    return $content
}

# Функция для сохранения словаря в файл
proc saveWordMap {wordMap outputFile} {
    set f [open $outputFile w]
    puts $f "global wordMap"
    puts $f "set wordMap \{"
    dict for {dirName files} $wordMap {
        puts $f "    \"$dirName\" \{"
        dict for {fileName content} $files {
            puts $f "        \"$fileName\" \{"
            foreach line $content {
                puts $f "            \"$line\""
            }
            puts $f "        \}"
        }
        puts $f "    \}"
    }
    puts $f "\}"
    close $f
}

# Основной код программы
if {[llength $argv] < 1} {
    puts "Использование: gen_dict.tcl \[-r\] <путь_к_каталогу> \[<путь_к_файлу_назначения>\]"
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

set outputDir [pwd]
if {[llength $argv] > $dirIndex+1} {
    set outputDir [lindex $argv [expr {$dirIndex+1}]]
    if {![file isdirectory $outputDir]} {
        puts "Ошибка: $outputDir не является каталогом."
        exit 1
    }
}

set wordMap [createWordMap $targetDir $recursive]
set outputFile [file join $outputDir dict.tcl]
saveWordMap $wordMap $outputFile

puts "Словарь успешно сохранен в $outputFile"