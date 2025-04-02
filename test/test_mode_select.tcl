set script_dir [file dirname [file normalize [info script]]]
set mock_file [file join $script_dir "test" "mocks.tcl"]
set dict_file [file join $script_dir "test" "dict.tcl"]

if {[file exists $mock_file] && [file exists $dict_file]} {
    puts "\n\033\[31mВключен режим имитации голосовых оповещений\033\[0m"
    source $dict_file
    source $mock_file
    # puts "dict.tcl загружен ($dict_file) и mocks.tcl загружен ($mock_file)"
} else {
    
    puts "\n\033\[31mСистема работает в обычном режиме\033\[0m"
}