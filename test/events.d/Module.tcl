###############################################################################
#
# Generic module event handlers
#
###############################################################################

#
# This is the namespace in which all functions and variables below will exist.
#
namespace eval Module {

proc playCoreMsg {msg} {
	playMsg "Core" $msg
}

# включается модуль ...
# Executed when a module is being activated
#
proc activating_module {module_name} {
  playMsg "Core" "activating";
  playMsg "Core" "module";
  playSilence 100;
  playMsg $module_name "name";
  playSilence 200;
}


# выключается модуль ...
# Executed when a module is being deactivated.
#
proc deactivating_module {module_name} {
  playMsg "Core" "deactivating";
  playMsg "Core" "module"; 
  playSilence 100;
  playMsg $module_name "name";
  playSilence 200;
}


# модуль ... отключен по тайм-ауту
# Executed when the inactivity timeout for a module has expired.
#
proc timeout {module_name} {
  
  playMsg "Core" "module";
  playMsg $module_name "name";
  playMsg "Core" "disconnected";
  playMsg "Core" "with_timeout";
  playSilence 100;
}


#
# Executed when playing of the help message for a module has been requested.
#
proc play_help {module_name} {
  playMsg $module_name "help"
  playSubcommands $module_name help_subcmd "sub_commands_are"
}

# proc playSubcommands {module_name help_subcmd help_anounce} {
#     playMsg $module_name "help" 
#     playMsg "Core" $help_anounce
# 	  playSilence 100
# 	  playMsg $module_name $help_subcmd
# }

proc playCoreMsg {msg} {
	playMsg "Core" $msg
}

# End of namespace
}

#
# This file has not been truncated
#
