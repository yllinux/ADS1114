/*****************************************************************************

*    Engineer       : yanglei
*    Target Device  : Cyclone IV E ( EP4CE6F17C8 )
*    Tool versions  : Quartus II 12.1
*    Create Date    : 2018-1-12
*    Revision       : v1.0
*    Description    : 仅适用于时钟频率为 50MHz 的分频为 1KHz 的分频器模块

*****************************************************************************/
module FRE_DIV (clk, rst_n, clk_div);  //得到 1 KHz 时钟
    input       clk;
    input       rst_n;
    
    output      clk_div;
    
    reg         clk_div_r;
    reg [19:0]  cnt;
    
    assign clk_div = clk_div_r;
    
    always @(posedge clk or negedge rst_n)
        begin 
            if (!rst_n)
                begin 
                    clk_div_r   <= 1'b1;
                    cnt       <= 20'd0;
                end 
            else 
                begin
                    if (cnt < 20'd24999)
                        cnt   <= cnt + 20'd1;
                    else
                        begin 
                            cnt      <= 20'd0;
                            clk_div_r  <= ~clk_div_r;
                        end 
                end 
        end 
    
endmodule