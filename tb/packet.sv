
import apb_package::*;

class packet;    

    logic   [DATA_W-1:0]    PWDATA;
    logic   [ADDR_W-1:0]    PADDR;
    logic                   PRESETn;
    logic                   PREADY;
    logic   [DATA_W-1:0]    PRDATA;
    logic                   PSLVERR;
    logic                   PWRITE;
    logic   [8:0]           PSTRB;

endclass //packet