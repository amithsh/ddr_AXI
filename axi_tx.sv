
typedef enum{WRITE_ONLY, READ_ONLY, WRITE_THEN_READ, WRITE_PARALEL_READ} write_read;
class axi_tx;
	//we need to include all signals, which all are signals inputs
	//mantaine rand keyword and which all are signals outputs no need to
	//mataine rand keyword

      rand write_read wr_rd;	
      //write address channel  awready from slave remaining all from master 
      rand bit [31:0] awaddr;
      randc bit [3:0] awid;
      rand bit awvalid;
      rand bit [3:0] awlen;
      rand bit [2:0] awsize;
      rand bit [1:0] awburst;
      rand bit [3:0] awcache;
      rand bit [2:0] awprot;
      rand bit [1:0] awlock;
           bit awready;
      //write data channel wready from slave and remaining all from master 
      rand bit [31:0] wdata[$];//maximum 1024 bit 
      rand bit [3:0] wstrb;//maximum 128 bits possible 
      rand bit wlast;
      rand bit [3:0] wid;
      rand bit wvalid;
           bit wready;
      //write response channel  bready from master and remaining all signals
      //fom slave
      rand bit bready;
           bit bvalid;
	   bit [3:0] bid;
	   bit [1:0] bresp;

      //read address channel arready from slave and remaining all from master 
      rand bit [31:0] araddr;
      rand bit [3:0] arid;
      rand bit arvalid;
      rand bit [3:0] arlen;
      rand bit [2:0] arsize;
      rand bit [1:0] arburst;
      rand bit [3:0] arcache;
      rand bit [2:0] arprot;
      rand bit [1:0] arlock;
           bit arready;

      //read data channel  rready from master and remaining all from slave 
      rand bit rready;
           bit rvalid;
           bit [31:0] rdata;
           bit [3:0] rid;
           bit rlast;
           bit [1:0] rresp;


   constraint c1{
                 wdata.size() == awlen+1;
         }	 
	 /* random value of awlen is 3  wdata.size=4   wdata[0]=32'hrandom  wdata[1]=32'jrandom
	 * wdata[2]=32'hrandom  wdata[3]=32'hrandom*/
endclass
