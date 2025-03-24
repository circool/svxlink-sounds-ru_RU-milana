#!/usr/bin/env tclsh
global debugMode
set ::debugMode 1

# Устанавливаем переменную окружения
set ::env(TEST_DEBUG_MODE) $debugMode    

# Процедура для запуска runTests с заданными параметрами
# Возвращает 1, если тест не пройден, и 0, если тест пройден успешно
proc runTest { args expected } {
    global debugMode
    
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

# Обрабатываем каждый файл по отдельности
if { $debugMode } {
    # Включен режим отладки - проверяем только проблемные строки, выводим любой результат в консоль
    # set file "./data_table/problem_test_data.tcl"
    set file "./data_table/echolink_test_data.tcl"
    puts -nonewline "\nОбрабатываю файл $file. "
    runTestsFromFile $file
} else {
    
    # Выключен режим отладки - проверяем все строки, выводим ошибки в консоль
    
    set file "./data_table/logic_test_data.tcl"
    puts -nonewline "\nОбрабатываю файл $file. "
    runTestsFromFile $file


    set file "./data_table/echolink_test_data.tcl"
    puts -nonewline "\nОбрабатываю файл $file. "
    runTestsFromFile $file
    
    set file "./data_table/metar_test_data.tcl"
    puts -nonewline "\nОбрабатываю файл $file. "
    runTestsFromFile $file 
    
    
    set file "./data_table/num_test_data.tcl"
    puts -nonewline "\nОбрабатываю файл $file. "
    runTestsFromFile $file
    
    set file "./data_table/num_test_female_data.tcl"
    puts -nonewline "\nОбрабатываю файл $file. "
    runTestsFromFile $file

    set file "./data_table/numbers_test_data.tcl"
    puts -nonewline "\nОбрабатываю файл $file. "
    runTestsFromFile $file

    set file "./data_table/time_test_data.tcl"
    puts -nonewline "\nОбрабатываю файл $file. "
    runTestsFromFile $file

    # set file "./data_table/time12_test_data.tcl"
    # puts -nonewline "\nОбрабатываю файл $file. "
    # runTestsFromFile $file

    set file "./data_table/numbers_with_unit_test_data.tcl"
    puts -nonewline "\nОбрабатываю файл $file. "
    runTestsFromFile $file

    set file "./data_table/numbers_with_units_test_data.tcl"
    puts -nonewline "\nОбрабатываю файл $file. "
    runTestsFromFile $file

}


# Итоговое сообщение
if {$testFailed} {
    puts "\n\033\[31mТест не пройден\033\[0m"
} else {
    puts "\n\033\[32mТест пройден успешно\033\[0m"
}