class axi_env;

	axi_gen gen;
	axi_bfm bfm;
	//axi_slave_bfm sbfm;

	task run();
		fork
            //sbfm=new();
			gen=new();
			bfm=new();
			gen.run();
			bfm.run();
			//sbfm.run();
		join
	endtask
endclass
