#!/usr/bin/env tclsh

# отладка 
# 1 - выбирать только особо назначенные файлы для тестирования и выводить все результаты для сравнения
# 0 - прогонять все файлы, выводить только ошибки
global debugMode
set ::debugMode 1

# визуализация пауз (отображение результата playSilence)
# - паузы более 200 показаны точками, менее - запятыми
# global showPauses
# set ::showPauses 0

# Устанавливаем переменную окружения
set ::env(TEST_DEBUG_MODE) $debugMode    

# Процедура для запуска runTests с заданными параметрами
# Возвращает 1, если тест не пройден, и 0, если тест пройден успешно
proc runTest { args expected } {
    global debugMode  
    # global showPauses

    # Запускаем runTests.tcl и захватываем его вывод
    set result [exec ./runTests.tcl {*}$args]

    # Удаляем пробелы в конце результата
    set result [string trimright $result]
    set expected [string trimright $expected]
    
    # Сравниваем ожидаемый и фактический результат
    if {$result eq $expected} {
        if {$debugMode} {
            puts "\nТест ($args) пройден: \nожидалось \033\[32m'$expected'\033\[0m, \nполучено  \033\[32m'$result'\033\[0m"
        }        
        return 0
    } else {
        puts -nonewline "\nТест ($args) не пройден: \nожидалось \033\[32m'$expected'\033\[0m, \nполучено  \033\[31m'$result'\033\[0m"
        return 1
    }
}


# Основной код

# Глобальный флаг для отслеживания ошибок во всех файлах
set testFailed 0

# Процедура для запуска тестов из файла
proc runTestsFromFile {file} {   
    global debugMode
    global showPauses
    global testFailed

    # Локальная переменная для отслеживания ошибок в текущем файле
    set currentTestFailed 0

    # Проверяем существование файла
    if {[file exists $file]} {
        # Если файл существует, загружаем его
        source $file
        set count [llength $dataTests]
        puts -nonewline "Найдено $count тестовых условий. "
        # Проходим по всем тестовым случаям
        foreach testCase $dataTests {
            # Извлекаем аргументы и ожидаемый результат
            set args [lrange $testCase 0 end-1]
            set expected [lindex $testCase end]
            
            # Запускаем тест и обновляем флаг, если тест не пройден
            if {[runTest $args $expected]} {
                set currentTestFailed 1
                set ::testFailed 1
            }
        }
    } else {
        # Если файл не найден, выводим сообщение с именем файла
        puts "\033\[31mФайл $file не найден.\033\[0m"
        set currentTestFailed 1
        set ::testFailed 1
    }

    # Если все тесты в файле пройдены успешно, выводим сообщение
    if {!$currentTestFailed} {
        puts "\033\[32mТест пройден успешно\033\[0m"
    }
}




# Список файлов для тестирования
set testFiles {
    "./data_table/reflector_test_data.tcl"
    "./data_table/logic_test_data.tcl"
    "./data_table/echolink_test_data.tcl"
    "./data_table/metar_test_data.tcl"
    "./data_table/num_test_data.tcl"
    "./data_table/num_test_female_data.tcl"
    "./data_table/numbers_test_data.tcl"
    "./data_table/time_test_data.tcl"
    "./data_table/numbers_with_unit_test_data.tcl"
    "./data_table/numbers_with_units_test_data.tcl"
}

set debugFiles {
    "./data_table/reflector_test_data.tcl"
}

if { $debugMode } {
    # В режиме отладки берем только первый файл из списка
    set fileList $debugFiles
} else {
    set fileList $testFiles
}

foreach file $fileList {
    puts -nonewline "\nОбрабатываю файл $file."
    runTestsFromFile $file
}


# Итоговое сообщение
if {$testFailed} {
    puts "\n\033\[31mТест не пройден\033\[0m"
} else {
    puts "\n\033\[32mТест пройден успешно\033\[0m"
}