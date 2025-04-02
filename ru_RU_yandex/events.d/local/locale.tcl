###############################################################################
#
# Locale specific functions for playing back time, numbers and spelling words.
# Often, the functions in this file are the only ones that have to be
# reimplemented for a new language pack.
#
###############################################################################

#
# Spell the specified word using phonetic alphabet or plain letters depending
# on the setting of the PHONETIC_SPELLING configuration variable.
#
#   word -- The word to spell
#



proc spellWord {word} {
  variable Logic::CFG_PHONETIC_SPELLING
  set word [string tolower $word];
  for {set i 0} {$i < [string length $word]} {set i [expr $i + 1]} {
    set char [string index $word $i];
    if {[regexp {[a-z0-9]} $char]} {
      if {([info exists CFG_PHONETIC_SPELLING]) && \
          ($CFG_PHONETIC_SPELLING == 0)} {
        playMsg "Default" "$char";
      } else {
        playMsg "Default" "phonetic_$char";
      }
    } elseif {$char == "/"} {
      playMsg "Default" "slash";
    } elseif {$char == "-"} {
      playMsg "Default" "dash";
    } elseif {$char == "*"} {
      playMsg "Default" "star";
    }
  }
}


#
# Spell the specified number digit for digit
#
# This is a rather stupid function that just read out the digits one by one in
# a given number. There is no check that it's a valid number.
#
proc spellNumber {number} {
  for {set i 0} {$i < [string length $number]} {set i [expr $i + 1]} {
    set ch [string index $number $i];
    if {$ch == "."} {
      playMsg "Default" "decimal"
    } elseif {$ch == "+"} {
      playMsg "Default" "plus"
    } elseif {$ch == "-"} {
      playMsg "Default" "minus"
    } else {
      playMsg "Default" "$ch";
    }
  }
}


#
# Say the specified two digit number (00 - 99)
#
proc playTwoDigitNumber {number} {
  if {[string length $number] != 2} {
    puts "*** WARNING: Функция playTwoDigitNumber получила не двузначное число: $number";
    return;
  }
  
  set first [string index $number 0];
  if {($first == "0") || ($first == "o")} {
    playMsg "Default" $first;
    playMsg "Default" [string index $number 1];
  } elseif {$first == "1"} {
    playMsg "Default" $number;
  } elseif {[string index $number 1] == "0"} {
    playMsg "Default" $number;
  } else {
    playMsg "Default" "[string index $number 0]X";
    playMsg "Default" "[string index $number 1]";
  }
}


#
# Say the specified three digit number (000 - 999)
#
proc playThreeDigitNumber {number} {
  if {[string length $number] != 3} {
    puts "*** WARNING: Функция playThreeDigitNumber получила не трехзначное число: $number";
    return;
  }
  
  set first [string index $number 0];
  if {($first == "0") || ($first == "o")} {
    spellNumber $number
  } else {
    append first "00";
    playMsg "Default" $first;
    if {[string index $number 1] != "0"} {
      playMsg "Default" "and"
      playTwoDigitNumber [string range $number 1 2];
    } elseif {[string index $number 2] != "0"} {
      playMsg "Default" "and"
      playMsg "Default" [string index $number 2];
    }
  }
}



###############################################################################
#
# Русифицированные процедуры
#
###############################################################################
proc playNumber { number } {
	playNumberUnit $number "male"
}

proc playFrequency {fq} {
  if {$fq < 1000} {
    set unit "Hz"
  } elseif {$fq < 1000000} {
    set fq [expr {$fq / 1000.0}]
    set unit "kHz"
  } elseif {$fq < 1000000000} {
    set fq [expr {$fq / 1000000.0}]
    set unit "MHz"
  } else {
    set fq [expr {$fq / 1000000000.0}]
    set unit "GHz"
  }

  set fq_value [string trimright [format "%.3f" $fq] ".0"]
  playNumberWithUnit $fq_value $unit
#   playInit $unit $fq_value
}


