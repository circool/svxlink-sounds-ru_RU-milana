global argv


variable report_ctcss "88.5"
variable active_module "EchoLink"
variable loaded_modules "ModuleEchoLink,ModuleFrn,ModuleMetarInfo,ModuleHelp,ModuleParrot"

set argc [llength $args]
set arg1 [lindex $args 0]

#  langdir
variable langdir
set langdir "../ru_RU"

variable logic_name "ReflectorLogic"

# Процедуры глобального пространства имен
# if {[info proc ::$arg1] ne ""} {
# 	::$arg1 {*}[lrange $args 1 end]	
# 	return
# }



namespace eval DtmfRepeater {
	variable CFG_ID "4";	
}
source "./DtmfRepeater.tcl"

namespace eval EchoLink {
	variable CFG_ID "2"; 
	variable CFG_LOCAL_RGR_SOUND
	set CFG_LOCAL_RGR_SOUND 1
}
source "./EchoLink.tcl"

namespace eval Frn {
	variable CFG_ID "7"; 	
}
source "./Frn.tcl"

namespace eval Help {
	variable CFG_ID "0";
}
source "./Help.tcl"

# source "./locale.tcl"

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

namespace eval CW {

}
source "./CW.tcl"

namespace eval MetarInfo {
	variable CFG_ID "5";  
}
source "./MetarInfo.tcl"

namespace eval Module {
	variable activating_module 1
}
source "./Module.tcl"

namespace eval Parrot {
	variable CFG_ID "1"
}
source "./Parrot.tcl"

namespace eval PropagationMonitor {
	variable CFG_ID "10"
}
source "./PropagationMonitor.tcl"

namespace eval ReflectorLogic {
	# $logic_name <== ReflectorLogic
	# variable CFG_ID 10
	variable reflector_connection_established 0
}
source "./ReflectorLogic.tcl"

namespace eval RepeaterLogic {
	# $logic_name <== RepeaterLogic
}
source "./RepeaterLogic.tcl"

namespace eval SimplexLogic {
	# $logic_name <== SimplexLogic
}
source "./SimplexLogic.tcl"

namespace eval SelCall {

}
source "./SelCall.tcl"

namespace eval SelCallEnc {
	variable CFG_ID 6
}
source "./SelCallEnc.tcl"



namespace eval TclVoiceMail {
	variable CFG_ID 3
}
source "./TclVoiceMail.tcl"

namespace eval Trx {
	variable CFG_ID 8
}
source "./Trx.tcl"