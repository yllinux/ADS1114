/*****************************************************************************

*    Engineer       : yanglei
*    Target Device  : Cyclone IV E ( EP4CE6F17C8 )
*    Tool versions  : Quartus II 12.1
*    Create Date    : 2018-1-12
*    Revision       : v1.0
*    Description    : 仅适用于 50MHz 时钟的按键模块

*****************************************************************************/
`timescale 1ns / 1ps
module KEY (clk, rst_n, key_in, key_out);

    input             key_in;
    input             clk;
    input             rst_n ;
    output reg [3:0]  key_out;
    
    parameter  MODE  =  4'd10;      //模式种类参数

//--------------------消抖------------------------------
    reg [19:0]  cnt;
    reg         key_scan;
    always @(posedge clk or negedge rst_n)              
        begin 
            if(!rst_n)                                  //复位信号低有效
                cnt <= 20'd0;                           //计数器清0 
            else 
                begin 
                    if(cnt >= 20'd99_9999)              //20ms扫描一次, 50MHz 的时钟周期 T = 20ns，计数100_0000次为20ms
                        begin
                            cnt       <= 20'd0;         //计数器计到ms，计数器清零 
                            key_scan  <= key_in;        //采样按键输入电平 
                        end 
                    else 
                        cnt <= cnt + 20'd1;             //计数器加1 
                end 
        end

//--------------------按键信号锁存一个时钟节拍-------------
    reg key_scan_r; 
    always @(posedge clk or negedge rst_n)
        if (!rst_n)
            key_scan_r  <= 1'b0;                        //保证内部寄存器都可以被复位
        else 
            key_scan_r  <= key_scan;
        
    wire flag = (key_scan_r) & (~key_scan);             //当检测到按键有下降沿变化时，代表该按键被按下，按键有敊    
  //wire flag;
  //assign flag = (key_scan_r) & (~key_scan);

//--------------------信号输出---------------------------
    always @ (posedge clk or negedge rst_n)            
        begin 
            if (!rst_n)                                 //复位信号低有效
                key_out <= 4'd0;
            else 
                if ( flag ) 
                    key_out <= key_out + 4'd1;
                else 
                    if (key_out >= MODE) 
                        key_out <= 4'd0;
                    else 
                        key_out <= key_out;
        end

endmodule