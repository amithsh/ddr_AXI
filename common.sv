class common;
	static mailbox gen2bfm=new();//un bounded mailbox, non- parameterized 
	static virtual axi_interface vif;
	static string testname;
	static bit out_of_order=0;//1 out of order is enable 0 out of order disable 
	static bit overlapping=0;
endclass 
