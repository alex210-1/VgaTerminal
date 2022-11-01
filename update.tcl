puts "import sources from external editor"

cd [get_property DIRECTORY [current_project]]

add_files -fileset sources_1 "../device"
add_files -fileset sim_1 "../simulation"

puts "done"
