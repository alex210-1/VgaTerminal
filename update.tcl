# reload project sources from external editor
# TODO perform diff and only add new sources when this gets too slow

puts "import sources from external editor"

cd [get_property DIRECTORY [current_project]]

add_files -fileset sources_1 "../device"
add_files -fileset sim_1 "../simulation"

puts "done"
