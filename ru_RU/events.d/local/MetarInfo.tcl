# @author vladimir@tsurkanenko.ru
# aka circool
# aka R2ADU


# MetarInfo
namespace eval MetarInfo {

  proc activating_module {} {
    # variable module_name;
    # Module::activating_module $module_name;
  }


  # Это "перегруженная" форма вызова playUnit которая использует текущее простаранство имен как первый параметр,
  # позволяя упростить вызов из текущего пространства, не указывая модуль из которого она вызывается
  #
  proc playUnit {value unit} {
    variable module_name;
    ::playUnit $module_name $value $unit;
  }

  # Процедура определения рода для единицы измерения
  proc getGender { unit } {
    # Проверяем единицы женского рода
    if {$unit eq "unit_mile"} {
      return "female"
    } elseif {$unit eq "unit_mph"} {
      return "female"
    }

    # Все остальные случаи - мужской род
    return "male"
  }


  # Обрабатывает строки с несколькими значениями, например пара значение-единица измерения
  proc handleMultiplyReports {args {anounce ""}} {
    
    # Если анонс не пустой, воспроизводим его
    if {$anounce ne ""} {
      playMsg $anounce
    }

    set i 0
    while {$i < [llength $args]} {
      set item [lindex $args $i]
      # За числом может идти единица измерения или какое-либо другое слово
      if {[regexp {\d+} $item]} {
        # Обработка числового значения
        set val $item
        incr i

        if {$i < [llength $args]} {
          set unit [lindex $args $i]

          # Устанавливаем gender в зависимости от значения unit
          if {[string match "unit_*" $unit]} {
            set gender [getGender $unit]
          } else {
            set gender "male"
          }

          playNumberRu $val $gender

          # Для слов выражающих единицу измерения
          if {[string match "unit_*" $unit]} {
            # Удаляем принудительно заданную логикой множественную форму
            if {[string index $unit end] eq "s"} {
              set unit [string range $unit 0 end-1]
            }
            playUnit $val $unit
          } else {
            # Вызываем playMsg для слов не выражающих единицы измерения
            playMsg $unit
          }
          incr i
        } else {
          playNumberRu $val "male"
        }
      } else {
        # Обработка нечисловых значений
        playMsg $item
        incr i
      }
    }
    playSilence 200
  }

  # Выделение из строки выражений [.._от] ... до ... [unit_единицы]
  proc split_string {input} {

    set pattern {([a-z]+_from\s\d+\s*to\s*\d+\s*unit_[a-z]+)}

    # Разбиваем строку на части
    set result [regexp -all -inline $pattern $input]
    puts "Результат разбивки: $result"
    # Если найдено совпадение
    if {[llength $result] > 0} {
      # Получаем основной блок
      set main_block [lindex $result 0]

      # Получаем текст до и после основного блока
      set before [string range $input 0 [expr {[string first $main_block $input] - 1}]]
      set after [string range $input [expr {[string first $main_block $input] + [string length $main_block]}] end]

      # Возвращаем результат в виде списка
      return [list $before $main_block $after]
    } else {
      return {}
    }
  }


  # Для улучшения восприятия для ходовых фраз подготовлены фразы вместо коипоновки отдельных слов

  # status_report


  # METAR as raw txt to make them available in a file


  # no airport defined
  proc no_airport_defined {} {
    playMsg "no_airport_defined";
    playSilence 200;
  }


  # no such airport
  proc no_such_airport {} {
    playMsg "no_such_airport";
    playSilence 200;
  }


  # METAR not valid
  proc metar_not_valid {} {
    playMsg "metar_not_valid";
    playSilence 200;
  }


  # MET-report TIME / Время отчета
  proc metreport_time item {
    # puts "metreport_time: $item"
    playMsg "metreport_time"
    scan [string range $item 0 1] %d hr
    scan [string range $item 2 3] %d mn
    playTime $hr $mn
    playSilence 200
  }


  # visibility / Видимость 5 километров 900 метров  (более чем ... )
  proc visibility args {
    # puts "visibility: $args"
    handleMultiplyReports $args "visibility"
  }


  # temperature
  proc temperature {temp} {
    # puts "temperature: $temp"
    playMsg "temperature"
    playSilence 100
    if {$temp == "not"} {
      playMsg "not"
      playMsg "reported"
    } else {
      if { int($temp) < 0} {
        playMsg "minus";
        set temp [string trimleft $temp "-"];
      }
      playNumberRu $temp "male"
      playUnit $temp "unit_degree"
    }
    playSilence 200
  }


  # dewpoint / Точка росы
  proc dewpoint {dewpt} {
    # puts "dewpoint: $dewpt"
    playMsg "dewpoint"
    playSilence 100
    if {$dewpt == "not"} {
      playMsg "not"
      playMsg "reported"
    } else {
      playNumberRu $dewpt "male"
      playUnit $dewpt "unit_degree"
    }
    playSilence 200
  }


  # sea level pressure
  proc slp {slp} {
    # puts "slp: $slp"
    playMsg "slp"
    playNumberRu $slp "male"
    playUnit $slp "unit_hPa"
    playSilence 200
  }

