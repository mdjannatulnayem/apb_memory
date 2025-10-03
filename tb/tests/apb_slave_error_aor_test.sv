class apb_slave_error_aor_test extends apb_base_test;

    function new(virtual apb_interface inf);
        super.new(inf);
        $display("[%0t] :: apb_slave_error_aor_test Constructed", $time);
    endfunction

    task run_test();
        int num_words = BASE_ADDR + (MEM_SIZE_K * 1024) - 1;
        reset(1'b1);


        for (int i = num_words-10; i < num_words + 100; i++) begin
            write(BASE_ADDR + i, { $urandom(), $urandom() }, 'hFF);
            read(BASE_ADDR + i);
        end

        env.scb.report_generate();
    endtask
endclass
