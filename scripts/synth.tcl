# Get project root dynamically
set project_root [file normalize [file dirname [info script]]/..]

# Set source directory
set src_dir "$project_root/src"
set sv_files [glob -nocomplain "$src_dir/*.sv"]

# Check if source files exist
if {[llength $sv_files] == 0} {
    puts "❌ ERROR: No SystemVerilog files found in $src_dir"
    exit 1
}

# Load Verilog/SystemVerilog files
read_verilog -sv $sv_files

# Set the top module (modify the part number if needed)
puts "⚙️  Synthesizing the design..."
synth_design -top ace_ccu_top -part xc7z020clg400-1

# Save synthesis checkpoint
puts "💾 Saving synthesis checkpoint..."
write_checkpoint -force "$project_root/build/synth.dcp"

# Generate reports
puts "📊 Generating utilization and timing reports..."
report_utilization -file "$project_root/build/utilization.rpt"
report_timing -file "$project_root/build/timing.rpt"

exit
