// The apb_agent class encapsulates the driver and monitor components for the APB
// verification environment. It acts as a container to group related components
// that operate on a specific APB interface.
class apb_agent;

    // --- Component Handles ---
    apb_driver  drvr; // Drives transactions onto the APB interface.
    apb_monitor mntr; // Monitors the APB interface and captures transactions.

    // --- Constructor ---
    // Creates the driver and monitor instances.
    //
    // @param inf         - Virtual handle to the APB interface.
    // @param mb_expected - Mailbox for expected transactions (passed to monitor).
    // @param mb_actual   - Mailbox for actual transactions (passed to monitor).
    // @param sem         - Semaphore for coordinating driver access (passed to driver).
    function new(virtual apb_interface inf, mailbox mb_expected, mailbox mb_actual, semaphore sem);
        $display("[%0t] :: apb_agent :: Agent Constructed", $time);
        // Instantiate the driver and monitor, passing the necessary handles.
        drvr = new(inf, sem);
        mntr = new(inf, mb_expected, mb_actual);
    endfunction


endclass