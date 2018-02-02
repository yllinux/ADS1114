/*****************************************************************************

*    Engineer       : yanglei
*    Target Device  : Cyclone IV E ( EP4CE6F17C8 )
*    Tool versions  : Quartus II 12.1
*    Create Date    : 2018-1-12
*    Revision       : v1.0
*    Description    : 仅适用于时钟频率为 10MHz 的 ADS1114 或 ADS1115 的I2C模块

*****************************************************************************

--------------------------------------------ADS1114读写步骤-----------------------------------------
1、读操作时（主机读取ADS1114发送的数据）
    主机发送启动信号-主机发送从机地址(W)-从机应答-主机给从机地址指针寄存器赋值-从机应答-主机停止-主机发送启动信号
    -主机发送从机地址(R)-从机应答-主机接收从机数据-主机应答-▪▪▪-主机接收从机数据-主机应答-主机发送停止信号。

2、写操作时（主机向ADS1114写入的数据）
    主机发送启动信号-主机发送从机地址(W)-从机应答-主机给从机地址指针寄存器赋值-从机应答
    -主机发送给从机数据-从机应答-▪▪▪-主机发送给从机数据-从机应答-主机发送停止信号。
*/

module IIC (clk, rst_n, sda, scl, data);

    input          clk;                      //0.2MHz，周期 T = 5us
    input          rst_n; 
     
    inout          sda;                      //串行数据线（双向端口）
    output         scl;                      //串行时钟线
    output [15:0]  data;                     //一个字节输出

    
    //reg            scl;
    reg    [15:0]  data;
    reg    [7:0]   data_h;                   //一个高8位字节输出数据寄存
    reg    [7:0]   data_l;                   //一个低8位字节输出数据寄存
    
//----------------定义ADS1114配置寄存器------------------------
    parameter
        OS          = 1'b1,
        MUX         = 3'b100,
        PGA         = 3'b001,
        MODE        = 1'b1,
        
        DR          = 3'b111,
        COMP_MODE   = 1'b0,
        COMP_POL    = 1'b0,
        COMP_LAT    = 1'b0,
        COMP_QUE    = 2'b11;
          

    reg [15:0] config_h; //= {OS, MUX, PGA, MODE, DR, COMP_MODE, COMP_POL, COMP_LAT,COMP_QUE}; //Config Register 配置
    reg [15:0] config_l;
     
//----------------从机地址定义(A/D)---------------------------
    localparam         
        SL_ADDR_R   = 8'b1001_0001,          //读操作寻址地址，引脚 ALERT/RDY => GND
        SL_ADDR_W   = 8'b1001_0000;          //写操作寻址地址，引脚 ALERT/RDY => GND
        //SL_ADDR   = 7'b1001_000;           //slave_address 即从机地址，接GND
        //sl_addr   = 7'b1001_001;           //slave_address 即从机地址，接VDD
        //sl_addr   = 7'b1001_010;           //slave_address 即从机地址，接SDA
        //sl_addr   = 7'b1001_011;           //slave_address 即从机地址，接SCL
        
    reg [7:0]  slar;                         //寄存 SL_ADDR_R
    reg [7:0]  slaw;                         //寄存 SL_ADDR_W
         
//----------------定义ADS1114地址指针寄存器--------------------
    localparam     //address_pointer 即地址指针寄存器 
        ADDR_PO_00  = 8'b000000_00,          //Conversion register     转换寄存器包含最后一个转换的结果
        ADDR_PO_01  = 8'b000000_01,          //Config register         配置寄存器用于更改ADS111x操作模式，并查询设备的状态。
        ADDR_PO_10  = 8'b000000_10,          //Lo_thresh register      设置用于比较器函数的阈值值，在ADS1113中不可用
        ADDR_PO_11  = 8'b000000_11;          //Hi_thresh register      设置用于比较器函数的阈值值，在ADS1113中不可用
       
    reg [7:0]  apr0;                      //寄存 ADDR_PO_00
    reg [7:0]  apr1;                      //寄存 ADDR_PO_01

