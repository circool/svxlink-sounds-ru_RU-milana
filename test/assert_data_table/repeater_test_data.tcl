# Logig procs:
	# startup
	# no_such_module
	# manual_identification
	# send_rgr_sound
	# macro_empty
	# macro_not_found
	# macro_syntax_error
	# macro_module_not_found
	# macro_module_activation_failed
	# macro_another_active_module
	# unknown_command
	# command_failed
	# activating_link
	# deactivating_link
	# link_not_active
	# link_already_active
	# transmit
	# squelch_open
	# every_minute
	# every_second
	# checkPeriodicIdentify
	# dtmf_digit_received
	# dtmf_cmd_received
	# activating_qso_recorder
	# deactivating_qso_recorder
	# qso_recorder_not_active
	# qso_recorder_already_active
	# qso_recorder_timeout_activate
	# qso_recorder_timeout_deactivate
	# set_language
	# list_languages
	# logic_online
	# config_updated
	# remote_cmd_received x2

# unique procs:	

# необходимо установить $logic_name <== RepeaterLogic
set dataTests {
	{"startup" "на частоте работает репитер Роман двойка Анна Дмитрий Ульяна дробь Роман"}
	{"manual_identification" "на частоте работает репитер Роман двойка Анна Дмитрий Ульяна дробь Роман Текущее время тринадцать часов сорок семь минут Частота субтона восемьдесят пять целых и пять десятых Герц активный модуль Эхо линк ноль подключенных станций"}
	{"send_short_ident" "-1" "-1" "репитер Роман двойка Анна Дмитрий Ульяна дробь Роман"}
	{"send_long_ident" "11" "51" "репитер Роман двойка Анна Дмитрий Ульяна дробь Роман Текущее время одиннадцать часов пятьдесят одна минута"}
	{"logic_online" "1" "на частоте работает репитер Роман двойка Анна Дмитрий Ульяна дробь Роман"}
	{"logic_online" "0" ""}
	{"repeater_up" "SQL_CLOSE" ""}
	{"repeater_down" "IDLE" "звучит тон 400 900 50
звучит тон 360 900 50"}
	{"repeater_down" "SQL_FLAP_SUP" "репитер выключается из-за помех"}
	{"repeater_idle" "звучит тон 1100 150 100
звучит тон 1200 150 100
звучит тон 1100 75 100
звучит тон 1200 75 100
звучит тон 1100 38 100
звучит тон 1200 38 100
звучит тон 1100 19 100
звучит тон 1200 19 100
звучит тон 1100 9 100
звучит тон 1200 9 100
звучит тон 1100 5 100
звучит тон 1200 5 100
звучит тон 1100 2 100
звучит тон 1200 2 100
звучит тон 1100 1 100
звучит тон 1200 1 100"}
	{"identify_nag" "Пожалуйста, идентифицируйте себя"}

}