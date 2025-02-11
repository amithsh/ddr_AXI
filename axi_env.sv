class axi_env;

	axi_gen gen;
	axi_bfm bfm;
	dram_vip dvip;
	//axi_slave_bfm sbfm;

	task run();
		fork
            //sbfm=new();
			gen=new();
			bfm=new();
			dvip=new();
			
			gen.run();
			bfm.run();
			dvip.run();
			//sbfm.run();
		join
	endtask
endclass
