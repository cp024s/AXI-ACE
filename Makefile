# Set Vivado as the default tool
VIVADO      ?= vivado
XSIM        ?= xsim

# Define testbenches
TBS         ?= ace_ccu_top \
               ace_ccu_top_sanity

# Create log file names for testbenches
SIM_TARGETS := $(addsuffix .log,$(addprefix sim-,$(TBS)))

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
all: compile.log synth.log sim_all

# Run all testbenches
sim_all: $(SIM_TARGETS)

# Create the build directory
build:
	mkdir -p $@

# Run synthesis using Vivado
synth.log: Bender.yml | build
	$(VIVADO) -mode batch -source scripts/synth.tcl | tee ../$@
	(! grep -n "ERROR" $@)

# Compile and elaborate the design
compile.log: Bender.yml | build
	$(VIVADO) -mode batch -source scripts/compile_xsim.tcl | tee ../$@
	(! grep -n "ERROR" $@)

# Run simulation for a specific testbench
sim-%.log: compile.log
	$(XSIM) $* --runall | tee ../$@
	(! grep -n "ERROR" $@)
	(! grep -n "FATAL" $@)

# Clean up generated files
clean:
	rm -rf build
	rm -f  *.log
