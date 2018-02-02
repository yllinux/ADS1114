/****************************************************************************

*    Engineer       : yanglei
*    Target Device  : Cyclone IV E ( EP4CE6F17C8 )
*    Tool versions  : Quartus II 12.1
*    Create Date    : 2018-1-12
*    Revision       : v1.0
*    Description    : 仅适用于 ADS1114 或 ADS1115 的数码管显示和VGA显示的顶层

*****************************************************************************/
module ADS_IIC_SEG_VGA (clk, rst_n, key_in, key_seg, seg, sel, sda, scl, hsync, vsync, DATA);

    //------------外部输入------------------
    input             clk;
    input             rst_n;
    input             key_in;
    input             key_seg;
    //------------数码管输出----------------
    output [7:0]      seg;
    output [5:0]      sel;
    //------------ VGA 输出----------------
    inout             sda;
    output            scl;
    output            hsync;
    output            vsync;
    output [15:0]     DATA;
  
//-------------锁相环的倍频数、分频数参数---------------  
    parameter 
        CLK0_MUL = 1,
        CLK0_DIV = 1,
      //CLK1_MUL = 3,
      //CLK1_DIV = 1,
        CLK2_MUL = 1,
        CLK2_DIV = 10; //2~10 即IIC 时钟线频率为 100K ~ 20K
        
//***********************************************************************
//***********************************************************************可更改区↓        
//-------------ADS1114配置寄存器----------------------
    parameter
        OS          = 1'b1,
        MUX         = 3'b101,//100,
        PGA         = 3'b001,//FSR = 4.096V 不要变，若变化则SEG7程序算法也变。
        MODE        = 1'b1,
        DR          = 3'b111,//100,
        COMP_MODE   = 1'b0,
        COMP_POL    = 1'b0,
        COMP_LAT    = 1'b0,
        COMP_QUE    = 2'b11;

    `define resolution_1280_1024_60FPS_108MHz
  //`define resolution_1920_1080_60FPS_148MHz
  //`define resolution_1024_768_60FPS_65MHz 
  //`define resolution_800_600_72FPS_50MHz
  //`define resolution_640_480_60FPS_25MHz
//***********************************************************************可更改区↑   
//***********************************************************************  
 
    `ifdef resolution_1920_1080_60FPS_148MHz
//--------------------Horizontal Parameter-----------------------                                       
        parameter 
            CLK1_MUL    = 3,
            CLK1_DIV    = 1,
            H_FRONT     = 12'd88,                           //行同步前
            H_SYNC      = 12'd44,                           //行同步期
            H_BACK      = 12'd148,                          //行同步后    
            H_ACT       = 12'd1920,                         //横向屏幕可见区域                                                                                                
//--------------------Vertical Parameter-------------------------  
            V_FRONT     = 12'd4,                                          
            V_SYNC      = 12'd5,
            V_BACK      = 12'd36,
            V_ACT       = 12'd1080;                         //纵向屏幕可见区域 
    `elsif resolution_1280_1024_60FPS_108MHz
        parameter
            CLK1_MUL    = 24,
            CLK1_DIV    = 11,
            H_FRONT     = 12'd48,                           
            H_SYNC      = 12'd112,                         
            H_BACK      = 12'd248,                         
            H_ACT       = 12'd1280,                                                                                                                     
            V_FRONT     = 12'd1,                                          
            V_SYNC      = 12'd3,
            V_BACK      = 12'd38,
            V_ACT       = 12'd1024;
    `elsif resolution_1024_768_60FPS_65MHz 
       parameter
            CLK1_MUL    = 21,
            CLK1_DIV    = 16,
            H_FRONT     = 12'd24,                           
            H_SYNC      = 12'd136,                         
            H_BACK      = 12'd160,                         
            H_ACT       = 12'd1024,                                                                                                                     
            V_FRONT     = 12'd3,                                          
            V_SYNC      = 12'd6,
            V_BACK      = 12'd29,
            V_ACT       = 12'd768;
    `elsif resolution_800_600_72FPS_50MHz
        parameter
            CLK1_MUL    = 1,
            CLK1_DIV    = 1,
            H_FRONT     = 12'd56,                           
            H_SYNC      = 12'd120,                         
            H_BACK      = 12'd64,                         
            H_ACT       = 12'd800,                                                                                                                     
            V_FRONT     = 12'd37,                                          
            V_SYNC      = 12'd6,
            V_BACK      = 12'd23,
            V_ACT       = 12'd600;
    `elsif resolution_640_480_60FPS_25MHz
        parameter
            CLK1_MUL    = 1,
            CLK1_DIV    = 2,
            H_FRONT     = 12'd16,                           
            H_SYNC      = 12'd96,                         
            H_BACK      = 12'd48,                         
            H_ACT       = 12'd640,                                                                                                                     
            V_FRONT     = 12'd10,                                          
            V_SYNC      = 12'd2,
            V_BACK      = 12'd33,
            V_ACT       = 12'd480;
    `endif 
    
  
    wire          clk0;
    wire          clk1;
    wire          clk2;
    wire          locked;
    wire  [15:0]  data;                                 //IIC产生的数据 连线
    wire  [23:0]  data_w; 
    wire          rst = ~rst_n;
  //VGA输出24位数据 连线
  //wire  [23:0]  din;
  //assign        din  = {data, {8{1'b0}}};
    assign        DATA = data_w[23:8];

