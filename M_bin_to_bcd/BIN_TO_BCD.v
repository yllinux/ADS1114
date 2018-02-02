/*****************************************************************************

*    Engineer       : yanglei
*    Target Device  : Cyclone IV E ( EP4CE6F17C8 )
*    Tool versions  : Quartus II 12.1
*    Create Date    : 2018-1-19
*    Revision       : v1.0
*    Description    : 仅适用于 10二进制转BCD码顶层 模块
*****************************************************************************/
module BIN_TO_BCD (bin, bcd);

    input   [9:0]  bin;
    output  [15:0] bcd;
    
    wire [25:0] shift0;
    wire [25:0] shift1;        //10 次移位结果输出
    wire [25:0] shift2;
    wire [25:0] shift3;
    wire [25:0] shift4;
    wire [25:0] shift5;
    wire [25:0] shift6;
    wire [25:0] shift7;
    wire [25:0] shift8;
    wire [25:0] shift9;
    wire [25:0] shift10;

    assign shift0  = {16'b0000_0000_0000_0000, bin};
    assign bcd     = {shift10[25:10]};   //取高 16 位输出
    
    SHIFT U_SHIFT_1            //第 1 次移位
    (
        .din     ( shift0 ),
        .dout    ( shift1 )
    );
    
    SHIFT U_SHIFT_2            //第 2 次移位
    (
        .din     ( shift1 ),
        .dout    ( shift2 )
    );
    
    SHIFT U_SHIFT_3            //第 3 次移位
    (
        .din     ( shift2 ),
        .dout    ( shift3 )
    );
    
    SHIFT U_SHIFT_4            //第 4 次移位
    (
        .din     ( shift3 ),
        .dout    ( shift4 )
    );
    
    SHIFT U_SHIFT_5            //第 5 次移位
    (
        .din     ( shift4 ),
        .dout    ( shift5 )
    );
    
    SHIFT U_SHIFT_6            //第 6 次移位
    (
        .din     ( shift5 ),
        .dout    ( shift6 )
    );
    
    SHIFT U_SHIFT_7            //第 7 次移位
    (
        .din     ( shift6 ),
        .dout    ( shift7 )
    );
    
    SHIFT U_SHIFT_8            //第 8 次移位
    (
        .din     ( shift7 ),
        .dout    ( shift8 )
    );
    
    SHIFT U_SHIFT_9            //第 9 次移位
    (
        .din     ( shift8 ),
        .dout    ( shift9 )
    );
    
    SHIFT U_SHIFT_10            //第 10 次移位
    (
        .din     ( shift9 ),
        .dout    ( shift10)
    );
    
endmodule 