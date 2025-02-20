# Print debug message
puts "Looking for SystemVerilog files in ../src/"

# Get list of SystemVerilog files in src directory
set sv_files [glob -nocomplain ../src/*.sv]

# Check if files were found
if {$sv_files eq ""} {
    puts "Error: No SystemVerilog files found in ../src/"
    exit 1
} else {
    puts "Found files: $sv_files"
}

# Read the Verilog files
read_verilog -sv $sv_files

# Load constraints file
puts "Reading constraints file..."
if {[file exists ../constraints/top.xdc]} {
    read_xdc ../constraints/top.xdc
} else {
    puts "Warning: Constraints file ../constraints/top.xdc not found."
}

# Synthesize the design
puts "Starting synthesis..."
synth_design -top ace_ccu_top

# Save synthesis checkpoint
puts "Saving synthesis checkpoint..."
write_checkpoint -force ../build/synth.dcp

# Elaborate the design for simulation
puts "Elaborating the design for simulation..."
xelab ace_ccu_top -s ace_ccu_top_sim

# Run simulation
puts "Running simulation..."
xsim ace_ccu_top_sim -R

exit