proc playTime {hour minute } {
	variable Logic::CFG_TIME_FORMAT
  
	if {[info exists Logic::CFG_TIME_FORMAT]} {
		# Установить формат часа и время суток для 12-часового формата
		if {$CFG_TIME_FORMAT == 12} {
			if {$hour == 0} {
				set hour 12
				set ampm "AM"
			} elseif {$hour < 12} {
				set ampm "AM"
			} else {
				if {$hour > 12} {
					set hour [expr {$hour - 12}]
				}
				set ampm "PM"
			}
		}	
	}

	# Strip white space and leading zeros. Check ranges.
	if {[scan $hour "%d" hour] != 1 || $hour < 0 || $hour > 23} {
		error "playTime: Не цифровой час или значение вне диапазона: $hour"
	}
	if {[scan $minute "%d" minute] != 1 || $minute < 0 || $minute > 59} {
		error "playTime: Не цифровая минута или значение вне диапазона: $hour"
	}

	playNumberUnit $hour "hour"
	playUnit "hour" $hour

	if { $minute > 0 } {
		playNumberUnit $minute "minute"
		playUnit "minute" $minute
	} else {
		playMsg "Default" "equal"
	}
	
	if {$CFG_TIME_FORMAT == 12} {
		playMsg "Core" "$ampm"
	}
}

# разбивает число на составляющие, которые могут быть представлены базовыми единицами в диапазоне от 0 до 999 для целых чисел 
# или от 0 до 99 для дробных частей.
# отправляет их в playNumbers по очереди как количественно-именное сочетание
# Параметры:
# 	value 	- число (-999999.99 ... 999999.99) - именная часть
#	[unit]	- строка ( minute | hour | unit* ) - количественная часть
#	[unit]	- строка ( _range ) - признак винительного падежа (для количественной и именной частей)
# Описание логики
#  - для дробных чисел лидирующие нули целой части отбрасываются
#  - обрабатываются только 2 разряда дробной части
#  - для винительного падежа женский род применяется только для чисел заканчивающихся на "1"
proc playNumberUnit { value {unit ""} } {
	# числа произносим в модуле "Default"
	set modulename "Default"
	
	# для пар число + единица удаляем лидирующие нули для предотвращения интерпретации числа как восьмеричного
	set dangerous_units { hour minute }
	if { [string match "unit_*" $unit] || [string match "*_range" $unit] || $unit in $dangerous_units} {
		regsub {^0+(\d+)} $value {\1} value
		# puts "***DEBUG value=$value"
	}
	
	# валидные единицы
	if { ![string is double -strict $value] } {
		puts "\nERROR*** playNumberUnit получил недопустимое число ($value)"
		exit 1
	}
	



	# знак
	if {$value < 0} {
		playMsg "Default" "minus"
		# Убираем знак для дальнейшей обработки
		set value [expr {abs($value)}]
	}

	


	# нулевая целая часть 
	set isZeroIntegerPart [expr {$value < 1}]

	# тысячи
	set thousands [expr {int($value / 1000)}]	
	if {$thousands > 0} {		
		# винительный падеж
		if { [string match "*_range" $unit] } {
			set units "thousand_range"
		} else {
			set units "thousand"
		}
		playNumbers $thousands $units
		set value [expr {$value - $thousands * 1000}]
	}
	# из value были удалены тысячи

	# целые (от 1 до 999)
	# puts "начало проверки целых"
	set integerPart [expr {int(floor($value))}]
	if {$integerPart > 0} {	
		# произносим количество диапазона 1-999,
		# если дробной части нет, склоняем его к единице измерения
		# иначе склоняем к слову "целых/целая"
		if {$value != int($value)} {
						
			if { [string match "*_range" $unit] } {
				# винительный падеж
				playNumbers $integerPart "integer_range"
			} else {
				# именительный падеж
				playNumbers $integerPart "integer"
			}

		} else {
			playNumbers $integerPart $unit
		}
		# удаляем целую часть и форматируем		
		set value [format %.2f [expr {$value - $integerPart}]]		
	}
	# из value удалена целая часть, остаток отформатирован до 2 знака после точки
	
	# дробная часть
	# Если ноль в целой части, нет тысяч, произносим "ноль" или [от] "ноля"
	# работает как для винительного, так и для именительного падежа
	if { $isZeroIntegerPart} {
		set actualUnit "integer"
		if { [string match "*_range" $unit] } {
			# винительный падеж		
			set actualUnit "integer_range"
		}
		set suffix [getNumberSuffix "0" $actualUnit]
		playMsg "Default" "0${suffix}"
	}
	
	if { $value > 0} {
		
		# произношение "целых" для чисел с нулевой целой частью проверено - работает как для винительного, так и для именительного падежа
		if { $isZeroIntegerPart || $integerPart==0 } {		
			if { [string match "*_range" $unit] } {
				# винительный падеж
				set suffix [getUnitSuffix "integer_range" "0" ]
			} else {
				# именительный падеж
				set suffix [getUnitSuffix "integer" "0" ]
			}
			playMsg "Default" "integer${suffix}"			
		}

		playMsg "Default" "and"

		# тут произносятся числа (десятых и сотых) долей
		if { [string match "*_range" $unit] } {
			# винительный падеж
			if {[expr {abs($value - [format %.1f $value]) < 0.0001}]} {
				playNumbers [expr {int([format %.1f $value] * 10)}] "tenth_range"
			} else {
				playNumbers [expr {int([format %.2f $value] * 100)}] "hundredth_range"
			}
			
		} else {
			
			# именительный падеж
			if {[expr {abs($value - [format %.1f $value]) < 0.0001}]} {
				playNumbers [expr {int([format %.1f $value] * 10)}] "tenth"
			} else {
				playNumbers [expr {int([format %.2f $value] * 100)}] "hundredth"
			}
		}		
	}
}

