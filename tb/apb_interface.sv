// This interface encapsulates all the signals for the AMBA APB protocol.
// It serves as a single connection point between the DUT and the testbench.
// It also contains SystemVerilog Assertions (SVA) to verify that the
// communication between the master and slave adheres to the APB protocol rules.

import apb_package::*;


interface apb_interface (input bit PCLK);

    // --- Master Signals (driven by testbench driver) ---
    logic                   PRESETn;        // Active-low reset
    logic                   PSELx;          // Select signal for the slave
    logic                   PENABLE;        // Indicates the access phase of a transfer
    logic                   PWRITE;         // Indicates a write (1) or read (0) transfer
    logic   [ADDR_W-1:0]    PADDR;          // Address bus
    logic   [DATA_W-1:0]    PWDATA;         // Write data bus
    logic   [DATA_W/8-1:0]  PSTRB;          // Write strobes (one per byte of PWDATA)

    // --- Slave Signals (driven by DUT) ---
    logic   [DATA_W-1:0]    PRDATA;         // Read data bus
    logic                   PREADY;         // Indicates that the slave is ready to complete the transfer
    logic                   PSLVERR;        // Indicates a slave error has occurred


    // --- SVA Properties: Defining APB Protocol Rules ---

    // Property 1: In the SETUP phase (PSELx=1, PENABLE=0), the next state must be
    // the ACCESS phase (PENABLE=1) if PSELx remains high.
    property apb_sel_enable_assert;
        @(posedge PCLK) disable iff(!PRESETn)
        (PSELx && !PENABLE) |=> (PSELx && PENABLE);
    endproperty

    // Property 2: Once in the ACCESS phase (PSELx=1, PENABLE=1), the master must
    // hold these signals until the slave indicates it is ready (PREADY=1).
    property apb_pready_assert;
        @(posedge PCLK) disable iff(!PRESETn)
        (PSELx && PENABLE) |-> (PSELx && PENABLE) until_with PREADY;
    endproperty

    // Property 3: The slave error signal (PSLVERR) must only be asserted during
    // the final cycle of a transfer (when PSELx, PENABLE, and PREADY are all high).
    property apb_pslverr_assert;
        @(posedge PCLK) disable iff(!PRESETn)
        PSLVERR |-> ##0 (PSELx && PENABLE && PREADY);
    endproperty

    // Property 4: During reset (PRESETn=0), all bus signals should be driven to
    // their inactive (zero) state.
    property apb_reset_assert;
        @(posedge PCLK) disable iff(PRESETn)
        (!PRESETn) |-> ##1 (PADDR == 0 && PWDATA == 0 && PRDATA == 'z && PENABLE == 0 
        && PSELx == 0 && PWRITE == 0 && PREADY == 0 && PSLVERR == 0);
    endproperty

    // Property 5: For a valid write transfer, the write data (PWDATA) must remain
    // stable throughout the ACCESS phase until the transfer completes (PREADY=1).
    property apb_valid_write_assert;
        @(posedge PCLK) disable iff(!PRESETn)
        (PSELx && PWRITE && !PSLVERR) |-> ($stable(PWDATA) until_with PREADY);
    endproperty

    // Property 6: For a valid read transfer, the read data (PRDATA) must be stable
    // on the cycle that the transfer completes (when PREADY is asserted).
    property apb_valid_read_assert;
        @(posedge PCLK) disable iff(!PRESETn)
        (PSELx && PENABLE && !PWRITE && !PSLVERR) |-> ($stable(PRDATA) until_with PREADY);
    endproperty



    // --- SVA Assertions: Instantiating the Properties ---
    // Each assertion instantiates one of the properties defined above and provides
    // an error message to be displayed if the property fails.

    assert property (apb_sel_enable_assert)
        else $error("PENABLE not asserted in cycle after PSELx HIGH");

    assert property (apb_pready_assert)
        else $error("PREADY not asserted while PSELx & PENABLE HIGH");

    assert property (apb_pslverr_assert)
        else $error("PSLVERR asserted without valid transfer");

    assert property (apb_reset_assert)
        else $error("Signals not reset correctly during PRESETn LOW");

    assert property (apb_valid_write_assert)
        else $error("PWDATA not stable during write transfer");

    assert property (apb_valid_read_assert)
        else $error("PRDATA not stable during read transfer");


endinterface