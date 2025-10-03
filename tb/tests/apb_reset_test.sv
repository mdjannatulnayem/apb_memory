//--------------------------------------------------------------------------------------------
// Class: apb_reset_test
//
// This test verifies the DUT's behavior during and after a reset.
// It holds the DUT in a reset state (by keeping PRESETn low) and attempts to
// perform write and read operations. The expected outcome is that the memory
// ignores these transactions, which will be verified by the scoreboard.
//--------------------------------------------------------------------------------------------
class apb_reset_test extends apb_base_test;

    // Constructor: Initializes the test.
    // @param inf - Virtual interface handle for the APB bus.
    function new(virtual apb_interface inf);
        super.new(inf);
        $display("[%0t] :: apb_reset_test :: Reset Test Constructed", $time);
    endfunction

    // Task: run_test
    // This task defines the main stimulus sequence for the reset test.
    // It holds the DUT in reset and attempts a write/read sequence.
    task run_test();

        // Apply and hold reset (PRESETn = 0).
        // The DUT should ignore any subsequent APB transactions.
        reset(1'b0);

        // Attempt to write to an address while reset is active.
        // This transaction should be ignored by the DUT.
        write('h0000_0008, 'hC0DE_BEEF_F00D_DEAD, 'hFF);
        // Attempt to read from the same address. This should also be ignored.
        read('h0000_00008);

        // Generate the final report. The scoreboard should report zero successful
        // transactions, as the monitor should not have captured any valid operations.
        env.scb.report_generate();
        
    endtask

endclass