# Процедура для воспроизведения числа (беэ единицы измерения)
# locale.tcl
# Воспроизведение количества value в диапазоне (0-999)
# единица измерения unit служит только для определения рода/склонения и не произносится
# исключение - тысячи, целые, десятые, сотые
proc playNumbers {value {unit ""} } {

	# для тестов.
	set modulename "Default"


	# Ошибка для чисел вне рабочего диапазона
	if {!([string is integer -strict $value] && $value <= 999) } {
		puts "ERROR*** playNumbers получил недопустимое число ($value)"
		return
	}

	# определяем какие единицы произносить после числа (тысячи, целые, десятые, сотые и их сочетания с _range)
	set validUnits { thousand integer tenth hundredth thousand_range integer_range tenth_range hundredth_range}
	
	# работаем с сотнями
	set hundreds [expr {$value / 100}]
	if { $hundreds > 0} {
		if { [string match "*_range" $unit] } {
			playMsg "Default" "${hundreds}00[getNumberSuffix $value $unit]"
		} else { 
			playMsg "Default" "${hundreds}00"
		}
		# удаляем сотни
		set value [expr {$value - $hundreds * 100}]
	}


	# работаем с десятками (только если число заканчивается на 20+)
	set tens [expr {$value / 10}]
	if {$tens >= 2} {
		#  для винительного падежа выясняем суффикс исходя из десятки * 10
		if { [string match "*_range" $unit] } {
			set tensValue [expr {$tens * 10}]
			playMsg "Default" "${tens}X[getNumberSuffix $tensValue $unit]"
		} else {
			playMsg "Default" "${tens}X"
		}
		# удаляем десятки
		set value [expr {$value - $tens * 10}]
	}

	

	# работаем с единицами (от 1 до 19)
	if {$value > 0} {
		set suffix [getNumberSuffix $value $unit]
		playMsg "Default" "${value}${suffix}"
	}



	# работаем с именной частью
	if { $unit in $validUnits && ($value > 0 || $tens > 0 || $hundreds > 0) } {
		
		# отделяем range от основной части
		set mainUnit [string map {"_range" ""} $unit]
		set suffix [getUnitSuffix $unit $value]
		set suffix_range [getUnitSuffix $mainUnit $value]
		if {[string match "*_range" $unit]} {
			# puts "\nDEBUG ошибка в единице $unit"
			set unit [string map {"_range" ""} $unit]
		}
		playMsg "Default" "${unit}${suffix}"
	}
}


