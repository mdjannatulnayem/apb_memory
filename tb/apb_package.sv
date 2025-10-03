// This package defines global parameters used throughout the APB verification environment.
// Centralizing these parameters here allows for easy configuration of the testbench
// to match different DUT settings.
package apb_package;
    // Note: The testbench address width is set to 20, which is a subset of the
    // DUT's default 32-bit address bus. This focuses verification on a 1MB address space.
    parameter int           ADDR_W = 20; // Address bus width for the test environment.
    parameter int           DATA_W = 64; // Data bus width.
    parameter int           MEM_SIZE_K = 64; // Memory size in Kilobytes (e.g., 64 for 64KB).
    parameter int unsigned  BASE_ADDR = 0; // Base address of the APB memory slave.
endpackage