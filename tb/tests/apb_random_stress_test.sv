
class apb_random_stress_test extends apb_base_test;

    int strobe;
    int addr;
    longint unsigned data;
    longint unsigned rand_addr;

    function new(virtual apb_interface inf);
        super.new(inf);
        $display("[%0t] :: apb_random_stress_test :: Consecutive Write Test Constructed", $time);
    endfunction

    task run_test();
        int num_words = (MEM_SIZE_K * 1024) - 1;
        
            reset(1'b1);

            for(int i = 0; i < 5; i++) begin
                // Misaligned
                $display("Misaligned Test");
                for (int i = 0; i < num_words; i++) begin
                    if(i%8 != 0) begin
                        write(i, { $urandom(), $urandom() }, $urandom_range(0, 255));
                        read(i);
                    end
                end

                // Back to back
                $display("Back to Back Test");
                for(int i = 0; i < num_words; i++) begin
                    rand_addr = $urandom_range(BASE_ADDR, BASE_ADDR + num_words);
                    write(rand_addr, {$urandom(), $urandom()}, 'hFF);
                    write(rand_addr, {$urandom(), $urandom()}, 'hFF);
                    read(rand_addr);
                    write(rand_addr, {$urandom(), $urandom()}, 'hFF);
                    read(rand_addr);
                end

                // Boundary Test
                $display("Boundary Test");
                write('d0, 'h1234_5678_90AB_C0DE, 'hFF);
                write('d65528, 'h1234_5678_90AB_BEEF, 'hFF);
                read('d0);
                read('d65528);

                // Random write-read
                $display("Random Test");
                for (int i = 0; i < num_words; i++) begin
                    rand_addr = $urandom_range(BASE_ADDR, BASE_ADDR + num_words);
                    write(rand_addr, { $urandom(), $urandom() }, 'hFF);
                    read(rand_addr);
                end


                // Sequential
                $display("Sequential Test");
                for (int i = 0; i < num_words; i++) begin
                    write(BASE_ADDR + i, ($urandom << 32) | $urandom, 'hFF);
                end
                for (int i = 0; i < num_words; i++) begin
                    read(BASE_ADDR + i);
                end

                // Slave Error AOR
                // $display("Slave Error AOR Test");
                // for (int i = num_words; i < num_words + 100; i++) begin
                //     write(BASE_ADDR + i, ($urandom << 32) | $urandom, 'hFF);
                //     read(BASE_ADDR + i);
                // end

                //Strobe
                $display("Strobe Test");
                for (int i = 0; i < num_words; i++) begin
                    addr = BASE_ADDR + i;
                    strobe = 1 << i%8;                  
                    data = ($urandom << 32) | $urandom; 
                    write(addr, data, strobe);        
                    read(addr);                        
                end
            end 


        env.scb.report_generate();
    endtask

endclass
