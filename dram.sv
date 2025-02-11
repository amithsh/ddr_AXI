class dram_vip;
reg [17:0] temp_a;
reg [31:0] dram  [(2**31)-1000 :0];
reg [(2^32)-1:0] addr;

virtual ddr_intf vi;

    task run();
        vi=common::ddr_vif;
        forever begin
            @(posedge vi.clk);
                if(vi.reset==1)begin
                    vi.prdata=0;
                    temp_a=0;
                end
                else begin
                    if(vi.cs_n==0 && vi.act_n==0)begin
                        temp_a=vi.a;
                    end

                    if(vi.cs_n==0 && vi.act_n==1)begin
                        if(vi.a[14]==0)begin
                            addr={vi.bg,vi.ba,temp_a,vi.a[9:0]};
                            dram[addr]=vi.tpwdata;
                            $display("write  data=%0d  addr=%0d",dram[addr],addr);
                        end
                        else if(vi.a[14]==1)begin
                            addr={vi.bg,vi.ba,temp_a,vi.a[9:0]};
                            vi.prdata=dram[addr];
                            $display("read  data=%0d  addr=%0d",dram[addr],addr);
                        end
                    end
                end
        end
    endtask
endclass