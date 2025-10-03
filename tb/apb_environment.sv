// The apb_environment class is the top-level container for the APB verification
// environment. It instantiates and connects all the major verification components,
// such as the agent, scoreboard, and coverage collector.
class apb_environment;

    // --- Component Handles ---
    apb_agent      agnt; // Handle for the APB agent (contains driver and monitor)
    apb_scoreboard scb;  // Handle for the scoreboard
    apb_coverage   cov;  // Handle for the coverage collector

    // --- Mailboxes ---
    // Mailboxes used for communication between the monitor and scoreboard.
    mailbox mb_expected, mb_actual;

    // --- Constructor ---
    // Constructs the environment and all its sub-components.
    //
    // @param inf - Virtual handle to the APB interface, passed down to components.
    // @param sem - Semaphore for coordinating driver access, passed to the agent.
    function new(virtual apb_interface inf, semaphore sem);
        $display("[%0t] :: apb_environment :: Environment Constructed", $time);

        // Create the mailboxes for communication.
        mb_expected = new();
        mb_actual = new();

        // Instantiate the verification components and connect them.
        agnt = new(inf, mb_expected, mb_actual, sem);
        scb = new(mb_expected, mb_actual);
        cov = new(inf);
    endfunction

endclass 