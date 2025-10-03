# ====== USER CONFIGURATION ======
FILELIST   ?= filelist.f          # Containing design + TB files
TOP        ?= apb_tb              # Top-level testbench module
SIM_NAME   ?= sim_snapshot        # Simulation snapshot name
WAVE_FILE  ?= wave.vcd            # Optional waveform file
COV_DIR    ?= coverage			  # Coverage database directory
COV_REPORT ?= cov_report       	  # Coverage report output directory
TEST       ?= reset				  # Default test if none given
COV        ?= 0                   # Enable coverage (1=yes, 0=no)

# ====== VIVADO SIMULATION TOOLS ======
XVLOG = xvlog --sv
XELAB = xelab
XSIM  = xsim

# ====== TARGETS ======
.PHONY: all compile elab sim gui sim_cov regression clean clean_tcl cov_report

all: sim

# Compile design + testbench
compile:
	$(XVLOG) -f $(FILELIST)

# Elaborate design (normal)
elab: compile
	$(XELAB) $(TOP) -s $(SIM_NAME) --debug typical

# Run simulation (batch)
sim: elab
	$(XSIM) $(SIM_NAME) -runall --testplusarg "TEST=$(TEST) -sv_seed random"

# Run simulation GUI
gui: elab
	$(XSIM) $(SIM_NAME) --gui --testplusarg "TEST=$(TEST)"

# Run simulation with coverage (Vivado 2025)
sim_cov: compile
ifeq ($(COV),1)
	@mkdir -p $(COV_DIR) $(COV_REPORT)
	# Elaborate with coverage enabled
	$(XELAB) $(TOP) -s $(SIM_NAME) --debug typical --cov_db_dir $(COV_DIR)
	# Create TCL script
	@echo "puts \"Running test: $(TEST)\"" > sim_cov.tcl
	@echo "run -all" >> sim_cov.tcl
	@echo "write_xsim_coverage -cov_db_dir $(COV_DIR) -cov_db_name covDB" >> sim_cov.tcl
	@echo "export_xsim_coverage -cov_db_name covDB -cov_db_dir $(COV_DIR) -output_dir $(COV_REPORT)" >> sim_cov.tcl
	# Launch simulation with TEST plusarg
	$(XSIM) $(SIM_NAME) -tclbatch sim_cov.tcl --testplusarg "TEST=$(TEST)" -sv_seed random
	@rm -f sim_cov.tcl
else
	@echo "Coverage is disabled (set COV=1 to enable)"
endif


# Generate coverage report from existing database (no rerun)
cov_report:
ifeq ($(COV),1)
	@mkdir -p $(COV_REPORT)
	@echo "export_xsim_coverage -cov_db_name covDB -cov_db_dir $(COV_DIR) -output_dir $(COV_REPORT)" > cov_export.tcl
	$(XSIM) $(SIM_NAME) -tclbatch cov_export.tcl
	@rm -f cov_export.tcl
else
	@echo "Coverage is disabled (set COV=1 to enable)"
endif


# Clean all build files
clean:
	rm -rf .Xil *.log *.jou *.wdb $(SIM_NAME) $(WAVE_FILE) *.dir *.pb $(COV_DIR) $(COV_REPORT) sim_cov.tcl cov_export.tcl *.vcd *.covdb

# Clean TCL files only
clean_tcl:
	rm -f *.tcl
