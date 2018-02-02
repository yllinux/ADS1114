/*****************************************************************************

*    Engineer       : yanglei
*    Target Device  : Cyclone IV E ( EP4CE6F17C8 )
*    Tool versions  : Quartus II 12.1
*    Create Date    : 2018-1-19
*    Revision       : v1.0
*    Description    : 仅适用于 大四加三 处理模块

*****************************************************************************/
module CMP(cmp_in, cmp_out);

    input   [3:0] cmp_in;
    output  [3:0] cmp_out;
    
    assign cmp_out = (cmp_in > 4'd4) ? (cmp_in + 4'd3) : (cmp_in);
   
endmodule