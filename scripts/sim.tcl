# Print debug message
puts "🔍 Looking for SystemVerilog files in ../src/"

# Define project root and source/include directories
set project_root [file normalize [file dirname [info script]]/..]
set src_dir "$project_root/src"
set include_dir "$project_root/include"

# Get list of SystemVerilog files
set sv_files [glob -nocomplain "$src_dir/*.sv"]

# Check if source files exist
if {$sv_files eq ""} {
    puts "❌ Error: No SystemVerilog files found in $src_dir"
    exit 1
} else {
    puts "✅ Found files: $sv_files"
}

# Read Verilog files with include directory
puts "📂 Reading Verilog files with include directory $include_dir"
read_verilog -sv "+incdir+$include_dir" $sv_files

# Load constraints file
puts "📌 Reading constraints file..."
if {[file exists "$project_root/constraints/top.xdc"]} {
    read_xdc "$project_root/constraints/top.xdc"
} else {
    puts "⚠️ Warning: Constraints file not found. Skipping..."
}

# Synthesize the design
puts "🚀 Starting synthesis..."
synth_design -top ace_ccu_top

# Save synthesis checkpoint
puts "💾 Saving synthesis checkpoint..."
write_checkpoint -force "$project_root/build/synth.dcp"

# Elaborate the design for simulation
puts "🔬 Elaborating the design..."
exec xelab ace_ccu_top -s ace_ccu_top_sim

# Run simulation
puts "🎬 Running simulation..."
exec xsim ace_ccu_top_sim -R

exit
