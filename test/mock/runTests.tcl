#!/usr/bin/env tclsh
# Процедура для анализа аргументов и вызова соответствующей процедуры
proc runTests {args} {
	namespace eval MetarInfo {
		# Объявляем переменную CFG_ID
		variable CFG_ID
		set CFG_ID "5";  

		# Проверка наличия CFG_ID
		if {![info exists CFG_ID]} {
			puts "*** ERROR CFG_ID не объявлена в runTest"
			return
		}
	}
	namespace eval Logic {
		variable CFG_TIME_FORMAT
		if {![info exists CFG_TIME_FORMAT]} {
			set CFG_TIME_FORMAT 24
		}
	}
	
    
	
	# Загрузка библиотек
	source "../locale.tcl"
	source "../Logic.tcl"
	source "../MetarInfo.tcl"
	global argv
	set argc [llength $args]
	set arg1 [lindex $args 0]

	set namespaces {CW DtmfRepeater EchoLink Frn Help Logic MetarInfo Module Parrot PropagationMonitor ReflectorLogic RepeaterLogic SelCall SelCallEnc TclVoiceMail Trx}
	# Проверяем, принадлежит ли первый аргумент какому-либо из пространств имен
    foreach ns $namespaces {
        if {[info proc ${ns}::$arg1] ne ""} {
            # Если процедура найдена, вызываем её с оставшимися аргументами
            ${ns}::$arg1 {*}[lrange $args 1 end]
            return
        }
    }


	# перечень единиц измерения и родов
	set validUnits { hour minute }
	set validGenders { male female neuter male_range female_range neuter_range}

	

	

	# и выбираем куда их отправлять
	if {$argc == 1} {	
		set arg1 [lindex $args 0]
		
		# единственный аргумент - простое число мужского рода 
		playNumberUnit [lindex $args 0]

	} elseif  {$argc == 2} {
		# два аргумента - число плюс род или единица измерения
		# или сводка МЕТАР
		set arg1 [lindex $args 0]
		set arg2 [lindex $args 1]
		
		if {$arg1 == "spellNumber"} {
			spellNumber $arg2
		
		} elseif { $arg2 in $validGenders} {
			# второй аргумент - род
			# puts "arg2 is gender"
			playNumberUnit $arg1 $arg2;	
		} elseif { $arg2 in $validUnits || [string match "unit_*" $arg2]} {
			# второй аргумент единица измерения
			playNumberUnit $arg1 $arg2
			playUnit $arg2 $arg1
		}
	} elseif {$argc == 3} {
		# puts "argc == 3"
		
		# три аргумента может быть как время, так и число-род-единица
		set arg1 [lindex $args 0]
		set arg2 [lindex $args 1]
		set arg3 [lindex $args 2]
		
		if {$arg1 == "playTime"} {
			# если третий аргумент равен 12 или 24, вызываем playTime
			playTime $arg2 $arg3
		
		} elseif { [string is double -strict $arg1]} {
			# иначе вызываем playNumberUnit + playUnit 
			playNumberUnit $arg1 $arg2
			playUnit $arg3 $arg2
		}

	} else {
		puts "\033\[31mНедостаточно аргументов ($argc) для выполнения сравнения\033\[0m"
		exit 1
	}
}

# Основная процедура
proc main {} {
	global argv
	runTests {*}$argv
}

# Вызов основной процедуры
main