//------------- pll 例化-----------------------------    
    pll	#( 
        .CLK0_MUL        ( CLK0_MUL ),
        .CLK0_DIV        ( CLK0_DIV ),
        .CLK1_MUL        ( CLK1_MUL ),
        .CLK1_DIV        ( CLK1_DIV ),
        .CLK2_MUL        ( CLK2_MUL ),
        .CLK2_DIV        ( CLK2_DIV )
    ) U_pll 
    (   //------------input--------------------
        .areset          ( rst      ),
        .inclk0          ( clk      ),
        //------------output-------------------
        .c0              ( clk0     ),   //50MHz
        .c1              ( clk1     ),
        .c2              ( clk2     ),
        .locked          ( locked   )
	);
   
//------------- IIC 例化-----------------------------    
    IIC #(
        .OS              ( OS       ),
        .MUX             ( MUX      ),
        .PGA             ( PGA      ),
        .MODE            ( MODE     ),
        .DR              ( DR       ),
        .COMP_MODE       ( COMP_MODE),
        .COMP_POL        ( COMP_POL ),
        .COMP_LAT        ( COMP_LAT ),
        .COMP_QUE        ( COMP_QUE )
    ) U_IIC 
    (   //------------input--------------------
        .clk             ( clk2     ), 
        .rst_n           ( locked   ), 
        //------------output-------------------
        .sda             ( sda      ), 
        .scl             ( scl      ), 
        .data            ( data     )
    );
 
//------------- SEG7_TOP 例化------------------------
    SEG7_TOP  U_SEG7_TOP
    (   //------------input--------------------
        .clk             ( clk0    ), 
        .rst_n           ( locked  ), 
        .key2            ( key_seg ),
        .data            ( data    ), 
        //------------output-------------------
        .seg             ( seg     ), 
        .sel             ( sel     )
    );
 
//------------- VGA_TOP 例化------------------------- 
    VGA_TOP #(
        .H_FRONT         ( H_FRONT ),
        .H_SYNC          ( H_SYNC  ),
        .H_BACK          ( H_BACK  ),
        .H_ACT           ( H_ACT   ),                                                                                        
        //------------Vertical Parameter-------  
        .V_FRONT         ( V_FRONT ),                                       
        .V_SYNC          ( V_SYNC  ),
        .V_BACK          ( V_BACK  ),
        .V_ACT           ( V_ACT   )   
    ) U_VGA_TOP
    (   //------------input--------------------
        .clk             ( clk1    ), 
        .clk_sys         ( clk0    ), 
        .key_in          ( key_in  ), 
        .din             ( {data, {8{1'b0}}} ), 
        .rst_n           ( locked  ), 
        //------------output-------------------
        .hsync           ( hsync   ), 
        .vsync           ( vsync   ), 
        .DATA            ( data_w  )
    );
    
endmodule
