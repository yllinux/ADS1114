/*****************************************************************************

*    Engineer       : yanglei
*    Target Device  : Cyclone IV E ( EP4CE6F17C8 )
*    Tool versions  : Quartus II 12.1
*    Create Date    : 2018-1-19
*    Revision       : v1.0
*    Description    : 仅适用于 时钟频率（1KHz）合适的数码管显示模块

*****************************************************************************/
module SEG7_ALG (clk, rst_n, data, seg, sel);
 
    input           clk;
    input           rst_n;
    input   [15:0]  data;
    output  [7:0]   seg;        //段选
    output  [5:0]   sel;        //位选
   
    reg     [7:0]   seg;
    reg     [5:0]   sel;
    reg     [3:0]   data_temp;  //数码管显示的数
    reg     [2:0]   st;         //状态寄存器
    reg     [15:0]  data_r;
    reg     [11:0]  cnt;
    
    wire    [9:0]   result_1000;  //结果的1000倍
    assign result_1000   =  (data_r[15]) ? ((4096 * (65535 - data_r)) / 32767) :  ((4096 * data_r) / 32767);
    
    d
     
    always @(posedge clk or negedge rst_n)
        begin 
            if (!rst_n)
                begin 
                    data_r  <=  16'h0000;
                    cnt     <=  12'd0;
                end 
            else 
                if (cnt >= 200)      //输入的数据每计数到300 ，显示一次。
                    begin 
                        data_r  <=  data;
                        cnt     <=  12'd0;
                    end 
                else 
                    cnt   <=  cnt + 12'd1;
        end 
    
    always @(posedge clk or negedge rst_n)
        begin 
            if(!rst_n)
                begin 
                    sel        <=  6'b11_1110;
                    data_temp  <=  4'b0000;
                    st         <=  3'd0;
                end 
            else 
                begin 
                    case (st)    //选择数码管
                        3'd4 :
                            begin 
                                sel        <=  6'b101111; //实际上是左起 第 6 个
                                data_temp  <=  data_r[3:0];
                                st         <=  3'd5;
                            end 
                            
                        3'd3 :                                 //将第 [15:12] 位数显示在从左至右第 1 个数码管上
                            begin 
                                sel        <=  6'b110111; //实际上是左起 第 5 个
                                data_temp  <=  data_r[7:4];
                                st         <=  3'd4;
                            end 
                            
                        3'd2 :                                 //将第 [11:8] 位数显示在从左至右第 2 个数码管上
                            begin 
                                sel        <=  6'b111011; //实际上是左起 第 4 个
                                data_temp  <=  data_r[11:8];
                                st         <=  3'd3;
                            end   
                            
                        3'd1 :                                 //将第 [7:4] 位数显示在从左至右第 3 个数码管上
                            begin 
                                sel        <=  6'b111101; //实际上是左起 第 3 个
                                data_temp  <=  data_r[15:12];
                                st         <=  3'd2;
                            end 
                    
                        3'd0 :                                 //将第 [3:0]; 位数显示在从左至右第 4 个数码管上
                            begin 
                                sel        <=  6'b111110; //实际上是左起 第 2 个
                                data_temp  <=  data_r[19:16];
                                st         <=  3'd1;
                            end 
                          
                        3'd5 :
                            begin 
                                sel        <=  6'b01_1111; //实际上是左起 第 1 个
                                data_temp  <=  data_r[23:20];
                                st         <=  3'd0;
                            end
                            
                        default :
                            begin 
                                st         <=  3'd0;
                            end 
                    endcase
                end 
        end 
    always @(posedge clk or negedge rst_n)
        begin 
            if (!rst_n)
                seg    <=  8'b1111_1111;
            else 
                begin 
                    case (data_temp)
                        4'b0000  :  seg  <=  8'b1100_0000;     //显示 0
                        4'b0001  :  seg  <=  8'b1111_1001;     //显示 1
                        4'b0010  :  seg  <=  8'b1010_0100;     //显示 2
                        4'b0011  :  seg  <=  8'b1011_0000;     //显示 3
                        
                        4'b0100  :  seg  <=  8'b1001_1001;     //显示 4
                        4'b0101  :  seg  <=  8'b1001_0010;     //显示 5
                        4'b0110  :  seg  <=  8'b1000_0010;     //显示 6
                        4'b0111  :  seg  <=  8'b1111_1000;     //显示 7
                       
                        4'b1000  :  seg  <=  8'b1000_0000;     //显示 8 
                        4'b1001  :  seg  <=  8'b1001_0000;     //显示 9
                        4'b1010  :  seg  <=  8'b1000_1000;     //显示 A
                        4'b1011  :  seg  <=  8'b1000_0011;     //显示 B
                        
                        4'b1100  :  seg  <=  8'b1100_0110;     //显示 C
                        4'b1101  :  seg  <=  8'b1010_0001;     //显示 D
                        4'b1110  :  seg  <=  8'b1000_0110;     //显示 E
                        4'b1111  :  seg  <=  8'b1000_1110;     //显示 F
                        default  :  seg  <=  8'b1111_1111;     //不显示
                    endcase 
                end 
        end 
        
endmodule