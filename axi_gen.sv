class axi_gen;

	axi_tx tx;

task run();
  case(common::testname)

   "SINGLE_WRITE_TEST":begin //we are expecting ok response for slave w,r\.rt id	  

	                tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; awaddr==2; awlen==3; awsize==2; awburst==1; wid==awid;};
	                common::gen2bfm.put(tx);
		end//both aligned and unaligned singe wr test is working fine (we are reciving ok response from slave)


   "MULTIPLE_WRITE_TEST":begin//5 write transaction
	           //first traansaction  
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; awaddr==2; awlen==3; awsize==2; awburst==1; wid==awid;};
			//4transfres 1st wstrb=4'b1100 second onawrds 4'b1111 
	                common::gen2bfm.put(tx);
                 //second transaction is narrow transfer 2bytes are active in
		 //each transfer 
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; awaddr==100; awlen==4; awsize==1; awburst==1; wid==awid;};
	                common::gen2bfm.put(tx);
			//5 transfers, 
		//3rd transaction  is awwor transfer with unaligned address 1byte is active in each
		//transfer  4'b0011  4'b1100   4'b0011  4'b1100
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; awaddr==201; awlen==3; awsize==0; awburst==1; wid==awid;};
	                common::gen2bfm.put(tx);

			//2 transfers wstrb=4'b0010  wstrb=4'b0100
			//wstrb=4'b1000  wstrb=4'b0001
		//4th transaction 

                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; awaddr==300; awlen==7; awsize==2; awburst==1; wid==awid;};
	                common::gen2bfm.put(tx);
		//5th transaction   wstrb=1000  wstrb=1111  ......	
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; awaddr==400; awlen==3; awsize==2; awburst==1; wid==awid;};
	                common::gen2bfm.put(tx);
			//wstrb=4'1111  wstrb=4'b1111
  
  
  
   end
   "SINGLE_WRITE_READ_TEST":begin
      //write transaction 
      
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_THEN_READ; awaddr==2; awlen==3; awsize==2; awburst==1; wid==awid;  araddr==2; arlen==3; arsize==2; arburst==1; };
	                common::gen2bfm.put(tx);
                        
   end 
   "MULTIPLE_WRITE_READ_TEST":begin
  //first traansaction  
                tx=new();
	            tx.randomize() with {wr_rd==WRITE_THEN_READ; awaddr==1; awlen==3; awsize==1; awburst==1; wid==awid; araddr==1; arlen==3; arsize==1; arburst==1; };
	            common::gen2bfm.put(tx);

				//non-aligned and non-narrow transfer
				tx=new();
	            tx.randomize() with {wr_rd==WRITE_THEN_READ; awaddr==2; awlen==3; awsize==2; awburst==1; wid==awid; araddr==2; arlen==3; arsize==2; arburst==1; };
	            common::gen2bfm.put(tx);
				
				//non-aligned and narrow transfer
				tx=new();
	            tx.randomize() with {wr_rd==WRITE_THEN_READ; awaddr==20; awlen==3; awsize==1; awburst==1; wid==awid; araddr==20; arlen==3; arsize==1; arburst==1; };
	            common::gen2bfm.put(tx);

  
  
  
   end 

   //Please enable overlalping pin is 1 to isndie common class 
   "OVERLAPPING_TRANSACTION_TEST":begin//verified 
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; awaddr==0; awlen==3; awsize==2; awburst==1; awid==5; awvalid==1; wvalid==0;};
		        common::gen2bfm.put(tx);

			//2nd write address and first transaction write data 

                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; awaddr==100; awlen==3; awsize==2; awburst==1; awid==10; awvalid==1; wvalid==1; wid==5;};
		        common::gen2bfm.put(tx);
			//3rd write address and sedond transaction write data 
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; awaddr==200; awlen==3; awsize==2; awburst==1; awid==12; awvalid==1; wvalid==1; wid==10;};
		        common::gen2bfm.put(tx);
			//3rd address data 
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY;  wvalid==1; wid==12;};
		        common::gen2bfm.put(tx);


                         tx=new();
	                tx.randomize() with{wr_rd==READ_ONLY; araddr==0; arlen==3; arsize==2; arburst==1;};
		        common::gen2bfm.put(tx);
                        tx=new();
	                tx.randomize() with{wr_rd==READ_ONLY; araddr==100; arlen==3; arsize==2; arburst==1;};
		        common::gen2bfm.put(tx);
                        tx=new();
	                tx.randomize() with{wr_rd==READ_ONLY; araddr==200; arlen==3; arsize==2; arburst==1;};
		        common::gen2bfm.put(tx);



    
    end 
    //please enable out_of_order pin inside common class 
   "OUT_OF_ORDER_TRANSACTION_TEST":begin //verifed 
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; awaddr==0; awlen==3; awsize==2; awburst==1; awid==5; awvalid==1; wvalid==0;};
		        common::gen2bfm.put(tx);

                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; awaddr==100; awlen==3; awsize==2; awburst==1; awid==10; awvalid==1; wvalid==0;};
		        common::gen2bfm.put(tx);
			
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; awaddr==200; awlen==3; awsize==2; awburst==1; awid==12; awvalid==1; wvalid==0;};
		        common::gen2bfm.put(tx);
			//3 write data will start with diffrent order of
			//address
			
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; wvalid==1; awvalid==0; wid==12;};
		        common::gen2bfm.put(tx);
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; wvalid==1; awvalid==0; wid==10;};
		        common::gen2bfm.put(tx);
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; wvalid==1; awvalid==0; wid==5;};
		        common::gen2bfm.put(tx);



			//any order you will read 

                        tx=new();
	                tx.randomize() with{wr_rd==READ_ONLY; araddr==100; arlen==3; arsize==2; arburst==1;};
		        common::gen2bfm.put(tx);
                        tx=new();
	                tx.randomize() with{wr_rd==READ_ONLY; araddr==200; arlen==3; arsize==2; arburst==1;};
		        common::gen2bfm.put(tx);
                        tx=new();
	                tx.randomize() with{wr_rd==READ_ONLY; araddr==0; arlen==3; arsize==2; arburst==1;};
		        common::gen2bfm.put(tx);




 

  
    end


   "INCRIMENT_TRANSACTION_TEST":begin //done 
   tx=new();
	                tx.randomize() with{wr_rd==WRITE_THEN_READ; awaddr==2; awlen==3; awsize==2; awburst==1; wid==awid; araddr==2;  arlen==3; arsize==2; arburst==1;};
			//4transfres 1st wstrb=4'b1100 second onawrds 4'b1111 
	                common::gen2bfm.put(tx);
                 //second transaction is narrow transfer 2bytes are active in
		 //each transfer 
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_THEN_READ; awaddr==100; awlen==4; awsize==1; awburst==1; wid==awid; araddr==100;  arlen==4; arsize==1; arburst==1;};
	                common::gen2bfm.put(tx);

   end    //done
   "NARROW_TRANSFER_TEST":begin//verified 
   tx=new();
	                tx.randomize() with{wr_rd==WRITE_THEN_READ; awaddr==100; awlen==4; awsize==1; awburst==1; wid==awid; araddr==100;  arlen==4; arsize==1; arburst==1;};
	                common::gen2bfm.put(tx);
			//5 transfers, 
		//3rd transaction  is awwor transfer with unaligned address 1byte is active in each
		//transfer  4'b0011  4'b1100   4'b0011  4'b1100
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_THEN_READ; awaddr==201; awlen==3; awsize==0; awburst==1; wid==awid;  araddr==201;  arlen==3; arsize==0; arburst==1;};
	                common::gen2bfm.put(tx);

  
   end  //done
   "ALIDNED_NARROW_TRASNFER":begin 
 tx=new();
	                tx.randomize() with{wr_rd==WRITE_THEN_READ; awaddr==201; awlen==3; awsize==0; awburst==1; wid==awid;  araddr==200;  arlen==3; arsize==0; arburst==1;};
	                common::gen2bfm.put(tx);
