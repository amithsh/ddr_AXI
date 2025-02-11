class axi_bfm;

	axi_tx tx;

	//getting poitnted vitual interface from top module 
	//
	axi_tx wr_tx[int];

	int a[int];
	int b;
	int c;



	int data_size_in_bytes;
	int each_beat_active_bytes;
	int offset_addr;
	int aligned_addr;
	int wstrb_bit;
	
	virtual axi_interface mvif;
	task run();
		mvif=common::vif;
		forever begin 
		@(posedge mvif.aclk);//1st posedge 
		common::gen2bfm.get(tx);//get the randomized data from gen
                
		//put all randomized data to interface
                  
		  //write then read 
	if(tx.wr_rd==WRITE_THEN_READ)
	         begin 
		 //1.write address chahhenl
		 write_address_channel();
		 //2.write data channel
		 write_data_channel();
		 //3.write response channel
		 write_response_channel();
		 //4.read address channel
		 read_address_channel();
		 //5.read data channel
		 read_data_channel();
	        end

		  //write parallel read 
	     if(tx.wr_rd==WRITE_PARALEL_READ) fork
		   begin
		   //1.write address chahhenl
		   write_address_channel();
		   //2.write data channel
		   write_data_channel();
		   //3.write response channel
		   write_response_channel();
		   end
	           begin
		   //4.read address channel
		   read_address_channel();
		   //5.read data channel
		   read_data_channel();
	           end
	      join
           //write_only
	   if(tx.wr_rd==WRITE_ONLY)begin 
                  if(common::out_of_order || common::overlapping)begin 
			if(tx.awvalid==1 && tx.wvalid==0)begin 
		   //1.write address chahhenl
		   write_address_channel();
		   $display("write addr channel =%h", tx.awaddr);
		     end
		   if(tx.wvalid==1)begin
		   $display("write data channel");
		   //2.write data channel
		   write_data_channel();
		   //3.write response channel
		   write_response_channel();
	          end
	        end
	

	else begin //no out of oreder or overlaping 
		 $display("write address isndie else");
		   //1.write address chahhenl
		   write_address_channel();
		   //2.write data channel
		   write_data_channel();
		   //3.write response channel
		   write_response_channel();
		end
	   end

	   if(tx.wr_rd==READ_ONLY)begin
		   //4.read address channel
		   read_address_channel();
		   //5.read data channel
		   read_data_channel();
	   end	
		end//forver 		
	endtask



//awaddr=0  awlen=3  awsize=2 wdata size 32bit awbrst=1 wdata[0]=32'h11223344
//awid=5
//wdata[1]=32'haabbccdd  wdata[2]=32'h1a1b1c1d  wdata[3]=32'h55667788
//wid=5








//1. write address channel  put all randomized address & control signals to
//interfae
task write_address_channel();//first clock
	mvif.awaddr<=tx.awaddr;
	mvif.awid<=tx.awid;
	mvif.awlen<=tx.awlen;
	mvif.awcache<=tx.awcache;
	mvif.awprot<=tx.awprot;
	mvif.awlock<=tx.awlock;
	mvif.awsize<=tx.awsize;
	mvif.awburst<=tx.awburst;
	mvif.awvalid<=1;
	//master need to wait untill ready come from slave 
	wait(mvif.awready==1);


//stored all write addres soignals to one assictaive 
     wr_tx[tx.awid]=new();
     wr_tx[tx.awid].awaddr=tx.awaddr;
     wr_tx[tx.awid].awid=tx.awid;
     wr_tx[tx.awid].awlen=tx.awlen;
     wr_tx[tx.awid].awsize=tx.awsize;
     wr_tx[tx.awid].awprot=tx.awprot;
     wr_tx[tx.awid].awcache=tx.awcache;
     wr_tx[tx.awid].awburst=tx.awburst;
     //wr_tx[5].awaddr=0  wr_tx[5].awlen=3  wr_tx[5].awsize=2
	@(posedge mvif.aclk);//second
	mvif.awvalid<=0;//inside slave awready=0
endtask

