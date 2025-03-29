#!/usr/bin/env tclsh
global argv debugMode module_name module_list CFG_TYPE logic_name mycall report_ctcss langdir debug_active_module showPauses
# описание массивов для тестирования
source "./assert_data_table/data_files_specs.tcl"

# режим тестирования
set ::debugMode 1
set ::showPauses 0
set ::debug_active_module 1


variable active_module "EchoLink"

# различные переменные
set mycall "R2ADU"
set report_ctcss "88.5"
variable loaded_modules "ModuleEchoLink ModuleFrn ModuleMetarInfo ModuleHelp ModuleParrot"
set module_list {
  0 "Help"
  1 "Parrot"
  2 "EchoLink"
  5 "MetarInfo"
  7 "Frn"
}

set langdir "../ru_RU"
variable list_languages {ru_RU en_EN}


source "./envs.tcl"
source "./mocks.tcl"



# Устанавливаем переменную окружения
set ::env(TEST_DEBUG_MODE) $debugMode    

source "test_routines.tcl"

# Основной код
set testFailed 0



# выбираем что запускать
if {$debugMode} {
    puts "\n\033\[32mОбработка проблемных сочетаний\033\[0m"
    
    foreach file $debugFiles {       
        runTestsFromFile $file
    }

    if { $debug_active_module } {
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
        foreach file $moduleFileList {
            runTestsFromFile $file $active_module
        }

    }
    
} else {
    puts "\n\033\[33mОбработка цифровых сочетаний\033\[0m"  
    set logic_name ""   
    foreach file $numFiles {
        runTestsFromFile $file $logic_name
    }

    # Обработка модулей
    puts "\n\033\[33mОбработка модулей\033\[0m"
    foreach module $loaded_modules {
        
        set active_module [string map {"Module" ""} $module]
        
        switch $active_module {
            "MetarInfo" {
                set moduleFileList $moduleMetarInfoFiles
                set mycall "R2ADU/L"
            }
            "EchoLink" {
                set moduleFileList $moduleEchoLinkFiles
                set mycall "R2ADU/L"
            }
            "Frn" {
                set moduleFileList $moduleFrnFiles
                set mycall "R2ADU-1"
            }
            "Parrot" {
                set moduleFileList $moduleParrotFiles
                set mycall "R2ADU/L"
            }
            "Help" {
                set moduleFileList $moduleHelpFiles
                set mycall "R2ADU/L"
            }
        }

        foreach file $moduleFileList {
            runTestsFromFile $file $active_module
        }


        
    }
    
    # Эмулируем работу модуля Эхолинк
    set active_module "EchoLink"
    
    # Обработка логики
    puts "\n\033\[33mОбработка логики\033\[0m"
    
    # "Repeater"
    set logic_name "RepeaterLogic"
    set logicFileList $logicRepeater
    set Logic::CFG_TYPE "Repeater"
    set mycall "R2ADU/R"
    foreach file $logicFileList {
        runTestsFromFile $file $logic_name
    }
        
    # "Simplex"
    set logic_name "SimplexLogic"
    set logicFileList $logicSimplex
    set Logic::CFG_TYPE "Simplex"
    set mycall "R2ADU/L"
    foreach file $logicFileList {
        runTestsFromFile $file $logic_name
    }

    # "Reflector"
    set logic_name "ReflectorLogic"
    set logicFileList $logicReflector
    set Logic::CFG_TYPE "Reflector"
    set mycall "R2ADU-1"
    namespace eval ReflectorLogic {
        set previous_tg 999
        set selected_tg 111
        set reflector_connection_established 1
    }
    foreach file $logicFileList {
        runTestsFromFile $file $logic_name
    }
    
}


# Итоговое сообщение
if {$testFailed} {
    puts "\n\033\[31mТест не пройден\033\[0m"
} else {
    puts "\n\033\[32mТест пройден успешно\033\[0m"
}