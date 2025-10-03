// ==========================================
// RTL
// ==========================================
../src/mem_1024x32.sv
../src/generic_mem.sv
../src/err_gen.sv
../src/apb_fsm.sv
../src/apb_wrapper.sv

// ==========================================
// Utility
// ==========================================
../tb/apb_package.sv
../tb/apb_interface.sv
../tb/packet.sv


// ==========================================
// Classes
// ==========================================
../tb/apb_monitor.sv
../tb/apb_driver.sv
../tb/apb_agent.sv
../tb/apb_scoreboard.sv
../tb/apb_coverage.sv
../tb/apb_environment.sv


// ==========================================
// Tests
// ==========================================
../tb/tests/apb_base_test.sv
../tb/tests/apb_seq_wr_test.sv
../tb/tests/apb_reset_test.sv
../tb/tests/apb_random_wr_test.sv
../tb/tests/apb_slave_error_aor_test.sv
../tb/tests/apb_random_stress_test.sv
../tb/tests/apb_addr_misaligned_test.sv
../tb/tests/apb_boundary_test.sv
../tb/tests/apb_strobe_test.sv
../tb/tests/apb_violation_test.sv
../tb/tests/apb_b2b_wr_test.sv
../tb/tests/apb_single_wr_test.sv

../tb/apb_tb.sv