# Воспроизведение единицы измерения unit в правильном падеже и количественной форме
# количественная quantity часть служит для определения единственной или
# множественной формы именной части и не произносится
proc playUnit { unit quantity } {
	# puts "***DEBUG playUnit: unit=$unit quantity=$quantity"
	set modulename [getModuleName $unit]
	# удалить лидирующие нули из количества
	regsub {^0+(\d+)} $quantity {\1} quantity
	# puts "***DEBUG playUnit: unit=$unit quantity=$quantity"

	# специальная логика для винительного падежа
	if { [string match "*_range" $unit] } {		

		# для целых тысяч, единицей измерения выступает "тысяча/тысячи/тысяч"
		# встречается только в винительном падеже, поэтому устанавливаем падеж принудительно и произносим полученную единицу
		if {$quantity >= 1000 } {
			set unit [string map {"_range" ""} $unit]
			playMsg $modulename "${unit}2"
			return
		}	
		
		# для дробных чисел склонение нужно приводить относительно слов "десятая" или "сотая"
		set integerPart [expr {int($quantity)}]
		set fractial [expr {$quantity - $integerPart}]
		if { $fractial != 0 } {
			set unit [string map {"_range" ""} $unit]
			playMsg $modulename "${unit}1"
			return
		}
	}

	# для дробных чисел используются только
	# именные сочетания для множественной формы именительного или винительного падежа
	if { [expr {$quantity != int($quantity)}] } {		
		set quantity 2
	}
	
	# получаем базовое числительное
	set numeral [getNumeral $quantity]
	# puts "***DEBUG playUnit: numeral=$numeral quantity=$quantity"
	# если в unit есть "_range", получаем суффикс, посе чего удаляем "_range" из $unit и произносим полученную единицу
	if {[string match "*_range" $unit]} {
		set suffix [getUnitSuffix $unit $numeral]
		set unit [string map {"_range" ""} $unit]
	} else {
		set suffix [getUnitSuffix $unit $numeral]	
	}

	playMsg $modulename "${unit}${suffix}"
}

# Возвращает род единицы измерения 
# если вместо единицы измерения получен род или диапазон - возвращается без изменений
proc getGender {unit} {
	# определяем список единиц женского рода и список простых родов
	set femaleUnits { el_connected_station female unit_mile unit_mph thousand integer tenth hundredth minute }
	set genders {male female neuter}
	
	# для винительного падежа или рода возвращаем без изменения
	if { [string match "*_range" $unit] || ($unit in $genders) } {
		return $unit
	} 
	
	# для единиц измерения формируем род (мужской или женский)
	if { $unit in $femaleUnits } {
		return "female"
	} else {
		return  "male"
	}
}

# для аргументов с префиксом "unit_" возвращает "MetarInfo", для остальных - "Default"
proc getModuleName {unit} {
	# puts "DEBUG: getGender: Получен аргумент $unit"
	if {[string match "unit_*" $unit] } {
		set result "MetarInfo"
	} elseif {[string match "el_*" $unit]} {
		set result "EchoLink"
	} elseif {[string match "frn_*" $unit]} {
		set result "Frn"
	} else {
		set result "Default"
	}
	return $result
}


