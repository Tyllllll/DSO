module vga_ctr
(
	input		vga_clk,//输入时钟50M
	input		vga_rst_n, //复位 
	
	input    shift_l,  //左移按键输入  key3    Y16  按下 0
	input    shift_r,  //右移按键输入  key2    W15   
	input		[9:0] i_data,
	
	input		[11:0] v_num_data,    // 3位BCD码 0001 0010 0011 -->  1.23 v
	input		[23:0] f_num_data,    // 6位BCD码   123.456 khz
	input		f_div_select,	//高电平20ms 低电平100us
	input		V_div_select,    
	input    vga_rst,      // 图像复位，高有效
	
	
	output	[11:0] o_address,
	output	reg[23:0] color_data,//颜色信号 红--绿--蓝
	output	 vga_hs,	//行同步信号输出
	output	 vga_vs,	//场同步信号输出
	output	reg clk_25M,
	output	blank_n,	//消隐
	output	sync_n	//信号同步
);

reg [11:0] cnt_hs;  //行信号clk计数,
reg [11:0] cnt_vs;	 //场信号clk计数
wire lcd_request;
wire [11:0] vga_x;	//VGA的x坐标
wire [11:0] vga_y;	//VGA的y坐标
reg [9:0] i_temp;

reg[19:0]  divider_25hz;   //25m 分频至25hz 
reg        clk_25hz;
reg [11:0] shift_h ; 
reg [11:0] position_X,position_Y;


wire area0;//网格线标志
wire area1;//界面区域标志
wire area2;//数据框标志
wire area3,area4,area_u,area_m,area_k;//

wire num0,num1,num2,num3,num4,num5,num6,num7,num8,num9;
wire [11:0] temp_x;
wire [11:0] temp_y;


//--------测试幅值、频率显示---------
//wire [11:0] v_num_data;
//wire [23:0] f_num_data;
//  assign v_num_data = 12'b0000_0001_0010 ;
//	assign f_num_data = 24'b0010_0000_0000_0110_0111_1000 ;

//define colors RGB--8|8|8 
`define RED     24'hFF0000 /*11111111,00000000,00000000   */ 
`define GREEN   24'h00FF00 /*00000000,11111111,00000000   */ 
`define BLUE    24'h0000FF /*00000000,00000000,11111111   */ 
`define WHITE   24'haaaaaa/*11111111,11111111,11111111   */ 
`define BLACK   24'h000000 /*00000000,00000000,00000000   */ 
`define YELLOW  24'hFFFF00 /*11111111,11111111,00000000   */ 
`define CYAN    24'hFF00FF /*11111111,00000000,11111111   */ 
`define ROYAL   24'h00FFFF /*00000000,11111111,11111111   */

//  640 * 480 
`define H_FRONT 11'd16 
`define H_SYNC  11'd96 
`define H_BACK  11'd48 
`define H_DISP  11'd640 
`define H_TOTAL 11'd800 
`define V_FRONT 11'd10 
`define V_SYNC  11'd2 
`define V_BACK  11'd33 
`define V_DISP  11'd480 
`define V_TOTAL 11'd525


//---------------------------------------------------------
//功能： 产生25MHz的像素时钟
always @(posedge vga_clk or posedge vga_rst_n)
	begin
		 if(vga_rst_n)
			  clk_25M   <=  1'b0        ;
		 else
			  clk_25M   <=  ~clk_25M  ;     
	end

	
