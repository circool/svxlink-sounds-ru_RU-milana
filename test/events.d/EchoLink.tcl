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

#
# Check if this module is loaded in the current logic core
#
if {![info exists CFG_ID]} {
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
  # puts "\noverloaded EchoLink playMsg modulename = $module_name msg=$msg"
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
# This variable is updated by the EchoLink module when a station connects or
# disconnects. It contains the number of currently connected stations.
#
variable num_connected_stations 0;


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
# Spell an EchoLink callsign
#
proc spellEchoLinkCallsign {call} {
  global langdir
  if [regexp {^(\w+)-L$} $call ignored callsign] {
    spellWord $callsign
    playSilence 50
    playMsg "link"
  } elseif [regexp {^(\w+)-R$} $call ignored callsign] {
    spellWord $callsign
    playSilence 50
    playMsg "repeater"
  } elseif [regexp {^\*(.+)\*$} $call ignored name] {
    playMsg "conference"
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


#
# Executed when a request to list all connected stations is received.
# That is, someone press DTMF "1#" when the EchoLink module is active.
#
proc list_connected_stations {connected_stations} {
  set quantity [llength $connected_stations];
  playNumberWithUnits $quantity "el_connected_station"
  
  foreach {call} "$connected_stations" {
    spellEchoLinkCallsign $call;
    playSilence 250;
  }
}


#
# Executed when someone tries to setup an outgoing EchoLink connection but
# the directory server is offline due to communications failure.
#
proc directory_server_offline {} {
  playMsg "directory_server_offline";
  Module::playCoreMsg "please_try_again_later";
}


#
# Executed when the limit for maximum number of QSOs has been reached and
# an outgoing connection request is received.
#
proc no_more_connections_allowed {} {
  # FIXME: Change the message to something that makes more sense...
  playMsg "limit_exceeded";
}


#
# Executed when a status report is requested. This usually happens at
# manual identification when the user press DTMF "*".
#
proc status_report {} {
  variable num_connected_stations;
  variable module_name;
  global active_module;
  
  if {$active_module == $module_name} {
    playNumberWithUnits $num_connected_stations "el_connected_station";
  }
}


#
# Executed when an EchoLink id cannot be found in an outgoing connect request.
#
proc station_id_not_found {station_id} {
  Module::playCoreMsg "station"
  Module::playCoreMsg "with"
  playMsg "station_id2"
  spellNumber $station_id;
  Module::playCoreMsg "not"
  Module::playCoreMsg "foundf";
}


#
# Executed when the lookup of an EchoLink callsign fail in an outgoing connect
# request.
#
proc lookup_failed {station_id} {
  Module::playCoreMsg "callsign";
  spellEchoLinkCallsign $station_id 
  Module::playCoreMsg "not"
  Module::playCoreMsg "found"
}


#
# Executed when a local user tries to connect to the local node.
#
proc self_connect {} {
  playMsg "self_connect";
}


# соединение с ... уже установлено
# Executed when a local user tries to connect to a node that is already
# connected.
#
proc already_connected_to {call} {
  Module::playCoreMsg "connection";
  Module::playCoreMsg "with";
  spellEchoLinkCallsign $call;
  Module::playCoreMsg "already";
  Module::playCoreMsg "established"
  playSilence 50;
  
}


#
# Executed when an internal error occurs.
#
proc internal_error {} {
  Module::playCoreMsg "operation_failed";
}


# выполняется соединение с ...
# Executed when an outgoing connection has been requested.
#
proc connecting_to {call} {
  Module::playCoreMsg "do";
  Module::playCoreMsg "connection";
  Module::playCoreMsg "with";
  spellEchoLinkCallsign $call;
  playSilence 500;
}


# разрывается соединение с ...
# Executed when an EchoLink connection has been terminated
#
proc disconnected {call} {
  Module::playCoreMsg "disconnecting"
  Module::playCoreMsg "with"
  spellEchoLinkCallsign $call;
  playSilence 500;
}


#
# Executed when an incoming EchoLink connection has been accepted.
#
proc remote_connected {call} {
  Module::playCoreMsg "established";
  Module::playCoreMsg "remote"
  Module::playCoreMsg "incoming"
  
  Module::playCoreMsg "connection"
  Module::playCoreMsg "with"
  spellEchoLinkCallsign $call;
  
  playSilence 500;
}


#
# Executed when an outgoing connection has been established.
#   call - The callsign of the remote station
#
proc connected {call} {
  #puts "Outgoing Echolink connection to $call established"
  Module::playCoreMsg "established";
  Module::playCoreMsg "connection";
  Module::playCoreMsg "with";
  spellEchoLinkCallsign $call;
  playSilence 500;
}


#
# Executed when the list of connected remote EchoLink clients changes
#   client_list - List of connected clients
#
proc client_list_changed {client_list} {
  foreach {call} $client_list {
   puts -nonewline "$call "
  }
}


#
# Executed when the EchoLink connection has been idle for too long. The
# connection will be terminated.
#
proc link_inactivity_timeout {} {
  Module::playCoreMsg "timeout";
  playMsg link_inactivity_timeout
}


#
# Executed when a too short connect by callsign command is received
#
proc cbc_too_short_cmd {cmd} {
  playMsg "too_short"
  Module::playCoreMsg "command"
  spellWord $cmd;
  playSilence 50;
}


# нет совпадений для 
# Executed when the connect by callsign function cannot find a match
#
proc cbc_no_match {code} {
  Module::playCoreMsg "no_match";
  Module::playCoreMsg "for";
  spellNumber $code;
  playSilence 50;
  
}


#
# Executed when the connect by callsign list has been retrieved
#
proc cbc_list {call_list} {
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


#
# Executed when the connect by callsign function is manually aborted
#
proc cbc_aborted {} {
  Module::playCoreMsg "connection";
  Module::playCoreMsg "aborted";
}


#
# Executed when an out of range index is entered in the connect by callsign
# list
#
proc cbc_index_out_of_range {idx} {
  playNumber $idx;
  playSilence 50;
  playMsg "idx_out_of_range";
}


#
# Executed when there are more than nine matches in the connect by
# callsign function
#
proc cbc_too_many_matches {} {
  playMsg "too_many_matches";
}


#
# Executed when no station have been chosen in 60 seconds in the connect
# by callsign function
#
proc cbc_timeout {} {
  Module::playCoreMsg "connection";
  Module::playCoreMsg "aborted";
  Module::playCoreMsg "due_timeout";
}


#
# Executed when the disconnect by callsign list has been retrieved
#
proc dbc_list {call_list} {
  playMsg "disconnect_by_callsign";
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


#
# Executed when the disconnect by callsign function is manually aborted
#
proc dbc_aborted {} {
  # playMsg "disconnect_by_callsign";
  
  Module::playCoreMsg "aborted";
}


#
# Executed when an out of range index is entered in the disconnect by callsign
# list
#
proc dbc_index_out_of_range {idx} {
  playNumber $idx;
  playSilence 50;
  playMsg "idx_out_of_range";
}


# соединение прервано по тайм-ауту
# Executed when no station have been chosen in 60 seconds in the disconnect
# by callsign function
#
proc dbc_timeout {} {
  Module::playCoreMsg "connection";
  Module::playCoreMsg "aborted";
  # playMsg "disconnect_by_callsign";

  Module::playCoreMsg "due_timeout";
}


#
# Executed when a local user enter the DTMF code for playing back the
# local node ID.
#
proc play_node_id {my_node_id} {
  
  if { $my_node_id == 0} {
    Module::playCoreMsg "unknownm";
    playMsg "node_id_is"; 
  } else {
    playMsg "node_id_is";
    spellNumber $my_node_id;
  }
  playSilence 200;
  
}


#
# Executed when an entered command failed or have bad syntax.
#
proc command_failed {cmd} {
  Module::playCoreMsg "command";
  spellWord $cmd;
  Module::playCoreMsg "not"
  Module::playCoreMsg "operatedf";
}


# неизвестная команда ...
# Executed when an unrecognized command has been received.
#
proc unknown_command {cmd} {
  Module::playCoreMsg "unknownf";
  Module::playCoreMsg "command";
  spellWord $cmd;
  
}


#
# Executed when the listen only feature is activated or deactivated
#   status    - The current status of the feature (0=deactivated, 1=activated)
#   activate  - The requested new status of the feature
#               (0=deactivate, 1=activate)
#
proc listen_only {status activate} {
  variable module_name;
  Module::playCoreMsg "listen_only";
  
  if {$status == $activate } {
    Module::playCoreMsg "already"
  }
  Module::playCoreMsg [expr {$activate ? "activating" : "deactivating"}];
}


# попытка подключения к ... отклонена
# Executed when an outgoing connection is rejected. This can happen if
# REJECT_OUTGOING and/or ACCEPT_OUTGOING has been setup.
#
proc reject_outgoing_connection {call} {
  playMsg "tryout_connecting";
  # Module::playCoreMsg "with";
  spellEchoLinkCallsign $call;
  Module::playCoreMsg "rejectedf"
  playSilence 50;
  
}


#
# Executed when a transmission from an EchoLink station is starting
# or stopping
#   rx   - 1 if receiving or 0 if not
#   call - The callsign of the remote station
#
proc is_receiving {rx call} {
  variable CFG_LOCAL_RGR_SOUND
  if {[getVar CFG_LOCAL_RGR_SOUND 1] && !$rx} {
    playTone 1000 100 100
  }
}


#
# Executed when a chat message is received from a remote station
#
#   msg -- The message text
#
# WARNING: This is a slightly dangerous function since unexepected input
# may open up a security flaw. Make sure that the message string is handled
# as unknown data that can contain anything. Check it thoroughly before
# using it. Do not run SvxLink as user root.
proc chat_received {msg} {
  #puts $msg
}


#
# Executed when an info message is received from a remote station
#
#   call -- The callsign of the sending station
#   msg  -- The message text
#
# WARNING: This is a slightly dangerous function since unexepected input
# may open up a security flaw. Make sure that the message string is handled
# as unknown data that can contain anything. Check it thoroughly before
# using it. Do not run SvxLink as user root.
proc info_received {call msg} {
  #puts "$call: $msg"
}


#
# Executed when a configuration variable is updated at runtime
#
proc config_updated {tag value} {
  puts "Configuration variable updated: $tag=$value"
}


#-----------------------------------------------------------------------------
# The events below are for remote EchoLink announcements. Sounds are not
# played over the local transmitter but are sent to the remote station.
#-----------------------------------------------------------------------------

#
# Executed when an incoming connection is accepted
#
proc remote_greeting {call} {
  playSilence 1000;
  playMsg "greeting";
}


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


#
# Executed when the inactivity timer times out
#
proc remote_timeout {} {
  playMsg "timeout";
  playSilence 1000;
}


#
# Executed when the squelch state changes
#
proc squelch_open {is_open} {
  # The listen_only_active and CFG_REMOTE_RGR_SOUND global variables are set by
  # the C++ code
  variable listen_only_active
  variable CFG_REMOTE_RGR_SOUND
  if {$CFG_REMOTE_RGR_SOUND && !$is_open && !$listen_only_active} {
    playSilence 200
    playTone 1000 100 100
  }
}


# end of namespace
}

#
# This file has not been truncated
#