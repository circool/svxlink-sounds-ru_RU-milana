#!/usr/bin/env tclsh
# Процедура для анализа аргументов и вызова соответствующей процедуры
proc runTests {args} {
	
	if {[info exists ::env(TEST_DEBUG_MODE)]} {
        set debugMode $::env(TEST_DEBUG_MODE)
    }
	
	source "./envs.tcl"
	source "./mocks.tcl"
	# Инициируем переменные и подключаем модули
	# global langdir
	# set langdir "../ru_RU"

	# MetarInfo
	# namespace eval MetarInfo {
	# 	# Объявляем переменную CFG_ID
	# 	variable CFG_ID
	# 	set CFG_ID "5";  

	# 	# Проверка наличия CFG_ID
	# 	if {![info exists CFG_ID]} {
	# 		puts "*** ERROR CFG_ID не объявлена в runTest"
	# 		return
	# 	}

	# 	#  langdir
	# 	variable langdir
	# 	set langdir "../ru_RU"

	# 	proc spellWord word {
	# 		playMsg $word
	# 	}
		
	# }
	# source "./MetarInfo.tcl"
	
	# Logic
	# namespace eval Logic {
	# 	variable CFG_TIME_FORMAT
	# 	variable CFG_PHONETIC_SPELLING 1
	# 	if {![info exists CFG_TIME_FORMAT]} {
	# 		set CFG_TIME_FORMAT 24
	# 	}
	# 	variable ::mycall "R2ADU"
	# 	variable CFG_TYPE "Simplex"
	# 	variable loaded_modules "ModuleEchoLink,ModuleFrn,ModuleMetarInfo,ModuleHelp,ModuleParrot"
	# 	variable list_languages {ru_RU en_EN}
		
	# }	
	# source "./Logic.tcl"

	# namespace eval Module {
	# 	variable activating_module 1
	# }
	# source "./Module.tcl"

	

	# Загрузка библиотек
	# 
	# set debugMode $::env(TEST_DEBUG_MODE)
	# source "./locale.tcl"
	# source "./fake_locale.tcl"
	
	# global argv
	# variable report_ctcss "88.5"
	# variable active_module "EchoLink"
	# variable loaded_modules "ModuleEchoLink,ModuleFrn,ModuleMetarInfo,ModuleHelp,ModuleParrot"
	# variable logic_name "Simplex"
	# set argc [llength $args]
	# set arg1 [lindex $args 0]
	
	# # Процедуры глобального пространства имен
	if {[info proc ::$arg1] ne ""} {
		::$arg1 {*}[lrange $args 1 end]	
		return
	}



	


	# Проверяем, принадлежит ли первый аргумент какому-либо из пространств имен
	set namespaces {CW DtmfRepeater EchoLink Frn Help Logic MetarInfo Module Parrot PropagationMonitor ReflectorLogic RepeaterLogic SelCall SelCallEnc TclVoiceMail Trx}
    foreach ns $namespaces {
        if {[info proc ${ns}::$arg1] ne ""} {
            # Если процедура найдена, вызываем её с оставшимися аргументами
			# puts "Call $ns $arg1 "
            ${ns}::$arg1 {*}[lrange $args 1 end]
            return
        }
    }

	puts "Не найдено соответствующих процедур для вызова теста \"$args\"."
	exit 0	
}

# Основная процедура
proc main {} {
	global argv
	runTests {*}$argv
}

# Вызов основной процедуры
main