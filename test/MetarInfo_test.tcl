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


# MET-report TIME
proc metreport_time item {
   puts "metreport_time: $item"
   return
   
   playMsg "metreport_time";
   spellNumber $item;
   playSilence 200;
}


# visibility
proc visibility args {
  puts "visibility: $args"
  return

  playMsg "visibility";
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


# temperature
proc temperature {temp} {
  puts "temperature: $temp"
  return
  
  playMsg "temperature";
  playSilence 100;
  if {$temp == "not"} {
    playMsg "not";
    playMsg "reported";
  } else {
    if { int($temp) < 0} {
       playMsg "minus";
       set temp [string trimleft $temp "-"];
    }
    spellNumber $temp;
    if {int($temp) == 1} {
      playMsg "unit_degree";
    } else {
      playMsg "unit_degrees";
    }
    playSilence 100;
  }
  playSilence 200;
}


# dewpoint
proc dewpoint {dewpt} {
  puts "dewpoint: $dewpt"
  return

  playMsg "dewpoint";
  playSilence 100;
  if {$dewpt == "not"} {
    playMsg "not";
    playMsg "reported";
  } else {
    if { int($dewpt) < 0} {
       playMsg "minus";
       set dewpt [string trimleft $dewpt "-"];
    }
    spellNumber $dewpt;
    if {int($dewpt) == 1} {
      playMsg "unit_degree";
    } else {
      playMsg "unit_degrees";
    }
    playSilence 100;
  }
  playSilence 200;
}


# sea level pressure
proc slp {slp} {
  puts "slp: $slp"
  return

  playMsg "slp";
  spellNumber $slp;
  playMsg "unit_hPa";
  playSilence 200;
}


# flightlevel
proc flightlevel {level} {
  puts "flightlevel: $level"
  return

  playMsg "flightlevel";
  spellNumber $level;
  playSilence 200;
}


# No specific reports taken
proc nospeci {} {
  playMsg "no";
  playMsg "specific_reports_taken";
  playSilence 100;
}


# peakwind
proc peakwind {val} {
  puts  "peakwind: $val"
  return

  
  playMsg "pk_wnd";
  playSilence 100;
  playNumber $val;
  playSilence 200;
}


# wind
proc wind {deg {vel 0 } {unit 0} {gusts 0} {gvel 0}} {
  puts "wind: deg=$deg vel=$vel unit=$unit gusts=$gusts gvel=$gvel"
  return


  playMsg "wind";

  if {$deg == "calm"} {
    playMsg "calm";
  } elseif {$deg == "variable"} {
    playMsg "variable";
    playSilence 200;
    spellNumber $vel;
    playMsg $unit;
  } else {
    sayNumber $deg;
    playMsg "unit_degree";
    playSilence 100;
    playMsg "at";
    playSilence 100;
    spellNumber $vel;
    playMsg $unit;
    playSilence 100;

    if {$gusts > 0} {
      playMsg "gusts_up";
      spellNumber $gusts;
      playMsg $gvel;
    }
  }
  playSilence 200;
}


# weather actually
proc actualWX args {

  puts "actualWX: $args"
  return


  foreach item $args {
    if [regexp {(\d+)} $item] {
      spellNumber $item;
    } else {
      playMsg $item;
    }
  }
  playSilence 200;
}


# wind varies $from $to
proc windvaries {from to} {

   puts "windvaries: $from $to"
   return

   playMsg "wind";
   playSilence 50;
   playMsg "varies_from";
   playSilence 100;

   sayNumber $from;
   playSilence 100;

   playMsg "to";
   playSilence 100;
   sayNumber $to;

   playMsg "unit_degrees";
   playSilence 200;
}


# Peak WIND
proc peakwind {deg kts hh mm} {
  puts "peakwind: $deg $kts $hh $mm"
  return


   playMsg "pk_wnd";
   playMsg "from";
   playSilence 100;
   playNumber $deg;
   playMsg "unit_degrees";

   playSilence 100;
   playNumber $kts;
   playMsg "unit_kts";
   playSilence 100;
   playMsg "at";
   if {$hh != "XX"} {
      playNumber $hh;
   }
   playNumber $mm;
   playMsg "utc";
   playSilence 200;
}


# ceiling varies $from $to
proc ceilingvaries {from to} {

   puts "ceilingvaries: $from $to"
   return


   playMsg "ca";
   playSilence 50;
   playMsg "varies_from";
   playSilence 100;
   set from [expr {int($from) * 100}];
   sayNumber $from;
   playSilence 100;

   playMsg "to";
   playSilence 100;
   set to [expr {int($to)*100}];
   sayNumber $to;

   playMsg "unit_feet";
   playSilence 200;
}

# runway visual range
proc rvr args {

   puts "rvr: $args"
   return


   playMsg "rwy";
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


# airport is closed due to snow
proc snowclosed {} {
   playMag "aiport";
   playMag "closed";
   playMsg "due_to"
   playMsg "sn";
   playSilence 200;
}


# RWY is clear
proc all_rwy_clear {} {
  playMsg "all";
  playMsg "runways";
  playMsg "clr";
  playSilence 200;
}


# Runway designator
proc runway args {
  puts "runway: $args"
  return



  foreach item $args {
    if [regexp {(\d+)} $item] {
      spellNumber $item;
    } else {
      playMsg $item;
    }
    playSilence 100;
  }
  playSilence 200;
}


# time
proc utime {utime} {

   puts "utime: $utime"
   return

   playNumber $utime;
   playSilence 100;
   playMsg "utc";
   playSilence 200;
}


# vv100 -> "vertical view (ceiling) 1000 feet"
proc ceiling {param} {

   puts "ceiling: $param"
   return


   playMsg "ca";
   playSilence 100;
   sayNumber $param;
   playSilence 100;
   playMsg "unit_feet";
   playSilence 200;
}


# QNH
proc qnh {value} {

   puts "qnh: $value"
   return

  playMsg "qnh";
  if {$value == 1000} {
     playNumber 1;
     playMsg "thousand";
  } else {
     spellNumber $value;
  }
  playMsg "unit_hPa";
  playSilence 200;
}


# altimeter
proc altimeter {value} {
  puts "altimeter: $value"
  return


  playMsg "altimeter";
  playSilence 100;
  spellNumber $value;
  playMsg "unit_inches";
  playSilence 200;
}


# trend
proc trend args {

  puts "trend: $args"
  return

  playMsg "trend";
  foreach item $args {
    playMsg $item;
    playSilence 100;
  }
  playSilence 200;
}


# clouds with arguments
proc clouds {obs height {cbs ""}} {
  puts "clouds: $obs $height $cbs"
  return



  playMsg $obs;
  playSilence 100;
  sayNumber $height;
  playSilence 100;
  playMsg "unit_feet";

  if {[string length $cbs] > 0} {
    playMsg $cbs;
  }
  playSilence 200;
}


# temporary weather obscuration
proc tempo_obscuration {from until} {
  puts "tempo_obscuration: $from $until"
  return
  
  playMsg "tempo";
  playSilence 100;
  playMsg "obsc";
  playSilence 200;
  playMsg "from";
  playNumber $from;
  playSilence 200;
  playMsg "to";
  playSilence 100;
  playNumber $until;
  playSilence 200;
}


# max day temperature
proc max_daytemp {deg time} {

  puts "max_daytemp: $deg $time"
  return

  playMsg "predicted";
  playSilence 50;
  playMsg "maximal";
  playSilence 50;
  playMsg "daytime_temperature";
  playSilence 150;
  playNumber $deg;
  playMsg "unit_degrees";
  playSilence 150;
  playMsg "at";
  playSilence 50;
  playNumber $time;
  playSilence 200;
}


# min day temperature
proc min_daytemp {deg time} {

  puts "min_daytemp: $deg $time"
  return

  playMsg "predicted";
  playSilence 50;
  playMsg "minimal";
  playSilence 50;
  playMsg "daytime_temperature";
  playSilence 150;
  spellNumber $deg;
  playMsg "unit_degrees";
  playSilence 150;
  playMsg "at";
  playSilence 50;
  playNumber $time;
  playSilence 200;
}


# Maximum temperature in RMK section
proc rmk_maxtemp {val} {
  puts "rmk_maxtemp: $val"
  return

  playMsg "maximal";
  playMsg "temperature";
  playMsg "last";
  playNumber 6;
  playMsg "hours";
  if {$val < 0} {
    playMsg "minus";
  }
  spellNumber $val;
  playMsg "unit_degrees";
  playSilence 200;
}


# Minimum temperature in RMK section
proc rmk_mintemp {val} {

  puts "rmk_mintemp: $val"
  return

  playMsg "minimal";
  playMsg "temperature";
  playMsg "last";
  playNumber 6;
  playMsg "hours";
  if {$val < 0} {
    playMsg "minus";
  }
  spellNumber $val;
  playMsg "unit_degrees";
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

  puts "rmk_pressure: val=$val args=$args"
  return


  playMsg "pressure";
  playMsg "tendency";
  playMsg "next";
  playNumber 3;
  playMsg "hours";
  playSilence 150;
  playNumber $val;
  playSilence 150;
  playMsg "unit_mbs";
  playSilence 250;

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


# precipitation last hours in RMK section
proc rmk_precipitation {hour val} {
  
  puts "rmk_precipitation: hour=$hour val=$val"
  return
  
  
  playMsg "precipitation";
  playMsg "last";

  if {$hour == "1"} {
     playMsg "hour";
  } else {
     playNumber $hour;
     playMsg "hours";
  }

  playSilence 150;
  playNumber $val;
  playMsg "unit_inches";
  playSilence 200;
}

# precipitations in RMK section
proc rmk_precip {args} {

  puts "rmk_precip: $args"
  return


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

  puts "rmk_minmaxtemp: $max $min"
  return

  playMsg "daytime";
  playMsg "temperature";
  playMsg "maximum";
  if { $max < 0} {
     playMsg "minus";
     set max [string trimleft $max "-"];
  }
  spellNumber $min;
  playMsg "unit_degrees";

  playMsg "minimum";
  if { $min < 0} {
     playMsg "minus";
     set min [string trimleft $min "-"];
  }
  spellNumber $max;
  playMsg "unit_degrees";
  playSilence 200;
}


# recent temperature and dewpoint in RMK section
proc rmk_tempdew {temp dewpt} {

  puts "rmk_tempdew: $temp $dewpt"
  return

  playMsg "re";
  playMsg "temperature";
  if { $temp < 0} {
     playMsg "minus";
     set temp [string trimleft $temp "-"];
  }

  spellNumber $temp;
  playMsg "unit_degrees";
  playSilence 200;
  playMsg "dewpoint";
  if { $dewpt < 0} {
     playMsg "minus";
     set dewpt [string trimleft $dewpt "-"];
  }
  spellNumber $dewpt;
  playMsg "unit_degrees";
  playSilence 200;
}


# wind shift
proc windshift {val} {
  puts "windshift: $val"
  return


  playMsg "wshft";
  playSilence 100;
  playMsg "at";
  playSilence 100;
  playNumber $val;
  playSilence 200;
}

# QFE value
proc qfe {val} {
  puts "qfe: $val"
  return

  playMsg "qfe";
  spellNumber $val;
  playMsg "unit_hPa";
  playSilence 200;
}

# runwaystate
proc runwaystate args {

  puts "runwaystate: $args"
  return


  foreach item $args {
    if [regexp {(\d+)} $item] {
      sayNumber $item;
    } else {
      playMsg $item;
    }
    playSilence 200;
  }
  playSilence 200;
}


# output numbers
proc sayNumber { number } {

  puts "sayNumber: $number"
  return

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
  if [file exists "$langdir/MetarInfo/$icao.wav"] {
    playMsg $icao;
  } else {
    spellWord $icao;
  }
  playSilence 100;
  playMsg "airport";
}


# say preconfigured airports
proc airports args {
  global langdir;
#  global lang;
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
     playSilence 100;
  }
  playSilence 200;
}


# say clouds with covering
proc cloudtypes {} {

  puts "cloudtypes: $args"
  return
  
variable a 0;
  variable l [llength $args];

  while {$a < $l} {
    set msg [lindex $args $a];
    playMsg "cld_$msg";
    playMsg "covering";
    incr a;
    playNumber [lindex $args $a];
    playMsg "eighth";
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