# определяем склонение единицы измерения или именной части количественно-именного сочетания
proc getUnitSuffix {unit quantity} {

	# эти всегда склоняются в единственном или множественном числе
	set numeralUnits { integer integer_range tenth tenth_range hundredth hundredth_range minute_range hour_range } 
	set quantity [getNumeral $quantity]
		
	# всегда склоняются в единственном или множественном числе
	if {$unit in $numeralUnits } {		
		if { [string match "*_range" $unit] } {
			# винительного падежа
			if {$quantity == 1} {
				# единственной формы
				return "2"
			} else {
				# множественной формы
				return "1"
			}
		} else {
			# именительного падежа
			if {$quantity == 1} {
				# единственной формы
				return ""
			} else {
				# множественной формы для остальных
				return "1"
			}
		}	
	}

	# винительный падеж для числовых единиц, склоняемых в зависимости от количества в именительном падеже
	if { [string match "*_range" $unit] } {
		if {$quantity == 1} {
			return "1"
		} else {
			# это множественная форма -> 1
			return "2"
		}
	}
	
	# остальное (склоняется в зависимости от количества 1, 2-4, 5-19) 
	if {$quantity == 1} {
		return ""
	} elseif {$quantity >= 2 && $quantity <= 4} {
		return "1"
	} else {
		return "2"
	}
}


proc getNumeral {value} {
	# удаляем минус
	set value [expr {abs($value)}]
	
	# если есть тысячи, проверить есть ли единицы/десятки/сотни.
	# если есть, считаем по ним, если только тысячи, считаем по тысячам
	if {$value >= 1000} {
		# Разделяем число на тысячи и остаток
		set thousands [expr {$value / 1000}]
		set remainder [expr {$value % 1000}]

		if {$remainder == 0} {
			# Если остаток равен нулю, возвращаем только количество тысяч
			# set value $thousands

			# круглые тысячи возвращаем полностью (для склонений целых тысяч)
			return $value
		} else {
			# Если остаток не равен нулю, возвращаем только остаток
			set value $remainder
		}
	}
	
	# убеждаемся что получилось меньше тысячи
	if { $value >= 1000 } {
		puts "ERROR*** getNumeral получил недопустимое число ($value)"
		# Прерываем выполнение
		return
	}

	# приводим результат как число от 0 до 19
	# для дробных чисел используем количество сотых долей
	set integerPart [expr {int($value)}]
	set fractial [expr {$value - $integerPart}]
	if { $fractial != 0 } {
		set value [expr {int($fractial*100)}]
	}	
	set tens [expr {$value % 100}]
	return [expr {$tens > 19 ? $tens % 10 : $tens}]	
}

# для именительного падежа женский род применяется для чисел заканчивается на "1" или "2"
# для винительного падежа женский род применяется только для чисел заканчивающихся на "1"
proc getNumberSuffix {quantity unit} {
	
	# приводим количество к диапазону 0-19
	set quantity [getNumeral $quantity]
	# получаем род именного сочетания
	set gender [getGender $unit]
	set mainUnit [string map {"_range" ""} $unit]
	set mainGender [getGender $mainUnit]
	
	# для винительного падежа женский род применяется только для чисел заканчивающихся на "1"
	if { [string match "*_range" $gender] } {
		# puts "\nDEBUG getNumberSuffix: quantity=$quantity gender=$gender mainGender=$mainGender"
		if { ($quantity ==1) && [string match "female*" $mainGender]  } {
			# это единица женского рода
			return "fs"
		} else {
			return "s"
		}
	}
	
	# для среднего рода 
	if { $quantity ==1  && [string match "neuter" $gender] } {
		return "o"
	}

	# для женского рода, если заканчивается на "1" или "2"
	if { ($quantity == 1 || $quantity == 2) && [string match "female*" $gender] } {
		return "f"
	}
	
	# для остального - мужской род именительного падежа
	return ""

}

# воспроизведение пары число - единица измерения
proc playNumberWithUnit {number unit} {
	playNumberUnit $number $unit
	playUnit $unit $number
}


