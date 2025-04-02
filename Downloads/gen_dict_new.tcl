#!/usr/bin/env tclsh
# Формирует словарь из текстовых файлов в каталоге.

package require cmdline

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
    if {[catch {
        set f [open $filePath r]
        while {[gets $f line] != -1} {
            if {[string trim $line] ne ""} {
                lappend content $line
            }
        }
        close $f
    } err]} {
        puts "Ошибка чтения файла $filePath: $err"
        return ""
    }
    return $content
}

# Функция для сохранения словаря в файл
proc saveWordMap {wordMap outputFile} {
    if {[catch {
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
    } err]} {
        puts "Ошибка сохранения словаря в $outputFile: $err"
        return 0
    }
    return 1
}

# Функция для поиска пар файлов (wav-txt)
proc findFilePairs {audioDir definitionDir dictPath priority reportPath deleteWrong ignoreMissing} {
    set reportContent {}
    set wordMap {}
    
    # Получаем список всех wav и txt файлов
    set wavFiles {}
    if {$audioDir ne ""} {
        set wavFiles [findFiles $audioDir *.wav 1]
    }
    
    set txtFiles {}
    if {$definitionDir ne ""} {
        if {[file isdirectory $definitionDir]} {
            set txtFiles [findFiles $definitionDir *.txt 1]
        } elseif {[file exists $definitionDir]} {
            # Это файл dict.tcl
            source $definitionDir
            if {[info exists ::wordMap]} {
                set wordMap $::wordMap
            }
            return $wordMap
        }
    }
    
    # Если указан дополнительный словарь, загружаем его
    set dictMap {}
    if {$dictPath ne ""} {
        if {[file isdirectory $dictPath]} {
            set dictMap [createWordMap $dictPath 1]
        } elseif {[file exists $dictPath]} {
            source $dictPath
            if {[info exists ::wordMap]} {
                set dictMap $::wordMap
            }
        }
    }
    
    # Определяем приоритет обработки на основе переданных параметров
    if {$priority eq ""} {
        if {$audioDir ne "" && $definitionDir eq ""} {
            set priority "audio"
        } elseif {$audioDir eq "" && $definitionDir ne ""} {
            set priority "definition"
        }
    }
    
    # Обработка файлов в зависимости от приоритета
    switch $priority {
        "audio" {
            foreach wavFile $wavFiles {
                set dirName [file tail [file dirname $wavFile]]
                set fileName [file rootname [file tail $wavFile]]
                
                # Ищем соответствующий txt файл
                set found 0
                foreach txtFile $txtFiles {
                    if {[file tail [file dirname $txtFile]] eq $dirName && 
                        [file rootname [file tail $txtFile]] eq $fileName} {
                        set content [readFile $txtFile]
                        if {[llength $content] > 0} {
                            dict set wordMap $dirName $fileName $content
                            set found 1
                            break
                        }
                    }
                }
                
                # Если не нашли в txt файлах, ищем в словаре
                if {!$found && $dictPath ne ""} {
                    if {[dict exists $dictMap $dirName $fileName]} {
                        dict set wordMap $dirName $fileName [dict get $dictMap $dirName $fileName]
                        set found 1
                    }
                }
                
                if {!$found} {
                    if {$ignoreMissing} {
                        # Добавляем запись с пустым значением
                        dict set wordMap $dirName $fileName {}
                    }
                    lappend reportContent "Не найдена пара для файла $wavFile"
                }
            }
        }
        "definition" {
            foreach txtFile $txtFiles {
                set dirName [file tail [file dirname $txtFile]]
                set fileName [file rootname [file tail $txtFile]]
                
                # Ищем соответствующий wav файл
                set found 0
                foreach wavFile $wavFiles {
                    if {[file tail [file dirname $wavFile]] eq $dirName && 
                        [file rootname [file tail $wavFile]] eq $fileName} {
                        set content [readFile $txtFile]
                        if {[llength $content] > 0} {
                            dict set wordMap $dirName $fileName $content
                            set found 1
                            break
                        }
                    }
                }
                
                # Если не нашли в wav файлах, проверяем словарь
                if {!$found && $dictPath ne ""} {
                    if {[dict exists $dictMap $dirName $fileName]} {
                        dict set wordMap $dirName $fileName [dict get $dictMap $dirName $fileName]
                        set found 1
                    }
                }
                
                if {!$found} {
                    if {$ignoreMissing} {
                        # Добавляем запись с пустым значением
                        dict set wordMap $dirName $fileName {}
                    }
                    lappend reportContent "Не найдена пара для файла $txtFile"
                }
            }
        }
        "dict" {
            if {$dictPath eq ""} {
                puts "Ошибка: для priority=dict необходимо указать параметр dict"
                exit 1
            }
            
            # Сначала добавляем все из словаря
            dict for {dirName files} $dictMap {
                dict for {fileName content} $files {
                    dict set wordMap $dirName $fileName $content
                }
            }
            
            # Затем дополняем из txt файлов
            foreach txtFile $txtFiles {
                set dirName [file tail [file dirname $txtFile]]
                set fileName [file rootname [file tail $txtFile]]
                
                if {![dict exists $wordMap $dirName $fileName]} {
                    set content [readFile $txtFile]
                    if {[llength $content] > 0} {
                        dict set wordMap $dirName $fileName $content
                    } elseif {$ignoreMissing} {
                        dict set wordMap $dirName $fileName {}
                    }
                }
            }
        }
        default {
            # Если приоритет не указан, используем оба каталога
            if {$audioDir ne "" && $definitionDir ne ""} {
                # Сначала обрабатываем audio
                foreach wavFile $wavFiles {
                    set dirName [file tail [file dirname $wavFile]]
                    set fileName [file rootname [file tail $wavFile]]
                    
                    # Ищем соответствующий txt файл
                    set found 0
                    foreach txtFile $txtFiles {
                        if {[file tail [file dirname $txtFile]] eq $dirName && 
                            [file rootname [file tail $txtFile]] eq $fileName} {
                            set content [readFile $txtFile]
                            if {[llength $content] > 0} {
                                dict set wordMap $dirName $fileName $content
                                set found 1
                                break
                            }
                        }
                    }
                    
                    if {!$found} {
                        if {$ignoreMissing} {
                            # Добавляем запись с пустым значением
                            dict set wordMap $dirName $fileName {}
                        }
                        lappend reportContent "Не найдена пара для файла $wavFile"
                    }
                }
                
                # Затем обрабатываем оставшиеся txt файлы
                foreach txtFile $txtFiles {
                    set dirName [file tail [file dirname $txtFile]]
                    set fileName [file rootname [file tail $txtFile]]
                    
                    if {![dict exists $wordMap $dirName $fileName]} {
                        set content [readFile $txtFile]
                        if {[llength $content] > 0} {
                            dict set wordMap $dirName $fileName $content
                        } elseif {$ignoreMissing} {
                            dict set wordMap $dirName $fileName {}
                        }
                    }
                }
            }
        }
    }
    
    # Удаление файлов с неподдерживаемыми расширениями
    if {$deleteWrong} {
        # В audio каталоге
        if {$audioDir ne ""} {
            set allFiles [findFiles $audioDir * 1]
            foreach file $allFiles {
                if {![string match *.wav $file]} {
                    if {[catch {file delete $file} err]} {
                        lappend reportContent "Ошибка удаления файла $file: $err"
                    } else {
                        lappend reportContent "Удален файл с неподдерживаемым расширением: $file"
                    }
                }
            }
        }
        
        # В definition каталоге
        if {$definitionDir ne "" && [file isdirectory $definitionDir]} {
            set allFiles [findFiles $definitionDir * 1]
            foreach file $allFiles {
                if {![string match *.txt $file]} {
                    if {[catch {file delete $file} err]} {
                        lappend reportContent "Ошибка удаления файла $file: $err"
                    } else {
                        lappend reportContent "Удален файл с неподдерживаемым расширением: $file"
                    }
                }
            }
        }
    }
    
    # Сохранение отчета
    if {$reportPath ne ""} {
        set reportFile [file join $reportPath report.txt]
        if {[catch {
            set f [open $reportFile w]
            foreach line $reportContent {
                puts $f $line
            }
            close $f
        } err]} {
            puts "Ошибка сохранения отчета: $err"
        }
    }
    
    return $wordMap
}

