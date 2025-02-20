# Load Verilog/SystemVerilog source files
read_verilog -sv [glob ../src/*.sv]

# Load constraints (modify path if needed)
read_xdc ../constraints/top.xdc

# Synthesize the design
synth_design -top ace_ccu_top

# Save synthesis checkpoint
write_checkpoint -force ../build/synth.dcp

# Elaborate the design for simulation
xelab ace_ccu_top -s ace_ccu_top_sim

# Run simulation
xsim ace_ccu_top_sim -R

exit
