// The apb_driver class is responsible for driving APB transactions onto the
// virtual interface. It contains tasks to perform specific operations like
// reset, write, and read, which are called by the test sequences.
class apb_driver;

    // --- Handles ---
    virtual apb_interface inf;
    semaphore sem; // Used to ensure only one task drives the bus at a time.

    // --- Internal Properties ---
    int cycle_cnt = 0; // Counter for implementing a timeout mechanism.

    // --- Constructor ---
    // Creates the driver instance.
    // @param inf - The virtual interface handle to connect to the DUT.
    // @param sem - The semaphore used for synchronization with the test.
    function new(virtual apb_interface inf, semaphore sem);
        $display("[%0t] :: apb_driver :: Driver Constructed", $time );
        this.inf = inf;
        this.sem = sem;
    endfunction

    // --- Task: reset_drive ---
    // Drives the APB reset sequence.
    // @param val - The value to drive on PRESETn after the reset pulse.
    task reset_drive(input logic val);
        // Drive all signals to a known, inactive state.
        inf.PRESETn = 0;
        inf.PWRITE = 0;
        inf.PWDATA = 0;
        inf.PADDR = 0;
        inf.PSELx = 0;
        inf.PENABLE = 0;
        inf.PSTRB = 0;

        // Hold reset for a few cycles.
        repeat(2) @(posedge inf.PCLK);
        inf.PRESETn = val;

        // Release the semaphore, indicating the reset is complete.
        sem.put(1);
    endtask

    // --- Task: write_drive ---
    // Drives a single APB write transaction.
    // @param PADDR  - The address to write to.
    // @param PWDATA - The data to write.
    // @param PSTRB  - The write strobes.
    task write_drive( input logic [ADDR_W-1:0] PADDR, input logic [DATA_W-1:0] PWDATA, input logic [DATA_W/8-1:0] PSTRB );
        // SETUP phase: Drive address, data, and control signals.
        inf.PSELx   <= 1;
        inf.PWRITE  <= 1;
        inf.PADDR   <= PADDR;
        inf.PWDATA  <= PWDATA;
        inf.PSTRB   <= PSTRB;
        inf.PENABLE <= 0;

        // Move to ACCESS phase on the next clock edge.
        @(posedge inf.PCLK);
        inf.PENABLE <= 1;

        // Wait for the slave to be ready (PREADY=1), with a timeout to prevent hanging.
        cycle_cnt = 0;
        while (!inf.PREADY && cycle_cnt < 10) begin
            @(posedge inf.PCLK);
            cycle_cnt++;
        end

        // End of transaction: De-assert signals.
        inf.PSELx   <= 0;
        inf.PENABLE <= 0;
        inf.PWRITE  <= 0;
        cycle_cnt = 0;

        // Release the semaphore, indicating the write is complete.
        sem.put(1);
    endtask


    // --- Task: read_drive ---
    // Drives a single APB read transaction.
    // @param PADDR - The address to read from.
    task read_drive(input logic [ADDR_W-1:0] PADDR );
        // SETUP phase: Drive address and control signals.
        inf.PSELx   <= 1;
        inf.PWRITE  <= 0;
        inf.PADDR   <= PADDR;
        inf.PENABLE <= 0;

        // Move to ACCESS phase on the next clock edge.
        @(posedge inf.PCLK);
        inf.PENABLE <= 1;

        // Wait for the slave to be ready (PREADY=1), with a timeout to prevent hanging.
        cycle_cnt = 0;
        while (!inf.PREADY && cycle_cnt < 10) begin
            @(posedge inf.PCLK);
            cycle_cnt++;
        end

        // End of transaction: De-assert signals.
        inf.PSELx   <= 0;
        inf.PENABLE <= 0;
        cycle_cnt = 0;

        // Wait one extra cycle to allow the monitor to sample the final state
        // of the read transaction before the next transaction begins.
        @(posedge inf.PCLK);

        // Release the semaphore, indicating the read is complete.
        sem.put(1);
    endtask

endclass