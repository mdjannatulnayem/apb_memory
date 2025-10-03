class apb_strobe_test extends apb_base_test;

    longint unsigned data; 
    int addr;
    int strobe;

    // Constructor
    function new(virtual apb_interface inf);
        super.new(inf);
        $display("[%0t] :: apb_strobe_test :: APB Strobe Test Constructed", $time);
    endfunction

    // Main test task
    task run_test();
        int num_words = (MEM_SIZE_K * 1024) - 1;
        reset(1'b1);

        // Write all addresses using individual byte strobes
        for (int i = 0; i < 20; i++) begin

            addr = BASE_ADDR + i;

            if(addr%8 == 0) begin
                strobe = $urandom_range(0, 255);    
                data = ($urandom << 32) | $urandom; 
                write(addr, data, strobe);          
                read(addr);                         
            end

        end

        env.scb.report_generate();
    endtask

endclass
