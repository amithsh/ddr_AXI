module axi_top;

bit aclk,aresetn;

initial begin 
	aclk=0;
	forever #5 aclk=~aclk;
end
initial begin 
	aresetn=1;
	repeat(2)@(posedge aclk);
	aresetn=0;
end



axi_interface pvif(aclk,aresetn);
ddr_intf  dpi(aclk,aresetn);

ddrcntrl ctrl_dut(
    .clk(aclk),
    .rst(aresetn),
    .logical_addr(dpi.logical_addr),
    .pwdata(dpi.pwdata),
    .tpwdata(dpi.tpwdata),
    .pwrite(dpi.pwrite),
    .prdata(dpi.prdata),
    .bg(dpi.bg),
    .ba(dpi.ba),
    .a(dpi.a),
    .cs_n(dpi.cs_n),
    .act_n(dpi.act_n));

axi_module dut(
	.aclk(aclk),
	.aresetn(aresetn),
	.awaddr(pvif.awaddr),
	.awid(pvif.awid),
	.awvalid(pvif.awvalid),
	.awready(pvif.awready),
	.awsize(pvif.awsize),
	.awlen(pvif.awlen),
	.awcache(),
	.awprot(),
	.awlock(),
	.awburst(pvif.awburst),
	.wdata(pvif.wdata),
	.wstrb(pvif.wstrb),
	.wlast(pvif.wlast),
	.wvalid(pvif.wvalid),
	.wid(pvif.wid),
	.wready(pvif.wready),
	.bready(pvif.bready),
	.bresp(pvif.bresp),
	.bvalid(pvif.bvalid),
	.bid(pvif.bid),
	.araddr(pvif.araddr),
	.arid(pvif.arid),
	.arvalid(pvif.arvalid),
	.arready(pvif.arready),
	.arsize(pvif.arsize),
	.arlen(pvif.arlen),
	.arcache(),
	.arprot(),
	.arlock(),
	.arburst(pvif.arburst),
	.rready(pvif.rready),
	.rdata(pvif.rdata),
	.rvalid(pvif.rvalid),
	.rresp(pvif.rresp),
	.rid(pvif.rid),
	.rlast(pvif.rlast));

axi_env e;
initial begin 
	e=new();
	common::vif=pvif;//awlays maintaine before calling run() method
	common::ddr_vif=dpi;
	
	//common::testname="SINGLE_WRITE_TEST";
	common::testname="SINGLE_WRITE_READ_TEST";
	//common::testname="MULTIPLE_WRITE_READ_TEST";
	//common::testname="OVERLAPPING_TRANSACTION_TEST";
	//common::testname="WRITE_PARALEL_READ";
	//common::testname="OUT_OF_ORDER_TRANSACTION_TEST";
	//common::testname="INCRIMENT_TRANSACTION_TEST";
	//common::testname="NARROW_TRANSFER_TEST";
	//common::testname="ALIDNED_NARROW_TRASNFER";
	//common::testname="UN_ALIGNED_NARROW_TRANSFER";
	//common::testname="OVERLAPPING_TRANSACTION_OUT_OF_ORDER_TEST";


	e.run();
end


//point physical interface to virtual interface 
//initial begin 
//end

initial begin 
	#500;
	$finish;
end

endmodule 

