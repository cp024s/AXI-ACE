# Set source directory
set src_dir "src"
set sv_files [glob -nocomplain $src_dir/*.sv]

# Check if source files exist
if {[llength $sv_files] == 0} {
    puts "ERROR: No Verilog/SystemVerilog files found in $src_dir"
    exit 1
}

# Load Verilog/SystemVerilog files
read_verilog -sv $sv_files

# Set the top module (modify if needed)
synth_design -top ace_ccu_top -part xc7z020clg400-1

# Save synthesis checkpoint
write_checkpoint -force ../build/synth.dcp

# Generate reports
report_utilization -file ../build/utilization.rpt
report_timing -file ../build/timing.rpt

exit