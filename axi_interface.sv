interface axi_interface(input bit aclk, aresetn);

	//write addres channel
	logic [31:0] awaddr;
	logic [3:0] awid;
	logic awvalid;
	logic awready;
	logic [3:0] awlen;
	logic [3:0] awcache;
	logic [2:0] awprot;
	logic [2:0] awsize;
	logic [1:0] awlock;
	logic [1:0] awburst;
	//write data channel
	logic [31:0] wdata;
	logic [3:0] wstrb;
	logic wlast;
	logic wvalid;
	logic wready;
	logic [3:0] wid;
	//write response channel
	logic bvalid;
	logic bready;
	logic [3:0] bid;
	logic [1:0] bresp;
	//read address channel
	logic [31:0] araddr;
	logic [3:0] arid;
	logic arvalid;
	logic arready;
	logic [3:0] arlen;
	logic [3:0] arcache;
	logic [2:0] arprot;
	logic [2:0] arsize;
	logic [1:0] arlock;
	logic [1:0] arburst;
	
	//read data channel
	logic [31:0] rdata;
        logic [3:0] rid;
        logic rlast;
        logic rvalid;
        logic rready;
        logic [1:0] rresp;
endinterface 
