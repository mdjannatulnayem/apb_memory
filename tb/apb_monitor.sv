// The apb_monitor class is a passive component that observes the APB interface.
// It captures completed APB transactions and sends them to the scoreboard for checking.
// It distinguishes between write transactions (which are used to build the expected
// memory model) and read transactions (which are the actual results to be verified).
class apb_monitor;

    // --- Handles ---
    virtual apb_interface inf;
    mailbox mb_expected, mb_actual; // Mailboxes for communicating with the scoreboard
    packet exp_pkt, act_pkt;        // Packet handles for creating transaction objects


    // --- Constructor ---
    // Creates the monitor instance.
    // @param inf         - The virtual interface handle to monitor.
    // @param mb_expected - Mailbox to send expected (write) transactions to the scoreboard.
    // @param mb_actual   - Mailbox to send actual (read) transactions to the scoreboard.
    function new(virtual apb_interface inf, mailbox mb_expected, mailbox mb_actual);
        $display("[%0t] :: apb_monitor :: Monitor Constructed", $time);
        this.inf = inf;
        this.mb_expected = mb_expected;
        this.mb_actual = mb_actual;
    endfunction
    
    // --- Task: capture ---
    // Continuously monitors the APB bus for completed transactions.
    task capture();

        forever begin
            // Wait for the next clock edge to sample the signals.
            @(posedge inf.PCLK);

            // Special case: Capture bus state during reset if a transfer is active.
            // This is for specific reset tests to verify DUT behavior.
            if(inf.PRESETn===0 && inf.PSELx===1 && inf.PENABLE===1) begin

                act_pkt = new();
                // Capture all relevant signals during this unusual event.
                // The scoreboard will check if PRDATA is correctly driven to 0.
                act_pkt.PADDR   = inf.PADDR;
                act_pkt.PRDATA  = inf.PRDATA;
                act_pkt.PREADY  = inf.PREADY;
                act_pkt.PRESETn = inf.PRESETn;
                act_pkt.PWRITE  = inf.PWRITE;
                act_pkt.PSLVERR = inf.PSLVERR;
                act_pkt.PSTRB   = inf.PSTRB;
                mb_actual.put(act_pkt);         // Send this as an "actual" packet for the scoreboard to check.
            end

            // Standard case: Capture a transaction at the end of the ACCESS phase.
            // This occurs when PSEL, PENABLE, and PREADY are all high.
            else if(inf.PSELx===1 && inf.PENABLE===1 && inf.PREADY===1) begin 

                // Check if it's a write transaction.
                if(inf.PWRITE===1) begin
                    // For a write, we create an "expected" packet.
                    // The scoreboard will use this to update its internal reference memory.
                    exp_pkt = new();
                    exp_pkt.PWDATA  = inf.PWDATA;
                    exp_pkt.PADDR   = inf.PADDR;
                    exp_pkt.PREADY  = inf.PREADY;
                    exp_pkt.PRESETn = inf.PRESETn;
                    exp_pkt.PWRITE  = inf.PWRITE;
                    exp_pkt.PSLVERR = inf.PSLVERR;
                    exp_pkt.PSTRB   = inf.PSTRB;
                    mb_expected.put(exp_pkt);
                end
                // Otherwise, it's a read transaction.
                else begin
                    // For a read, we create an "actual" packet.
                    // The scoreboard will compare this against its expected value.
                    act_pkt = new();
                    act_pkt.PADDR   = inf.PADDR;
                    act_pkt.PRDATA  = inf.PRDATA;
                    act_pkt.PREADY  = inf.PREADY;
                    act_pkt.PRESETn = inf.PRESETn;
                    act_pkt.PWRITE  = inf.PWRITE;
                    act_pkt.PSLVERR = inf.PSLVERR;
                    act_pkt.PSTRB   = inf.PSTRB;
                    mb_actual.put(act_pkt);         // Send this as an "actual" packet for the scoreboard to check.
                end 
            end
        end
    endtask

endclass 