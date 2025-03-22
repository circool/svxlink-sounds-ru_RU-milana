#!/usr/bin/env tclsh

# CUT UP WHEN DEBUG IS DONE ============================================================== <<<
###############################################################################
#
# MetarInfo module event handlers
#
###############################################################################

#
# This is the namespace in which all functions and variables below will exist.
# The name must match the configuration variable "NAME" in the
# [ModuleMetarInfo] section in the configuration file. The name may be changed
# but it must be changed in both places.
#
namespace eval MetarInfo {

#
# Check if this module is loaded in the current logic core
#
if {![info exists CFG_ID]} {
  # puts "*** ERROR CFG_ID не существует "
  return;
}


#
# Extract the module name from the current namespace
#
set module_name [namespace tail [namespace current]];


#
# An "overloaded" playMsg that eliminates the need to write the module name
# as the first argument.
#
proc playMsg {msg} {
  variable module_name;
  ::playMsg $module_name $msg;
}


#
# A convenience function for printing out information prefixed by the
# module name
#
proc printInfo {msg} {
  variable module_name;
  puts "$module_name: $msg";
}


#
# Executed when this module is being activated
#
proc activating_module {} {
  variable module_name;
  Module::activating_module $module_name;
}


#
# Executed when this module is being deactivated.
#
proc deactivating_module {} {
  variable module_name;
  Module::deactivating_module $module_name;
}


#
# Executed when the inactivity timeout for this module has expired.
#
proc timeout {} {
  variable module_name;
  Module::timeout $module_name;
}


#
# Executed when playing of the help message for this module has been requested.
#
proc play_help {} {
  variable module_name;
  Module::play_help $module_name;
}


#
# Executed when the state of this module should be reported on the radio
# channel. Typically this is done when a manual identification has been
# triggered by the user by sending a "*".
# This function will only be called if this module is active.
#
proc status_report {} {
  printInfo "status_report called...";
}


# METAR as raw txt to make them available in a file
proc metar {input} {
  set fp [open "/tmp/metar" w];
  puts $fp $input;
  close $fp
}


# no airport defined
proc no_airport_defined {} {
   playMsg "no";
   playMsg "airport";
   playMsg "defined";
   playSilence 200;
}


# no airport defined
proc no_such_airport {} {
   playMsg "no";
   playMsg "such";
   playMsg "airport";
   playSilence 200;
}


# METAR not valid
proc metar_not_valid {} {
  playMsg "metarinformation";
  playMsg "not";
  playMsg "valid";
   playSilence 200;
}


# MET-report TIME +
proc metreport_time {item} {
   # Проверка, что аргумент содержит ровно 4 цифры
    if {![string is digit $item] || [string length $item] != 4} {
        puts "*** ERROR: metreport_time: Аргумент должен содержать ровно 4 цифры"
        return
    }
   
   playMsg "metreport_time";
   
   set part1 [string range $item 0 1]  
   set part2 [string range $item 2 3]  
   
   # удаляем лидирующие нули (но не более одного!)
   regsub {^0(\d)} $part1 {\1} part1
   regsub {^0(\d)} $part2 {\1} part2
   playTime $part1 $part2;
   playSilence 200;
}


# visibility +
# переменная suffix инициируется пустым значением
# допускается 2 и более аргументов
# все аргументы (arg_1...arg_n) с строковым содержимым обрабатываются командой [playMsg arg_n];
# если в таких аргументах встречается сочетание "*_than" (например "more_than" или "less_than"), переменная suffix получает значение "_range"
# если arg_n имеет числовое значение (целое или дробное), проверяется arg_n+1, и если arg_n+1 это строка соответствующая шаблону "unit_*", 
# выполняется [playNumberUnit arg_n "${arg_n+1}suffix"; playUnit "${arg_n+1}suffix" arg_n]
#  если arg_n+1 отсутствует или не подпадает под шаблон, выполняется [playNumberUnit arg_n "male$suffix"] и обработка продолжается с следующего аргумента 
proc visibility {args} {
    
    set argc [llength $args]
    
    if {$argc < 2} {
        puts "*** ERROR: MetarInfo::visibility: Недостаточно аргументов"
        return
    }
    playMsg "visibility"
    set suffix ""
    
    for {set i 0} {$i < $argc} {incr i} {
        set arg [lindex $args $i]
        
        # Если аргумент числовой
        if {[string is double -strict $arg]} {
            
            # получаем следующий аргумент
            set next_arg [lindex $args [expr {$i + 1}]]
            
            # Если следующий аргумент соответствует шаблону "unit_*"
            if {[string match "unit_*" $next_arg]} {               
                
                # для множественного числа удаляем признак ("s")
                if {[string index $next_arg end] eq "s"} {
                    set next_arg [string range $next_arg 0 end-1]
                }
                # удалить лидирующие нули перед произношением чисел
                # regsub {^0+(\d+)} $arg {\1} arg 
                
                playNumberUnit $arg "${next_arg}$suffix"
                playUnit "${next_arg}$suffix" $arg
                
                # Пропускаем следующий аргумент, так как он уже обработан
                incr i  ; 
            
            } else {
                
                # Если следующий аргумент не соответствует шаблону или отсутствует
                playNumberUnit $arg "male$suffix"
            }
        } else {
            # Если аргумент не числовой, считаем его строкой
            if {[string match "*_than" $arg]} {
                # Если строка содержит "_than"
                set suffix "_range"
            }
            playMsg $arg
        }
    }
    playSilence 200
}



# temperature +
proc temperature {temp} {
  playMsg "temperature";
  # playSilence 100;
  if {$temp == "not"} {
    playMsg "not";
    playMsg "reported";
  } else {
    playNumberUnit $temp "unit_degree";
    playUnit "unit_degree" $temp;
    # playSilence 100;
  }
  playSilence 200;
}


# dewpoint +
proc dewpoint {dewpt} {
  playMsg "dewpoint";
  # playSilence 100;
  if {$dewpt == "not"} {
    playMsg "not";
    playMsg "reported";
  } else {
    playNumberUnit $dewpt "unit_degree";
    playUnit "unit_degree" $dewpt;
    # playSilence 100;
  }
  playSilence 200;
}


# sea level pressure +
proc slp {slp} {
  playMsg "slp";
  playNumberUnit $slp "unit_hPa";
  playUnit "unit_hPa" $slp;
  playSilence 200;
}


# flightlevel
proc flightlevel {level} {
  playMsg "flightlevel";
  spellNumber $level;
  playSilence 200;
}


# No specific reports taken
proc nospeci {} {
  playMsg "nospeci";
  playSilence 100;
}


# peakwind
proc peakwind1 {val} {
  playMsg "pk_wnd";
  # playSilence 100;
  # удаляем лидирующие нули поскольку передаем число без указания единиц
  regsub {^0+(\d+)} $val {\1} val
  playNumberUnit $val "male";
  playSilence 200;
}


# wind
proc wind {deg {vel 0 } {unit 0} {gusts 0} {gvel 0}} {
  # puts "\nПолучено deg=$deg vel=$vel unit=$unit gusts=$gusts gvel=$gvel"
  playMsg "wind";
  
  # удалить множественный признак для е/и кроме unit_mps
  if {$unit ne "unit_mps"} {
    set unit [string trimright $unit "s"]
    set gvel [string trimright $gvel "s"]
  }
  
  # if {$vel > 0} {
  #   regsub {^0+(\d+)} $vel {\1} vel
  # }

  if {$deg == "calm"} {
    playMsg "calm";
  } elseif {$deg == "variable"} {
    playMsg "variable";
    # playSilence 200;
    
    playNumberUnit $vel $unit;
    playUnit $unit $vel ;
  } else {
    # regsub {^0+(\d+)} $deg {\1} deg
    playMsg "at"
    playNumberUnit $deg "unit_degree";
    playUnit "unit_degree" $deg;
    playSilence 100;
    playMsg "wspd";
    # playSilence 100;
    playNumberUnit $vel $unit;
    playUnit $unit $vel ;
    

    if {$gusts > 0} {
      playSilence 100;
      playMsg "gusts_up";
      # regsub {^0+(\d+)} $gusts {\1} gusts
      playNumberUnit $gusts "${gvel}_range";
      playUnit "${gvel}_range" $gusts;
    }
  playSilence 200;
  }
}


# weather actually
proc actualWX args {
  foreach item $args {
    if [regexp {(\d+)} $item] {
      playNumber $item;
    } else {
      playMsg $item;
    }
  }
  playSilence 200;
}


# wind varies $from $to
proc windvaries {from to} {
   playMsg "wind";
   playSilence 50;
   playMsg "varies_from";
   playSilence 50;
   
  #  regsub {^0+(\d+)} $from {\1} from
  #  regsub {^0+(\d+)} $to {\1} to

   playNumberUnit $from "unit_degree_range";
   playSilence 50;

   playMsg "to";
  #  playSilence 50;
   playNumberUnit $to "unit_degree_range";

   playUnit "unit_degree" $to;
   playSilence 200;
}


# Peak WIND +? это пиковый ветер 280 градусов со скоростью 32 узла, зарегистрированный на [HH часов] mm минут
proc peakwind {deg kts hh mm} {
  playMsg "pk_wnd";
  # 
  #  playMsg "dir";
  #  playSilence 100;
   playMsg "at";
   playNumberUnit $deg "unit_degree";
   playUnit "unit_degree" $deg;
   playSilence 100;
  #  playMsg "from";
   playMsg "with_speed";
   playNumberUnit $kts "unit_kt";
   playUnit "unit_kt" $kts;
   playSilence 100;
   
   playMsg "fixed_at";
   if {$hh != "XX"} {
      playNumberUnit $hh "hour";
      playUnit "hour" $hh;
      
    }
  #  playMsg "pk_wnd";
   playNumberUnit $mm "minute";
   playUnit "minute" $mm;
  playMsg "utc";

   playSilence 200;
}


# ceiling varies $from $to
proc ceilingvaries {from to} {
   playMsg "ca";
   playSilence 50;
   playMsg "varies_from";
   playSilence 100;
   set from [expr {int($from) * 100}];
   playNumberUnit $from "unit_feet_range";
   playSilence 100;

   playMsg "to";
   playSilence 100;
   set to [expr {int($to)*100}];
   playNumberUnit $to "unit_feet_range";

   playUnit "unit_feet_range" $to;
   playSilence 200;
}

# runway visual range
proc rvr args {
   playMsg "rwy";
   foreach item $args {
     if [regexp {(\d+)} $item] {
      #  sayNumber $item;
      playNumberUnit $item "male_range";
     } else {
       playMsg $item;
     }
     playSilence 100;
   }
   playSilence 200;
}


# airport is closed due to snow
proc snowclosed {} {
  #  playMag "aiport";
  #  playMag "closed";
  #  playMsg "due_to"
  #  playMsg "sn";
   playMsg "airport_closed_due_to_sn"
   playSilence 200;
}


# RWY is clear
proc all_rwy_clear {} {
  # playMsg "all";
  # playMsg "runways";
  # playMsg "clr";
  playMsg "all_runways_clr";
  playSilence 200;
}


# Runway designator
proc runway args {
  foreach item $args {
    if [regexp {(\d+)} $item] {
      playNumberUnit $item "male";
    } else {
      playMsg $item;
    }
    playSilence 100;
  }
  playSilence 200;
}


# time
proc utime {utime} {
   
   set part1 [string range $utime 0 1]  
   set part2 [string range $utime 2 3]  

   playTime $part1 $part2;
   
   playSilence 100;
   playMsg "utc";
   playSilence 200;
}


# vv100 -> "vertical view (ceiling) 1000 feet"
proc ceiling {param} {
   playMsg "ca";
   playSilence 100;
   playNumberUnit $param "unit_feet";
   playSilence 100;
   playUnit "unit_feet" $param
   playSilence 200;
}


# QNH
proc qnh {value} {
  playMsg "qnh"; 
  playNumberUnit $value "unit_hPa";
  playUnit "unit_hPa" $value;
  playSilence 200;
}


# altimeter
proc altimeter {value} {
  playMsg "altimeter";
  playSilence 100;
  playNumberUnit $value "unit_inch";
  playUnit "unit_inch" $value;
  playSilence 200;
}


# trend
proc trend args {
  playMsg "trend";
  foreach item $args {
    playMsg $item;
    playSilence 100;
  }
  playSilence 200;
}


# clouds with arguments
proc clouds {obs height {cbs ""}} {
  # playMsg "clouds"
  playMsg $obs;
  if {[string length $cbs] > 0} {
    playMsg $cbs;
  }
  # playSilence 100;
  playMsg "altimeter"
  playNumberUnit $height "unit_feet";
  #playSilence 100;
  playUnit "unit_feet" $height;
 
  playSilence 200;
}


# temporary weather obscuration
proc tempo_obscuration {from until} {
  playMsg "tempo";
  playSilence 100;
  playMsg "obsc";
  playSilence 200;
  playMsg "from";
  playNumberUnit $from "male_range";
  playSilence 200;
  playMsg "to";
  playSilence 100;
  playNumberUnit $until "male_range";
  playSilence 200;
}


# max day temperature
proc max_daytemp {deg time} {
  playMsg "predicted";
  playSilence 50;
  playMsg "maximal";
  playSilence 50;
  playMsg "daytime_temperature";
  playSilence 150;
  playNumberUnit $deg "unit_degree";
  playUnit "unit_degree" $deg;
  playSilence 150;
  playMsg "at";
  playSilence 50;
  
  # regsub {^0(\d)} $time {\1} time
  playNumberUnit $time "hour";
  playUnit "hour" $time
  playSilence 200;
}


# min day temperature




proc min_daytemp {deg time} {
  playMsg "predicted";
  playSilence 50;
  playMsg "minimal";
  playSilence 50;
  playMsg "daytime_temperature";
  playSilence 150;
  playNumberUnit $deg "unit_degree";
  playUnit "unit_degree" $deg;
  
  playSilence 150;
  playMsg "at";
  playSilence 50;
  # regsub {^0(\d)} $time {\1} time
  playNumberUnit $time "hour";
  playSilence 200;
}


# Maximum temperature in RMK section
proc rmk_maxtemp {val} {
  playMsg "maximal";
  playMsg "temperature";
  playMsg "for";
  playMsg "last1";
  playNumberUnit 6 "hour";
  playUnit "hour" 6;
  # if {$val < 0} {
  #   playMsg "minus";
  # }
  playNumberUnit $val "unit_degree";
  playUnit "unit_degree" $val;
  playSilence 200;
}


# Minimum temperature in RMK section
proc rmk_mintemp {val} {
  playMsg "minimalf";
  playMsg "temperature";
  playMsg "at"
  playMsg "last1";
  playNumberUnit 6 "hour";
  playUnit "hour" 6;
  playNumberUnit $val "unit_degree";
  playUnit "unit_degree" $val;
  playSilence 200;
}


# the begin of RMK section
proc remarks {} {
  playSilence 200;
  playMsg "remarks";
  playSilence 200;
}


# RMK section pressure trend next 3 h
proc rmk_pressure {val args} {
  playMsg "tendency";
  playMsg "at"
  playMsg "next1";
  playNumberUnit 3 "hour";
  playUnit "hour" 3;
  # playSilence 150;
  playMsg "pressure";
  playNumberUnit $val "unit_mb";
  playUnit "unit_mb" $val;
  # playSilence 150;
  # playMsg "unit_mbs";
  # playSilence 250;

  foreach item $args {
     if [regexp {(\d+)} $item] {
       sayNumber $item;
     } else {
       playMsg $item;
     }
    #  playSilence 100;
  }
  playSilence 200;
}


# precipitation last hours in RMK section
proc rmk_precipitation {hour val} {
  playMsg "precipitation";
  if {$hour == 1 } {
    playMsg "last";  
  } else {
    playMsg "last1";
  }
  
  # regsub {^0(\d)} $hour {\1} hour
  playNumberUnit $hour "hour";
  playUnit "hour" $hour;

  # playSilence 150;
  playNumberUnit $val "unit_inch";
  playUnit "unit_inch" $val;
  playSilence 200;
}

# precipitations in RMK section
proc rmk_precip {args} {
  playMsg "re";
  foreach item $args {
     if [regexp {(\d+)} $item] {
       sayNumber $item;
     } else {
       playMsg $item;
     }
     playSilence 100;
  }
  playSilence 200;
}


# daytime minimal/maximal temperature
proc rmk_minmaxtemp {max min} {
  playMsg "maximum";
  playMsg "daytime";
  playMsg "temperature";
  
  # if { $max < 0} {
  #    playMsg "minus";
  #    set max [string trimleft $max "-"];
  # }
  playNumberUnit $min "unit_degree";
  playMsg "unit_degree" $min;

  # playMsg "minimum";
  # if { $min < 0} {
  #    playMsg "minus";
  #    set min [string trimleft $min "-"];
  # }
  playNumberUnit $max "unit_degree";
  playMsg "unit_degree" $max;
  playSilence 200;
}


# recent temperature and dewpoint in RMK section
proc rmk_tempdew {temp dewpt} {
  
  playMsg "re";
  
  playMsg "temperature";
  playNumberUnit $temp "unit_degree";
  playUnit "unit_degree" $temp  ;
  # playSilence 200;
  # playMsg "and"
  playMsg "dewpoint";
  playNumberUnit $dewpt "unit_degree";
  playUnit "unit_degree" $dewpt;
  playSilence 200;
}


# wind shift
proc windshift {val} {
  playMsg "wshft";
  playSilence 100;
  playMsg "in";
  playSilence 100;
  
  playNumberUnit $val "hour";
  playUnit "hour" $val
  
  playSilence 200;
}

# QFE value
proc qfe {val} {
  playMsg "qfe";
  playNumberUnit $val "unit_hPa";
  playUnit "unit_hPa" $val;
  playSilence 200;
}


# Пример: runwaystate runway 06 center damp contamination 51 to 100 percent deposit_depth less_than 1 unit_mm  friction_coefficient 0.45

# Начало пврвметров всегда (1-2- и возможно 3-й аргументы): runway 06 или runway 06 center
# блок по паттерну "runway" "число" "[center|left|right]"
# обрабатывать так:
# playMsg "runway"
# SpeelNumber "число"
# Если есть [center|left|right] -> playMsg center|left|right -> перейти к 4-му параметру, если нет - к 3-му
#
# Последующие параметры:  
# блоки по патерну  ("less_or_equal" или "less") "10" "percent"
# обрабатывать так:
# playMsg "less_or_equal" или "less"
# playNumberUnit 10 "percent_range";
# playUnit "percent_range" 10;

# блоки по патерну "51" "to" "100" "percent"
# обрабатывать так:

# playNumberUnit 51 "percent_range";
# playMsg "to"
# playNumberUnit 100 "percent_range";
# playUnit "percent_range" 100;

# если за числом идет параметр начинающийся на "unit_", вызывать блок 
# блоки по патерну [число] "unit_*" 
# обрабатывать так:
# playNumberUnit $число "unit_*";
# playUnit "unit_*" $число;

# блоки до/после паттерна обрабатывать так:
# если параметр это слово, вызывать playMsg
# runwaystate
# proc runwaystate args {
    
#     set len [llength $args]
#     set i 0
#     while {$i < $len} {
#         set current [lindex $args $i]
        
#         # Паттерн ВВП \d\d
#         if {[string match "runway" $current] && $i + 1 < $len} {
#           set unit [lindex $args $i+1]
#           playMsg "runway"
#           spellNumber $unit
#           incr i 3
#         }


#         # Паттерн 1: "less_or_equal"/"less" + число + ("unit_*" или "percent")
#         if {[string match "less*" $current] && $i + 2 < $len} {
#             set num [lindex $args $i+1]
#             set unit [lindex $args $i+2]
#             if {[string is integer -strict $num] && ($unit eq "percent" || [string match "unit_*" $unit])} {
#                 # Генерация суффикса для единицы
#                 set unit_suffix [expr {$unit eq "percent" ? "unit_percent_range" : "${unit}_range"}]
#                 # puts "DEBUG Паттерн 1: $current $num $unit → $unit_suffix"
#                 playMsg $current
#                 playNumberUnit $num $unit_suffix
#                 playUnit $unit_suffix $num
#                 incr i 3
#                 playSilence 100
#                 continue
#             }
#         }
        
#         # Паттерн 2: число + "to" + число + ("unit_*" или "percent")
#         if {[string is integer -strict $current] && $i + 3 < $len} {
#             set next1 [lindex $args $i+1]
#             set next2 [lindex $args $i+2]
#             set next3 [lindex $args $i+3]
#             if {$next1 eq "to" && [string is integer -strict $next2] && ($next3 eq "percent" || [string match "unit_*" $next3])} {
#                 playMsg "from"
#                 # Генерация суффикса для единицы
#                 set unit_suffix [expr {$next3 eq "percent" ? "unit_percent_range" : "${next3}_range"}]
#                 # puts "DEBUG Паттерн 2: $current to $next2 $next3 → $unit_suffix"
#                 playNumberUnit $current $unit_suffix
#                 playMsg "to"
#                 playNumberUnit $next2 $unit_suffix
#                 playUnit $unit_suffix $next2
#                 incr i 4
#                 playSilence 100
#                 continue
#             }
#         }
        
#         # Паттерн 3: число + ("unit_*" или "percent")
#         if {[string is integer -strict $current] && $i + 1 < $len} {
#             set unit [lindex $args $i+1]
#             if {$unit eq "percent" || [string match "unit_*" $unit]} {
#                 # Генерация суффикса для единицы
#                 set unit_suffix [expr {$unit eq "percent" ? "unit_percent" : $unit}]
#                 # puts "DEBUG Паттерн 3: $current $unit → $unit_suffix"
#                 playNumberUnit $current $unit_suffix
#                 playUnit $unit_suffix $current
#                 incr i 2
#                 playSilence 100
#                 continue
#             }
#         }
        
        
#         # Одиночные элементы
#         if {[string is double -strict $current] || [string is integer -strict $current]} {
#             playNumberUnit $current "male"
#         } else {
#             playMsg $current
#         }
#         playSilence 100
#         incr i
#     }
#     playSilence 200
# }


proc runwaystate args {
    set len [llength $args]
    set i 0
    while {$i < $len} {
        set current [lindex $args $i]
        
        # Паттерн ВПП: "runway" + номер + [center|left|right]?
        if {[string match "runway" $current] && $i + 1 < $len} {
            set runway_number [lindex $args $i+1]
            playMsg "runway"
            spellNumber $runway_number
            incr i 2
            
            # Проверяем, есть ли указание на center/left/right
            if {$i < $len} {
                set direction [lindex $args $i]
                if {[string match "center" $direction] || [string match "left" $direction] || [string match "right" $direction]} {
                    playMsg $direction
                    incr i
                }
            }
            continue
        }

        # Паттерн 1: "less_or_equal"/"less" + число + ("unit_*" или "percent")
        if {[string match "less*" $current] && $i + 2 < $len} {
            set num [lindex $args $i+1]
            set unit [lindex $args $i+2]
            if {[string is integer -strict $num] && ($unit eq "percent" || [string match "unit_*" $unit])} {
                set unit_suffix [expr {$unit eq "percent" ? "unit_percent_range" : "${unit}_range"}]
                
                playMsg $current
                playNumberUnit $num $unit_suffix
                playUnit $unit_suffix $num
                incr i 3
                continue
            }
        }
        
        # Паттерн 2: число + "to" + число + ("unit_*" или "percent")
        if {[string is integer -strict $current] && $i + 3 < $len} {
            set next1 [lindex $args $i+1]
            set next2 [lindex $args $i+2]
            set next3 [lindex $args $i+3]
            if {$next1 eq "to" && [string is integer -strict $next2] && ($next3 eq "percent" || [string match "unit_*" $next3])} {
                playMsg "from"
                set unit_suffix [expr {$next3 eq "percent" ? "unit_percent_range" : "${next3}_range"}]
                playNumberUnit $current $unit_suffix
                playMsg "to"
                playNumberUnit $next2 $unit_suffix
                playUnit $unit_suffix $next2
                incr i 4
                continue
            }
        }
        
        # Паттерн 3: число + ("unit_*" или "percent")
        if {[string is integer -strict $current] && $i + 1 < $len} {
            set unit [lindex $args $i+1]
            if {$unit eq "percent" || [string match "unit_*" $unit]} {
                set unit_suffix [expr {$unit eq "percent" ? "unit_percent" : $unit}]
                playNumberUnit $current $unit_suffix
                playUnit $unit_suffix $current
                incr i 2
                continue
            }
        }
        
        # Одиночные элементы
        if {[string is double -strict $current] || [string is integer -strict $current]} {
            playNumberUnit $current "male"
        } else {
            playMsg $current
        }
        incr i
    }
    playSilence 200
}










# output numbers
proc sayNumber { number } {
  variable ts;
  variable hd;

  if {$number > 99 && $number < 10000} {
    if [ expr {$number % 100} ] {
      spellNumber $number;
    } else {
      set ts [expr {int($number / 1000)}];   # 1...9 thousand
      set hd [expr {(($number - $ts * 1000)/100) * 100}];  # 1...9 houndred

      # say 1...9 thousand
      if { $ts > 0 } {
        playMsg $ts;
        playMsg "thousand";
      }
      if { $hd > 0 } {
        playMsg $hd;
      }
    }
  } else {
    spellNumber $number;
  }
}


# output
proc say args {
  variable tsay;

  playSilence 100;
  foreach item $args {
    if [regexp {^(\d+)} $item] {
      sayNumber $item;
    } else {
      if {$item == "."} {
        playMsg "decimal";
      } else {
        playMsg $item;
      }
    }
    playSilence 100;
  }
  playSilence 200;
}


# part 1 of help #01
proc icao_available {} {
   playMsg "icao_available";
   playSilence 200;
}


# announce airport at the beginning of the MEATAR
proc announce_airport {icao} {
  
  global langdir;
  playMsg "airport";
  
  if [file exists "$langdir/MetarInfo/$icao.wav"] {
    playMsg $icao;
  } else {
    spellWord $icao;
  }
  playSilence 100;
  
}


# say preconfigured airports
proc airports args {
  global langdir;
  variable tval;

  foreach item $args {

     # is a number??
     if {[regexp {(\d+)} $item tval]} {
       sayNumber $tval;
     } else {
       if [file exists "$langdir/MetarInfo/$item.wav"] {
         playFile "$langdir/MetarInfo/$item.wav";
       } else {
         spellWord $item;
       }
     }
    #  playSilence 100;
  }
  playSilence 200;
}


# say clouds with covering
proc cloudtypes {args} {
variable a 0;
  variable l [llength $args];

  while {$a < $l} {
    set msg [lindex $args $a];
    if { [string match "cld_*" $msg] } {
      playMsg "$msg";
    } else {
      playMsg "cld_$msg";
    }
    
    playMsg "covering";
    incr a;
    playNumberUnit [lindex $args $a] "unit_eighth";
    playUnit "unit_eighth" [lindex $args $a];
    incr a;
    playSilence 100;
  }
}


#
# Spell the specified number
#
proc playNr {number} {
  for {set i 0} {$i < [string length $number]} {set i [expr $i + 1]} {
    set ch [string index $number $i];
    if {$ch == "."} {
      playMsg "decimal";
    } else {
      playMsg "$ch";
    }
  }
}


# end of namespace

}



#
# This file has not been truncated
#
