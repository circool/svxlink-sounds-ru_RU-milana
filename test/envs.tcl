global argv
variable report_ctcss "88.5"
variable active_module "EchoLink"
variable loaded_modules "ModuleEchoLink,ModuleFrn,ModuleMetarInfo,ModuleHelp,ModuleParrot"
variable logic_name "Simplex"
set argc [llength $args]
set arg1 [lindex $args 0]

#  langdir
variable langdir
set langdir "../ru_RU"


# Процедуры глобального пространства имен
# if {[info proc ::$arg1] ne ""} {
# 	::$arg1 {*}[lrange $args 1 end]	
# 	return
# }


namespace eval Module {
  proc playSubcommands {module_name help_subcmd text} {
    playMsg $module_name $text 
    playMsg $module_name $help_subcmd
  }

}

# MetarInfo
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
source "./MetarInfo.tcl"

# Logic
namespace eval Logic {
	variable CFG_TIME_FORMAT
	variable CFG_PHONETIC_SPELLING 1
	if {![info exists CFG_TIME_FORMAT]} {
		set CFG_TIME_FORMAT 24
	}
	variable ::mycall "R2ADU"
	variable CFG_TYPE "Simplex"
	variable loaded_modules "ModuleEchoLink,ModuleFrn,ModuleMetarInfo,ModuleHelp,ModuleParrot"
	variable list_languages {ru_RU en_EN}
	
}	
source "./Logic.tcl"

namespace eval Module {
	variable activating_module 1
}
source "./Module.tcl"

namespace eval EchoLink {
	variable CFG_ID
	set CFG_ID "2"; 
	variable CFG_LOCAL_RGR_SOUND
	set CFG_LOCAL_RGR_SOUND 1
}
source "./EchoLink.tcl"