# @author vladimir@tsurkanenko.ru
# aka circool
# aka R2ADU

# Запускается процедура ручной идентификации
# *** ERROR: Unable to handle event: SimplexLogic::manual_identification in logic SimplexLogic (invalid command name "spellWord")



# Logic
namespace eval Logic {

	# Начальный запуск программы
	proc startup {} {
		global mycall;
		# Подготовить переменные для ананса текущего времени
		set current_time [clock seconds]
		set hour [clock format $current_time -format "%H"]
		set minute [clock format $current_time -format "%M"]

		# Сообщить что программа запущена, передать короткий анонс и сообщить текущее время
		# playMsg "Core" "online_short"
		# spellWord $mycall
		# send_short_ident
		# playSilence 250;
		# playMsg "Core" "the_time_is";
		# playTime $hour $minute;
		# playSilence 500;

		puts "Программа запущена"

	}

	# Ручная идентификация
	proc manual_identification {} {
		puts "Запускается процедура ручной идентификации";
		global mycall;
		global report_ctcss;
		global active_module;
		global loaded_modules;
		variable CFG_TYPE;
		variable prev_ident;

		set epoch [clock seconds];
		set hour [clock format $epoch -format "%k"];
		regexp {([1-5]?\d)$} [clock format $epoch -format "%M"] -> minute;
		set prev_ident $epoch;

		# playMsg "Core" "online_short";
		# spellWord $mycall;
		if {$CFG_TYPE == "Repeater"} {
			playMsg "Core" "repeater";
		}
		playSilence 250;

		playMsg "Core" "the_time_is";
		playTime $hour $minute;
		playSilence 250;

		if {$report_ctcss > 0} {
			playMsg "Core" "pl_is";
			playFrequency $report_ctcss
			playSilence 300;
		}
		


		if {$active_module != ""} {
			playMsg "Core" "active_module";
			playMsg $active_module "name";
			playSilence 250;

			set func "::";
			append func $active_module "::status_report";
			if {"[info procs $func]" ne ""} {
				$func;
			}
		} else {
			foreach module [split $loaded_modules " "] {
				set func "::";
				append func $module "::status_report";
				if {"[info procs $func]" ne ""} {
					$func;
				}
			}
		}
		
		playSilence 400;
		foreach module [split $loaded_modules " "] {
			if { $module ==  "Help"} {
				playMsg "Default" "press_0_for_help"
			}
		}
	}

	
	

}