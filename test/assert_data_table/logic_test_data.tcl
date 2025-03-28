set dataTests {
	
	{"no_such_module" "2" "модуль два не найден"}	
	{"send_rgr_sound" "звучит тон 440 500 100"}
	{"macro_empty" "получена пустая макрокоманда"}
	{"macro_not_found" "макрокоманда не найдена"}
	{"macro_syntax_error" "макрокоманда содержит ошибки"}
	{"macro_module_not_found" "макрокоманда содержит ошибки модуль не найден"}
	{"macro_module_activation_failed" "не удалось включить модуль"}
	{"macro_another_active_module" "невозможно включить модуль пока активен модуль Эхо линк"}
	{"unknown_command" "command" "неизвестная команда Центр Ольга Михаил Михаил Анна Николай Дмитрий"}
	{"command_failed" "command" "не удалось выполнить команду Центр Ольга Михаил Михаил Анна Николай Дмитрий"}
	{"activating_link" "RUSSIA" "выполняется соединение с Роман Ульяна Семен Семен Иван Анна"}
	{"deactivating_link" "RUSSIA" "разрывается соединение с Роман Ульяна Семен Семен Иван Анна"}
	{"link_not_active" "RUSSIA" "линк Роман Ульяна Семен Семен Иван Анна не активен"}
	{"link_already_active" "name" "линк Николай Анна Михаил Елена уже активен"}
	{"dtmf_digit_received" "3" "100" "получена DTMF посылка 3 продолжительностью в 100 миллисекунд"}
	{"qso_recorder_not_active" "Q S O рекордер не активен"}
	{"qso_recorder_already_active" "Q S O рекордер уже активен"}
	{"qso_recorder_timeout_activate" "Q S O рекордер подключен по тайм-ауту"}
	{"qso_recorder_timeout_deactivate" "Q S O рекордер отключен по тайм-ауту"}
	{"set_language" "ru_Ru" "${logic_name}: Setting language ru_Ru (NOT IMPLEMENTED)"}
	{"list_languages" "${logic_name}: Available languages: (NOT IMPLEMENTED)"}	
	{"config_updated" "test" "2" "Переменная конфигурации test изменила значение на 2"}
	{"remote_cmd_received" "${active_module}" "123" "Модулем ${active_module} получена команда 123"}
	{"remote_received_tg_updated" "${active_module}" "112" "От логического ядра ${active_module} принята разговорная группа 112"}
}