  # flightlevel
  proc flightlevel {level} {
    # puts "flightlevel: $level"
    playMsg "flightlevel"
    playNumberRu $level "male"
    playSilence 200
  }


  # No specific reports taken


  # peakwind
  proc peakwind {val} {
    # puts "peakwind: $val"
    playMsg "pk_wnd";
    playSilence 100;
    playNumberRu $val "male";
    playSilence 200;
  }


  # wind
  proc wind {deg {vel 0 } {unit 0} {gusts 0} {gvel 0}} {
    puts "wind: deg=$deg vel=$vel unit=$unit gusts=$gusts gvel=$gvel"
    set vel [scan $vel %d]
    set gusts [scan $gusts %d]

    playMsg "wind"
    if {$deg == "calm"} {
      playMsg "calm"
    } elseif {$deg == "variable"} {
      playMsg "variable"
      playSilence 200
      playNumberRu $vel "male"
      playUnit $vel $unit
    } else {
      # ветер ... м/сек на ... градусов
      playNumberRu $vel "male"
      playUnit $vel $unit
      playSilence 100

      playMsg "at"
      playSilence 100
      playNumberRu $deg "male"
      playUnit $deg "unit_degree"
      playSilence 100

      if {$gusts > 0} {
        playMsg "gusts_up"
        playNumberRu $gusts "male"
        playUnit $gusts $gvel
      }
    }
    playSilence 200
  }


  # weather actually
  # Несколько пар значений без анонса
  proc actualWX args {
    puts "actualWX: $args"
    handleMultiplyReports $args ""
  }

  # Диапазон значений от ... до ...
  # wind varies $from $to
  proc windvaries {from to} {
    puts "windvaries: $from $to"
    playMsg "wind"
    playSilence 50
    playMsg "varies_from"
    playSilence 100
    playNumberRu $from "male"
    playSilence 100
    playMsg "to"
    playSilence 100
    playNumberRu $to "male"
    playUnit $to "unit_degree"
    playSilence 200
  }


  # Peak WIND
  # Перегрузка peakwind?
  proc peakwind {deg kts hh mm} {
    puts "peakwind: $deg $kts $hh $mm"
    playMsg "pk_wnd"
    playMsg "from"
    playSilence 100
    playNumberRu $deg "male"
    playUnit $deg "unit_kt"
    playSilence 100

    playNumberRu $kts "male"
    playUnit $kts "unit_kt"
    playSilence 100

    playMsg "at"
    playTime $hh $mm

    playMsg "utc"
    playSilence 200
  }

  # Диапазон значений от ... до ...
  # ceiling varies $from $to
  proc ceilingvaries {from to} {
    puts "ceilingvaries $from $to"
    playMsg "ca"
    playSilence 50
    playMsg "varies_from"
    playSilence 100
    set from [expr {int($from) * 100}]
    playNumberRu $from "male"
    playSilence 100
    playMsg "to"
    playSilence 100
    set to [expr {int($to)*100}]
    playNumberRu $to "male"
    playUnit $to "unit_feet"
    playSilence 200
  }


  # airport is closed due to snow / Аэропорт закрыт из-за снега
  proc snowclosed {} {
    playMag "aiport_closed_due_to_sn";
    playSilence 200;
  }

  # RWY is clear / Все ВВП чисты (звучит ужасно)
  proc all_rwy_clear {} {
    playMsg "all_runways_clr";
    playSilence 200;
  }


  # runway visual range
  # Несколько аргументов без анонса
  proc rvr args {
    puts "rvr: $args"
    handleMultiplyReports $args ""
  }


  # airport is closed due to snow

  # RWY is clear

  # Runway designator

  # time
  proc utime {utime} {
    puts "utime: $utime"
    set hr [string range $utime 0 1]
    set mn [string range $utime 2 3]
    playTime $hr $mn
    playSilence 100
    playMsg "utc"
    playSilence 200
  }

  # vv100 -> "vertical view (ceiling) 1000 feet"
  proc ceiling {param} {
    puts "ceiling: $param"
    playMsg "ca"
    playSilence 100
    playNumberRu $param "male"
    playUnit $param "unit_feet"
    playSilence 200
  }

  # QNH
  proc qnh {value} {
    puts "qnh: $value"
    playMsg "qnh"
    playNumberRu $value "male"
    playUnit $value "unit_hPa"
    playSilence 200
  }

  # altimeter
  proc altimeter {value} {
    puts "altimeter: $value"
    playMsg "altimeter"
    playSilence 100
    playNumberRu $value "male"
    playUnit $value "unit_inch"
    playSilence 200
  }

  # trend

  # clouds with arguments
  proc clouds {obs height {cbs ""}} {
    # puts "clouds: $obs $height $cbs"
    playMsg $obs
    playSilence 100
    playNumberRu $height "male"
    playUnit $height "unit_feet"
    if {[string length $cbs] > 0} {
      playMsg $cbs
    }
    playSilence 200
  }

