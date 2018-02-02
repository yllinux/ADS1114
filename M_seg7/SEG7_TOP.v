/*****************************************************************************

*    Engineer       : yanglei
*    Target Device  : Cyclone IV E ( EP4CE6F17C8 )
*    Tool versions  : Quartus II 12.1
*    Create Date    : 2018-1-12
*    Revision       : v1.0
*    Description    : 适用于 数码管的 顶层模块

*****************************************************************************/
module SEG7_TOP (clk, rst_n, key2, data, seg, sel);
    input           key2;
    input           clk; //50MHz
    input           rst_n;
    input   [15:0]  data;
    
    output  [7:0]   seg;     //段选
    output  [5:0]   sel;     //位选
    
    wire clk_div;
    wire [15:0] data;
    wire [3:0]  key_w;
    
    KEY #(
        .MODE            ( 4'd2    )
    ) U_KEY_2 
    (
        .clk             ( clk     ), 
        .rst_n           ( rst_n   ), 
        .key_in          ( key2    ), 
        .key_out         ( key_w   )
    );
    
    FRE_DIV U_FRE_DIV (
        .clk        ( clk     ), 
        .rst_n      ( rst_n   ), 
        
        .clk_div    ( clk_div )
    );
    
    SEG7 U_SEG7 (
        .key2       ( key_w   ),
        .clk        ( clk_div ), 
        .rst_n      ( rst_n   ), 
        .data       ( data    ),
        
        .seg        ( seg     ), 
        .sel        ( sel     )
    );
    
endmodule