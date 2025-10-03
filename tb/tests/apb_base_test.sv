
// The apb_base_test class serves as the foundation for all other APB test cases.
// It sets up the verification environment and provides common tasks (reset, write, read)
// that can be used by the extended test classes to create specific stimulus scenarios.
class apb_base_test;

    // --- Component Handles ---
    apb_environment env; // Handle to the top-level verification environment.
    semaphore sem;       // Semaphore used to synchronize test execution with the driver.


    // --- Constructor ---
    // This function initializes the base test.
    // @param inf - The virtual interface handle for the APB bus.
    function new(virtual apb_interface inf);
        $display("[%0t] :: apb_base_test :: Base Test Constructed", $time);
        // Create the semaphore, which will have a key count of 0 initially.
        sem = new();
        // Create the verification environment, passing the interface and semaphore handles.
        env = new(inf, sem);

        // Start the scoreboard's comparison and the monitor's capture tasks in parallel.
        // These tasks will run continuously in the background for the duration of the test.
        fork
            env.scb.compare();
            env.agnt.mntr.capture();
        join_none

    endfunction

    // --- Task: reset ---
    // A convenience task to initiate a reset sequence.
    // It calls the driver's reset task and then waits for it to complete.
    // @param x - The value to drive on PRESETn after the reset pulse.
    task reset(input logic x);
        env.agnt.drvr.reset_drive(x);
        // Wait for the driver to release the semaphore, indicating the reset is done.
        sem.get(1);
    endtask

    // --- Task: write ---
    // A convenience task to initiate a write transaction.
    // It calls the driver's write task and then waits for it to complete.
    task write(input logic [ADDR_W-1:0] PADDR, input logic [DATA_W-1:0] PWDATA, input logic [DATA_W/8-1:0] PSTRB);
        env.agnt.drvr.write_drive( PADDR, PWDATA, PSTRB);
        // Wait for the driver to release the semaphore, indicating the write is done.
        sem.get(1);
    endtask

    // --- Task: read ---
    // A convenience task to initiate a read transaction.
    // It calls the driver's read task and then waits for it to complete.
    task read(input logic [ADDR_W-1:0] PADDR );
        env.agnt.drvr.read_drive(PADDR);
        // Wait for the driver to release the semaphore, indicating the read is done.
        sem.get(1);
    endtask

endclass 