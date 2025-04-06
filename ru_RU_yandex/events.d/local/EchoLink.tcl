###############################################################################
#
# EchoLink module event handlers
#
###############################################################################

#
# This is the namespace in which all functions and variables below will exist.
# The name must match the configuration variable "NAME" in the
# [ModuleEchoLink] section in the configuration file. The name may be changed
# but it must be changed in both places.
#
namespace eval EchoLink {

# Без изменений
# Check if this module is loaded in the current logic core
#
if {![info exists CFG_ID]} {
  return;
}

# Без изменений
# Extract the module name from the current namespace
#
set module_name [namespace tail [namespace current]];

# Без изменений
# An "overloaded" playMsg that eliminates the need to write the module name
# as the first argument.
#
# proc playMsg {msg} {
#   variable module_name;
#   # puts "\noverloaded EchoLink playMsg modulename = $module_name msg=$msg"
#   ::playMsg $module_name $msg;
# }


# Без изменений
# A convenience function for printing out information prefixed by the
# module name
#
# proc printInfo {msg} {
#   variable module_name;
#   puts "$module_name: $msg";
# }


#
# This variable is updated by the EchoLink module when a station connects or
# disconnects. It contains the number of currently connected stations.
#
variable num_connected_stations 0;


# Без изменений
# Executed when this module is being activated
#
# proc activating_module {} {
#   variable module_name;
#   Module::activating_module $module_name;
# }


# Без изменений
# Executed when this module is being deactivated.
#
# proc deactivating_module {} {
#   variable module_name;
#   Module::deactivating_module $module_name;
# }


# Без изменений
# Executed when the inactivity timeout for this module has expired.
#
# proc timeout {} {
#   variable module_name;
#   Module::timeout $module_name;
# }


# Без изменений
# Executed when playing of the help message for this module has been requested.
#
# proc play_help {} {
#   variable module_name;
#   Module::play_help $module_name;
# }


# Изменен порядок произношения - сначала [репитер|конференция|линк] потом позывной
# аудиоклипы [репитер|конференция|линк] перенесены в Core
# Spell an EchoLink callsign
#
proc spellEchoLinkCallsign {call} {
  global langdir
  if [regexp {^(\w+)-L$} $call ignored callsign] {
    Module::playCoreMsg "link"
    playSilence 50
    spellWord $callsign
  } elseif [regexp {^(\w+)-R$} $call ignored callsign] {
    Module::playCoreMsg "repeater"
    playSilence 50
    spellWord $callsign
  } elseif [regexp {^\*(.+)\*$} $call ignored name] {
    Module::playCoreMsg "conference"
    playSilence 50
    set lc_name [string tolower $name]
    if [file exists "$langdir/EchoLink/conf-$lc_name.wav"] {
      playFile "$langdir/EchoLink/conf-$lc_name.wav"
    } else {
      spellEchoLinkCallsign $name
    }
  } else {
    spellWord $call
  }
}

# Произношение позывного эхолинк в винительном пажеже 
proc spellEchoLinkCallsignTo {call} {
  global langdir
  if [regexp {^(\w+)-L$} $call ignored callsign] {
    Module::playCoreMsg "link2"
    playSilence 50
    spellWord $callsign
  } elseif [regexp {^(\w+)-R$} $call ignored callsign] {
    Module::playCoreMsg "repeater2"
    playSilence 50
    spellWord $callsign
  } elseif [regexp {^\*(.+)\*$} $call ignored name] {
    Module::playCoreMsg "conference2"
    playSilence 50
    set lc_name [string tolower $name]
    if [file exists "$langdir/EchoLink/conf-$lc_name.wav"] {
      playFile "$langdir/EchoLink/conf-$lc_name.wav"
    } else {
      spellEchoLinkCallsign $name
    }
  } else {
    spellWord $call
  }  
}


# Добавлено склонение для количества подключенных станций
# Executed when a request to list all connected stations is received.
# That is, someone press DTMF "1#" when the EchoLink module is active.
#
proc list_connected_stations {connected_stations} {
  set quantity [llength $connected_stations];
  playNumberWithUnit $quantity "el_connected_station"  
  foreach {call} "$connected_stations" {
    spellEchoLinkCallsign $call;
    playSilence 250;
  }
}


# Добавлена фраза "Пожалуйста попробуйте позже"
# Executed when someone tries to setup an outgoing EchoLink connection but
# the directory server is offline due to communications failure.
#
proc directory_server_offline {} {
  playMsg "directory_server_offline";
  Module::playCoreMsg "please_try_again_later";
}

# Добавлен вывод сообщения в консоль
# Линк занят -> Превышен лимит на количество активных соединений
# Executed when the limit for maximum number of QSOs has been reached and
# an outgoing connection request is received.
#
proc no_more_connections_allowed {} {
  variable module_name;
  variable num_connected_stations;
  puts "$module_name: Превышен лимит на количество активных соединений (> $num_connected_stations)"
  playMsg "limit_exceeded";
}

# Добавлена пауза 100 мсек в начале
# Добавлено склонение для количества подключенных станций
# Executed when a status report is requested. This usually happens at
# manual identification when the user press DTMF "*".
#
proc status_report {} {
  variable num_connected_stations;
  variable module_name;
  global active_module;
  
  if {$active_module == $module_name} {
    playSilence 100;
    playNumberWithUnit $num_connected_stations "el_connected_station";
  }
}


# Добавлено информирование о id несуществующей станции
# Станция с идентификатором ... не найдена
# Идентификатор произносится группами по 2-3 цифры
# Executed when an EchoLink id cannot be found in an outgoing connect request.
#
proc station_id_not_found {station_id} {
  Module::playCoreMsg "station_with_id";
  SplitAndSpeakNumber $station_id;
  Module::playCoreMsg "not_foundf";
}


# Позывной ... не найден
# Executed when the lookup of an EchoLink callsign fail in an outgoing connect
# request.
#
proc lookup_failed {station_id} {
  Module::playCoreMsg "callsign";
  spellEchoLinkCallsign $station_id 
  Module::playCoreMsg "not_found"
}


# Новый клип "self_connect"
# Подключение невозможно: исходный и конечный адреса совпадают
# Executed when a local user tries to connect to the local node.
#
proc self_connect {} {
  playMsg "self_connect";
}


# соединение с ... уже установлено
# винительный падеж
# Executed when a local user tries to connect to a node that is already
# connected.
#
proc already_connected_to {call} {
  Module::playCoreMsg "connection";
  Module::playCoreMsg "with";
  spellEchoLinkCallsignTo $call;
  Module::playCoreMsg "already";
  Module::playCoreMsg "established"
}


# Обработка перенесена в Logic
# Executed when an internal error occurs.
#
proc internal_error {} {
  Logic::operation_failed;
}


# выполняется соединение с ...
# винительный падеж
# Executed when an outgoing connection has been requested.
#
proc connecting_to {call} {
  Module::playCoreMsg "do_attempt_connection";
  spellEchoLinkCallsignTo $call;
  playSilence 500;
}


# разрывается соединение с ...
# винительный падеж
# Добавлен вывод сообщения в консоль
# Executed when an EchoLink connection has been terminated
#
proc disconnected {call} {
  variable module_name;
  puts "$module_name: Разрывается соединение с $call"
  Module::playCoreMsg "disconnecting_connection_with"
  spellEchoLinkCallsignTo $call;
  playSilence 500;
}


# Принято входящее соединение от узла ...
# Добавлен вывод сообщения в консоль
# Executed when an incoming EchoLink connection has been accepted.
#
proc remote_connected {call} {
  variable module_name;
  puts "$module_name: Принято входящее соединение от узла $call" 
  Module::playCoreMsg "incoming_connection_from";
  spellEchoLinkCallsign $call; 
  playSilence 500;
}


# Соединение установлено
# Executed when an outgoing connection has been established.
#   call - The callsign of the remote station
#
proc connected {call} {
  variable module_name;
  puts "$module_name: Исходящее соединение с $call установлено."
  Module::playCoreMsg "connection_estabilished";
  playSilence 500;
}


# Без изменений
# Executed when the list of connected remote EchoLink clients changes
#   client_list - List of connected clients
#
# proc client_list_changed {client_list} {
#   # foreach {call} $client_list {
#   #  puts -nonewline "$call "
#   # }
# }


# Клип "timeout" перенесен в Core
# После воспроизведение "тайм-аут" произносится причина
# "по отсутствию активности линка"
# Executed when the EchoLink connection has been idle for too long. The
# connection will be terminated.
#
proc link_inactivity_timeout {} {
  Module::playCoreMsg "timeout";
  playMsg link_inactivity_timeout
}


# Слишком короткая команда ...
# Executed when a too short connect by callsign command is received
#
proc cbc_too_short_cmd {cmd} {
  playMsg "too_short"
  Module::playCoreMsg "command"
  playSilence 50;
  spellWord $cmd;
}


# нет совпадений для 
# Executed when the connect by callsign function cannot find a match
#
proc cbc_no_match {code} {
  Module::playCoreMsg "no_match";
  Module::playCoreMsg "for";
  playSilence 50;
  spellNumber $code;
}


# Соединение разорвано
# Пожалуйста выберите станцию {список станций}
# Executed when the connect by callsign list has been retrieved
#
proc cbc_list {call_list} {
  Module::playCoreMsg "connection_aborted";
  playSilence 200
  playMsg "choose_station";
  set idx 0;
  foreach {call} $call_list {
    incr idx;
    playSilence 500;
    playNumberUnit $idx "male";
    playSilence 200;
    spellEchoLinkCallsign $call;
  }
}


# Соединение разорвано
# Добавлен вывод сообщения в консоль
# Аудиоклипы перенесены в Core
# Executed when the connect by callsign function is manually aborted
#
proc cbc_aborted {} {
  puts "Соединение разорвано"
  Module::playCoreMsg "connection";
  Module::playCoreMsg "aborted";
}


# Индекс ... вне доступного диапазона
# Executed when an out of range index is entered in the connect by callsign
# list
#
proc cbc_index_out_of_range {idx} {
  playMsg "index"
  playNumberUnit $idx "male";
  playMsg "out_of_range";
}


# Без изменений
# Executed when there are more than nine matches in the connect by
# callsign function
#
# proc cbc_too_many_matches {} {
#   playMsg "too_many_matches";
# }


# Соединение прервано по тайм-ауту
# Executed when no station have been chosen in 60 seconds in the connect
# by callsign function
#
proc cbc_timeout {} {
  Module::playCoreMsg "connection_aborted";
  Module::playCoreMsg "due_timeout";
}


# Соединение разорвано. Пожалуйста выберите станцию
# Executed when the disconnect by callsign list has been retrieved
#
proc dbc_list {call_list} {
  Module::playCoreMsg "connection_aborted";
  playSilence 200
  playMsg "choose_station";
  set idx 0;
  foreach {call} $call_list {
    incr idx;
    playSilence 500;
    playNumber $idx;
    playSilence 200;
    spellEchoLinkCallsign $call;
  }
}


# Соединение разорвано
# Executed when the disconnect by callsign function is manually aborted
#
proc dbc_aborted {} {
  # playMsg "disconnect_by_callsign";
  Module::playCoreMsg "connection_aborted";
}


# Индекс ... вне доступного диапазона
# Executed when an out of range index is entered in the disconnect by callsign
# list
#
proc dbc_index_out_of_range {idx} {
  playMsg "index"
  playNumberUnit $idx "male";
  playMsg "out_of_range";
}


# соединение прервано по тайм-ауту
# Executed when no station have been chosen in 60 seconds in the disconnect
# by callsign function
#
proc dbc_timeout {} {
  Module::playCoreMsg "connection_aborted";
  Module::playCoreMsg "due_timeout";
}


# Неизвестный идентификатор узла | Идентификатор узла ...
# Executed when a local user enter the DTMF code for playing back the
# local node ID.
#
proc play_node_id {my_node_id} {
  if { $my_node_id == 0} {
    Module::playCoreMsg "unknownm";
    playMsg "node_id_is"; 
  } else {
    playMsg "node_id_is";
    SplitAndSpeakNumber $my_node_id;
  }  
}


# Команда ...не выполнена
# Перенесено в Logic
# Executed when an entered command failed or have bad syntax.
#
proc command_failed {cmd} {
  Logic::command_failed $cmd
}


# неизвестная команда ...
# Перенесено в Logic
# Executed when an unrecognized command has been received.
#
proc unknown_command {cmd} {
  Logic::unknown_command $cmd;
}


# [уже]активен|отключен Режим только прием уже 
# Перенесено в Logic
# Executed when the listen only feature is activated or deactivated
#   status    - The current status of the feature (0=deactivated, 1=activated)
#   activate  - The requested new status of the feature
#               (0=deactivate, 1=activate)
#
proc listen_only {status activate} {
  variable module_name;
  Module::playCoreMsg "listen_only_mode";
  if {$status == $activate } {
    Module::playCoreMsg "already"
  }
  Module::playCoreMsg [expr {$activate ? "active1" : "disconnected"}];
  
}


# попытка подключения к [линку|репитер|уконференции] отклонена
# Executed when an outgoing connection is rejected. This can happen if
# REJECT_OUTGOING and/or ACCEPT_OUTGOING has been setup.
#
proc reject_outgoing_connection {call} {
  playMsg "tryout_connecting_to";
  spellEchoLinkCallsignTo $call;
  Module::playCoreMsg "rejectedf"
  playSilence 50;
  
}


# Без изменений
# Executed when a transmission from an EchoLink station is starting
# or stopping
#   rx   - 1 if receiving or 0 if not
#   call - The callsign of the remote station
#
# proc is_receiving {rx call} {
#   variable CFG_LOCAL_RGR_SOUND
#   if {[getVar CFG_LOCAL_RGR_SOUND 1] && !$rx} {
#     playTone 1000 100 100
#   }
# }


# Без изменений
# Executed when a chat message is received from a remote station
#
#   msg -- The message text
#
# WARNING: This is a slightly dangerous function since unexepected input
# may open up a security flaw. Make sure that the message string is handled
# as unknown data that can contain anything. Check it thoroughly before
# using it. Do not run SvxLink as user root.
# proc chat_received {msg} {
#   #puts $msg
# }


# Без изменений
# Executed when an info message is received from a remote station
#
#   call -- The callsign of the sending station
#   msg  -- The message text
#
# WARNING: This is a slightly dangerous function since unexepected input
# may open up a security flaw. Make sure that the message string is handled
# as unknown data that can contain anything. Check it thoroughly before
# using it. Do not run SvxLink as user root.
# proc info_received {call msg} {
#   #puts "$call: $msg"
# }


# Добавлен вывод в консоль
# Executed when a configuration variable is updated at runtime
#
proc config_updated {tag value} {
  puts "Configuration variable updated: $tag=$value"
}


#-----------------------------------------------------------------------------
# The events below are for remote EchoLink announcements. Sounds are not
# played over the local transmitter but are sent to the remote station.
#-----------------------------------------------------------------------------

# Без изменений
# Executed when an incoming connection is accepted
#
# proc remote_greeting {call} {
#   playSilence 1000;
#   playMsg "greeting";
# }

# Перенесено в Module
# входящее удаленное соединение отклонено [Пожалуйста, попробуйте позднее]
# Executed when an incoming connection is rejected
#
proc reject_remote_connection {perm} {
  playSilence 1000;
  Module::playCoreMsg "incoming"
  Module::playCoreMsg "remote"
  Module::playCoreMsg "connection"
  Module::playCoreMsg "rejected"; 
  if {$perm == 0} {
    Module::playCoreMsg "please_try_again_later"
  }
  playSilence 1000;
}


# Перенесено в Module
# Удаленное соединение прервано по таймауту
# Executed when the inactivity timer times out
#
proc remote_timeout {} {
  Module::playCoreMsg "remote"
  Module::playCoreMsg "connection"
  Module::playCoreMsg "aborted"
  Module::playCoreMsg "due_timeout";
  playSilence 1000;
}


# Без изменений
# Executed when the squelch state changes
#
# proc squelch_open {is_open} {
#   # The listen_only_active and CFG_REMOTE_RGR_SOUND global variables are set by
#   # the C++ code
#   variable listen_only_active
#   variable CFG_REMOTE_RGR_SOUND
#   if {$CFG_REMOTE_RGR_SOUND && !$is_open && !$listen_only_active} {
#     playSilence 200
#     playTone 1000 100 100
#   }
# }


# end of namespace
}

#
# This file has not been truncated
#