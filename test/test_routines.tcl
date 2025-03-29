# Процедура для проверки существования процедуры
proc procedureExists {procName} {
    # Проверяем наличие процедуры по полному пути
    if {[info proc $procName] ne ""} {
        return 1
    }
    
    # Пытаемся разобрать имя процедуры
    set parts [split $procName "::"]
    
    # Если есть пространство имен (формат NS::procname)
    if {[llength $parts] > 1} {
        set ns [lindex $parts 0]
        set procname [join [lrange $parts 1 end] "::"]
        
        # Проверяем наличие процедуры в указанном namespace
        if {[info proc ${ns}::$procname] ne ""} {
            return 1
        }
    }
    
    return 0
}

# Упрощенная процедура для запуска тестов
proc runTests {args} {
    if {[info exists ::env(TEST_DEBUG_MODE)]} {
        set debugMode $::env(TEST_DEBUG_MODE)
    }
    
    # Сохраняем оригинальный puts и создаем временный буфер
    set ::testOutput ""
    rename ::puts ::original_puts
    proc ::puts {args} {
        if {[llength $args] == 1} {
            append ::testOutput [lindex $args 0]\n
        } elseif {[lindex $args 0] eq "-nonewline"} {
            append ::testOutput [lindex $args 1]
        } else {
            eval ::original_puts $args
        }
    }
    
    # Извлекаем первый аргумент (имя процедуры)
    set procName [lindex $args 0]
    
    # Вызываем процедуру, если она существует
    if {[procedureExists $procName]} {
        $procName {*}[lrange $args 1 end]
    } else {
        append ::testOutput "Процедура $procName не найдена"
    }
    
    # Восстанавливаем оригинальный puts
    rename ::puts ""
    rename ::original_puts ::puts
    
    # Возвращаем захваченный вывод
    return [string trimright $::testOutput]
}


proc runTest {args expected} {
    global debugMode logic_name active_module module_list
    
    # Извлекаем имя процедуры из аргументов
    set procName [lindex $args 0]
    
    # Проверяем существование процедуры перед выполнением теста
    if {![procedureExists $procName]} {
        if { $debugMode } {
            puts "\nТест ($args) не выполнен: \033\[31mПодходящая процедура '$procName' не найдена\033\[0m"    
        }
        
        return 1
    }
    
    # Заменяем ${active_module} в аргументах
    set processedArgs [list $procName]
    foreach arg [lrange $args 1 end] {
        lappend processedArgs [string map [list "\${active_module}" $::active_module] $arg]
    }
    
    # Выполняем тест с обработанными аргументами
    set result [runTests {*}$processedArgs]
    set result [string trimright $result]
    set expected [string map [list "\${active_module}" $::active_module] $expected]
    set expected [string map [list "\${logic_name}" $::logic_name] $expected]

    if {$result eq $expected} {
        if {$debugMode} {
            puts "\nТест ($args) пройден: \nожидалось \033\[32m'$expected'\033\[0m, \nполучено  \033\[32m'$result'\033\[0m"
        }        
        return 0
    } else {
        puts "\nТест ($args) не пройден: \nожидалось \033\[32m'$expected'\033\[0m, \nполучено  \033\[31m'$result'\033\[0m"
        return 1
    }
}

# Процедура для запуска тестов из файла
# proc runTestsFromFile {file { logic ""} } {   
#     global debugMode testFailed active_module logic_name
#     set currentTestFailed 0

#     if {[file exists $file]} {
#         puts -nonewline "\nОбрабатываю логику \033\[33m$logic \033\[0mиз файла $file. "
#         source $file
#         set count [llength $dataTests]
#         puts -nonewline "Найдено $count тестовых условий. "
        
#         foreach testCase $dataTests {
#             set args [lrange $testCase 0 end-1]
#             set expected [lindex $testCase end]
            
#             # Заменяем имя процедуры с учетом active_module
#             set procName [lindex $args 0]
#             set args [lreplace $args 0 0 "${logic}::${procName}"]
            
#             if {[runTest $args $expected]} {
#                 set currentTestFailed 1
#                 set ::testFailed 1
#             }

            
#         }
#     } else {
#         puts "\033\[31mФайл $file не найден.\033\[0m"
#         set currentTestFailed 1
#         set ::testFailed 1
#     }

#     if {!$currentTestFailed} {
#         puts "\033\[32mТест пройден успешно\033\[0m"
#     }
# }

proc runTestsFromFile {file { logic ""} } {   
    global debugMode testFailed active_module logic_name module_list
    set currentTestFailed 0
    set testsExecuted 0

    if {[file exists $file]} {
        puts -nonewline "\nОбрабатываю логику \033\[33m$logic \033\[0mиз файла $file. "
        source $file
        set count [llength $dataTests]
        puts -nonewline "Найдено $count тестовых условий. "
        
        foreach testCase $dataTests {
            set args [lrange $testCase 0 end-1]
            set expected [lindex $testCase end]
            
            # Заменяем имя процедуры с учетом active_module
            set procName [lindex $args 0]
            set args [lreplace $args 0 0 "${logic}::${procName}"]
            
            if {[runTest $args $expected]} {
                set currentTestFailed 1
                set ::testFailed 1
            }
            incr testsExecuted
        }
    } else {
        puts "\033\[31mФайл $file не найден.\033\[0m"
        set currentTestFailed 1
        set ::testFailed 1
    }

    if {!$currentTestFailed && $testsExecuted > 0} {
        puts "\033\[32mТест пройден успешно\033\[0m"
    }
}