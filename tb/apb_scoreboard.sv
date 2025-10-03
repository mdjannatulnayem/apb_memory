// The apb_scoreboard class is responsible for verifying the correctness of the DUT's behavior.
// It maintains a reference memory model and compares the actual read data from the DUT
// against the expected data stored in its model.
class apb_scoreboard;

    // --- Mailboxes ---
    // Mailboxes for receiving transaction packets from the monitor.
    mailbox mb_expected, mb_actual;
    // Packet handles for the received transactions.
    packet exp_pkt, act_pkt;

    // --- Constants ---
    // Total depth of the reference memory in bytes.
    localparam int MEM_DEPTH = MEM_SIZE_K * 1024; // e.g., 64 * 1024 = 65536 bytes

    // --- Reference Memory Model ---
    // A byte-addressable array to mimic the DUT's internal memory.
    logic [7:0] memory [0:MEM_DEPTH-1];


    // --- Internal Variables ---
    // Variables used for address calculation and data reconstruction.
    int signed aligned_base;
    logic [DATA_W-1 : 0] exp_data;

    // --- Counters ---
    // Track the number of passed, failed, and total transactions.
    int pass_count = 0;
    int fail_count = 0;
    int total_count = 0;
    

    // --- Constructor ---
    // Creates the scoreboard and connects it to the mailboxes.
    function new(mailbox mb_expected, mailbox mb_actual);
        $display("[%0t] :: apb_scoreboard :: Scoreboard Constructed", $time);
        this.mb_expected = mb_expected;
        this.mb_actual = mb_actual;
    endfunction

    // --- Task: receieve_expected_packet ---
    // This task continuously waits for "expected" packets (writes) from the monitor.
    // It uses these packets to update its internal reference memory model.
    task receieve_expected_packet();
        
        forever begin
            mb_expected.get(exp_pkt);

            if(exp_pkt.PSLVERR === 0) begin
                aligned_base = (exp_pkt.PADDR / 8) * 8;
                
                // Iterate through each byte of the write data.
                for(int i = 0; i < DATA_W/8; i++) begin
                    // Only update the memory byte if the corresponding strobe bit is active.
                    if(exp_pkt.PSTRB[i]) begin
                        memory[aligned_base + i] = exp_pkt.PWDATA[8 * i +: 8];

                    end
                
                end
            end
        end
    endtask


    // --- Task: receieve_actual_packet ---
    // This task continuously waits for "actual" packets (reads) from the monitor.
    // It compares the data in the packet against the data in the reference model.
    task receieve_actual_packet();
        
        forever begin
            mb_actual.get(act_pkt);

            total_count++;
            
            // Special check for the reset test: if a transfer is active during reset,
            // the read data should be zero.
            if(act_pkt.PRESETn === 0) begin
                if(act_pkt.PRDATA === 0) begin
                    pass_count++;
                    $display("[%0t PASSED] :: Expected DATA=%0h | Actual DATA=%0h", $time, 0, act_pkt.PRDATA);
                end
                else begin
                    // This is a failure because PRDATA was not 0 during reset.
                    fail_count++;
                    $display("[%0t FAILED] :: Expected DATA=%0h | Actual DATA=%0h", $time, 0, act_pkt.PRDATA);
                end
                    
            end
            else begin
                aligned_base = (act_pkt.PADDR / 8) * 8;
                
                // Reconstruct the expected 64-bit data word from the byte-addressable memory model.
                // This loop is more scalable than hardcoding the concatenation.
                for (int i = 0; i < DATA_W/8; i++) begin
                    exp_data[8 * i +: 8] = memory[aligned_base + i];
                end
                
                if(exp_data === act_pkt.PRDATA) begin
                    pass_count++;
                    $display("[%0t PASSED] :: ADDR=%0d | Expected DATA=%0h | Actual DATA=%0h", $time, act_pkt.PADDR, exp_data, act_pkt.PRDATA);
                end
                else begin
                    fail_count++;
                    $display("[%0t FAILED] :: ADDR=%0d | Expected DATA=%0h | Actual DATA=%0h", $time, act_pkt.PADDR, exp_data, act_pkt.PRDATA);
                end
            end
        end
    endtask

    // --- Task: compare ---
    // Forks the two main tasks to run them in parallel, enabling simultaneous
    // updating of the model and checking of results.
    task compare();
        fork
            receieve_expected_packet();
            receieve_actual_packet();
        join
    endtask

    // --- Task: report_generate ---
    // Prints a final summary of the test results.
    task report_generate();
        // A small delay can be added here if needed to ensure all final transactions are processed.
        $display("\n================================================================");
        $display(" APB TEST SUMMARY: Total=%0d, Passed=%0d, Failed=%0d ", 
                 total_count, pass_count, fail_count);
        $display("==================================================================");
    endtask

endclass
