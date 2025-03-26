# процедуры вызывающие модуль Module
set dataTests {
	{"DtmfRepeater::printInfo" "msg" "DtmfRepeater: msg"}
	{"EchoLink::printInfo" "msg" "EchoLink: msg"}
	{"Frn::printInfo" "msg" "Frn: msg"}
	{"Help::printInfo" "msg" "Help: msg"}
	{"MetarInfo::printInfo" "msg" "MetarInfo: msg"}
	{"Parrot::printInfo" "msg" "Parrot: msg"}
	{"PropagationMonitor::printInfo" "msg" "PropagationMonitor: msg"}
	{"TclVoiceMail::printInfo" "msg" "TclVoiceMail: msg"}
	{"Trx::printInfo" "msg" "Trx: msg"}
	
	{"EchoLink::activating_module" "включается модуль Эхо линк"}
	{"Parrot::activating_module" "включается модуль Попугай"}
	{"PropagationMonitor::activating_module" "включается модуль Мониторинг прохождения радиоволн"}
	{"SelCallEnc::activating_module" "включается модуль Декодер селективного вызова"}
	{"DtmfRepeater::activating_module" "включается модуль DTMF репитер"}
	{"Frn::activating_module" "включается модуль Эф Эр Эн"}
	{"MetarInfo::activating_module" "включается модуль метеосводка"}
	
	{"EchoLink::deactivating_module" "выключается модуль Эхо линк"}
	{"Parrot::deactivating_module" "выключается модуль Попугай"}
	{"PropagationMonitor::deactivating_module" "выключается модуль Мониторинг прохождения радиоволн"}
	{"SelCallEnc::deactivating_module" "выключается модуль Декодер селективного вызова"}
	{"DtmfRepeater::deactivating_module" "выключается модуль DTMF репитер"}
	{"Frn::deactivating_module" "выключается модуль Эф Эр Эн"}
	{"MetarInfo::deactivating_module" "выключается модуль метеосводка"}
	
	{"EchoLink::timeout" "модуль Эхо линк отключен по тайм-ауту"}	
	{"Parrot::timeout" "модуль Попугай отключен по тайм-ауту"}	
	{"PropagationMonitor::timeout" "модуль Мониторинг прохождения радиоволн отключен по тайм-ауту"}	
	{"SelCallEnc::timeout" "модуль Декодер селективного вызова отключен по тайм-ауту"}	
	{"DtmfRepeater::timeout" "модуль DTMF репитер отключен по тайм-ауту"}	
	{"Frn::timeout" "модуль Эф Эр Эн отключен по тайм-ауту"}	
	{"MetarInfo::timeout" "модуль метеосводка отключен по тайм-ауту"}	

	{"PropagationMonitor::unknown_command" "1" "---"}	
	{"Frn::unknown_command" "1" "---"}	
	{"EchoLink::unknown_command" "1" "---"}	

	{"EchoLink::play_help" "---"}	
	{"Parrot::play_help" "---"}	
	{"SelCallEnc::play_help" "---"}	
	{"DtmfRepeater::play_help" "Модуль DTMF репитера используется для ретрансляции принятой DTMF последовательности. Он может использоваться для управления другими станциями. Принятые DTMF команды будут ретранслированы без какой-либо обработки.  Для отключения модуля передавайте символ решетки не менее трех секунд. Модуль DTMF репитера используется для ретрансляции принятой DTMF последовательности. Он может использоваться для управления другими станциями. Принятые DTMF команды будут ретранслированы без какой-либо обработки.  Для отключения модуля передавайте символ решетки не менее трех секунд. доступные подкоманды Ошибка: Каталог 'DtmfRepeater' или файл 'help_subcmd' не найдены в словаре."}	
	{"PropagationMonitor::play_help" "---"}	
	{"Frn::play_help" "---"}	
	{"MetarInfo::play_help" "---"}	
	
}