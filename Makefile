# Set Vivado and XSIM as default tools
VIVADO      ?= vivado
XSIM        ?= xsim

# Define testbenches
TBS         ?= ace_ccu_top \
               ace_ccu_top_sanity

# Create log file names for testbenches
LOG_DIR     := logs
BUILD_DIR   := build
SIM_TARGETS := $(addsuffix .log,$(addprefix $(LOG_DIR)/sim-,$(TBS)))

# Use bash shell
.SHELL: bash

.PHONY: help all synth compile sim sim_all clean

help:
	@echo ""
	@echo "Available targets:"
	@echo "  make synth     - Runs synthesis and generates reports"
	@echo "  make compile   - Compiles and elaborates design using XSIM"
	@echo "  make sim       - Runs simulation"
	@echo "  make sim_all   - Runs all testbenches"
	@echo "  make clean     - Removes generated files"
	@echo ""

# Run everything: synthesis, compilation, and simulation
all: $(LOG_DIR)/synth.log $(LOG_DIR)/compile.log sim_all

# Run all testbenches
sim_all: $(SIM_TARGETS)

# Ensure log and build directories exist
$(LOG_DIR) $(BUILD_DIR):
	mkdir -p $(LOG_DIR) $(BUILD_DIR)

# Run synthesis using Vivado
$(LOG_DIR)/synth.log: | $(LOG_DIR) $(BUILD_DIR)
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

# Run a general simulation
sim: | $(LOG_DIR)
	$(VIVADO) -mode batch -source scripts/sim.tcl | tee $(LOG_DIR)/sim.log
	(! grep -n "ERROR" $(LOG_DIR)/sim.log || exit 0)
	(! grep -n "FATAL" $(LOG_DIR)/sim.log || exit 0)

# Clean up generated files
clean:
	rm -rf $(LOG_DIR) $(BUILD_DIR)
	rm -f *.log *.jou *.str *.wdb
