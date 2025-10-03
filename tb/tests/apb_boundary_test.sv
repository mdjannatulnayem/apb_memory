//--------------------------------------------------------------------------------------------
// Class: apb_boundary_test
//
// This test verifies the functionality of the APB memory at its address boundaries.
// It performs write and read operations at the lowest and highest possible aligned
// addresses to ensure the memory map is correctly handled by the DUT.
//--------------------------------------------------------------------------------------------
class apb_boundary_test extends apb_base_test;

    // Constructor: Initializes the test.
    // @param inf - Virtual interface handle for the APB bus.
    function new(virtual apb_interface inf);
        super.new(inf);
        $display("[%0t] :: apb_boundary_test :: Boundary Test Constructed", $time);
    endfunction

    // Task: run_test
    // This task defines the sequence of operations for the boundary address test.
    // It writes to and reads from the first and last word-aligned addresses of the memory.
    task run_test();

        // Apply reset to the DUT.
        reset(1'b1);
        
        // Write to the first address of the memory (0).
        // Assuming BASE_ADDR is 0.
        write('d0, 'h1234_5678_90AB_C0DE, 'hFF);

        // Write to the last word-aligned address of the 64KB memory.
        // For a 64KB memory (65536 bytes) and 8-byte data width, the last address is 65535.
        // The last word-aligned address starts at 65536 - 8 = 65528.
        write('d65528, 'h1234_5678_90AB_BEEF, 'hFF);

        // Read from the first address to verify the write.
        read('d0);
        // Read from the last word-aligned address to verify the write.
        read('d65528);

        // Generate the final report from the scoreboard.
        env.scb.report_generate();
        
    endtask

endclass