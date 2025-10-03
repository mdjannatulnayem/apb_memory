// This is the top-level testbench module for the APB memory design.
// It is responsible for:
// 1. Instantiating the DUT (apb_wrapper).
// 2. Providing the clock (PCLK) and reset (PRESETn) signals.
// 3. Connecting the DUT to the verification environment via the apb_interface.
// 4. Selecting and running a specific test case based on the `+TEST` plusarg.
module apb_tb;

    // --- Clock and Reset ---
    bit PCLK;    // Clock signal, driven by the testbench
    reg PRESETn; // Active-low reset signal

    // --- APB Interface Instance ---
    // The virtual interface is used by the verification components (driver, monitor, etc.)
    // to interact with the DUT's pins.
    apb_interface inf(PCLK);

    // --- DUT Instance ---
    // Instantiate the apb_wrapper, which is the top-level module of the design.
    // Parameters are passed down from the test level (defined in apb_test_pkg).
    apb_wrapper #(
        .ADDR_W(ADDR_W),
        .DATA_W(DATA_W),
        .MEM_SIZE_K(MEM_SIZE_K),
        .BASE_ADDR(BASE_ADDR)
    ) DUT (
        .PCLK    (inf.PCLK),
        .PRESETn (inf.PRESETn),
        .PSELx   (inf.PSELx),
        .PENABLE (inf.PENABLE),
        .PWRITE  (inf.PWRITE),
        .PADDR   (inf.PADDR),
        .PWDATA  (inf.PWDATA),
        .PSTRB   (inf.PSTRB),
        .PRDATA  (inf.PRDATA),
        .PREADY  (inf.PREADY),
        .PSLVERR (inf.PSLVERR)
    );

    // --- Clock Generation ---
    // Generates a 100 MHz clock (10ns period).
    initial forever #5 PCLK = ~PCLK; // 100 MHz

    // --- Test Case Handles ---
    // Handles for all the different test case classes. Only the selected
    // test will be constructed and run.
    apb_seq_wr_test             seq_wr_test;
    apb_reset_test              reset_test;
    apb_random_wr_test          random_wr_test;
    apb_strobe_test             strobe_test;
    apb_violation_test          violation_test;
    apb_slave_error_aor_test    slave_error_aor_test;
    apb_addr_misaligned_test    addr_misaligned_test;
    apb_boundary_test           boundary_test;
    apb_random_stress_test      random_stress_test;
    apb_b2b_wr_test             b2b_wr_test;
    apb_single_wr_test          single_wr_test;

    // Variable to hold the test name from the command line.
    string testname;

    // --- Main Test Execution Block ---
    initial begin
        // Enable waveform dumping for debugging.
        $dumpfile("waves.vcd");
        $dumpvars(0, apb_tb);

        // Get the test name from the command line arguments (+TEST=<name>).
        // If no test is specified, display an error and exit.
        if (!$value$plusargs("TEST=%s", testname)) begin
            $display("ERROR: No TEST specified! Use +TEST=<name>");
            $finish;
        end

        $display("Running test: %s", testname);
        if (testname == "seq_wr") begin
            seq_wr_test = new(inf);
            seq_wr_test.run_test();
        end
        else if (testname == "reset") begin
            reset_test = new(inf);
            reset_test.run_test();
        end
        else if (testname == "random_wr") begin
            random_wr_test = new(inf);
            random_wr_test.run_test();
        end
        else if (testname == "strobe") begin
            strobe_test = new(inf);
            strobe_test.run_test();
        end
        else if (testname == "violation") begin
            violation_test = new(inf);
            violation_test.run_test();
        end
        else if (testname == "slave_error_aor") begin
            slave_error_aor_test = new(inf);
            slave_error_aor_test.run_test();
        end
        else if(testname == "addr_misaligned") begin
            addr_misaligned_test = new(inf);
            addr_misaligned_test.run_test();
        end
        else if(testname == "boundary") begin
            boundary_test = new(inf);
            boundary_test.run_test();
        end
        else if(testname == "random_stress") begin
            random_stress_test = new(inf);
            random_stress_test.run_test();
        end
        else if(testname == "b2b_wr") begin
            b2b_wr_test = new(inf);
            b2b_wr_test.run_test();
        end
        else if(testname == "single_wr") begin
            single_wr_test = new(inf);
            single_wr_test.run_test();
        end
        else begin
            $display("ERROR: Unknown test '%s'", testname);
        end

        $finish;
    end

endmodule