//2.write data channel
task write_data_channel();//wdata, wid, wlast, wvalid , wstrb 
       mvif.bready<=1;//master ready to reciv
 	//master need to genrate multiple transfers
	for(int i=0; i<=wr_tx[tx.wid].awlen; i++)begin //wr_tx[5].awlen=1
		//every transfer need to check master genrating address, that
		//need to send to interface 
	fork 
		//statment
	begin 
	if(common::overlapping)begin 
	     if(tx.awvalid==1)begin 
		   write_address_channel();
	     end
         end

        end
       //statment2
       begin
	
	mvif.wdata<=tx.wdata.pop_back();//get the data also delete the data from array
	//mvif.wdata=32'h55667788
	mvif.wid<=tx.wid;
	mvif.wvalid<=1;
	if(i==wr_tx[tx.wid].awlen) mvif.wlast<=1;//last trasfer wlast moving to 1 

	//each transfer need to send proper wstrb (aligned, unaligned, narrow
	//transfer)
	     //wdata size in bytes 
	     data_size_in_bytes= ($size(mvif.wdata) / 8); //wdata size 32 data_size_in_bytes=4, if 64 data_size_in_bytes=8
	     //how many bytes are active in each beat or transfer  //8
	     each_beat_active_bytes= ( 2** wr_tx[tx.wid].awsize);//naroow transfer  //4
	     //start address is aligned or unaligned, and reminder value
	     offset_addr=wr_tx[tx.wid].awaddr % data_size_in_bytes ;//narrow transfer   //0
	     //convert unaligned address to aligned address
	     aligned_addr=wr_tx[tx.wid].awaddr - (wr_tx[tx.wid].awaddr % (2 ** wr_tx[tx.wid].awsize)); //8
                c=  wr_tx[tx.wid].awaddr - aligned_addr;

	       tx.wstrb=0;

	       //1.if address is aligned 
		       if((wr_tx[tx.wid].awaddr % each_beat_active_bytes) ==0)begin 
			       for(int j=0; j<each_beat_active_bytes; j++)begin 
				 wstrb_bit=(offset_addr + j) % data_size_in_bytes;
				 tx.wstrb[wstrb_bit]=1'b1; 
			 end
		       end	       

	      //2. addres is unlaigned 	       
		       if((wr_tx[tx.wid].awaddr % each_beat_active_bytes) !=0)begin 
			       if(wr_tx[tx.wid].awsize==1)
				        c=1;
				else
					c=0;
			    for(int j=offset_addr; j< (wr_tx[tx.wid].awsize + offset_addr+c); j++)begin 
				     tx.wstrb[j]=1'b1;//10000000
			     end  

			    		       end

        mvif.wstrb<=tx.wstrb;
 
		       //convert unaligned adrrss to aligned address
	wr_tx[tx.wid].awaddr= wr_tx[tx.wid].awaddr - (wr_tx[tx.wid].awaddr % (2 ** wr_tx[tx.wid].awsize));
		       //0   //4
		       //next transfer start address 
	wr_tx[tx.wid].awaddr= wr_tx[tx.wid].awaddr + 2** wr_tx[tx.wid].awsize;//4+4=8

   wait(mvif.wready==1);//waititng each transfer untill wready come from slve 
	
	@(posedge mvif.aclk);//3rd clock cycle 
	 mvif.wlast<=0;// 
	 mvif.wvalid<=0;//

 end
 join

    end//for
	endtask

//3.write response channel
task write_response_channel();//we need to send only breay slave
      wait(mvif.bvalid==1);//slave send reponse to master
      if(common::out_of_order || common::overlapping)begin
      @(posedge mvif.aclk);      
      @(posedge mvif.aclk);  
      end    
endtask

//4.read_address_channel
task read_address_channel();
	mvif.araddr<=tx.araddr;
	mvif.arid<=tx.arid;
	mvif.arlen<=tx.arlen;
	mvif.arcache<=tx.arcache;
	mvif.arprot<=tx.arprot;
	mvif.arlock<=tx.arlock;
	mvif.arsize<=tx.arsize;
	mvif.arburst<=tx.arburst;
	mvif.arvalid<=1;
	//master need to wait untill ready come from slave 
	wait(mvif.arready==1);
	@(posedge mvif.aclk);
	mvif.arvalid<=0;//inside slave awready=0

	a[tx.arid]=tx.arlen;

endtask

//5.read data channel
task read_data_channel();//rready=1
a.first(b);

$display("b=%d",a[b]);
for(int i=0; i<=a[b]; i++)begin 
	mvif.rready<=1;
	wait(mvif.rvalid==1);
	@(posedge mvif.aclk);
	mvif.rready<=0;
	$display("time=%d",$time);
end
a.delete(b);
endtask
endclass 





