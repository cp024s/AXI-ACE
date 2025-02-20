# Print debug message
puts "🔍 Looking for SystemVerilog files in ../src/"

# Get list of SystemVerilog files in src directory
set project_root [file normalize [file dirname [info script]]/..]
set sv_files [glob -nocomplain "$project_root/src/*.sv"]

# Check if files were found
if {$sv_files eq ""} {
    puts "❌ Error: No SystemVerilog files found in $project_root/src/"
    exit 1
} else {
    puts "✅ Found files: $sv_files"
}

# Read the Verilog files
read_verilog -sv $sv_files

# Load constraints file if it exists
puts "📌 Reading constraints file..."
if {[file exists "$project_root/constraints/top.xdc"]} {
    read_xdc "$project_root/constraints/top.xdc"
} else {
    puts "⚠️ Warning: Constraints file not found. Skipping..."
}

# Elaborate the design for simulation
puts "🚀 Elaborating the design..."
xelab ace_ccu_top -s ace_ccu_top_sim

# Run simulation
puts "🎬 Running simulation..."
xsim ace_ccu_top_sim -R

exit