  # temporary weather obscuration


  # max day temperature
  proc max_daytemp {deg time} {
    # puts "max_daytemp: $deg $time"
    playMsg "predicted"
    playSilence 50
    playMsg "maximal"
    playSilence 50
    playMsg "daytime_temperature"
    playSilence 150
    playNumberRu $deg "male"
    playUnit $deg "unit_degree"
    playSilence 150
    playMsg "at"
    playSilence 50
    set hr [string range $time 0 1]
    set mn [string range $time 2 3]
    playTime $hr $mn
    playSilence 200
  }

  # min day temperature
  proc min_daytemp {deg time} {
    # puts "min_daytemp: $deg $time"
    playMsg "predicted"
    playSilence 50
    playMsg "minimal"
    playSilence 50
    playMsg "daytime_temperature"
    playSilence 150
    playNumberRu $deg "male"
    playUnit $deg "unit_degree"
    # speakNumber $deg "unit_degree"
    playSilence 150
    playMsg "at"
    playSilence 50
    set hr [string range $time 0 1]
    set mn [string range $time 2 3]
    playTime $hr $mn
    playSilence 200
  }

  # Maximum temperature in RMK section
  proc rmk_maxtemp {val} {
    # puts "rmk_maxtemp: $val"
    playMsg "maximal"
    playMsg "temperature"
    playMsg "last"
    playNumberRu 6 "male"
    playUnit 6 "hour"
    playSilence 50
    playNumberRu $val "male"
    playUnit $val "unit_degree"
    playSilence 200
  }

  # Minimum temperature in RMK section
  proc rmk_mintemp {val} {
    # puts "rmk_mintemp: $val"
    playMsg "minimal"
    playMsg "temperature"
    playMsg "last"
    playNumberRu 6 "male"
    playUnit 6 "hour"
    playSilence 50
    playNumberRu $val "male"
    playUnit $val "unit_degree"
    playSilence 200
  }

  # the begin of RMK section


  # RMK section pressure trend next 3 h
  proc rmk_pressure {val args} {
    # puts "rmk_pressure: val=$val args=$args"
    playMsg "pressure"
    playMsg "tendency"
    playMsg "next"
    playNumberRu 3 "male"
    playUnit 3 "hour"
    playSilence 50
    playNumberRu $val "male"
    playUnit $val "unit_mb"
    playSilence 200
    handleMultiplyReports $args ""
  }

  # precipitation last hours in RMK section
  proc rmk_precipitation {hour val} {
    # puts "rmk_precipitation: $hour $val"
    playMsg "precipitation"
    playMsg "last"
    playNumberRu $hour "male"
    playUnit $hour "hour"
    playSilence 50
    playNumberRu $val "male"
    playUnit $val "unit_inch"
    playSilence 200
  }

  # precipitations in RMK section
  proc rmk_precip {args} {
    # puts "rmk_precip: $args"
    handleMultiplyReports $args ""
  }

  # daytime minimal/maximal temperature
  proc rmk_minmaxtemp {max min} {
    # puts "rmk_precipitation: $max $min"
    playMsg "daytime"
    playMsg "temperature"
    playMsg "maximum"
    if { $max < 0} {
      playMsg "minus";
      set max [string trimleft $max "-"];
    }
    playNumberRu $min "male"
    playUnit $min "unit_degree"

    playMsg "minimum"
    if { $max < 0} {
      playMsg "minus";
      set max [string trimleft $max "-"];
    }
    playNumberRu $max "male"
    playUnit $max "unit_degree"
    playSilence 200
  }

  # recent temperature and dewpoint in RMK section
  proc rmk_tempdew {temp dewpt} {
    playMsg "re"
    playMsg "temperature"
    playNumberRu $temp "male"
    playUnit $temp "unit_degree"
    playSilence 200

    playMsg "dewpoint"
    playNumberRu $dewpt "male"
    playUnit $dewpt "unit_degree"
    playSilence 200
  }

  # wind shift
  proc windshift {val} {
    playMsg "wshft";
    playSilence 100;
    playMsg "at";
    playSilence 100;
    playNumberRu $val "male";
    playSilence 200;
  }


  # QFE value
  proc qfe {val} {
    playMsg "qfe"
    playNumberRu $val "male"
    playUnit $val "unit_hPa"
    playSilence 200
  }


  # runwaystate
  # runway 24 left wet_or_water_patches contamination 51 to 100 percent deposit_depth 1 unit_mms friction_coefficient 0.36
  proc runwaystate args {
    # puts "runwaystate: $args"
    handleMultiplyReports $args ""
  }


  # output numbers

  # output

  # part 1 of help #01

  # announce airport at the beginning of the MEATAR
  proc announce_airport {icao} {
    global langdir;

    playMsg "airport";
    playSilence 100;
    if [file exists "$langdir/MetarInfo/$icao.wav"] {
      playMsg $icao;
    } else {
      spellWord $icao;
    }

  }

  # say preconfigured airports

  #  global lang;

  # say clouds with covering


  # end of namespace

}
#
# This file has not been truncated
#