end   //done
  "UN_ALIGNED_NARROW_TRANSFER":begin
 //3rd transaction  is awwor transfer with unaligned address 1byte is active in each
		//transfer  4'b0011  4'b1100   4'b0011  4'b1100
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_THEN_READ; awaddr==201; awlen==3; awsize==0; awburst==1; wid==awid;  araddr==201;  arlen==3; arsize==0; arburst==1;};
	                common::gen2bfm.put(tx); 
  end   //done

//enable out_of_order and overlapping pin inside common class 
"OVERLAPPING_TRANSACTION_OUT_OF_ORDER_TEST":begin  // verified 
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; awaddr==0; awlen==3; awsize==2; awburst==1; awid==5; awvalid==1; wvalid==0;};
		        common::gen2bfm.put(tx);

			//2nd write address  

                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; awaddr==100; awlen==3; awsize==2; awburst==1; awid==10; awvalid==1; wvalid==0;};
		        common::gen2bfm.put(tx);
			//3rd write address and sedond transaction write data 
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; awaddr==200; awlen==3; awsize==2; awburst==1; awid==12; awvalid==1; wvalid==1; wid==10;};
		        common::gen2bfm.put(tx);
			//1st write address data 
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY;  wvalid==1; awvalid==0; wid==5;};
		        common::gen2bfm.put(tx);
			//3rd write address data 
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY;  wvalid==1;awvalid==0; wid==12;};
		        common::gen2bfm.put(tx);


                         tx=new();
	                tx.randomize() with{wr_rd==READ_ONLY; araddr==0; arlen==3; arsize==2; arburst==1;};
		        common::gen2bfm.put(tx);
                        tx=new();
	                tx.randomize() with{wr_rd==READ_ONLY; araddr==100; arlen==3; arsize==2; arburst==1;};
		        common::gen2bfm.put(tx);
                        tx=new();
	                tx.randomize() with{wr_rd==READ_ONLY; araddr==200; arlen==3; arsize==2; arburst==1;};
		        common::gen2bfm.put(tx);



    
    end 


