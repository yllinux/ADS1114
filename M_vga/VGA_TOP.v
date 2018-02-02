/*****************************************************************************

*    Engineer       : yanglei
*    Target Device  : Cyclone IV E ( EP4CE6F17C8 )
*    Tool versions  : Quartus II 12.1
*    Create Date    : 2018-1-12
*    Revision       : v1.0
*    Description    : 适用于 VGA 和 HDMI 的顶层模块

*****************************************************************************/
module VGA_TOP (clk, clk_sys, key_in, din, rst_n, hsync, vsync, DATA);

    input         clk;
    input         clk_sys;
    input         key_in;
    input  [23:0] din;
    input         rst_n;
    
    output        hsync;
    output        vsync;
    output [23:0] DATA;
    
//--------------------Horizontal Parameter-----------------------                                       
    parameter 
        H_FRONT   = 12'd88,                           //行同步前
        H_SYNC    = 12'd44,                           //行同步期
        H_BACK    = 12'd148,                          //行同步后    
        H_ACT     = 12'd1920,                         //横向屏幕可见区域                                                                                                
//--------------------Vertical Parameter-------------------------  
        V_FRONT   = 12'd4,                                          
        V_SYNC    = 12'd5,
        V_BACK    = 12'd36,
        V_ACT     = 12'd1080;                          //纵向屏幕可见区域     

    wire [23:0] data;
    wire [3:0]  key_w;
    wire [11:0] X;
    wire [11:0] Y;
        
    KEY #(
        .MODE            ( 4'd10   )
    ) U_KEY_1 
    (
        .clk             ( clk_sys ), 
        .rst_n           ( rst_n   ), 
        .key_in          ( key_in  ), 
        .key_out         ( key_w   )
    );

    VGA #(                               //数据传递
        .H_FRONT         ( H_FRONT ),
        .H_SYNC          ( H_SYNC  ),
        .H_BACK          ( H_BACK  ),
        .H_ACT           ( H_ACT   ),                                                                                        
//--------------------Vertical Parameter-------------------------  
        .V_FRONT         ( V_FRONT ),                                       
        .V_SYNC          ( V_SYNC  ),
        .V_BACK          ( V_BACK  ),
        .V_ACT           ( V_ACT   )   
    ) U_VGA  
    (
        .clk             ( clk     ), 
        .rst_n           ( rst_n   ), 
        .data            ( data    ), 
        .hsync           ( hsync   ), 
        .vsync           ( vsync   ), 
        .DATA            ( DATA    ), 
        .X               ( X       ), 
        .Y               ( Y       )
    );

    DATA #(
        .H_ACT           ( H_ACT   ),
        .V_ACT           ( V_ACT   )
    ) U_DATA 
    (
        .clk             ( clk     ), 
        .rst_n           ( rst_n   ), 
        .din             ( din     ), 
        .key_data        ( key_w   ), 
        .X               ( X       ), 
        .Y               ( Y       ), 
        .data            ( data    )
    );
    
endmodule