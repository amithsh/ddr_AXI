module axi_module(clk,a_resetn,awaddr,awid,awvalid,awready,awsize,awlen,awcache,awprot,awlock,awburst,wdata,wstrb,wlast,wvalid,wid;wready;bready,bresp,bvalid,bid;araddr,arid,arvalid,arready,arsize,arlen,arcache,arprot,arlock,arburst,rready,rdata,rvalid,rresp,rid,rlast);
    

      input clk;
      input a_resetn;
      input [31:0] awaddr;
	  input[3:0] awid;
	  input awvalid;
	  output awready;
	  input[2:0] awsize;
	  input[3:0] awlen;
	  input[3:0] awcache;
	  input[2:0] awprot;
	  input[1:0] awlock;
	  input[1:0] awburst;

      //write data channel
      input[31:0] wdata;
	  input [3:0] wstrb;
	  input wlast;
	  input wvalid;
	  input[3:0] wid;
      output wready;
	//write response channel
	  input bready;
	  output [1:0] bresp;
	  output bvalid;
	  output [3:0]bid;
	//read addr channel
	  input [31:0] araddr;
	  input[3:0] arid;
	  input arvalid;
	  output arready;
	  input[2:0] arsize;
	  input[3:0] arlen;
	  input[3:0] arcache;
	  input[2:0] arprot;
	  input[1:0] arlock;
	  input[1:0] arburst;
	//read data channel
	  input rready;
      output [31:0] rdata;
	  output rvalid;
	  output[1:0] rresp;
	  output[3:0] rid;
	  output rlast;

//variables 
int data_size;
int data_in_bytes;

int count;

int temp_id;

int data_size_in_bytes;
int each_beat_active_bytes;
int offset_addr;
int aligned_addr;

int wr_ptr=0;
int rd_ptr=0;

axi_tx wr_tx[int];//associative array, user want how many memeory location that much creation possible 

axi_tx rd_tx[int];//storing read address & cntrol infro,ation 

//logic block
always@(posedge clk) begin

 if(aresetn==1)begin 
			     awready<=1'bx;
			     wready<=1'bx;
			     bresp<=1'bx;
			     bvalid<=1'bx;
			     bid<=1'bx;
			     rvalid<=1'bx;
			     rresp<=1'bx;
			     arready<=1'bx;
			     rlast<=1'bx;
			     rdata<=1'bx;
			     rid<=1'bx;
		     end

             else begin
                 
                 if(svif.awvalid==0)
				        svif.awready<=0;
			     //write data channel
			      if(svif.wvalid==0)
			              svif.wready<=0;
			     //write response channel
			       if(svif.bready==0) 
				      svif.bvalid<=0;
			     //read address channel
			      if(svif.arvalid==0)
				      svif.arready<=0;
			     //read data channel
			     if(svif.rready==0)
				     svif.rvalid<=0;

                    if(svif.awvalid==1)begin  
			        svif.awready<=1;              
			        wr_tx[svif.awid]=new();
			        wr_tx[svif.awid].awaddr= svif.awaddr; 
			        wr_tx[svif.awid].awlen= svif.awlen;
			        wr_tx[svif.awid].awsize= svif.awsize;
			        wr_tx[svif.awid].awburst= svif.awburst;
			        wr_tx[svif.awid].awcache= svif.awcache;
			        wr_tx[svif.awid].awprot= svif.awprot;
			        wr_tx[svif.awid].awlock= svif.awlock;
			        wr_tx[svif.awid].awid= svif.awid;	
                    end

                    //write data channel  (only increment transaction)
                    if(svif.wvalid==1)begin
                       svif.wready<=1;
                        data_size=$size(svif.wdata);
		                data_in_bytes= data_size/8; 

                        if(wr_tx[svif.wid].awburst==1)begin
                        @(posedge svif.aclk);// 
		 
		                     for(int i=0; i<= wr_tx[svif.wid].awlen; i++)begin 

			                    $display("slave bfm numbber_transfer=%d start_Addr=%d wdata=%h time=%t",i,wr_tx[svif.wid].awaddr,svif.wdata,$time);
			                    count=0;
			                    for(int i=0; i<data_in_bytes; i++)begin
				                     if(svif.wstrb[i]==1)begin
			                             mem[wr_tx[svif.wid].awaddr+count]=svif.wdata[i*8 +: 8];
		                                count=count+1;  	   
				                        end  
			                    end 
			 		
                        wr_tx[svif.wid].awaddr = wr_tx[svif.wid].awaddr - (wr_tx[svif.wid].awaddr % 2**wr_tx[svif.wid].awsize);		
		                //next transer start address 

                        wr_tx[svif.wid].awaddr = wr_tx[svif.wid].awaddr + 2** wr_tx[svif.wid].awsize; //0+4


                        @(posedge svif.aclk);//5th

//write address channel need to check every postive edge of the clcock 
//again need to check master valid address and control information
////overlalping transaction
                              if(svif.awvalid==1)begin  
				                    svif.awready=1;                   
				                    wr_tx[svif.awid]=new();
				                    wr_tx[svif.awid].awaddr= svif.awaddr;
				                    wr_tx[svif.awid].awlen= svif.awlen;
				                    wr_tx[svif.awid].awsize= svif.awsize;
				                    wr_tx[svif.awid].awburst= svif.awburst;
				                    wr_tx[svif.awid].awcache= svif.awcache;
				                    wr_tx[svif.awid].awprot= svif.awprot;
				                    wr_tx[svif.awid].awlock= svif.awlock;
				                    wr_tx[svif.awid].awid= svif.awid;
			                    end	    

				          
		
                        //3.write response channel
                        if(svif.bready==1)begin
	                        if(svif.wlast==1)begin 
	                        svif.bvalid<=1;
                            svif.bid<=svif.wid;
                            svif.bresp<=2'b00;//ok response
                            end
                        end
		                end//awlen for
		                end//awburst
                    end
                end
end
endmodule