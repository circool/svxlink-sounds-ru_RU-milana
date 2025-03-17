#!/usr/bin/env tclsh

# Загрузка библиотек
source "../procedures.tcl"


# Процедура для анализа аргументов и вызова соответствующей процедуры
proc runTests {args} {
	global argv

	# перечень единиц измерения и родов
	set validUnits { hour minute }
	set validGenders { male female neuter male_range female_range neuter_range}
	
	
	
	# проверяем количество аргументов
	# и выбираем куда их отправлять
	set argc [llength $args]
	
	if  {$argc == 1} {	
		# единственный аргумент - простое число мужского рода 
		playNumberUnit [lindex $args 0]
	
	} elseif  {$argc == 2} {
		# два аргумента - число плюс род или единица измерения
		set arg1 [lindex $args 0]
		set arg2 [lindex $args 1]
		
		# второй аргумент - род
		if { $arg2 in $validGenders} {
			# puts "arg2 is gender"
			playNumberUnit $arg1 $arg2	
		}

		# второй аргумент единица измерения
		if { $arg2 in $validUnits || [string match "unit_*" $arg2]} {
			
			playNumberUnit $arg1 $arg2
			playUnit $arg2 $arg1
		}
	} elseif {$argc == 3} {
		# три аргумента может быть как время, так и число-род-единица
		set arg1 [lindex $args 0]
		set arg2 [lindex $args 1]
		set arg3 [lindex $args 2]
			
		if {$arg3 == 12 || $arg3 == 24} {
			# если третий аргумент равен 12 или 24, вызываем playTime
			playTime $arg1 $arg2 $arg3
		} else {
			# иначе вызываем playNumberUnit + playUnit 
			playNumberUnit $arg1 $arg2
			playUnit $arg3 $arg2
		}


	} elseif {$argc == 5} {
		# Если пять аргументов, выводим фразу для MetarInfo
		set prefix [lindex $args 0]
		set value_from [lindex $args 1]
		set to [lindex $args 2]
		set value_to [lindex $args 3]
		set unit [lindex $args 4]

		playMsg "MetarInfo" $prefix
		playNumberUnit $value_from "[getGender $unit]_range"
		playMsg "MetarInfo" $to
		playNumberUnit $value_to "[getGender $unit]_range"
		playUnit "${unit}_range" $value_to

	} else {
		puts "\033\[31mНедостаточно аргументов ($argc) для выполнения сравнения\033\[0m"
		# puts "Использование: runTests.tcl <аргументы>"
		# puts "Возможные варианты:"
		# puts "1. Для чисел: <value> <gender>"
		# puts "2. Для времени: <hour> <minute> <format>"
		# puts "3. Для чисел с единицей измерения для MetarInfo: <value> <gender> <unit>"
		# puts "4. Для диапазона значений MetarInfo: <prefix> <value_from> <to> <value_to> <unit>"
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