//======================================================================
//
//        Copyright (C) 2018
//        All rights reserved
//
//        filename: measuring
//
//        created by Tyl at 2019-01-11 16:27:29
//        modified by Tyl at 2019-01-13 00:37:00
//
//======================================================================
// Quartus II Verilog Template
// 4-State Moore state machine

// A Moore machine's outputs are dependent only on the current state.
// The output is written only when the state changes.  (State
// transitions are synchronous.)

module measuring
(
	input	clk, reset,
	input hscan_switch,
	input pause,
	input [9: 0]data,
	/*output statetest,
	output [9: 0]pretest, midtest, retest, maxvoltest, volrelatest, volBitest,
	output [11: 0]volBCDtest,
	output [12: 0]precounttest,
	output [19: 0]freqBitest,
	output [23: 0]freqBCDtest,
	output triggertest,
	output [14: 0]trigger_counttest,
	output prechecktest,
	output [13: 0]Ncounttest,
	output [23: 0]outcounttest,*/
	//频率电压均输出BCD码
	//频率以Hz为单位，幅值1MHz以内
	//电压以mV为单位，赋值4V以内
	output reg [23: 0]freqout,
	output reg [11: 0]volout
);

	// Declare state register
	reg		state;

	// Declare states
	parameter S0 = 0, S1 = 1;
	
	parameter trigger_vol = 10'b10_0000_0000;
	reg [9: 0]pre;
	reg [9: 0]mid;
	reg [9: 0]re;
	reg trigger;
	reg [9: 0]maxvol;
	reg [9: 0]volrela;
	wire [9: 0]volBi;
	wire [11: 0]volBCD;
	integer precount;
	reg [19: 0]freqBi;
	wire [23: 0]freqBCD;
	integer outcount;
	reg precheck;
	integer trigger_count;
	
	//测试模块
	/*assign statetest = state;
	assign pretest = pre;
	assign midtest = mid;
	assign retest = re;
	assign maxvoltest = maxvol;
	assign volrelatest = volrela;
	assign volBitest = volBi;
	assign volBCDtest = volBCD;
	assign precounttest = precount;
	assign freqBitest = freqBi;
	assign freqBCDtest = freqBCD;
	assign triggertest = trigger;
	assign prechecktest = precheck;
	assign trigger_counttest = trigger_count;
	assign Ncounttest = Ncount;
	assign outcounttest = outcount;*/
	
	// Output depends only on the state
	always @ (state) begin
		case (state)
			S0:
				trigger = 'b0;
			S1:
				trigger = 'b1;
		endcase
	end
	
	// Determine the next state and output
	always @ (posedge clk or posedge reset)
	begin
		if (reset)
			state <= S0;
		else
			case (state)
				S0:
					//判断触发
					if(pre > trigger_vol && re < trigger_vol)
						state <= S1;
					else
						state <= S0;
				S1:
					state <= S0;
			endcase
	end
	
	//移位寄存模块
	always@(posedge clk)
	begin
		pre <= data;
		mid <= pre;
		re <= mid;
	end
	
	//测压模块
	always@(posedge clk)
	begin
		if(trigger == 'b1)
		begin
			volrela[9: 1] <= maxvol[8: 0];
			volrela[0] <= 'b0;
			maxvol <= 'b0;
		end
		else if(maxvol < re)
			maxvol <= re;
	end
	
	//相对峰峰值转绝对峰峰值
	assign volBi = (volrela + 1) * 400 / 1024;
	//参考谭军提供的算法
	assign volBCD[11: 8] = volBi / 100 % 10;
	assign volBCD[7: 4] = volBi / 10 % 10;
	assign volBCD[3: 0] = volBi % 10;
	
	//频率预测量模块
	always@(posedge clk)
	begin
		if(trigger == 'b1)
		begin
			if(hscan_switch == 'b0)
			//高频
			begin
				if(500000 / precount >= 1000)
					precheck <= 'b1;
				else
					precheck <= 'b0;
			end
			else
			//低频
			begin
				if(2500 / precount >= 71)
					precheck <= 'b1;
				else
					precheck <= 'b0;
			end
			precount <= 'b0;
		end
		else
			precount <= precount + 1;
	end
	
	//测频模块
	always@(posedge clk)
	begin
		//if(hscan_switch == 'b1 && outcount == 1000 || hscan_switch == 'b0 && outcount == 5)
		if(hscan_switch == 'b0)
		begin
			if(outcount >= 250000)
			//输出
			begin
				if(precheck == 'b1)
					freqBi <= trigger_count * 2;
				else
				begin
					freqBi <= 500000 * trigger_count / outcount;
				end
				trigger_count <= 0;
			end
			else
			//计数
			begin
				if(trigger == 'b1)
					trigger_count <= trigger_count + 1;
			end
		end
		else
		begin
			if(outcount >= 1250)
			//输出
			begin
				if(precheck == 'b1)
					freqBi = trigger_count * 2;
				else
					freqBi = 2500 * trigger_count / outcount;
				trigger_count <= 0;
			end
			else
			//计数
			begin
				if(trigger == 'b1)
					trigger_count <= trigger_count + 1;
			end
		end
	end
	
	//======================================================================
	//转换二进制频率为BCD码，此算法由重庆大学20162628谭军提供
	assign freqBCD[23:20] = freqBi / 100000 %10;  
	assign freqBCD[19:16] = freqBi / 10000  %10;
	assign freqBCD[15:12] = freqBi / 1000   %10;
	assign freqBCD[11:8]  = freqBi / 100    %10;
	assign freqBCD[7:4]   = freqBi / 10     %10;
	assign freqBCD[3:0]   = freqBi          %10;
	//======================================================================
	
	//输出模块，0.5s输出一次
	always@(posedge clk)
	begin
		if(pause == 'b0)
		begin
			outcount <= outcount + 1;
			if(hscan_switch == 'b0)
			begin
				if(outcount >= 250000)
				begin
					volout <= volBCD;
					freqout <= freqBCD;
					outcount <= 0;
				end
			end
			else
				if(outcount >= 1250)
				begin
					volout <= volBCD;
					freqout <= freqBCD;
					outcount <= 0;
				end
		end;
	end
endmodule