# Основной код программы
set options {
    {audio.arg "" "Путь к каталогу с .wav файлами (альтернатива -af)"}
    {af.arg "" "Путь к каталогу с .wav файлами (альтернатива -audio)"}
    {definition.arg "" "Путь к каталогу с .txt файлами или файлу dict.tcl (альтернатива -df)"}
    {df.arg "" "Путь к каталогу с .txt файлами или файлу dict.tcl (альтернатива -definition)"}
    {of.arg "" "Путь к выходному файлу (по умолчанию ./dict.tcl)"}
    {priority.arg "" "Приоритет обработки (audio|definition|dict)"}
    {dict.arg "" "Дополнительный словарь или каталог с текстовыми файлами"}
    {report "Формировать отчет в текущем каталоге"}
    {reportdir.arg "" "Формировать отчет в указанном каталоге"}
    {delete_wrong "Удалять файлы с неподдерживаемыми расширениями"}
    {ignore_missing "Добавлять записи с пустыми значениями для отсутствующих пар"}
}

set usage "Использование: gen_dict.tcl \[-af=<audio_dir> | -audio=<audio_dir>\] \[-df=<definition_dir> | -definition=<definition_dir>\] \[-of=<output_file>\] \[-priority=audio|definition|dict\] \[-dict=<dict_path>\] \[-report\] \[-reportdir=<report_dir>\] \[-delete_wrong\] \[-ignore_missing\]"

