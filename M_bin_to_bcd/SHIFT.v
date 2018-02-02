/*****************************************************************************

*    Engineer       : yanglei
*    Target Device  : Cyclone IV E ( EP4CE6F17C8 )
*    Tool versions  : Quartus II 12.1
*    Create Date    : 2018-1-19
*    Revision       : v1.0
*    Description    : 仅适用于 二进制转BCD码移位 处理模块

*****************************************************************************/
module SHIFT (din, dout);
    
    input   [25:0] din;
    output  [25:0] dout;
    
    wire    [3:0]  sout1;  //shift out 即移位输出
    wire    [3:0]  sout2;
    wire    [3:0]  sout3;
    wire    [3:0]  sout4;

    CMP U_CMP_1            //din[25:22] 进行大四加三比较
    (
        .cmp_in       ( din[25:22] ),
        .cmp_out      ( sout1      )
    );
    
    CMP U_CMP_2            //din[21:18] 进行大四加三比较
    (
        .cmp_in       ( din[21:18] ),
        .cmp_out      ( sout2      )
    );
    
    CMP U_CMP_3            //din[17:14] 进行大四加三比较 
    (
        .cmp_in       ( din[17:14] ),
        .cmp_out      ( sout3      )
    );
    
    CMP U_CMP_4            //din[13:10] 进行大四加三比较 
    (
        .cmp_in       ( din[13:10]),
        .cmp_out      ( sout4     )
    );
    
    //din[25:10] 全部比较完之后，左移一位
    assign dout = {sout1[2:0], sout2, sout3, sout4, din[9:0], 1'b0};
    
endmodule