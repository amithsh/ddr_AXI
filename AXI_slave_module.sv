module axi_module(aclk,aresetn,awaddr,awid,awvalid,awready,awsize,awlen,awcache,awprot,awlock,awburst,wdata,wstrb,wlast,wvalid,wid,wready,bready,bresp,bvalid,bid,araddr,arid,arvalid,arready,arsize,arlen,arcache,arprot,arlock,arburst,rready,rdata,rvalid,rresp,rid,rlast,pwdata,logical_addr,pwrite,prdata,burstlen,strobe);
    
      input aclk;
      input aresetn;
      input [31:0] awaddr;
	  input[3:0] awid;
	  input awvalid;
	  output reg awready;
	  input[2:0] awsize;
	  input[3:0] awlen;
	  input[3:0] awcache;
	  input[2:0] awprot;
	  input[1:0] awlock;
	  input[1:0] awburst;

      //write data channel
      input[31:0] wdata;
	  input  [3:0] wstrb;
	  input wlast;
	  input wvalid;
	  input [3:0] wid;
      output reg wready;
	//write response channel
	  input bready;
	  output reg [1:0] bresp;
	  output reg bvalid;
	  output reg [3:0]bid;
	//read addr channel
	  input [31:0] araddr;
	  input[3:0] arid;
	  input arvalid;
	  output reg arready;
	  input[2:0] arsize;
	  input[3:0] arlen;
	  input[3:0] arcache;
	  input[2:0] arprot;
	  input[1:0] arlock;
	  input[1:0] arburst;
	//read data channel
	  input rready;
      output reg [31:0] rdata;
	  output reg rvalid;
	  output reg [1:0] rresp;
	  output reg [3:0] rid;
	  output reg rlast;

    //ddr signals
    output reg [31:0] logical_addr;
    output reg [31:0] pwdata;
    output reg pwrite;
    input [31:0] prdata; 
    output reg [3:0] burstlen;
    output reg [3:0]strobe;
    

//variables 
int data_size;
int data_in_bytes;

int count;

int temp_id;

int data_size_in_bytes;
int each_beat_active_bytes;
int offset_addr;
int aligned_addr;
bit read_in_progress =0;
bit write_in_progress =0;

reg [31:0] tawaddr;
reg [31:0] taraddr;

reg[31:0] temp_data;//used to store the temporary data to send to the controller of one transfer

//axi_tx wr_tx[int];//associative array, user want how many memeory location that much creation possible 

//axi_tx rd_tx[int];//storing read address & cntrol infro,ation

ddrcntrl ddrcontroller(
    .clk(aclk),
    .rst(aresetn),
    .logical_addr(logical_addr),
    .pwdata(pwdata),
    .pwrite(pwrite),
    .prdata(prdata),
    .strobe(strobe),
    .burstlen(burstlen)
);

reg [7:0] mem [1000];
//logic block
always@(posedge aclk) begin
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
                 read_in_progress<=0;
                 write_in_progress<=0;
