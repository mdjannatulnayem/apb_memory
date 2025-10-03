// This file defines the functional coverage model for the APB interface.
// It uses a standalone covergroup, which is then instantiated within a
// wrapper class for better encapsulation and integration into the testbench.

// Standalone covergroup for APB signals.
// It samples coverage data on every positive edge of the APB clock.
covergroup cg_apb (virtual apb_interface inf) @(posedge inf.PCLK);
    // Ensures that coverage is collected and reported for each instance of this covergroup.
    option.per_instance = 1;


    // Coverpoint for the PSELx (select) signal.
    PSELx_cp : coverpoint inf.PSELx {
        bins sel_active   = {1};
        bins sel_inactive = {0};
    }

    // Coverpoint for the PENABLE (enable) signal.
    PENABLE_cp : coverpoint inf.PENABLE {
        bins enable_active   = {1};
        bins enable_inactive = {0};
    }

    // Coverpoint for the PWRITE (write/read) signal.
    PWRITE_cp : coverpoint inf.PWRITE {
        bins write = {1};
        bins read  = {0};
    }

    // Coverpoint for the PREADY (slave ready) signal.
    PREADY_cp : coverpoint inf.PREADY {
        bins ready     = {1};
        bins not_ready = {0};
    }

    // Coverpoint for the PADDR (address) bus.
    PADDR_cp : coverpoint inf.PADDR {
        // Create 10 automatically distributed bins for addresses within the valid memory range.
        bins valid_range[10] = {[BASE_ADDR : BASE_ADDR + (MEM_SIZE_K*1024 - 1)]};
        // Create bin for addresses outside the valid range
        // to ensure out-of-bounds error handling is tested.
        bins invalid_range = {[BASE_ADDR + MEM_SIZE_K*1024 : BASE_ADDR + MEM_SIZE_K*1024 + 100]};
    }

    // Coverpoint for the PWDATA (write data) bus.
    PWDATA_cp : coverpoint inf.PWDATA {
        // Creates 10 automatically distributed bins across the entire 64-bit data range.
        // This helps verify that a variety of data values are being written.
        bins pwdata_range[10] = {[0 : 64'hFFFF_FFFF_FFFF_FFFF]}; 
    }



    // Coverpoint for the PRDATA (read data) bus.
    PRDATA_cp : coverpoint inf.PRDATA {
        // Creates 10 automatically distributed bins across the entire 64-bit data range.
        // This helps verify that a variety of data values are being read back.
        bins prdata_range[10] = {[0 : 64'hFFFF_FFFF_FFFF_FFFF]};    // Lower half of 64-bit
    }

    // Coverpoint for the PSLVERR (slave error) signal.
    PSLVERR_cp : coverpoint inf.PSLVERR {
        bins error      = {1};
        bins no_error   = {0};
    }

    // Cross coverage between address, write data, and the write operation.
    // This is sampled only when a valid transfer is completed (PSEL, PENABLE, and PREADY are high).
    cross_addr_data : cross PADDR_cp, PWDATA_cp, PWRITE_cp iff (inf.PSELx && inf.PENABLE && inf.PREADY) {
        // Exclude combinations where the address is in the invalid range, as these
        // should not result in a successful write and are not meaningful to cross.
        ignore_bins invalid_combo = binsof(PADDR_cp.invalid_range);
    }

endgroup : cg_apb


// The apb_coverage class acts as a wrapper for the covergroup.
// This makes it easier to instantiate and manage the coverage collection
// within the verification environment.
class apb_coverage;

    virtual apb_interface inf;

    // Handle to the standalone covergroup
    cg_apb cg_inst;

    // Constructor: Creates the coverage component.
    // @param inf - The virtual interface handle to be monitored.
    function new(virtual apb_interface inf);
        this.inf = inf;
        // Instantiate the covergroup and pass the interface handle to it.
        cg_inst = new(inf);
    endfunction

    // Task to manually trigger a sample of the covergroup.
    // Note: This is often redundant as the covergroup is set to sample automatically.
    task sample();
        cg_inst.sample();
    endtask

endclass
