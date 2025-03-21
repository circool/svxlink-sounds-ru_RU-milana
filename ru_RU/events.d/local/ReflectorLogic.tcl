# @author vladimir@tsurkanenko.ru
# aka circool
# aka R2ADU


namespace eval ReflectorLogic {

  # Произнести имя или номер разговорной группы, разбивая его на группы по 2 или 3 символа 
  proc say_talkgroup {tg} {
    if [playMsg "Core" "talk_group-$tg" 0] {
    # Найдена именованная группа
    } else {
      # Преобразуем число в строку
      set tg_str [format "%d" $tg]
      set len [string length $tg_str]

      # Если длина строки меньше 4, обрабатываем её как одну группу
      if {$len < 4} {
        set groups [list $tg_str]
      } elseif {$len == 4} {
        # Если длина строки равна 4, разбиваем на две группы по 2 символа
        set groups [list [string range $tg_str 0 1] [string range $tg_str 2 3]]
      } else {
        # Если длина строки больше 4, разбиваем на группы по 3 символа
        set groups [list]
        for {set i 0} {$i < $len} {incr i 3} {
          lappend groups [string range $tg_str $i [expr {$i + 2}]]
        }
      }

      # Обрабатываем каждую группу
      foreach group $groups {
        # Лидирующие нули отправляем по одному
        while {[string index $group 0] eq "0"} {
          playNumberUnit 0 "male"
          set group [string range $group 1 end]
        }
        # Если в группе остались символы, отправляем их
        if {$group ne ""} {
          playNumberUnit $group "male"
        }
        # Добавляем паузу, если это не последняя группа
        if {$group != [lindex $groups end]} {
          playSilence 200
        }
      }
    }
  }



}

proc report_tg_status {} {
  variable selected_tg
  variable previous_tg
  variable prev_announce_time
  variable prev_announce_tg
  variable reflector_connection_established
  playSilence 100
  playMsg "Core" "reflector"
  if {$reflector_connection_established} {
    playMsg "Core" "connected"
  } else {
    playMsg "Core" "disconnected"
  }
  playSilence 200
  if {$selected_tg > 0} {
    set prev_announce_time [clock seconds]
    set prev_announce_tg $selected_tg
    playMsg "Core" "talk_group"
    say_talkgroup $selected_tg
  } else {
    playMsg "Core" "previous"
    playMsg "Core" "talk_group"
    playSilence 50
    say_talkgroup $previous_tg
  }
}