//----------------状态机状态定义------------------------------
    localparam  
        S0        = 5'd0,                  
        S1        = 5'd1,                   
        S2        = 5'd2,               
        S3        = 5'd3,                    
        S4        = 5'd4,                    
        S5        = 5'd5,                   
        S6        = 5'd6,                     
        S7        = 5'd7,                  
        S8        = 5'd8,                 
        S9        = 5'd9,                 
        S10       = 5'd10,                
        S11       = 5'd11,                 
        S12       = 5'd12,                
        S13       = 5'd13,                
        S14       = 5'd14,                
        S15       = 5'd15,                 
        S16       = 5'd16,                
        S17       = 5'd17,                
        S18       = 5'd18,                
        S19       = 5'd19,               
        S20       = 5'd20,                 
        S21       = 5'd21,               
        S22       = 5'd22,                 
        S23       = 5'd23, 
        S24       = 5'd24,  
        S25       = 5'd25, 
        S26       = 5'd26,  
        S27       = 5'd27,  
        S28       = 5'd28,
        S29       = 5'd29,
        S30       = 5'd30;

    reg [5:0]      cs;                       //current_state 即现态
  //reg [5:0]      ns;                       //next_state 即次态
    reg            link;                     // 即数据线开关，控制系统是否占有总线控制权
    reg            sda_r;                    //sda_reg 即数据线寄存器
    reg [9:0]      cnt;                      //计数器
    
    reg            scl_r;                    //SCL 寄存
    reg            scl_p;                    //SCL 上升沿稍前
    reg            scl_h;                    //SCL 高电平中间时刻 
    reg            scl_n;                    //SCL 下降沿稍后
    reg            scl_l;                    //SCL 低电平中间时刻 
    
    assign sda  =  link ? sda_r : 1'bz;
    
    
    