end
else begin  
                 if(awvalid==0)
				        awready<=0;
			     //write data channel
			      if(wvalid==0)
			              wready<=0;
			     //write response channel
			       if(bready==0) 
				      bvalid<=0;
			     //read address channel
			      if(arvalid==0)
				      arready<=0;
			     //read data channel
			     if(rready==0)
				     rvalid<=0;

                    if(awvalid==1 && write_in_progress==0)begin  
			        awready<=1;   
                    tawaddr<=awaddr;           
			        // wr_tx[awid]=new();
			        // wr_tx[awid].awaddr= awaddr; 
			        // wr_tx[awid].awlen= awlen;
			        // wr_tx[awid].awsize= awsize;
			        // wr_tx[awid].awburst= awburst;
			        // wr_tx[awid].awcache= awcache;
			        // wr_tx[awid].awprot= awprot;
			        // wr_tx[awid].awlock= awlock;
			        // wr_tx[awid].awid= awid;
                    write_in_progress<=1;	
                    end

                    //write data channel  (only increment transaction)
                    if(wvalid==1 && write_in_progress==1 && read_in_progress==0)begin
                        wready<=1;
                        //tawaddr<=awaddr;
                        data_size=$size(wdata);
		                data_in_bytes= data_size/8; 
                        burstlen = awlen;
                        if(awburst==1)begin
                            @(posedge aclk);
		 
                            logical_addr=tawaddr;
                            pwrite=1;
                            
                            
		                    for(int i=0; i<=awlen; i++)begin 
                                aligned_addr= tawaddr - (tawaddr % 2** awsize);//1
                                strobe = wstrb;

                                //pwdata <= wdata;
			                    //$display("slave bfm numbber_transfer=%d start_Addr=%d wdata=%h time=%t",i,tawaddr,wdata,$time);
			                    count=0;
			                    for(int j=0; j<data_in_bytes; j++)begin
				                     if(wstrb[j]==1)begin
			                             //mem[tawaddr+count]=wdata[j*8 +: 8];
                                         //temp_data[tawaddr+count] = wdata[j*8 +: 8];
                                         temp_data =  { wdata[j*8 +: 8],temp_data[31:8]};
                                         //pwdata=wdata[j*8 +: 8];
                                         $display("data=%0h | addr=%0h | wdata=%0h | logical_addr=%0h | controller data=%0h time=%0d",mem[tawaddr+count],tawaddr+count,wdata[j*8 +: 8],logical_addr,wdata[j*8 +: 8],$time);
		                                count=count+1;  	   
				                        end      
			                    end 
                                pwdata <= temp_data;
			 		
                                tawaddr = awaddr - (awaddr % 2**awsize);		
                                //next transer start address 

                                tawaddr = aligned_addr + 2** awsize; //0+4


                                @(posedge aclk);//5th

                                    //write address channel need to check every postive edge of the clcock 
                                    //again need to check master valid address and control information
                                    ////overlalping transaction
                                    //   if(awvalid==1)begin  
                                    //         awready=1;    
                                                        
                                    //         // wr_tx[awid]=new();
                                    //         // wr_tx[awid].awaddr= awaddr;
                                    //         // wr_tx[awid].awlen= awlen;
                                    //         // wr_tx[awid].awsize= awsize;
                                    //         // wr_tx[awid].awburst= awburst;
                                    //         // wr_tx[awid].awcache= awcache;
                                    //         // wr_tx[awid].awprot= awprot;
                                    //         // wr_tx[awid].awlock= awlock;
                                    //         // wr_tx[awid].awid= awid;
                                    //     end	    

                                
                
                                //3.write response channel
                            //$display("before write resp channel  time=%0t",$time);
                            if(i==awlen)begin
                                //$display("out time=%0t",$time);
                                //if(wlast==1)begin 
                                    //$display("in");
                                bvalid=1;
                                bid=wid;
                                bresp=2'b00;//ok response
                                // end
                        end
		                end//awlen for
		                end//awburst
                        write_in_progress<=0;

                    end

                    //4.read address channel

                    if(arvalid==1 && read_in_progress==0)begin  //address check missed in 4th and 5th clock
                        arready<=1;//am ready to recive the addresss & control inf   
                        //taraddr<=araddr;                
                        //rd_tx[arid]=new();//wr_tx[5]=new();  wr_tx[10]=new() wr_tx[7]
                        // rd_tx[arid].araddr= araddr;//wr_tx[5].awaddr=4 
                        // rd_tx[arid].arlen= arlen;//wr_tx[5].awlen=1
                        // rd_tx[arid].arsize= arsize;
                        // rd_tx[arid].arburst= arburst;
                        // rd_tx[arid].arcache= arcache;
                        // rd_tx[arid].arprot= arprot;
                        // rd_tx[arid].arlock= arlock;
                        // rd_tx[arid].arid= arid;
                        rdata<=0;
                        read_in_progress=1;
			        end

                    if(rready==1 && read_in_progress==1 && write_in_progress==0)begin //master ready to recive read data 
                        rvalid<=1;
                        taraddr=araddr;
                        //rd_tx.first(temp_id);//temp_id=5
                        $display("data_size_in_bytes =%0d  araddr=%0d  id=%0d time=%0d",data_size_in_bytes,taraddr,temp_id,$time);
                        //INCRIMENT TRANSACTION
                        if(arburst==1)begin
                            //rdata=0;
                            logical_addr=taraddr;
                            pwrite=0;
                            burstlen = awlen;
                            //number of transfers of rdata slave need to send 
                            for(int i=0; i<=arlen; i++)begin

                                    //slave need to send rdata from memory
                                    count=0;
                                    //unaligned to aligned conversion 
                                    aligned_addr= taraddr - (taraddr % 2** arsize);//1
                                    data_size_in_bytes= $size(rdata)/8;//4
                                    each_beat_active_bytes= 2**arsize;//1
                                    offset_addr=taraddr % data_size_in_bytes ;//1

                                    //rdata=0;
                                    //$display("data_size_in_bytes =%0d  araddr=%0d  id=%0d",data_size_in_bytes,taraddr,temp_id);
                                    if((taraddr % data_size_in_bytes) ==0)begin 
                                        for(int j=0; j<each_beat_active_bytes; j++)begin 
                                            rdata[j*8 +:8] = mem[taraddr+count];
                                            wait(prdata);
                                            rdata[j*8 +: 8] <= prdata;
                                            $display("read transaction:- data=%0h |  addr=%0d | logical_address=%0h | pwrite=%0d | rdata=%0h time=%0t",rdata,taraddr+count,taraddr+count,pwrite,prdata,$time);
                                            count=count+1; 
                                            //$display("aligned rdata=%h time=%d",rdata,$time);
                                        end
                                    end 

                                    //2. addres is unlaigned 	       
                                    if((taraddr % data_size_in_bytes) !=0)begin 
                                        for(int j=offset_addr; j<  (each_beat_active_bytes+offset_addr); j++)begin
                                            rdata[j*8 +:8] = mem[taraddr+count];
                                            $display("read transaction:- data=%0h |  addr=%0d | logical_address=%0h | pwrite=%0d | rdata=%0h time=%0t",rdata,taraddr+count,taraddr+count,pwrite,prdata,$time);
                                            //$display("aligned rdata=%h time=%d",rdata,$time);		        
                                            count=count+1; 
                                        end  
                                    end
                                taraddr= aligned_addr + 2** arsize;//2
                                rid=temp_id;
                                rresp=2'b00;//ok response 

                                if(i==arlen)//last transfer only this conditon will true 
                                    rlast=1;

                                @(posedge aclk);
                                //read address channel 
                                // if(arvalid==1)begin  //address check missed in 4th and 5th clock
                                //             arready<=1;//am ready to recive the addresss & control inf                   
                                //             // rd_tx[arid]=new();//wr_tx[5]=new();  wr_tx[10]=new() wr_tx[7]
                                //             // rd_tx[arid].araddr= araddr;//wr_tx[5].awaddr=4 
                                //             // rd_tx[arid].arlen= arlen;//wr_tx[5].awlen=1
                                //             // rd_tx[arid].arsize= arsize;
                                //             // rd_tx[arid].arburst= arburst;
                                //             // rd_tx[arid].arcache= arcache;
                                //             // rd_tx[arid].arprot= arprot;
                                //             // rd_tx[arid].arlock= arlock;
                                //             // rd_tx[arid].arid= arid;		    
                                // end
                            end //for 
                        end//arburst 
                        read_in_progress<=0;
                        //rd_tx.delete(temp_id);
                    end
    end//else
end
endmodule