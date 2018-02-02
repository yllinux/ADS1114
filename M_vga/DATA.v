/*****************************************************************************

*    Engineer       : yanglei
*    Target Device  : Cyclone IV E ( EP4CE6F17C8 )
*    Tool versions  : Quartus II 12.1
*    Create Date    : 2018-1-12
*    Revision       : v1.0
*    Description    : 适用于 VGA 和 HDMI 的数据处理和产生模块

*****************************************************************************/
`timescale 1ns / 1ps
module DATA (clk, rst_n, din, key_data, X, Y, data);

    input      [23:0] din;                                            //外部输入RGB数据
    input      [3:0]  key_data;
    input             clk;                                            //时钟信号
    input             rst_n;                                          //系统复位信号
    input      [11:0] X;
    input      [11:0] Y;
    output reg [23:0] data;

    reg        [10:0] cnt_ma;                                         //马赛克计数
    reg        [4:0]  y_cnt;
    reg        [9:0]  x_cnt;                                          //未加按键控制时引入，用来控制功能切换的时间
    reg        [25:0] cnt;                                            //数据输入延时采样，保证IIC输入数据稳定
    reg        [23:0] din_r;                                          //延时采样数据寄存
    
    parameter
        H_ACT       =  12'd1920,
        V_ACT       =  12'd1080;
        
    always @(posedge clk or negedge rst_n)
        if (!rst_n)
            begin 
                cnt    <=  26'd0;
            end 
        else 
            begin
                if (cnt < 5999_9999)                                  //计 6000_0000 次
                    begin 
                        cnt  <=  cnt + 26'd1;
                    end 
                else 
                    begin 
                        cnt    <=  26'd0;
                        din_r  <=  din;
                    end 
            end 
    
    always @(posedge clk or negedge rst_n)
        if (!rst_n)                              
            data <= 24'h0;    
        else
            begin
                case (key_data)
					 
//--------------------默认输出IIC输入的RGB数据--------------------------
                    4'd0: data <= din_r;

//--------------------横彩条------------------------------------------					  
                    4'd1: data <=  (Y < (V_ACT / 8) * 1) ? 24'hff0000 :
                                   (Y < (V_ACT / 8) * 2) ? 24'h0ff000 :
                                   (Y < (V_ACT / 8) * 3) ? 24'h00ff00 :
                                   (Y < (V_ACT / 8) * 4) ? 24'h000ff0 :
                                   (Y < (V_ACT / 8) * 5) ? 24'h0000ff :
                                   (Y < (V_ACT / 8) * 6) ? 24'hffffff :
                                   (Y < (V_ACT / 8) * 7) ? 24'hff00ff :
                                   (Y < V_ACT)? 24'hffff00 : 24'h000000;
                                                     
//--------------------竖彩条------------------------------------------						  
                    4'd2: data <=  (X < (H_ACT / 8) * 1) ? 24'hff0000 :
                                   (X < (H_ACT / 8) * 2) ? 24'h0ff000 :
                                   (X < (H_ACT / 8) * 3) ? 24'h00ff00 :
                                   (X < (H_ACT / 8) * 4) ? 24'h000ff0 :
                                   (X < (H_ACT / 8) * 5) ? 24'h0000ff :
                                   (X < (H_ACT / 8) * 6) ? 24'hffffff :
                                   (X < (H_ACT / 8) * 7) ? 24'hff00ff :
                                   (X < H_ACT)? 24'hffff00 : 24'h000000;

//--------------------对角渐变----------------------------------------                                         
                    4'd3: data <=  24'h00ffff + (Y/5)*65536;

//--------------------全色渐变----------------------------------------                     
                    4'd4: data <=                           (Y < ((V_ACT / 8) * 1) ) ? 24'hd21e1e + Y * 256:
                                  (Y >= ((V_ACT / 8) * 1) && Y < ((V_ACT / 8) * 2) ) ? 24'hd2d21e - (Y - ((V_ACT / 8) * 1)) * 65536: 
                                  (Y >= ((V_ACT / 8) * 2) && Y < ((V_ACT / 8) * 3) ) ? 24'h1ed21e + (Y - ((V_ACT / 8) * 2)): 
                                  (Y >= ((V_ACT / 8) * 3) && Y < ((V_ACT / 8) * 4) ) ? 24'h1ed2d2 - (Y - ((V_ACT / 8) * 3)) * 256:
                                  (Y >= ((V_ACT / 8) * 4) && Y < ((V_ACT / 8) * 5) ) ? 24'h1e1ed2 + (Y - ((V_ACT / 8) * 4)) * 65536:
                                  (Y >= ((V_ACT / 8) * 5) && Y < ((V_ACT / 8) * 6) ) ? 24'hd21ed2 - (Y - ((V_ACT / 8) * 5)):
                                  (Y >= ((V_ACT / 8) * 6) && Y < ((V_ACT / 8) * 7) ) ? 24'h1ed2d2 - (Y - ((V_ACT / 8) * 6)) * 256:
                                  (Y >= ((V_ACT / 8) * 7) && Y < ((V_ACT / 8) * 8) ) ? 24'h1e1ed2 + (Y - ((V_ACT / 8) * 7)) * 65536:
                                   24'hffffff;
							  
//--------------------静态马赛克---------------------------------------                      
                    4'd5: data <= (((X / 64) + (Y / 64)) % 2 == 0) ? 24'h000000 : 24'h973dcf;
                
//--------------------横向动态马赛克-----------------------------------                      
                    4'd6: data <= ((((X + cnt_ma) / 64) + (Y / 64)) % 2 == 0) ? 24'h000000 : 24'h973dcf;

//--------------------纵向动态马赛克-----------------------------------                      
                    4'd7: data <= (((X / 64) + (( Y + cnt_ma) / 64)) % 2 == 0) ? 24'h000000 : 24'h973dcf;

//--------------------斜向动态马赛克-----------------------------------                      
                    4'd8: data <= ((((X + cnt_ma) / 64) + ((Y + cnt_ma) / 64)) % 2 == 0) ? 24'h000000 : 24'h973dcf;  						  
 
//--------------------缩变方形----------------------------------------                      
                    //4'd9: data <=((X - 960)*(X - 960) < cnt_ma*cnt_ma*64 && (Y - 540)*(Y - 540) < cnt_ma*cnt_ma*64) ? 24'hff0000 : 24'h0;

//--------------------缩变圆形----------------------------------------                      
                    //4'd10: data <=((X - 960)*(X - 960) + (Y - 540)*(Y - 540)) < cnt_ma*cnt_ma*64 ? 24'hff0000 : 24'h0;

//--------------------缩变太极----------------------------------------
                    /*
                    4'd11: data <= (Y < 540) ?     //屏幕上半部分?
                      (
                          ((X - 960)*(X - 960) + (Y - 540)*(Y - 540)) < cnt_ma*cnt_ma*64 ? //上半部分圆形内?
                              (
                                    ((X - 1440)*(X - 1440) + (Y - 540)*(Y - 540)) < cnt_ma*cnt_ma*16 ? 24'hff0000 : 24'hffffff //上半部分小半圆内?红：白
                                ): 24'h000000 //上半部分其它区域黑色 
                                 
                      ):(//屏幕下半部分
                          ((X - 960)*(X - 960) + (Y - 540)*(Y - 540)) < cnt_ma*cnt_ma*64 ? //下半部分圆形内
                                (
                                     ((X - 480 )*(X - 480 ) + (Y - 540)*(Y - 540)) < cnt_ma*cnt_ma*16 ? 24'hffffff : 24'hff0000 //上半部分小半圆内?白：红
                                 ): 24'h000000 //下半部分其它区域黑色 
                      );
                     */
                    default:
                            data <= 24'h0;
                endcase
            end 
            
    always @(posedge clk or negedge rst_n)  //动态马赛克
        begin 
            if (!rst_n)
                cnt_ma <= 11'd0;
            else 
                if (key_data >= 4'd6)
                    begin
                        if (cnt_ma == 11'd128) 
                            cnt_ma <= 11'd0;
                        else 
                            if (y_cnt == 5'd1) 
                                cnt_ma <= cnt_ma + 11'd1;
                            else    
                                cnt_ma <= cnt_ma;
                    end
                else 
                    cnt_ma <= 11'd0;
        end 
        
    always @(posedge clk or negedge rst_n)   //cnt_ma切换时间 
        begin 
            if (!rst_n)
                y_cnt <= 5'd0;
            else 
                if (y_cnt == 5'd1)
                    y_cnt <= 0;
                else 
                    if ((Y == (V_ACT / 2))&&(X == (H_ACT / 2)))
                        y_cnt <= y_cnt + 5'd1;
                    else
                        y_cnt <= y_cnt;
        end 
            
endmodule 