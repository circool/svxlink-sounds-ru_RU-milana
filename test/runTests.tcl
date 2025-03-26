#!/usr/bin/env tclsh
# Процедура для анализа аргументов и вызова соответствующей процедуры
proc runTests {args} {
	
	if {[info exists ::env(TEST_DEBUG_MODE)]} {
        set debugMode $::env(TEST_DEBUG_MODE)
    }
	
	source "./envs.tcl"
	source "./mocks.tcl"
		
	if {[info proc ::$arg1] ne ""} {
		::$arg1 {*}[lrange $args 1 end]	
		return
	}

	# Проверяем, принадлежит ли первый аргумент какому-либо из пространств имен
	set namespaces {CW DtmfRepeater EchoLink Frn Help Logic MetarInfo Module Parrot PropagationMonitor ReflectorLogic RepeaterLogic SelCall SelCallEnc TclVoiceMail Trx}
    foreach ns $namespaces {
        if {[info proc ${ns}::$arg1] ne ""} {
            # Если процедура найдена, вызываем её с оставшимися аргументами
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