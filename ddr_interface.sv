interface ddr_intf(input logic clk,reset);
    logic [31:0] logical_addr;
    logic [31:0] pwdata;
    logic [31:0] tpwdata;
    logic pwrite;
    logic [31:0] prdata;
    logic [1:0] bg;
    logic [1:0] ba;
    logic [17:0] a;
    logic cs_n;
    logic act_n;
    logic [17:0] ra;
    logic [9:0] ca;
endinterface