if {[catch {
    array set params [cmdline::getoptions argv $options $usage]
} err]} {
    puts stderr $err
    exit 1
}

# Объединяем альтернативные параметры
if {$params(audio) ne ""} { set params(af) $params(audio) }
if {$params(definition) ne ""} { set params(df) $params(definition) }

# Проверка что указан хотя бы один из обязательных параметров
if {$params(af) eq "" && $params(df) eq ""} {
    puts stderr "Ошибка: необходимо указать хотя бы один из параметров -af/-audio или -df/-definition"
    puts stderr $usage
    exit 1
}

# Проверка каталогов
if {$params(af) ne "" && ![file isdirectory $params(af)]} {
    puts stderr "Ошибка: $params(af) не является каталогом"
    exit 1
}

if {$params(df) ne "" && ![file isdirectory $params(df)] && ![file exists $params(df)]} {
    puts stderr "Ошибка: $params(df) не является каталогом или файлом"
    exit 1
}

# Установка пути для отчета
set reportPath ""
if {$params(reportdir) ne ""} {
    set reportPath $params(reportdir)
    if {![file isdirectory $reportPath]} {
        puts stderr "Ошибка: каталог для отчета $reportPath не существует"
        exit 1
    }
} elseif {$params(report)} {
    set reportPath [pwd]
}

# Установка выходного файла
set outputFile [file join [pwd] dict.tcl]
if {$params(of) ne ""} {
    set outputFile $params(of)
    set outputDir [file dirname $outputFile]
    if {![file isdirectory $outputDir]} {
        puts stderr "Ошибка: каталог для выходного файла $outputDir не существует"
        exit 1
    }
}

# Автоматически определяем приоритет, если не указан
if {$params(priority) eq ""} {
    if {$params(af) ne "" && $params(df) eq ""} {
        set params(priority) "audio"
    } elseif {$params(af) eq "" && $params(df) ne ""} {
        set params(priority) "definition"
    }
}

# Создание словаря
set wordMap [findFilePairs $params(af) $params(df) $params(dict) $params(priority) $reportPath \
             [info exists params(delete_wrong)] [info exists params(ignore_missing)]]

# Сохранение словаря
if {[saveWordMap $wordMap $outputFile]} {
    puts "Словарь успешно сохранен в $outputFile"
}