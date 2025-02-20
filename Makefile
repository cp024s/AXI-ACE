# Set Vivado as the default tool
VIVADO      ?= vivado
XSIM        ?= xsim

# Define testbenches
TBS         ?= ace_ccu_top \
               ace_ccu_top_sanity

# Create log file names for testbenches
LOG_DIR     := logs
SIM_TARGETS := $(addsuffix .log,$(addprefix $(LOG_DIR)/sim-,$(TBS)))

.SHELL: bash

.PHONY: help all sim_all clean

help:
	@echo ""
	@echo "synth.log:   Runs synthesis using Vivado"
	@echo "compile.log: Compiles and elaborates design using Vivado XSIM"
	@echo "sim-#TB#.log: Runs simulation for a given testbench, available TBs are:"
	@echo "$(addprefix ###############-#,$(TBS))" | sed -e 's/ /\n/g' | sed -e 's/#/ /g'
	@echo "sim_all: Runs all testbenches"
	@echo ""
	@echo "clean:    Removes generated files"
	@echo ""

# Run everything: synthesis, compilation, and simulation
all: $(LOG_DIR)/compile.log $(LOG_DIR)/synth.log sim_all

# Run all testbenches
sim_all: $(SIM_TARGETS)

# Ensure log directory exists
$(LOG_DIR):
	mkdir -p $(LOG_DIR)

# Run synthesis using Vivado
$(LOG_DIR)/synth.log: | $(LOG_DIR)
	$(VIVADO) -mode batch -source scripts/synth.tcl | tee $@
	(! grep -n "ERROR" $@ || exit 0)

# Compile and elaborate the design
$(LOG_DIR)/compile.log: | $(LOG_DIR)
	$(VIVADO) -mode batch -source scripts/compile_xsim.tcl | tee $@
	(! grep -n "ERROR" $@ || exit 0)

# Run simulation for a specific testbench
$(LOG_DIR)/sim-%.log: $(LOG_DIR)/compile.log
	$(XSIM) $* --runall | tee $@
	(! grep -n "ERROR" $@ || exit 0)
	(! grep -n "FATAL" $@ || exit 0)

# Clean up generated files
clean:
	rm -rf $(LOG_DIR)
