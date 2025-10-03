//--------------------------------------------------------------------------------------------
// Class: apb_random_wr_test
//
// This test verifies memory functionality by performing write and read operations
// to random addresses within the memory space. For each generated address, it writes
// random data and then immediately reads it back to confirm data integrity.
//
// NOTE: This test generates random byte addresses, which may include misaligned
// addresses. It relies on the DUT and scoreboard to handle these cases correctly.
// A separate test, `apb_addr_misaligned_test`, specifically targets misaligned accesses.
//--------------------------------------------------------------------------------------------
class apb_random_wr_test extends apb_base_test;

    // Class property to store the randomly generated address.
    int rand_addr;

    // Constructor: Initializes the test.
    // @param inf - Virtual interface handle for the APB bus.
    function new(virtual apb_interface inf);
        super.new(inf);
        $display("[%0t] :: apb_random_wr_test :: Random WR Test Constructed", $time);
    endfunction

    // Task: run_test
    // This task defines the main stimulus sequence for the test.
    // It applies a reset and then performs a series of random write-then-read operations.
    task run_test();
        // Calculate the highest byte address in the memory.
        // For a 64KB memory, this will be 65535.
        int num_words = (MEM_SIZE_K * 1024) - 1;

        // Apply reset to the DUT.
        reset(1'b1);

        // Loop a large number of times to perform random write-read operations.
        for (int i = 0; i < num_words; i++) begin
            // Generate a random byte address within the entire memory range.
            rand_addr = $urandom_range(BASE_ADDR, BASE_ADDR + num_words);

            // Write random data to the generated address.
            write(rand_addr, { $urandom(), $urandom() }, 'hFF);
            // Read from the same address to verify the write operation.
            read(rand_addr);
        end

        // Generate the final report from the scoreboard.
        env.scb.report_generate();
    endtask

endclass