//-----------------------------------------------------------	
// 25M分频成50hz计数器	 
always @(posedge clk_25M or posedge vga_rst_n)
	begin
		 if(vga_rst_n)
		   begin
			  clk_25hz   <=  1'b0   ;
			  divider_25hz <= 20'd0  ;
			end
		 else if(divider_25hz <= 20'd399999 ) 
		     begin  
				 if(divider_25hz == 20'd199999) 
			      clk_25hz   <=  ~clk_25hz  ; 
				 divider_25hz <=  divider_25hz+ 20'd1 ;
		     end
		 else  
		     divider_25hz <= 20'd0  ;	  
	end	 
	

 //按键检测，赋给水平偏移寄存器  
 // 0--  4095-512 ==3583
always@(posedge clk_25hz or posedge vga_rst )	
    begin
	     if(vga_rst)
				shift_h <= 0;
		  else if({ shift_l,shift_r} == 2'b01 )  // 左移
				if( shift_h <= 3578 )
					shift_h <= shift_h +5;
				else
				   shift_h <= 3583 ;
				
	     else if( {shift_l,shift_r} == 2'b10 )  // 右移
			   if( shift_h>= 5 )
				  shift_h <= shift_h -5;
				else
				  shift_h <= 5;
		  else                                  //同时按 、不按
		      shift_h <= shift_h ;
	   end
	  
   
//----------------------------------------------------
//VGA行同步信号
always @ (posedge clk_25M or posedge vga_rst_n)
	 begin     
		 if (vga_rst_n)         
			cnt_hs <= 11'd0;     
		 else         
			 begin         
				 if(cnt_hs < `H_TOTAL - 1'b1)     //line over                     
					cnt_hs <= cnt_hs + 1'b1;         
				 else             
					cnt_hs <= 11'd0;        
			 end 
	 end
assign vga_hs = (cnt_hs <= `H_SYNC - 1'b1) ? 1'b0 : 1'b1; 

 
//VGA场同步信号
always@(posedge clk_25M or posedge vga_rst_n) 
	begin 
		if (vga_rst_n) 
			cnt_vs <= 11'b0; 
		else if(cnt_hs == `H_TOTAL - 1'b1) //line over 
			begin 
				if(cnt_vs < `V_TOTAL - 1'b1) //frame over 
					cnt_vs <= cnt_vs + 1'b1; 
				else cnt_vs <= 11'd0; 
			end 
	end 
assign vga_vs = (cnt_vs <= `V_SYNC - 1'b1) ? 1'b0 : 1'b1; 


assign  blank_n = lcd_request;//vga_hs & vga_vs;
assign	sync_n=1'b0;
 //ahead x clock 
localparam H_AHEAD =   11'd1;
assign  lcd_request = ((cnt_hs >= `H_SYNC + `H_BACK - H_AHEAD )&& (cnt_hs < `H_SYNC + `H_BACK + `H_DISP - H_AHEAD) &&
                        (cnt_vs >= `V_SYNC + `V_BACK )&& (cnt_vs < `V_SYNC + `V_BACK + `V_DISP) )
                        ? 1'b1 : 1'b0; 
//lcd vgax & vgay
assign  	vga_x = lcd_request ? (cnt_hs - (`H_SYNC + `H_BACK - H_AHEAD)) : 11'd0; 
assign 	vga_y = lcd_request ? (cnt_vs - (`V_SYNC + `V_BACK)) : 11'd0;


//------------------------------------
//----------------波形平移、伸缩变换-------------
assign o_address =  (vga_x + shift_h -8) >=0  ?   (vga_x + shift_h -8)    :  12'd0   ;                    //  水平偏移量+水平扫描量-前框格点

always@(posedge clk_25M ) 
	if (V_div_select) 
	   i_temp = (349*10-i_data*11*10/50)-2400+240;
	else
		i_temp = (349-i_data*11/50) ;      // 1024*11/50
//------------------------------------



// 示波器界面取模区

assign area0 = (	(vga_x-10) %50 ==0 || (vga_y -20) % 55 ==0 ) ?1'b1 : 1'b0;                 //网格线								
assign area1 = (vga_x >= 10 && vga_x <= 510 && vga_y >= 20 && vga_y <= 460) ?1'b1 : 1'b0;    //波形显示与网格线总区域
assign area2 = (vga_x >= 520 && vga_x <= 620 && vga_y >= 80 && vga_y <= 400 ) ?1'b1 : 1'b0;
assign area_u =(
					vga_y == 468 && vga_x == 532 //38--32
					|| vga_y == 475 && vga_x == 534 
					|| vga_y >= 468 && vga_y <= 474 &&  vga_x == 533
					|| vga_y == 474 && vga_x == 535 
					|| vga_y >= 468 && vga_y <= 475 &&  vga_x == 536
					|| vga_y == 475 && vga_x == 537 //u
					)?1'b1 : 1'b0;
assign area_m =(
					vga_y == 468 && vga_x == 532 //38--32
					|| vga_y == 469 && vga_x == 534 
					|| vga_y >= 468 && vga_y <= 475 &&  ( vga_x == 533 || vga_x == 535)
					|| vga_y == 468 && vga_x == 536 
					|| vga_y >= 469 && vga_y <= 475 &&  vga_x == 537//m
					)?1'b1 : 1'b0;
assign area_k =(
					( (vga_y == 156|| vga_y == 157) && vga_x == 617 ) //显K
					|| ((vga_y == 155|| vga_y == 158) && vga_x == 618 )
					|| ((vga_y == 154|| vga_y == 159) && vga_x == 619 )
					|| vga_y >= 153 && vga_y <= 160 && ( vga_x == 616 )
					//k
					)?1'b1 : 1'b0;
					
assign area3 = ( 	vga_x >= 621  && vga_x <=  626 && ( vga_y == 156 ) || 	//显示Hz
						vga_y >= 151 && vga_y <= 161 && ( vga_x == 621 || vga_x == 626  )	||
						vga_x >= 628  && vga_x <=  633 && ( vga_y == 156 || vga_y == 161 ) || ( vga_x == 632 && vga_y == 157 )
						|| ( vga_x == 631 && vga_y == 158 )|| ( vga_x == 630 && vga_y == 159 )  || ( vga_x == 629 && vga_y == 160)
//显示 0
						|| vga_x >= 1  && vga_x <=  6 && ( vga_y == 234 || vga_y == 244 ) || 
						vga_y >= 234 && vga_y <= 244 && ( vga_x == 1 || vga_x == 6  )
//显示电压单位V 613--610 134-->11
						|| vga_y >= 101 && vga_y <= 104 && ( vga_x == 620 || vga_x == 624 )
						|| vga_y >= 105 && vga_y <= 108 && ( vga_x == 621 || vga_x == 623 )
						|| vga_y >= 109 && vga_y <= 111 && ( vga_x == 622 )
						
//显示 1 or 0.1  V/div 
						||vga_y >= 1 && vga_y <= 11 && (  vga_x == 15 )//1
												
						|| vga_y >= 1 && vga_y <= 4 && ( vga_x == 19 || vga_x == 23 )
						|| vga_y >= 5 && vga_y <= 8 && ( vga_x == 20 || vga_x == 22 )
						|| vga_y >= 9 && vga_y <= 11 && ( vga_x == 21 )//V

						|| vga_y >= 10 && vga_y <= 11 &&  vga_x == 25 
						|| vga_y >= 8 && vga_y <= 9 &&  vga_x == 26
						|| vga_y >= 6 && vga_y <= 7 &&  vga_x == 27 
						|| vga_y >= 4 && vga_y <= 5 &&  vga_x == 28
						|| vga_y >= 2 && vga_y <= 3 &&  vga_x == 29 // /
												
						|| vga_y >= 4 && vga_y <= 6 && ( vga_x == 40 || vga_x == 44 )
						|| vga_y >= 7 && vga_y <= 9 && ( vga_x == 41 || vga_x == 43 )
						|| vga_y >= 10 && vga_y <= 11 && ( vga_x == 42 )//v

						|| vga_y >= 4 && vga_y <= 11 &&  vga_x == 38 
						|| vga_y >= 1 && vga_y <= 2 &&  vga_x == 38 
						|| vga_y == 4 && vga_x >= 36 && vga_x <= 37   //i

						|| vga_y >= 1 && vga_y <= 11 &&  vga_x == 34 
						|| vga_y >= 5 && vga_y <= 10 &&  vga_x == 30
						||( vga_y == 4 || vga_y == 11 ) && vga_x >= 31 && vga_x <= 32  
						||( vga_y == 5 || vga_y == 10 ) && vga_x == 33 //d
						
//显示 时间 100us 20ms /div 2
						||( (vga_y == 468 || vga_y == 469) || vga_y == 474 ) &&  vga_x == 539
						|| (vga_y == 467 || vga_y == 475 ) &&( vga_x >= 540 &&  vga_x <= 542 )//458--443
						|| vga_y == 470 && ( vga_x >= 540 &&  vga_x <= 541 )//s
						|| vga_y == 471 && vga_x == 542 
						||( (vga_y == 468 || vga_y == 472) || vga_y == 473 || vga_y == 474 ) &&  vga_x == 543//s
						
						|| vga_y >= 468 && vga_y <= 470 && ( vga_x == 560 || vga_x == 564 )
						|| vga_y >= 471 && vga_y <= 473 && ( vga_x == 561 || vga_x == 563 )
						|| vga_y >= 474 && vga_y <= 475 && ( vga_x == 562 )//v
						
						|| vga_y >= 468 && vga_y <= 475 &&  vga_x == 558 
						|| vga_y >= 465 && vga_y <= 466 &&  vga_x == 558 
						|| vga_y == 468 && vga_x >= 556 && vga_x <= 557   //i
						
						|| vga_y >= 465 && vga_y <= 475 &&  vga_x == 554 
						|| vga_y >= 469 && vga_y <= 474 &&  vga_x == 550
						||( vga_y == 468 || vga_y == 475 ) && vga_x >= 551 && vga_x <= 552  
						||( vga_y == 469 || vga_y == 474 ) && vga_x == 553 //d
						
						|| vga_y >= 474 && vga_y <= 475 &&  vga_x == 545 
						|| vga_y >= 472 && vga_y <= 473 &&  vga_x == 546
						|| vga_y >= 470 && vga_y <= 471 &&  vga_x == 547 
						|| vga_y >= 468 && vga_y <= 469 &&  vga_x == 548
						|| vga_y >= 466 && vga_y <= 467 &&  vga_x == 549 // /						
						)?1'b1 : 1'b0;

						
//---------------数字去摸区---------------------
assign temp_x = vga_x - position_X;
assign temp_y = vga_y - position_Y;

assign num0 = ( 	temp_x >= 1  && temp_x <=  6 && ( temp_y == 1 || temp_y == 11 ) || 
						temp_y >= 1 && temp_y <= 11 && ( temp_x == 1 || temp_x == 6  )
					) ?1'b1 : 1'b0;
assign num1 = ( 	temp_y >= 1 && temp_y <= 11 && (  temp_x == 6 )
					) ?1'b1 : 1'b0;
assign num2 = ( 	temp_x >= 1 && temp_x <=  6 && ( temp_y == 1 || temp_y == 6 || temp_y == 11 ) || 
						temp_y >= 6 && temp_y <= 11 && ( temp_x == 1 )|| 
						temp_y >= 1 && temp_y <= 5 && ( temp_x == 6  )
					) ?1'b1 : 1'b0;
assign num3 = ( 	temp_x >= 1 && temp_x <=  6 && ( temp_y == 1 || temp_y == 6 || temp_y == 11 ) || 
						temp_y >= 1 && temp_y <= 11 && ( temp_x == 6  )
					) ?1'b1 : 1'b0;
assign num4 = ( 	temp_x >= 1 && temp_x <=  6 && ( temp_y == 6 ) || 
						temp_y >= 1 && temp_y <= 11 && ( temp_x == 6  ) ||
						temp_y >= 1 && temp_y <= 6 && ( temp_x == 1  )
					) ?1'b1 : 1'b0;
assign num5 = ( 	temp_x >= 1 && temp_x <=  6 && ( temp_y == 1 || temp_y == 6 || temp_y == 11 ) || 
						temp_y >= 6 && temp_y <= 11 && ( temp_x == 6 )|| 
						temp_y >= 1 && temp_y <= 5 && ( temp_x == 1  )
					) ?1'b1 : 1'b0;
assign num6 = ( 	temp_x >= 1 && temp_x <=  6 && ( temp_y == 1 || temp_y == 6 || temp_y == 11 ) || 
						temp_y >= 6 && temp_y <= 11 && ( temp_x == 6 )|| 
						temp_y >= 1 && temp_y <= 11 && ( temp_x == 1  )
					) ?1'b1 : 1'b0;
assign num7 = ( 	temp_x >= 1 && temp_x <=  6 && ( temp_y == 1 ) || 
						temp_y >= 1 && temp_y <= 11 && (  temp_x == 6  )
					) ?1'b1 : 1'b0;
assign num8 = ( 	temp_x >= 1 && temp_x <=  6 && ( temp_y == 1 || temp_y == 6 || temp_y == 11 ) || 
						temp_y >= 1 && temp_y <= 11 && ( temp_x == 1 || temp_x == 6  )
					) ?1'b1 : 1'b0;
assign num9 = ( 	temp_x >= 1 && temp_x <=  6 && ( temp_y == 1 || temp_y == 6 || temp_y == 11 ) || 
						temp_y >= 1 && temp_y <= 6 && ( temp_x == 1 )|| 
						temp_y >= 1 && temp_y <= 11 && ( temp_x == 6  )
					) ?1'b1 : 1'b0;
		

// 		
//-----------------------------------------------	
// 显示逻辑程序
always@(posedge clk_25M or posedge vga_rst_n) 
begin 
	
		if(vga_rst_n) 
			color_data <= 24'H0; 
	
// ------------波形显示区-------------------------------------
		else if(area1)                  
			if(vga_y == i_temp)
				color_data <= `RED;
			else if(area0)
				color_data<= `BLACK;     //格线
			else
					color_data <= 24'H606060;   //内背景

//-------------电压幅值数值显示区-------------------------------------					
		else if(vga_x >= 581 && vga_x <= 588 && vga_y >=100 && vga_y <= 111 )	//幅值第一位数
			begin
			position_X <= 581;
			position_Y <= 100;
				case(  v_num_data[11:8] )   
				4'd0: if(num0)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd1: if(num1)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd2: if(num2)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd3: if(num3)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd4: if(num4)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd5: if(num5)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd6: if(num6)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd7: if(num7)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd8: if(num8)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd9: if(num9)  color_data <= `BLACK;   else  color_data <= `WHITE;
				  default: color_data <= `WHITE;//
				endcase
			end
			
		else if(vga_x >= 589 && vga_x <= 590 && vga_y >= 111 && vga_y <= 112)//小数点
					color_data<= `BLACK; 
					
		else if(vga_x >= 591 && vga_x <= 598 && vga_y >=100 && vga_y <= 111 )	//幅值第二位数
			begin
			position_X <= 591;
			position_Y <= 100;
				case(v_num_data[7:4] )
				4'd0: if(num0)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd1: if(num1)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd2: if(num2)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd3: if(num3)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd4: if(num4)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd5: if(num5)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd6: if(num6)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd7: if(num7)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd8: if(num8)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd9: if(num9)  color_data <= `BLACK;   else  color_data <= `WHITE;
				  default: color_data <= `WHITE;//
				endcase
			end
			
		else if(vga_x >= 599 && vga_x <= 606 && vga_y >=100 && vga_y <= 111 )	//幅值第三位数
			begin
			position_X <= 599;
			position_Y <= 100;
				case(v_num_data[3:0])
				4'd0: if(num0)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd1: if(num1)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd2: if(num2)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd3: if(num3)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd4: if(num4)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd5: if(num5)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd6: if(num6)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd7: if(num7)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd8: if(num8)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd9: if(num9)  color_data <= `BLACK;   else  color_data <= `WHITE;
				default: color_data <= `WHITE;//
				endcase
			end
			
//----------------频率显示区------------------------
		
		

//---------------频率前三位+小数点+‘k’（判断显示）----------------------

     	else if(vga_x >= 565 && vga_x <= 572 && vga_y >=150 && vga_y <= 161 )	//频率第1位数
			if(f_num_data[23:12] > 0 )
			begin
			position_X <= 565;
			position_Y <= 150;
				case(f_num_data[23 :20])
				4'd0: if(num0)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd1: if(num1)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd2: if(num2)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd3: if(num3)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd4: if(num4)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd5: if(num5)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd6: if(num6)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd7: if(num7)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd8: if(num8)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd9: if(num9)  color_data <= `BLACK;   else  color_data <= `WHITE;
				default: color_data <= `WHITE;//
				endcase
				end
			 else 
			    color_data <= `WHITE;

		else if(vga_x >= 573 && vga_x <= 580 && vga_y >=150 && vga_y <= 161 )	//频率第2位数
			if(f_num_data[23:12] > 0 )
			begin
			position_X <= 573;
			position_Y <= 150;
				case(f_num_data[19 :16])
				4'd0: if(num0)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd1: if(num1)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd2: if(num2)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd3: if(num3)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd4: if(num4)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd5: if(num5)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd6: if(num6)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd7: if(num7)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd8: if(num8)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd9: if(num9)  color_data <= `BLACK;   else  color_data <= `WHITE;
				default: color_data <= `WHITE;//
				endcase
				end
			 else 
			    color_data <= `WHITE;
				
		else if(vga_x >= 581 && vga_x <= 588 && vga_y >=150 && vga_y <= 161 )	//频率第3位数
			if(f_num_data[23:12] > 0 )
			begin
			position_X <= 581;
			position_Y <= 150;
				case(f_num_data[15 :12])
				4'd0: if(num0)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd1: if(num1)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd2: if(num2)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd3: if(num3)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd4: if(num4)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd5: if(num5)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd6: if(num6)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd7: if(num7)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd8: if(num8)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd9: if(num9)  color_data <= `BLACK;   else  color_data <= `WHITE;
				default: color_data <= `WHITE;//
				endcase
				end
			 else 
			    color_data <= `WHITE;
			
				
	   else if(vga_x >= 589 &&vga_x <= 590 && vga_y >= 161 && vga_y <= 162)// 频率数值小数点，34位之间
	      if(f_num_data[23:12] > 0 ) color_data<= `BLACK;    else  color_data <= `WHITE;		
			
	else if(area_k)// 频率单位‘k’
	      if(f_num_data[23:12] > 0 ) color_data<= `BLACK;    else  color_data <= `WHITE;	
			
			
			
			
//------------------频率后三位（一直显示）----------------			
		else if(vga_x >= 591 && vga_x <= 598 && vga_y >=150 && vga_y <= 161 )	//频率第4位数
			begin
			position_X <= 591;
			position_Y <= 150;
				case( f_num_data[11:8] )
				4'd0: if(num0)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd1: if(num1)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd2: if(num2)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd3: if(num3)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd4: if(num4)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd5: if(num5)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd6: if(num6)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd7: if(num7)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd8: if(num8)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd9: if(num9)  color_data <= `BLACK;   else  color_data <= `WHITE;
				default: color_data <= `WHITE;//
				endcase
			end
			
		else if(vga_x >= 599 && vga_x <= 606 && vga_y >=150 && vga_y <= 161 )	//频率第5位数
			begin
			position_X <= 599;
			position_Y <= 150;
				case( f_num_data[7:4] )
				4'd0: if(num0)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd1: if(num1)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd2: if(num2)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd3: if(num3)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd4: if(num4)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd5: if(num5)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd6: if(num6)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd7: if(num7)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd8: if(num8)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd9: if(num9)  color_data <= `BLACK;   else  color_data <= `WHITE;
				default: color_data <= `WHITE;//
				endcase
			end
			
			else if(vga_x >= 607 && vga_x <= 614 && vga_y >=150 && vga_y <= 161 )	//频率第6位数
			begin
			position_X <= 607;
			position_Y <= 150;
				case( f_num_data[3:0] )
				4'd0: if(num0)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd1: if(num1)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd2: if(num2)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd3: if(num3)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd4: if(num4)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd5: if(num5)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd6: if(num6)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd7: if(num7)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd8: if(num8)  color_data <= `BLACK;   else  color_data <= `WHITE;
				4'd9: if(num9)  color_data <= `BLACK;   else  color_data <= `WHITE;
				default: color_data <= `WHITE;//
				endcase
			end
			
//----------1&0.1V切换
			else if(vga_x >= 1 && vga_x <= 8 && vga_y >=0 && vga_y <= 12 ) //
			begin
			position_X <= 1;
			position_Y <= 0;
				if(V_div_select) 
					if(num0)  color_data <= `BLACK;   
				else  color_data <= `WHITE;
			end
			
			else if(vga_x>=9 && vga_x <= 10 && vga_y >= 10 && vga_y <= 11) //
				if(V_div_select) color_data <= `BLACK;   
				else  color_data <= `WHITE;
				
//-----------100us&10ns切换--------
			else if(vga_x >= 523 && vga_x <= 530 && vga_y >=466 && vga_y <= 477 ) //最低位
			begin
			position_X <= 523;
			position_Y <= 466;
				if(num0)  color_data <= `BLACK;   else  color_data <= `WHITE;
			end
			
			
			else if(vga_x >= 515 && vga_x <= 522 && vga_y >=466 && vga_y <= 477 )	//第二位
			begin
			position_X <= 515;
			position_Y <= 466;
				if(~f_div_select) 
				begin 
					if(num0)  color_data <= `BLACK;   else  color_data <= `WHITE;
				end
				else 
				begin 
					if(num2)  color_data <= `BLACK;   else  color_data <= `WHITE;
				end
			end
			
			else if(vga_x >= 507 && vga_x <= 514 && vga_y >=466 && vga_y <= 477 ) //
			begin
			position_X <= 507;
			position_Y <= 466;
				if(~f_div_select) 
					if(num1)  color_data <= `BLACK;   
				else  color_data <= `WHITE;
			end
				
//------------	固定字符显示区------------------		
			else if(area3)	   
					 color_data <= `BLACK;

					 
//-------------背景色------------------					 
			else 
				if(~f_div_select) 
					if(area_u) color_data <= `BLACK; else color_data <= `WHITE;//背景灰色
				else  
					if(area_m) color_data <= `BLACK;	else color_data <= `WHITE;//背景灰色
					
end 


endmodule

 
 
 