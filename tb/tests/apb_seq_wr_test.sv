
class apb_seq_wr_test extends apb_base_test;

    int strobe;
    int addr;
    longint unsigned data;

    function new(virtual apb_interface inf);
        super.new(inf);
        $display("[%0t] :: apb_seq_wr_test :: Sequential Write Test Constructed", $time);
    endfunction

    task run_test();

        int num_words = (MEM_SIZE_K * 1024) - 1;
        reset(1'b1);
        for (int i = 0; i < num_words; i++) begin
            addr = BASE_ADDR + i;
            data = ($urandom << 32) | $urandom;
            write(BASE_ADDR + i, data, 'hFF);
        end

        for (int i = 0; i < num_words; i++) begin
            read(BASE_ADDR + i);
        end

        env.scb.report_generate();
    endtask
endclass
