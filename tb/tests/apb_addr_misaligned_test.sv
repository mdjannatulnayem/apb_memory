

class apb_addr_misaligned_test extends apb_base_test;
    // Constructor: Initializes the test.
    // @param inf - Virtual interface handle for the APB bus.
    function new(virtual apb_interface inf);
        super.new(inf);
        $display("[%0t] :: apb_addr_misaligned_test Constructed", $time);
    endfunction

    // Task: run_test
    // This task defines the sequence of operations for the misaligned address test.
    // It attempts to perform write and read operations at misaligned addresses
    // to verify the DUT's error handling for such cases.
    task run_test();
        // Calculate the total number of words in the memory, based on MEM_SIZE_K and BASE_ADDR.
        // This defines the upper bound for address generation.
        int num_words = BASE_ADDR + (MEM_SIZE_K * 1024) - 1;
        
        // Apply reset to the DUT.
        reset(1'b1);

        // Loop through a range of addresses to perform write and read operations.
        for (int i = 0; i < num_words; i++) begin
            // Check if the current address 'i' is misaligned.
            // For a 64-bit data bus (8 bytes), an address is misaligned if it's not a multiple of 8.
            if(i%8 != 0) begin
                // Perform a write operation to the misaligned address.
                // Data is randomized using $urandom, and strobe is also randomized.
                write(i, { $urandom(), $urandom() }, $urandom_range(0, 255));
                // Perform a read operation from the same misaligned address.
                read(i);
            end
        end

        // Generate the final report from the scoreboard, summarizing pass/fail counts.
        env.scb.report_generate();
    endtask
    
endclass