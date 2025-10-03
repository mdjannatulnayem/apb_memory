//--------------------------------------------------------------------------------------------
// Class: apb_violation_test
//
// This test is intended to verify the DUT's behavior when an APB protocol
// violation occurs.
//
// NOTE: The current implementation does not generate a protocol violation. It performs
// a standard write and read operation. To create a true violation test, a dedicated
// driver task would be needed to, for example, change PADDR or PWRITE during the
// ACCESS phase of a transfer.
//--------------------------------------------------------------------------------------------
class apb_violation_test extends apb_base_test;

    // Constructor: Initializes the test.
    // @param inf - Virtual interface handle for the APB bus.
    function new(virtual apb_interface inf);
        super.new(inf);
        $display("[%0t] :: apb_violation_test Constructed", $time);
    endfunction

    // Task: run_test
    // This task defines the main stimulus sequence for the test.
    task run_test();

        // Apply reset to the DUT.
        reset(1'b1);

        // Perform a standard write to an aligned address.
        write('d8, 'h1234_5678_90AB_CDEF, 'hFF);
        // Perform a standard read from the same address.
        read('d8);

        // Generate the final report from the scoreboard.
        env.scb.report_generate();
        
    endtask

endclass