//Assigment testcases 
//Outof order with narrow transfer aligned address
//out of order with barrow transfer unaligned
//overlapping with narrow transfer aligned address
//overlalping with narrow transfer unaligned address 


  "ALL_COMBIATION_AWSIZE_TEST":begin end 
  "ALL COMINATION_AWLEN": begin end
  "ALL_COMBINATION_OF_WSTRB":begin end 
  "ALL_COMBINATION_OF_WDATA_SIZE":begin end  

   "WRITE_PARALEL_READ":begin//verified 

	  //1st WRITE TRANSACTION 
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_ONLY; awaddr==0; awlen==3; awsize==2; awburst==1; awid==5;  wid==5; };
		        common::gen2bfm.put(tx);
         //2nd write transaction and first read transaction same time posible 
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_PARALEL_READ; awaddr==100; awlen==3; awsize==2; awburst==1; awid==10; wid==10;  araddr==0; arlen==3; arsize==2; arburst==1;};
		        common::gen2bfm.put(tx);
	//3rd write trabsaction and secodn read transaction same time 
                        tx=new();
	                tx.randomize() with{wr_rd==WRITE_PARALEL_READ; awaddr==200; awlen==3; awsize==2; awburst==1; awid==12; wid==12;  araddr==100; arlen==3; arsize==2; arburst==1;};
		        common::gen2bfm.put(tx);
	//3rd read address 
                         tx=new();
	                tx.randomize() with{wr_rd==READ_ONLY; araddr==200; arlen==3; arsize==2; arburst==1;};
		        common::gen2bfm.put(tx);
			
    end  
endcase

	endtask
	
endclass

/*
* step1: check aligned or unaligned  100% 2^1 = 0 aligned address 
* 100 is realted to which byte postion 

      100% wdata size in bytes    102%4 =2 its not start fron first yte 

     = start_Addr  - (Addr% wdata size in bytes))
     = 102   -  (102%4)
     = 102  -2
     =100 (is a start addr current transfer, this is unaligned address of 102)

     = 102 -  100
     =2  (102 address related 2nd byte not 0th byte, 1st byte)
     
     
     multiple write and read incriment transaction 
     narrow transafer 
     unaligned & aligned transfer deloped testcase and verified 
     order transaction (w.r.t address data also same order) verified 
     out of transaction verfied 
     overlaping transaction verified 
     non-overlappin transaction verfiied (normal only)
     write paralel read transaction verified 
     out of order with overlapping -- verfied
     write then read verfiied     
     */



  
