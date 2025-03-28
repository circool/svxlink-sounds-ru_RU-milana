

namespace eval DtmfRepeater {
	variable CFG_ID "4";	
}
source "./events.d/DtmfRepeater.tcl"

namespace eval EchoLink {
	variable CFG_ID "2"; 
	variable CFG_LOCAL_RGR_SOUND
	set CFG_LOCAL_RGR_SOUND 1
}
source "./events.d/EchoLink.tcl"

namespace eval Frn {
	variable CFG_ID "7"; 	
}
source "./events.d/Frn.tcl"

namespace eval Help {
	variable CFG_ID "0";
}
source "./events.d/Help.tcl"

# source "./locale.tcl"

namespace eval Logic {
	variable CFG_TIME_FORMAT
	variable CFG_PHONETIC_SPELLING 1
	if {![info exists CFG_TIME_FORMAT]} {
		set CFG_TIME_FORMAT 24
	}
	
	
}	
source "./events.d/Logic.tcl"

namespace eval CW {

}
source "./events.d/CW.tcl"

namespace eval MetarInfo {
	variable CFG_ID "5";  
}
source "./events.d/MetarInfo.tcl"

namespace eval Module {
	variable activating_module 1
}
source "./events.d/Module.tcl"

namespace eval Parrot {
	variable CFG_ID "1"
}
source "./events.d/Parrot.tcl"

namespace eval PropagationMonitor {
	variable CFG_ID "10"
}
source "./events.d/PropagationMonitor.tcl"

set logic_name "ReflectorLogic"
namespace eval ReflectorLogic {
	# $logic_name <== ReflectorLogic
	# variable CFG_ID 10
	variable reflector_connection_established 0
}
source "./events.d/ReflectorLogic.tcl"

set logic_name "RepeaterLogic"
namespace eval RepeaterLogic {
	# $logic_name <== RepeaterLogic
}
source "./events.d/RepeaterLogic.tcl"

set logic_name "SimplexLogic"
namespace eval SimplexLogic {
	# $logic_name <== SimplexLogic
}
source "./events.d/SimplexLogic.tcl"

namespace eval SelCall {

}
source "./events.d/SelCall.tcl"

namespace eval SelCallEnc {
	variable CFG_ID 6
}
source "./events.d/SelCallEnc.tcl"



namespace eval TclVoiceMail {
	variable CFG_ID 3
}
source "./events.d/TclVoiceMail.tcl"

namespace eval Trx {
	variable CFG_ID 8
}
source "./events.d/Trx.tcl"