//------------ 100 kHz_Counter --------------//25000K / 250 = 100K
    always @(posedge clk or negedge rst_n)
        if(!rst_n)
            cnt <= 10'd0;
        else if(cnt >= 10'd249)
            cnt <= 10'd0;
        else
            cnt <= cnt + 10'd1;             //cnt 为分频得到100 kHz 计数
//-----------------IIC_SCL-------------------
    always @(posedge clk or negedge rst_n)
        if (!rst_n)
            begin
                scl_r <= 1'b0;
                scl_n <= 1'b0;
                scl_l <= 1'b0;
                scl_p <= 1'b0;
                scl_h <= 1'b0;            //复位值
            end
        else if(cnt == 10'd62)            //SCL 高电平中间时刻，用于数据采样
            scl_h <= 1'b1;                //持续一个时钟周期的高电平
        else if(cnt == 10'd124)           //SCL 下降沿
            scl_r <= 1'b0;
        else if(cnt == 10'd128)           //SCL 下降沿滞后稍许时刻，保证高电平期间 SDA 保持不变
            scl_n <= 1'b1;                //持续一个时钟周期的高电平
        else if(cnt == 10'd186)           //SCL 低电平中间时刻，用于数据发送
            scl_l <= 1'b1;                //持续一个时钟周期的高电平
        else if(cnt == 10'd245)           //SCL 上升沿提前稍许时刻
            scl_p <= 1'b1;                //持续一个时钟周期的高电平
        else if(cnt == 10'd249)           //SCL 上升沿
            scl_r <= 1'b1;
        else
            begin
                scl_r <= scl_r;             //保持占空比为1/2 的方波
                scl_h <= 1'b0;              //持续一个时钟周期的高电平，然后为0
                scl_n <= 1'b0;              //持续一个时钟周期的高电平，然后为0
                scl_l <= 1'b0;              //持续一个时钟周期的高电平，然后为0
                scl_p <= 1'b0;              //持续一个时钟周期的高电平，然后为0
            end
   
    assign scl  =  scl_r;                 //SCL 为IIC 的时钟
    
//--------------h--------------▪_n_________________l_________________p_▪


    reg     [3:0]   num;
    
    always @(posedge clk or negedge rst_n)
            if (!rst_n)
                begin   
                    link    <=  1'b1;
                    sda_r   <=  1'b1;
                    num     <=  4'd0;
                    cs      <=  S0;
                    
                    data    <=  16'h0000;
                    data_h  <=  8'h00;
                    data_l  <=  8'h00;
                    config_h<=  8'h00;
                    config_l<=  8'h00;
                    slar    <=  8'h00;
                    slaw    <=  8'h00;
                    apr0    <=  8'h00;
                    apr1    <=  8'h00;
                end 
            else 
                begin 
                    case (cs)
                        S0  :                       //空闲状态
                            begin 
                                if(scl_h)
                                    begin 
                                        link    <=  1'b1;
                                        sda_r   <=  1'b1;
                                        cs      <=  S1;
                                    end 
                                else
                                    cs      <=  S0;
                            end 
                        
                        //---------------------主机产生启动信号设计--------------------------------
                        //  当IIC 接口模块检测到主机发送过来的有效START 信号后，该模块由空闲状态转入到产生IIC
                        //  接口模块启动信号状态，然后检测SCL 是否处于高电平状态，如是，则置SDA 由高电平转为低电平状
                        //  态，即可产生该模块的启动信号。
                        S1  :                       //启动
                            begin 
                                if(scl_h)
                                    begin 
                                        link    <=  1'b1;
                                        sda_r   <=  1'b0;
                                        cs      <=  S2;
                                    end 
                                else
                                    begin 
                                        cs      <=  S1;
                                        slaw    <=  SL_ADDR_W;
                                    end 
                            end 
                        
                        //---------------------主机发送和接收一个字节数据设计--------------------------------
                        //  由于IIC 是串行数据传输总线，主机要发送一个字节的数据，必须将字节数据经过并/串转换，然
                        //  后在时钟线SCL 的作用下将每一个BIT 位发送到数据线SDA 上。主机要接收一个字节的数据，必须
                        //  将数据线SDA 上每个数据位经过串/并转换，组合成一个字节的数据，供主机进行接收和处理。
                        S2  :                       //寻址
                            begin 
                                if (num <= 4'd7)
                                    begin 
                                        link    <=  1'b1;
                                        cs      <=  S2;
                                        if (scl_l)
                                            begin 
                                                link    <=  1'b1;
                                                num     <=  num + 4'd1;
                                                case (num)
                                                    4'd0 : sda_r    <=  slaw[7];
                                                    4'd1 : sda_r    <=  slaw[6];
                                                    4'd2 : sda_r    <=  slaw[5];
                                                    4'd3 : sda_r    <=  slaw[4];
                                                    4'd4 : sda_r    <=  slaw[3];
                                                    4'd5 : sda_r    <=  slaw[2];
                                                    4'd6 : sda_r    <=  slaw[1];
                                                    4'd7 : sda_r    <=  slaw[0];
                                                    default : sda_r    <=  sda_r;
                                                endcase     
                                            end 
                                        else 
                                            sda_r   <=  sda_r;
                                    end
                                else 
                                    if ((scl_n) && (num >= 4'd8)) 
                                        begin 
                                            link    <=  1'b0;
                                            sda_r   <=  1'b1;
                                            num     <=  4'd0;
                                            cs      <=  S3;
                                        end 
                                    else 
                                        cs  <=  S2;
                            end 
                        
                        //---------------------主机接收从机应答信号和主机向从机产生非应答号设计--------------------------------
                        //  当主机向从机写入器件地址、字节地址及数据时，从机会产生相应的应答信号（拉低SDA 信号），
                        //  主机检测到此信号后，才能下一数据传输过程。当主机不需要再向从机接收数据时，主机此时可以向
                        //  从机发送非应答号（拉高SDA 信号），然后产生停止信号，从而结束整个数据传输过程。
                        S3  :                       //检测应答
                            begin 
                                if (scl_h)
                                    if (sda == 1'b0)
                                        begin 
                                            cs      <=  S5;
                                            apr1    <=  ADDR_PO_01;
                                        end 
                                    else 
                                        begin 
                                            cs      <=  S4;
                                            link    <=  1'b1;
                                        end 
                                else 
                                    cs      <=  S3;
                            end 
                            
                        S4  :                       //停止
                            begin 
                                if (scl_l)
                                    begin 
                                        sda_r   <=  1'b0;
                                        cs      <=  S4;
                                    end 
                                else if (scl_h)
                                    begin
                                        sda_r   <=  1'b1;
                                        cs      <=  S0;
                                    end 
                                else 
                                    cs  <=  S4;
                            end 
//*********************************************************************************************************  
                        S5  :                       //地址指针
                            begin 
                                if (num <= 4'd7)
                                    begin 
                                        link    <=  1'b1;
                                        cs      <=  S5;
                                        if (scl_l)
                                            begin 
                                                link    <=  1'b1;
                                                num     <=  num + 4'd1;
                                                case (num)
                                                    4'd0 : sda_r    <=  apr1[7];
                                                    4'd1 : sda_r    <=  apr1[6];
                                                    4'd2 : sda_r    <=  apr1[5];
                                                    4'd3 : sda_r    <=  apr1[4];
                                                    4'd4 : sda_r    <=  apr1[3];
                                                    4'd5 : sda_r    <=  apr1[2];
                                                    4'd6 : sda_r    <=  apr1[1];
                                                    4'd7 : sda_r    <=  apr1[0];
                                                    default : sda_r    <=  sda_r;
                                                endcase     
                                            end 
                                        else 
                                            sda_r   <=  sda_r;
                                    end
                                else 
                                    if ((scl_n) && num >= 4'd8) 
                                        begin 
                                            link    <=  1'b0;
                                            sda_r   <=  1'b1;
                                            num     <=  4'd0;
                                            cs      <=  S6;
                                        end 
                                    else 
                                        cs  <=  S5;
                            end 
                            
                        S6  :                       //检测应答
                            begin 
                                if (scl_h)
                                    if (sda == 1'b0)
                                        begin 
                                            cs          <=  S8;
                                            config_h    <=  {OS, MUX, PGA, MODE};
                                        end 
                                    else 
                                        begin 
                                            cs      <=  S7;
                                            link    <=  1'b1;
                                        end 
                                else 
                                    cs      <=  S6;
                            end 
                            
                        S7  :                       //停止
                            begin 
                                if (scl_l)
                                    begin 
                                        sda_r   <=  1'b0;
                                        cs      <=  S7;
                                    end 
                                else if (scl_h)
                                    begin
                                        sda_r   <=  1'b1;
                                        cs      <=  S0;
                                    end 
                                else 
                                    cs  <=  S7;
                            end 
                            
                        S8  :                       //写高位
                            begin 
                                if (num <= 4'd7)
                                    begin 
                                        link    <=  1'b1;
                                        cs      <=  S8;
                                        if (scl_l)
                                            begin 
                                                link    <=  1'b1;
                                                num     <=  num + 4'd1;
                                                case (num)
                                                    4'd0 : sda_r    <=  config_h[7];
                                                    4'd1 : sda_r    <=  config_h[6];
                                                    4'd2 : sda_r    <=  config_h[5];
                                                    4'd3 : sda_r    <=  config_h[4];
                                                    4'd4 : sda_r    <=  config_h[3];
                                                    4'd5 : sda_r    <=  config_h[2];
                                                    4'd6 : sda_r    <=  config_h[1];
                                                    4'd7 : sda_r    <=  config_h[0];
                                                    default : sda_r    <=  sda_r;
                                                endcase     
                                            end 
                                        else 
                                            sda_r   <=  sda_r;
                                    end
                                else 
                                    if ((scl_n) && (num >= 4'd8)) 
                                        begin 
                                            link    <=  1'b0;
                                            sda_r   <=  1'b1;
                                            num     <=  4'd0;
                                            cs      <=  S9;
                                        end 
                                    else 
                                        cs  <=  S8;
                            end 
                            
                        S9  :                       //检测应答
                            begin 
                                if (scl_h)
                                    if (sda == 1'b0)
                                        begin 
                                            cs          <=  S11;
                                            config_l    <=  {DR, COMP_MODE, COMP_POL, COMP_LAT,COMP_QUE};
                                        end 
                                    else 
                                        begin 
                                            link    <=  1'b1;
                                            cs      <=  S10;
                                        end 
                                else
                                    cs      <=  S9;
                            end 
                            
                        S10 :                       //停止
                            begin 
                                if (scl_l)
                                    begin 
                                        sda_r   <=  1'b0;
                                        cs      <=  S10;
                                    end 
                                else if (scl_h)
                                    begin
                                        sda_r   <=  1'b1;
                                        cs      <=  S0;
                                    end 
                                else 
                                    cs  <=  S10;
                            end 
                            
                        S11 :                       //写低位
                            begin 
                                if (num <= 4'd7)
                                    begin 
                                        link    <=  1'b1;
                                        cs      <=  S11;
                                        if (scl_l)
                                            begin 
                                                link    <=  1'b1;
                                                num     <=  num + 4'd1;
                                                case (num)
                                                    4'd0 : sda_r    <=  config_l[7];
                                                    4'd1 : sda_r    <=  config_l[6];
                                                    4'd2 : sda_r    <=  config_l[5];
                                                    4'd3 : sda_r    <=  config_l[4];
                                                    4'd4 : sda_r    <=  config_l[3];
                                                    4'd5 : sda_r    <=  config_l[2];
                                                    4'd6 : sda_r    <=  config_l[1];
                                                    4'd7 : sda_r    <=  config_l[0];
                                                    default : sda_r    <=  sda_r;
                                                endcase     
                                            end 
                                        else 
                                            sda_r   <=  sda_r;
                                    end
                                else 
                                    if ((scl_n) && (num >= 4'd8)) 
                                        begin 
                                            link    <=  1'b0;
                                            sda_r   <=  1'b1;
                                            num     <=  4'd0;
                                            cs      <=  S12;
                                        end 
                                    else 
                                        cs  <=  S11;
                            end 
                            
                        S12 :                       //检测应答（有没有应答都停止，进行下一步骤）
                            begin 
                                if (scl_h)
                                    if (sda == 1'b0)
                                        begin 
                                            cs      <=  S13;
                                            link    <=  1'b1;
                                        end 
                                    else 
                                        begin 
                                            cs      <=  S13;
                                            link    <=  1'b1;
                                        end 
                                else 
                                    cs      <=  S12;
                            end 
                             
                        S13 :                       //停止
                            begin 
                                if (scl_l)
                                    begin 
                                        sda_r   <=  1'b0;
                                        cs      <=  S13;
                                    end 
                                else if (scl_h)
                                    begin
                                        sda_r   <=  1'b1;
                                        cs      <=  S14;
                                    end 
                                else 
                                    cs  <=  S13;
                            end 
                      
                        S14 :                       //启动
                            begin 
                                if(scl_h)
                                    begin 
                                        link    <=  1'b1;
                                        sda_r   <=  1'b0;
                                        cs      <=  S15;
                                    end 
                                else
                                    begin 
                                        cs      <=  S14;
                                        slaw    <=  SL_ADDR_W;
                                    end 
                            end 
                            
                        S15 :                       //寻址
                            begin 
                                if (num <= 4'd7)
                                    begin 
                                        link    <=  1'b1;
                                        cs      <=  S15;
                                        if (scl_l)
                                            begin 
                                                link    <=  1'b1;
                                                num     <=  num + 4'd1;
                                                case (num)
                                                    4'd0 : sda_r    <=  slaw[7];
                                                    4'd1 : sda_r    <=  slaw[6];
                                                    4'd2 : sda_r    <=  slaw[5];
                                                    4'd3 : sda_r    <=  slaw[4];
                                                    4'd4 : sda_r    <=  slaw[3];
                                                    4'd5 : sda_r    <=  slaw[2];
                                                    4'd6 : sda_r    <=  slaw[1];
                                                    4'd7 : sda_r    <=  slaw[0];
                                                    default : sda_r    <=  sda_r;
                                                endcase     
                                            end 
                                        else 
                                            sda_r   <=  sda_r;
                                    end
                                else 
                                    if ((scl_n) && (num >= 4'd8)) 
                                        begin 
                                            link    <=  1'b0;
                                            sda_r   <=  1'b1;
                                            num     <=  4'd0;
                                            cs      <=  S16;
                                        end 
                                    else 
                                        cs  <=  S15;
                            end 
                            
                        S16 :                       //检测应答
                            begin 
                                if (scl_h)
                                    if (sda == 1'b0)
                                        begin 
                                            cs      <=  S18;
                                            apr0    <=  ADDR_PO_00;
                                        end 
                                    else 
                                        begin 
                                            cs      <=  S17;
                                            link    <=  1'b1;
                                        end 
                                else 
                                    cs      <=  S16;
                            end 
                            
                        S17 :                       //停止
                            begin 
                                if (scl_l)
                                    begin 
                                        sda_r   <=  1'b0;
                                        cs      <=  S17;
                                    end 
                                else if (scl_h)
                                    begin
                                        sda_r   <=  1'b1;
                                        cs      <=  S0;
                                    end 
                                else 
                                    cs  <=  S17;
                            end 
                        
                        S18 :                       //寄存器指针
                            begin 
                                if (num <= 4'd7)
                                    begin 
                                        link    <=  1'b1;
                                        cs      <=  S18;
                                        if (scl_l)
                                            begin 
                                                link    <=  1'b1;
                                                num     <=  num + 4'd1;
                                                case (num)
                                                    4'd0 : sda_r    <=  apr0[7];
                                                    4'd1 : sda_r    <=  apr0[6];
                                                    4'd2 : sda_r    <=  apr0[5];
                                                    4'd3 : sda_r    <=  apr0[4];
                                                    4'd4 : sda_r    <=  apr0[3];
                                                    4'd5 : sda_r    <=  apr0[2];
                                                    4'd6 : sda_r    <=  apr0[1];
                                                    4'd7 : sda_r    <=  apr0[0];
                                                    default : sda_r    <=  sda_r;
                                                endcase     
                                            end 
                                        else 
                                            sda_r   <=  sda_r;
                                    end
                                else 
                                    if ((scl_n) && num >= 4'd8) 
                                        begin 
                                            link    <=  1'b0;
                                            sda_r   <=  1'b1;
                                            num     <=  4'd0;
                                            cs      <=  S19;
                                        end 
                                    else 
                                        cs  <=  S18;
                            end 
                        
                        S19 :                       //检测应答（有没有检测到都进行下一步骤）
                            begin 
                                if (scl_h)
                                    if (sda == 1'b0)
                                        begin 
                                            cs      <=  S20;
                                            link    <=  1'b1;
                                        end 
                                    else 
                                        begin 
                                            cs      <=  S20;
                                            link    <=  1'b1;
                                        end 
                                else 
                                    cs      <=  S19;
                            end 
                            
                        S20 :                       //停止
                            begin 
                                if (scl_l)
                                    begin 
                                        sda_r   <=  1'b0;
                                        cs      <=  S20;
                                    end 
                                else if (scl_h)
                                    begin
                                        sda_r   <=  1'b1;
                                        cs      <=  S21;
                                    end 
                                else 
                                    cs  <=  S20;
                            end  
                         
                        S21 :                       //启动
                            begin 
                                if(scl_h)
                                    begin 
                                        link    <=  1'b1;
                                        sda_r   <=  1'b0;
                                        cs      <=  S22;
                                    end 
                                else
                                    begin 
                                        cs      <=  S21;
                                        slar    <=  SL_ADDR_R;
                                    end 
                            end 
                            
                        S22 :                       //寻址
                            begin 
                                if (num <= 4'd7)
                                    begin 
                                        link    <=  1'b1;
                                        cs      <=  S22;
                                        if (scl_l)
                                            begin 
                                                link    <=  1'b1;
                                                num     <=  num + 4'd1;
                                                case (num)
                                                    4'd0 : sda_r    <=  slar[7];
                                                    4'd1 : sda_r    <=  slar[6];
                                                    4'd2 : sda_r    <=  slar[5];
                                                    4'd3 : sda_r    <=  slar[4];
                                                    4'd4 : sda_r    <=  slar[3];
                                                    4'd5 : sda_r    <=  slar[2];
                                                    4'd6 : sda_r    <=  slar[1];
                                                    4'd7 : sda_r    <=  slar[0];
                                                    default : sda_r    <=  sda_r;
                                                endcase     
                                            end 
                                        else 
                                            sda_r   <=  sda_r;
                                    end
                                else 
                                    if ((scl_n) && (num >= 4'd8)) 
                                        begin 
                                            link    <=  1'b0;
                                            sda_r   <=  1'b1;
                                            num     <=  4'd0;
                                            cs      <=  S23;
                                        end 
                                    else 
                                        cs  <=  S22;
                            end 
                            
                        S23 :                       //检测应答
                            begin 
                                if (scl_h)
                                    if (sda == 1'b0)
                                        begin 
                                            cs      <=  S25;
                                            link    <=  1'b0;
                                        end 
                                    else 
                                        begin 
                                            cs      <=  S24;
                                            link    <=  1'b1;
                                        end 
                                else 
                                    cs      <=  S23;
                            end 
                            
                        S24 :                       //停止
                            begin 
                                if (scl_l)
                                    begin 
                                        sda_r   <=  1'b0;
                                        cs      <=  S24;
                                    end 
                                else if (scl_h)
                                    begin
                                        sda_r   <=  1'b1;
                                        cs      <=  S0;
                                    end 
                                else 
                                    cs  <=  S24;
                            end 
                               
                        S25 :                       //读取一个字节，数据高8位
                            begin 
                                if (num <= 4'd7)
                                    begin 
                                        link    <=  1'b0;
                                        cs      <=  S25;
                                        if (scl_h)
                                            begin 
                                                link    <=  1'b0;
                                                num     <=  num + 4'd1;
                                                case (num)
                                                    4'd0 : data_h[7]    <=  sda;
                                                    4'd1 : data_h[6]    <=  sda;
                                                    4'd2 : data_h[5]    <=  sda;
                                                    4'd3 : data_h[4]    <=  sda;
                                                    4'd4 : data_h[3]    <=  sda;
                                                    4'd5 : data_h[2]    <=  sda;
                                                    4'd6 : data_h[1]    <=  sda;
                                                    4'd7 : data_h[0]    <=  sda;
                                                    default : data_h    <=  data_h;
                                                endcase     
                                            end 
                                        else 
                                            data_h   <=  data_h;
                                    end
                                else 
                                    if ((scl_n) && (num >= 4'd8)) 
                                        begin 
                                            link    <=  1'b1;
                                            sda_r   <=  1'b0;
                                            num     <=  4'd0;
                                            cs      <=  S26;
                                        end 
                                    else 
                                        cs  <=  S25;
                            end 
                            
                        S26 :                       //应答
                            begin 
                                if (scl_n)
                                    begin 
                                        link    <=  1'b0;
                                        sda_r   <=  1'b0;
                                        cs      <=  S27;
                                    end 
                                else 
                                    begin 
                                        cs      <=  S26;
                                        sda_r   <=  1'b0;
                                        link    <=  1'b1;
                                    end 
                            end 
                            
                        S27 :                       //读取一个字节，数据低8位
                            begin 
                                if (num <= 4'd7)
                                    begin 
                                        link    <=  1'b0;
                                        cs      <=  S27;
                                        if (scl_h)
                                            begin 
                                                link    <=  1'b0;
                                                num     <=  num + 4'd1;
                                                case (num)
                                                    4'd0 : data_l[7]    <=  sda;
                                                    4'd1 : data_l[6]    <=  sda;
                                                    4'd2 : data_l[5]    <=  sda;
                                                    4'd3 : data_l[4]    <=  sda;
                                                    4'd4 : data_l[3]    <=  sda;
                                                    4'd5 : data_l[2]    <=  sda;
                                                    4'd6 : data_l[1]    <=  sda;
                                                    4'd7 : data_l[0]    <=  sda;
                                                    default : data_l    <=  data_l;
                                                endcase     
                                            end 
                                        else 
                                            data_l   <=  data_l;
                                    end
                                else 
                                    if ((scl_n) && (num >= 4'd8)) 
                                        begin 
                                            link    <=  1'b1;
                                            sda_r   <=  1'b0;
                                            num     <=  4'd0;
                                            cs      <=  S28;
                                        end 
                                    else 
                                        cs  <=  S27;
                            end 
                            
                        S28 :                       //应答
                            begin 
                                if (scl_n)
                                    begin 
                                        link    <=  1'b0;
                                        sda_r   <=  1'b0;
                                        cs      <=  S0;
                                        //cs      <=  S0;
                                        data    <=  {data_h, data_l};
                                    end 
                                else 
                                    begin 
                                        cs      <=  S28;
                                        sda_r   <=  1'b0;
                                        link    <=  1'b1;
                                    end 
                            end 
                        default : cs    <=  S0;
                    endcase
                end 
               
endmodule