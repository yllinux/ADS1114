/*****************************************************************************

*    Engineer       : yanglei
*    Target Device  : Cyclone IV E ( EP4CE6F17C8 )
*    Tool versions  : Quartus II 12.1
*    Create Date    : 2018-1-12
*    Revision       : v1.0
*    Description    : 适用于 VGA 和 HDMI 的驱动模块

*****************************************************************************/
`timescale 1ns / 1ps
module VGA (clk, rst_n, data, hsync, vsync, DATA, X, Y); 

    input               clk;                                     //像素时钟                               
    input               rst_n;                                   //复位
    input       [23:0]  data;                                    //数据输入 
    output  reg         hsync;                                   //横向阵列在同步区的时候置一     
    output  reg         vsync;                                   //场同步
  //output  reg         de;                                      //有效信号，HDMI上需要此输出口                     
    output      [23:0]  DATA;                                    //认为是RBG三原色的输出或者内部计算变量
  //output              hdmi_clk;                                //像素时钟信号，HDMI上需要此输出口
    output  reg [11:0]  X;                                       //使屏幕只显示显示区域1920宽度范围 行
    output  reg [11:0]  Y;                                       //使屏幕只显示显示区域1080宽度范围 列

    reg         de;                                              //有效信号 

//--------------------Horizontal Parameter-----------------------                                       
    parameter         H_FRONT = 12'd88,                           //行同步前
                      H_SYNC  = 12'd44,                           //行同步期
                      H_BACK  = 12'd148,                          //行同步后    
                      H_ACT   = 12'd1920;                         //横向屏幕可见区域                                                                                                
    localparam [11:0] H_BLANK = H_FRONT + H_SYNC + H_BACK;        //横向屏幕隐藏区域                  
    localparam [11:0] H_TOTAL = H_FRONT + H_SYNC + H_BACK + H_ACT;//横向屏幕总区域  

//--------------------Vertical Parameter-------------------------  
    parameter         V_FRONT   = 12'd4,                                          
                      V_SYNC    = 12'd5,
                      V_BACK    = 12'd36,
                      V_ACT     = 12'd1080;                        //纵向屏幕可见区域                                                                                  
    localparam [11:0] V_BLANK   = V_FRONT + V_SYNC + V_BACK;       //纵向屏幕隐藏区域                   
    localparam [11:0] V_TOTAL   = V_FRONT + V_SYNC + V_BACK + V_ACT;//纵向屏幕总区域



//--------------------数据输出------------------------------------
    assign DATA = de ? data:24'h00;
  //assign hdmi_clk = ~clk;                                      //像素时钟信号，HDMI上需要此输出口
   

    reg [11:0]  h_cnt;                                           //认为 cnt 为扫描信号，扫描行或者列的像素点      
    // Horizontal Generator: Refer to the pixel clock 
//--------------------行计数信号发生器-----------------------------
    always @(posedge clk or negedge rst_n)     
        if (!rst_n)                                              //复位信号到来给h_cnt赋0                                         
            h_cnt <= 12'd0;
        else if (h_cnt >= H_TOTAL - 12'd1)                       //如果h_cnt大于等于总的宽度则从头重新开始
            h_cnt <= 0;
        else
            h_cnt <= h_cnt + 12'd1;                              //否则依次+1循环往复直到扫描完整个屏幕
        // 也可 if (h_cnt < H_TOTAL - 1)  h_cnt <= h_cnt + 1; else h_cnt <= 0;   

    // Horizontal Sync                //行同步区
//--------------------行同步信号发生器-----------------------------
    always @(posedge clk or negedge rst_n)
        if (!rst_n)                                              //复位置零                              
            hsync <= 0;                                                                     
        else if (h_cnt >= H_FRONT + H_SYNC - 12'd1)              //若扫描信号超过了前两个隐藏区域则hsync置零 
            hsync <= 1'b0;
        else if (h_cnt >= H_FRONT - 12'd1)                       //如果扫描信号在同步区域内则hsync置一 
            hsync <= 1'b1;
        else
            hsync <= hsync;                                      //否则维持原状
        // 也可 if (h_cnt >= H_FRONT -1 && h_cnt < H_FRONT + H_SYNC - 1) hsync <= 1; else hsync <= 0;
            
    // Current X
//--------------------行坐标信号发生器-----------------------------
    always @(posedge clk or negedge rst_n)                                          
        if (!rst_n)                                              //复位置零
            X <= 12'd0;                                                                       
        else if (X >= H_ACT)                                     //如果X大于显示区域的大小则置零
            X <= 12'd0;
        else if (h_cnt >= H_BLANK)                               //如果扫描信号扫描位置已经过了屏幕隐藏区域则X 这里认为X是使屏幕只显示显示区域即1920宽度范围
            X <= X + 12'd1; 
        else                                                     //如果扫描信号没超过屏幕隐藏区域则X维持原状不变 即为 0（认为）
            X <= X;
        // 也可 if (h_cnt >= H_BLANK && h_cnt < H_BLANK + H_ACT) X <= X + 1;  else x <= 0;


    reg [11:0]  v_cnt; 
//-------------------产生场同步发生的条件，此 always 句为了增强容错率，没有其实也可以-----------
    reg hsync_1;                                                 //定义变量hsync_1    
    always @(posedge clk or negedge rst_n)
        if (!rst_n)                                              //复位置零
            hsync_1 <= 1'b0;
        else                                                     //将hsync的值赋 hsync_1 类似于中间变量的替换
            hsync_1 <= hsync;
            
    wire pos_hsync = hsync && (!hsync_1);                        //当且仅当行同步信号发生上升沿变化时 pos_hsync 为1

    // Vertical Generator: Refer to the horizontal sync 下面语句都是在一瞬间完成，即在一个时钟周期内完成（因为pos_hsync）超过这个时钟周期则下面变量都不发生变化 类似于循环嵌套
//--------------------列计数信号发生器-----------------------------
    always @(posedge clk or negedge rst_n)
        if (!rst_n)
            v_cnt <= 12'd0;
        else if ((v_cnt >= V_TOTAL - 12'd1) && pos_hsync)
            v_cnt <= 12'd0;
        else if (pos_hsync)                                      //瞬间换行
            v_cnt <= v_cnt + 12'd1;
        else
            v_cnt <= v_cnt;
        // 也可 if ((v_cnt < V_TOTAL - 1) && pos_hsync) v_cnt = v_cnt + 1; else v_cnt <= 0;
            
    // Vertical Sync
//--------------------场同步信号发生器-----------------------------
    always @(posedge clk or negedge rst_n)                       //场同步区功能
        if (!rst_n)
            vsync <= 1'b0;
        else if ((v_cnt >= V_FRONT + V_SYNC - 12'd1) && pos_hsync)//超过列同步区则置0
            vsync <= 1'b0;
        else if ((v_cnt >= V_FRONT - 12'd1)&& pos_hsync)         //满足条件时列中间变量置一
            vsync <= 1'b1;
        else                                                     //否则不变
            vsync <= vsync;
        // 也可 if (v_cnt >= V_FRONT -1 && v_cnt < V_FRONT + V_SYNC - 1 && pos_hsync) vsync <= 1; else vsync <= 0;

    // Current Y
//--------------------列坐标信号发生器-----------------------------
    always @(posedge clk or negedge rst_n)                                                  
        if(!rst_n)     
            Y <= 12'd0;
        else if ((Y >= V_ACT - 12'd1) && pos_hsync)              //同样 如果Y处于列显示区域的时候Y为列编号 处于隐藏区域的时候Y置零 
            Y <= 12'd0;
        else if ((v_cnt >= V_BLANK) && pos_hsync)
            Y <= Y + 12'd1;
        else
            Y <= Y;
        // 也可 if (Y >= V_BLANK && Y < V_BLANK + V_ACT) Y <= Y + 1; else Y <= 0;
 
//--------------------产生显示区有效信号---------------------------
    always @(posedge clk or negedge rst_n)
        if (!rst_n)
            de <= 1'b0;
        else if ((h_cnt < H_BLANK) || (v_cnt < V_BLANK))         //如果行扫描或者列扫描任意一个处于隐藏区的时候变 de 置零
            de <= 1'b0;    
        else                                                     //如果显示在显示区的时 de 置一
            de <= 1'b1;

endmodule
