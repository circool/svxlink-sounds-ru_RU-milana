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
  # playMsg "Core" "activating";
  # playMsg "Core" "module";
  playMsg "Core" "module_activating";
  playMsg $module_name "name";
  playSilence 500;
}


# выключается модуль ...
# Executed when a module is being deactivated.
#
proc deactivating_module {module_name} {
  # playMsg "Core" "deactivating";
  # playMsg "Core" "module"; 
  # playSilence 100;
  playMsg "Core" "module_deactivating";
  playMsg $module_name "name";
  playSilence 500;
}


# модуль ... отключен по тайм-ауту
# Executed when the inactivity timeout for a module has expired.
#
proc timeout {module_name} {
  
  playMsg "Core" "module";
  playMsg $module_name "name";
  playMsg "Core" "disconnected";
  playMsg "Core" "with_timeout";
  playSilence 500;
}


#
# Executed when playing of the help message for a module has been requested.
#
proc play_help {module_name} {
  playMsg $module_name "help"
  playSubcommands $module_name help_subcmd "sub_commands_are"
  playSilence 500;
}


# End of namespace
}

#
# This file has not been truncated
#
