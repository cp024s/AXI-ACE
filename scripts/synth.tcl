# Load Verilog/SystemVerilog files
read_verilog -sv [ /src/*.sv]

# Set the top module (modify if needed)
synth_design -top ace_ccu_top -part xc7z020clg400-1

# Save synthesis checkpoint
write_checkpoint -force ../build/synth.dcp

# Generate reports
report_utilization -file ../build/utilization.rpt
report_timing -file ../build/timing.rpt

exit
