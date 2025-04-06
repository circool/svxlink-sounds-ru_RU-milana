puts "loading enveropment"

global langdir

source "$langdir/events.d/local/locale.tcl"

namespace eval DtmfRepeater {
	variable CFG_ID "4";	
}
source "$langdir/events.d/local/DtmfRepeater.tcl"

namespace eval EchoLink {
	variable CFG_ID "2"; 
	variable CFG_LOCAL_RGR_SOUND
	set CFG_LOCAL_RGR_SOUND 1
}
source "$langdir/events.d/local/EchoLink.tcl"

namespace eval Frn {
	variable CFG_ID "7"; 	
}
source "$langdir/events.d/local/Frn.tcl"

namespace eval Help {
	variable CFG_ID "0";
}
source "$langdir/events.d/local/Help.tcl"

namespace eval Logic {
	variable CFG_TIME_FORMAT
	variable CFG_PHONETIC_SPELLING 1
	if {![info exists CFG_TIME_FORMAT]} {
		set CFG_TIME_FORMAT 24
	}
}	
source "$langdir/events.d/local/Logic.tcl"

# namespace eval CW {}
source "$langdir/events.d/local/CW.tcl"

namespace eval MetarInfo {
	variable CFG_ID "5";  
}
source "$langdir/events.d/local/MetarInfo.tcl"

namespace eval Module {
	variable activating_module 1
}
source "$langdir/events.d/local/Module.tcl"

namespace eval Parrot {
	variable CFG_ID "1"
}
source "$langdir/events.d/local/Parrot.tcl"

namespace eval PropagationMonitor {
	variable CFG_ID "10"
}
source "$langdir/events.d/local/PropagationMonitor.tcl"

set logic_name "ReflectorLogic"
namespace eval ReflectorLogic {
	variable CFG_ID "9"
	variable reflector_connection_established 0
}
source "$langdir/events.d/local/ReflectorLogic.tcl"

set logic_name "RepeaterLogic"
# namespace eval RepeaterLogic {}
source "$langdir/events.d/local/RepeaterLogic.tcl"

set logic_name "SimplexLogic"
# namespace eval SimplexLogic {}
source "$langdir/events.d/local/SimplexLogic.tcl"

# namespace eval SelCall {}
source "$langdir/events.d/local/SelCall.tcl"

namespace eval SelCallEnc {
	variable CFG_ID "6"
}
source "$langdir/events.d/local/SelCallEnc.tcl"



namespace eval TclVoiceMail {
	variable CFG_ID "3"
}
source "$langdir/events.d/local/TclVoiceMail.tcl"

namespace eval Trx {
	variable CFG_ID "8"
}
source "$langdir/events.d/local/Trx.tcl"

# variable script_path ""
# source "./events.tcl"