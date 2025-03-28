#!/usr/bin/env tclsh
global argv debugMode module_name CFG_TYPE
# описание массивов для тестирования
source "./data_table/data_files_specs.tcl"

# режим тестирования
set ::debugMode 0
variable logic "Simplex"
variable active_module "EchoLink"

# пазличные переменные
variable logic_name "${logic}Logic"
variable mycall "R2ADU"
variable report_ctcss "88.9"
variable loaded_modules "ModuleEchoLink,ModuleFrn,ModuleMetarInfo,ModuleHelp,ModuleParrot"
variable langdir "../ru_RU"
variable list_languages {ru_RU en_EN}

source "./envs.tcl"
source "./mocks.tcl"

switch $logic_name {
    "SimplexLogic" {
        set logicFileList $logicSimplex
        set Logic::CFG_TYPE "Simplex"
    }
    "RepeaterLogic" {
        set logicFileList $logicRepeater
        set Logic::CFG_TYPE "Repeater"
    }
}

switch $active_module {
    "MetarInfo" {
        set moduleFileList $moduleMetarInfoFiles
    }
    "EchoLink" {
        set moduleFileList $moduleEchoLinkFiles
        # set mycall "R2ADU/L"
    }
    "Frn" {
        set moduleFileList $moduleFrnFiles
        set mycall "R2ADU-1"
    }
    "Parrot" {
        set moduleFileList $moduleParrotFiles
    }
    "Help" {
        set moduleFileList $moduleHelpFiles
    }
}

# Устанавливаем переменную окружения
set ::env(TEST_DEBUG_MODE) $debugMode    

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
    global debugMode logic_name active_module
    
    # Извлекаем имя процедуры из аргументов
    set procName [lindex $args 0]
    
    # Проверяем существование процедуры перед выполнением теста
    if {![procedureExists $procName]} {
        # puts "\nТест ($args) не выполнен: \033\[31mПодходящая процедура '$procName' не найдена\033\[0m"
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

# Основной код
set testFailed 0

# Процедура для запуска тестов из файла
proc runTestsFromFile {file { active_module ""}} {   
    global debugMode testFailed

    set currentTestFailed 0

    if {[file exists $file]} {
        source $file
        set count [llength $dataTests]
        puts -nonewline "Найдено $count тестовых условий. "
        
        foreach testCase $dataTests {
            set args [lrange $testCase 0 end-1]
            set expected [lindex $testCase end]
            
            # Заменяем имя процедуры с учетом active_module
            set procName [lindex $args 0]
            set args [lreplace $args 0 0 "${active_module}::${procName}"]
            
            if {[runTest $args $expected]} {
                set currentTestFailed 1
                set ::testFailed 1
            }
        }
    } else {
        puts "\033\[31mФайл $file не найден.\033\[0m"
        set currentTestFailed 1
        set ::testFailed 1
    }

    if {!$currentTestFailed} {
        puts "\033\[32mТест пройден успешно\033\[0m"
    }
}

# выбираем что запускать
if {$debugMode} {
    puts "\n\033\[32mОбработка проблемных сочетаний\033\[0m"
    
    foreach file $debugFiles {
        puts -nonewline "\nОбрабатываю файл $file."
        runTestsFromFile $file $logic_name
    }  

} else {
    puts "\n\033\[33mОбработка цифровых сочетаний\033\[0m"
    set tmp $logic_name
    set logic_name ""
     
    foreach file $numFiles {
        puts -nonewline "Обрабатываю файл $file."
        runTestsFromFile $file $logic_name
    }

    # Обработка логики
    puts "\n\033\[33mОбработка логики\033\[0m"
    set logic_name $tmp
    foreach file $logicFileList {
        puts -nonewline "Обрабатываю файл $file."
        runTestsFromFile $file $logic_name
    }

    # Обработка модулей
    puts "\n\033\[33mОбработка модулей\033\[0m"
    foreach file $moduleFileList {
        puts -nonewline "Обрабатываю файл $file."
        runTestsFromFile $file $logic_name
    }
}

# if {$debugMode == 0} {
#     puts "\n\033\[33mОбрабатывается логика\033\[0m"
    
#     foreach file $logicFileList {
#         puts -nonewline "\nОбрабатываю файл $file."
#         runTestsFromFile $file $logic_name
#     }
# }

# Итоговое сообщение
if {$testFailed} {
    puts "\n\033\[31mТест не пройден\033\[0m"
} else {
    puts "\n\033\[32mТест пройден успешно\033\[0m"
}