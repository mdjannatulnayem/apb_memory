
class apb_b2b_wr_test extends apb_base_test;

    int rand_addr;
    
    function new(virtual apb_interface inf);
        super.new(inf);
        $display("[%0t] :: apb_b2b_wr_test :: Back to Back Write Test Constructed", $time);
    endfunction

    task run_test();
        int num_words = (MEM_SIZE_K * 1024) - 1;
        reset(1'b1);

       for(int i = 0; i < num_words; i++) begin

            // Generate a random, aligned address within the valid memory range.
            rand_addr = $urandom_range(BASE_ADDR, BASE_ADDR + num_words);

            // Perform two consecutive write operations to the same address.
            write(rand_addr, {$urandom(), $urandom()}, 'hFF);
            write(rand_addr, {$urandom(), $urandom()}, 'hFF);

            // Read from the same address to verify that the second write was successful.
            read(rand_addr);

            write(rand_addr, {$urandom(), $urandom()}, 'hFF);

            // Read again to verify the subsequent write operation.
            read(rand_addr);
            
       end

        env.scb.report_generate();
    endtask

endclass