module ddrcntrl(clk,rst,logical_addr,pwdata,pwrite,prdata,bg,ba,a,cs_n,act_n,burstlen,strobe,tpwdata);
input clk,rst;
input [31:0] logical_addr;
input [31:0] pwdata;
input pwrite;
//input pvalid;
input [3:0]burstlen;
input [3:0]strobe;
output [31:0] prdata;
output reg [1:0] bg;
output reg [1:0] ba;
output reg [17:0] a;
output reg cs_n;
output reg act_n;
//output reg pready;


reg [17:0] ra;
reg [9:0] ca;

reg [1:0] tbg;
reg [1:0] tba;
reg [17:0] tra;
reg [9:0] tca;
output reg [31:0] tpwdata;

parameter IDLE=2'b00;
parameter ACTIVATE=2'b01;
parameter WRITE_READ=2'b10;
parameter PRECHARGE=2'b11;

reg [1:0] state;

//dram dutdram(.clk(clk),.rst(rst),.bg(bg),.ba(ba),.a(a),.cs_n(cs_n),.act_n(act_n),.pwdata(tpwdata),.prdata(prdata));

//write with autoprecharge and read with autoprecharge  
always@(posedge clk)begin
	bg=logical_addr[28:27];
	ba=logical_addr[26:25];
	ra=logical_addr[24:10];
	ca=logical_addr[9:0];
	if(rst==1)begin
		bg=0;
		ba=0;
		a=0;
		state=IDLE;
		//pready=0;
	end
	else begin
		case(state)
			IDLE:begin
				//pready<=0;
			
				//bg=logical_addr[28:27];
				//ba=logical_addr[26:25];
				//ra=logical_addr[24:10];
				//ca=logical_addr[9:0];
				//all bank prechrage
				if(((bg === 2'bx) && (ba === 2'bx) && (ra === 2'bx)) || ((tbg === bg) && (tba !== ba)))begin
					cs_n=0;
					act_n=1;
					a[16]=0;
					a[15]=1;
					a[14]=0;
					a[10]=1;
					tbg=bg;
					tba=ba;
					state=IDLE;
					$display("all bank precharge time=%0t",$time);
				end
				//single bank precharge
				else if(a[10]!==1 && a[16] === 1 && a[15] === 0 && tbg === bg && tba === ba && tra !== ra)begin
					cs_n=0;
					act_n=1;
					a[16]=0;
					a[15]=1;
					a[14]=0;
					a[10]=0;
					tbg=bg;
					tba=ba;
					tra=ra;
					state=IDLE;
					$display("single bank precharge time=%0t",$time);

				end
				else begin
					act_n=0;cs_n=0;
					state=ACTIVATE;
				end
			end

			ACTIVATE:begin
				tbg=bg;
				tba=ba;
				tra=ra;
				tca=ca;
				a=tra;//row activate

				tpwdata=pwdata;

				state=WRITE_READ;
				//pready<=0;
			end

			WRITE_READ:begin//45ns
				//if previous and current are same  or not
				//if not same then precharge
				//previous = current
				//else if same 
				//send 	a[14]=~pwrite;//we_n master pwrite 0 -> write  pwrite->1 read	a[9:0]=ca;state=IDLE;
				//
				//tbg tba tra tca   changed in this cycle
				//which checks next state addr
				//bg=logical_addr[28:27];
				//ba=logical_addr[26:25];
				//ra=logical_addr[24:10];
				//ca=logical_addr[9:0];

				act_n=1;cs_n=0;
				//pready=1;

				if((tbg === bg) && (tba === ba) && (tra !== ra))begin //single bank auto precharge
					//wirte/read with autoprecharge
					a[10]=1;
					a[16]=1;//ras_n
					a[15]=0;//cas_n
					a[14]=~pwrite;
					a[9:0]=tca;
					//tbg=ba; tba=ba; tra=ra; tca=ca;//copy
					//$display("if tra=%d  ra=%d",tra,ra);
					//$display("write/read auto precharge time=%0t",$time);

					state=IDLE;
				end
				else if((tbg === bg) && (tba === ba) && (tra === ra)) begin
					a[14]=~pwrite;
					a[9:0]=tca;
					a[10]=0;//wirte/read with  no autoprecharge
					a[16]=1;//ras_n
					a[15]=0;//cas_n
					//$display("else if tra=%d  ra=%d",tra,ra);
					//$display("write/ read   time=%0t",$time);
					state=IDLE;
				end
				else
					state=IDLE;


			end
		endcase
	end
end
endmodule

// module top;
// reg clk,rst;
// reg [31:0] logical_addr;
// reg [31:0] pwdata;
// reg pwrite;
// wire prdata;
// wire [1:0] bg;
// wire [1:0] ba;
// wire [17:0] a;
// wire cs_n;
// wire act_n;

// ddrcp dut(clk,rst,logical_addr,pwdata,pwrite,prdata,bg,ba,a,cs_n,act_n);

// initial begin
// 	clk=0;
// 	forever #5 clk=~clk;
// end

// /*initial begin
// 	@(posedge clk);rst=1;//5ns
// 	@(posedge clk);rst=0;//15ns

// ///	@(posedge clk);//idle
// 	logical_addr=1000;pwdata=10;
// 	@(posedge clk);//35//activate
// 	@(posedge clk);//45//write read
// 	pwrite=1;
// 	logical_addr=2000;pwdata=20;
// 	@(posedge clk);//55//idle
// 	@(posedge clk);//65//activate
// 	@(posedge clk);//75//write read
// 	pwrite=1;
// 	logical_addr=1000;
// 	@(posedge clk);//85//idle
// 	@(posedge clk);//95//activate
// 	@(posedge clk);//105//write read
// 	pwrite=0;
// 	logical_addr=2000;
// 	@(posedge clk);
// 	@(posedge clk);
// 	//logical_addr=32'bx;
// end*/
// 				//bg=logical_addr[28:27];
// 				//ba=logical_addr[26:25];
// 				//ra=logical_addr[24:10];
// 				//ca=logical_addr[9:0];

// initial begin
// 	@(posedge clk);rst=1;//5ns
// 	@(posedge clk);rst=0;//15ns

// ///	@(posedge clk);//idle
// 	logical_addr=1000;pwdata=10;
// 	@(posedge clk);//35//activate
// 	@(posedge clk);//45//write read
// 	pwrite=1;
// 	logical_addr=2000;logical_addr[26:25]=2'b11;pwdata=20;
// 	@(posedge clk);//55//idle
// 	@(posedge clk);//idle//expecting all bank precharge
// 	@(posedge clk);//65//activate
// 	@(posedge clk);//75//write read
// 	pwrite=1;
// 	logical_addr=2001;logical_addr[26:25]=2'b11;pwdata=30;
// 	@(posedge clk);//85//idle
// 	@(posedge clk);//95//activate
// 	@(posedge clk);//105//write read
// 	pwrite=1;
// 	logical_addr=2002;logical_addr[26:25]=2'b10;pwdata=40;
// 	@(posedge clk);//expecting all bank precharge
// 	@(posedge clk);//85//idle
// 	@(posedge clk);//95//activate
// 	@(posedge clk);//105//write read
// 	pwrite=1;
// 	logical_addr=2002;logical_addr[26:25]=2'b10;pwdata=50;
// 	@(posedge clk);//85//idle
// 	logical_addr=2002;logical_addr[26:25]=2'b10;logical_addr[24:10]=15'd15;pwdata=60;//expecting single bank precharge
// 	@(posedge clk);//idle
// 	@(posedge clk);//95//activate
// 	@(posedge clk);//105//write read
// 	pwrite=1;
// end


// initial begin
// 	#300;
// 	$finish();
// end
// endmodule


