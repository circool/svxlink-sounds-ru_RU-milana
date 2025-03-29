# Словарь для преобразования имен файлов в слова
source [file join [file dirname [info script]] dict.tcl]


# Процедуры для имитации воспроизведения сообщения

proc playMsg { modulename playingWord {warn 1}} {
	# puts "***DEBUG playMsg modulename=$modulename playingWord=$playingWord"
	
	# Словарь хранится в dict.tcl
	global wordMap

	# Проверяем, существует ли указанный каталог и файл в словаре
	if {[dict exists $wordMap $modulename $playingWord]} {
		set content [dict get $wordMap $modulename $playingWord]

		# Выводим содержимое файла
		foreach line $content {
			puts -nonewline "$line "
		}
	} else {
		if {$warn} {
			puts "\033\[31m*** WARNING: Каталог '$modulename' или файл '$playingWord' не найдены в словаре.\033\[0m"
		}	
		
		return 0
	}
	return 1
	
}

proc playSilence {param} {	
	if { $::showPauses } {
		set value [expr {int($param)}]
		if {$value < 200} {
			puts -nonewline ","
		} else {
			puts -nonewline "."
		}
	} else {
		return
	}
}

proc playTone { arg1 arg2 arg3 } {
	puts "звучит тон $arg1 $arg2 $arg3"
}


# Mock процедура playSubcommands, использующая словарь из dict.tcl
proc playSubcommands {context basename {header ""}} {
    global wordMap
    
    # Проверяем наличие заголовка и воспроизводим его
    if {$header != ""} {
        playSilence 500
        # playMsg $context $header
        playMsg "Core" $header
    }

    # Получаем все возможные ключи для данного контекста
    if {![dict exists $wordMap $context]} {
        puts "\033\[31m*** WARNING: Контекст '$context' не найден в словаре.\033\[0m"
        return
    }

    # Фильтруем ключи по базовому имени
    set subcommands [dict keys [dict get $wordMap $context]]
    set filtered_subcommands [list]
    
    foreach subcmd $subcommands {
        if {[string match "${basename}*" $subcmd]} {
            lappend filtered_subcommands $subcmd
        }
    }

    # Сортируем подкоманды по номеру
    set sorted_subcommands [lsort -dictionary $filtered_subcommands]

    # Воспроизводим каждую подкоманду
    foreach subcmd $sorted_subcommands {
        # Извлекаем номер и символы из имени подкоманды
        if {[regexp {^(\d+)([ABCD*#]*)$} [string range $subcmd [string length $basename] end] -> number chars]} {
            playSilence 200
            
            if {$chars == "*"} {
                set chars [getUnitSuffix $chars $number]
                playNumberWithUnit $number "star"

            } else {
               playNumber $number
               spellWord $chars 
               
            }
            playMsg $context $subcmd
            playSilence 200
            
        }
    }
}
