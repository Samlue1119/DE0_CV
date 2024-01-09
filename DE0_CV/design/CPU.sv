module CPU(
	input logic clk,
	input logic rst,
	output logic [7:0]w_q
	);
	
	logic [13:0]prog_data,ir_q;
	logic [10:0]pc_q,pc_next,mar_q, stack_q, w_change, k_change;
	logic [7:0]alu_q,mux1_out,opcode,oprand,ram_out,data_bus,RAM_mux,bcf_mux,bsf_mux, port_b_out;
	logic [3:0]ps,ns,op;
	logic [2:0]sel_bit, ir_out, sel_pc;
	logic [1:0]sel_RAM_mux;
	logic ram_en, sel_alu, load_pc,load_mar,load_ir,load_w, sel_bus, load_port_b, addr_port_b;
	logic btfsc_skip_bit, btfss_skip_bit, btfsc_btfss_skip_bit, aluout_zero, push, pop, reset_ir, ir_reset;
	
	//PC
	always_comb
	begin
		case(sel_pc)
			0: pc_next = pc_q + 1;
			1: pc_next = ir_q[10:0];
			2: pc_next = stack_q;
			3: pc_next = pc_q + k_change;
			4: pc_next = pc_q + w_change;
			default: pc_next = pc_q + 1;
		endcase
	end
	
	always_ff @(posedge clk or posedge rst)
	begin
		if(rst)					pc_q <= #1 0;
		else if (load_pc) 	pc_q <= #1 pc_next;
	end
	
	//MAR
	always_ff @(posedge clk or posedge rst)
	begin
		if(rst)					mar_q <= #1 0;
		else if(load_mar) 	mar_q <= #1 pc_q;
	end
	
	//ROM
	Program_Rom ROM1(
		.Rom_data_out(prog_data), 
		.Rom_addr_in(mar_q)
	);
	
	//RAM
	single_port_ram_128x8 RAM1(
		.data(data_bus), 
		.addr(ir_q[6:0]),
		.ram_en(ram_en),
		.clk(clk),
		.q(ram_out)
	);
	//STACK
	stack s1 (
		.push(push),
		.pop(pop),
		.reset(rst),
		.clk(clk),
		.stack_in(pc_q),
		.stack_out(stack_q)
	);
	
	//IR
	always_ff @(posedge clk or posedge rst)
	begin 
		if(rst)	     ir_q <= #1 0;
		else if (reset_ir ) ir_q <= 0;
		else if (load_ir)	 ir_q <= #1 prog_data;
	end
	
	//OPCODE
	assign ADDLW  = ir_q[13:8]  == 6'b111110;
	assign MOVLW  = ir_q[13:8]  == 6'h30;
	assign ADDWF  = ir_q[13:8]  == 6'b000111;
	assign IORLW  = ir_q[13:8]  == 6'h38;
	assign ANDWF  = ir_q[13:8]  == 6'b000101;
	assign SUBLW  = ir_q[13:8]  == 6'h3c;
	assign XORLW  = ir_q[13:8]  == 6'h3a;
	assign CLRF   = ir_q[13:7]  == 7'b0000011;
	assign CLRW   = ir_q[13:2]  == 12'b000001000000;
	assign COMF   = ir_q[13:8]  == 6'b001001;
	assign DECF   = ir_q[13:8]  == 6'b000011;
	assign GOTO   = ir_q[13:11] == 3'b101;
				  
	assign INCF   = ir_q[13:8]  == 6'b001010;
	assign IORWF  = ir_q[13:8]  == 6'b000100;
	assign MOVF   = ir_q[13:8]  == 6'b001000;
	assign MOVWF  = ir_q[13:7]  == 7'b0000001;
	assign SUBWF  = ir_q[13:8]  == 6'b000010;
	assign XORWF  = ir_q[13:8]  == 6'b000110;
				  
	assign BCF    = ir_q[13:10] == 4'b0100;
	assign BSF    = ir_q[13:10] == 4'b0101;
	assign BTFSC  = ir_q[13:10] == 4'b0110;
	assign BTFSS  = ir_q[13:10] == 4'b0111;
	assign DECFSZ = ir_q[13:8]  == 6'b001011;
	assign INCFSZ = ir_q[13:8]  == 6'b001111;
	
	assign ASRF	  = ir_q[13:8]  == 6'b110111;
	assign LSLF	  = ir_q[13:8]  == 6'b110101;
	assign LSRF   = ir_q[13:8]  == 6'b110110;
	assign RLF    = ir_q[13:8]  == 6'b001101;
	assign RRF    = ir_q[13:8]  == 6'b001100;
	assign SWAPF  = ir_q[13:8]  == 6'b001110;
	assign CALL   = ir_q[13:0]  == 14'b10000000001001;
	assign RETURN = ir_q[13:0]  == 14'b00000000001000;
	
	assign BRA    = ir_q[13:9]  == 5'b11001;
	assign BRW    = ir_q[13:0]  == 14'b00000000001011;
	assign NOP    = ir_q[13:0]  == 14'b00000000000000;
	
	//bsf bcf
	assign sel_bit = ir_q[9:7];
	//RAM_mux
	always_comb
	begin
		case(sel_RAM_mux)
			0: RAM_mux = ram_out;
			1: RAM_mux = bcf_mux;
			2: RAM_mux = bsf_mux;
		endcase
	end
	//BCF_mux
	always_comb
	begin
		case(sel_bit)
			3'b000: bcf_mux = ram_out & 8'b1111_1110;
			3'b001: bcf_mux = ram_out & 8'b1111_1101;
			3'b010: bcf_mux = ram_out & 8'b1111_1011;
			3'b011: bcf_mux = ram_out & 8'b1111_0111;
			3'b100: bcf_mux = ram_out & 8'b1110_1111;
			3'b101: bcf_mux = ram_out & 8'b1101_1111;
			3'b110: bcf_mux = ram_out & 8'b1011_1111;
			3'b111: bcf_mux = ram_out & 8'b0111_1111;
		endcase
	end
	//BSF_mux
	always_comb
	begin
		case(sel_bit)
			3'b000: bsf_mux = ram_out | 8'b0000_0001;
			3'b001: bsf_mux = ram_out | 8'b0000_0010;
			3'b010: bsf_mux = ram_out | 8'b0000_0100;
			3'b011: bsf_mux = ram_out | 8'b0000_1000;
			3'b100: bsf_mux = ram_out | 8'b0001_0000;
			3'b101: bsf_mux = ram_out | 8'b0010_0000;
			3'b110: bsf_mux = ram_out | 8'b0100_0000;
			3'b111: bsf_mux = ram_out | 8'b1000_0000;
		endcase
	end
	
	//BTFSC&BTFSS
	assign btfsc_skip_bit = ram_out[ir_q[9:7]] == 0;
	assign btfss_skip_bit = ram_out[ir_q[9:7]] == 1;
	assign btfsc_btfss_skip_bit = (BTFSC&btfsc_skip_bit) | (BTFSS&btfss_skip_bit);
	
	//DECFSZ & INCFSZ
	assign aluout_zero = (alu_q == 0);
	
	always_comb
	begin
		if(~sel_alu)	mux1_out <= #1 ir_q[7:0];
		else				mux1_out <= #1 RAM_mux;
	end
	always_comb
	begin
		if(~sel_bus)	data_bus <= #1 alu_q;
		else				data_bus <= #1 w_q;
	end
	
	//ALU	
	always_ff @(posedge clk or posedge rst)
	begin
		if(rst)				w_q <= #1 0;
		else if (load_w)	w_q <= #1 alu_q;
	end
	
	//Port_b
	always_ff @(posedge clk)
	begin
		if (rst) port_b_out <= 0;
		else if (load_port_b) port_b_out <= data_bus;
	end
	assign addr_port_b = (ir_q[6:0] == 7'h0d);
	
	always_comb
	begin	
		case(op)
			0:	  alu_q = mux1_out + w_q;
			1:	  alu_q = mux1_out - w_q;
			2:	  alu_q = mux1_out & w_q;
			3:	  alu_q = mux1_out | w_q;
			4:	  alu_q = mux1_out ^ w_q;
			5:	  alu_q = mux1_out;
			6:	  alu_q = mux1_out + 1;
			7:	  alu_q = mux1_out - 1;
			8:	  alu_q = 0;
			9:	  alu_q = ~mux1_out;
			4'hA: alu_q = {mux1_out[7]  , mux1_out[7:1]};
			4'hB: alu_q = {mux1_out[6:0], 1'b0         };
			4'hC: alu_q = {1'b0         , mux1_out[7:1]};
			4'hD: alu_q = {mux1_out[6:0], mux1_out[7]  };
			4'hE: alu_q = {mux1_out[0]  , mux1_out[7:1]};
			4'hF: alu_q = {mux1_out[3:0], mux1_out[7:4]};
			default alu_q = mux1_out + w_q;
		endcase 
	end
	
	//state
	typedef enum logic [3:0]{
		T0,T1,T2,T3,T4,T5,T6
	}state_t;

	always_ff @(posedge clk or posedge rst)
	begin
		if(rst)			ps <= #1 0;
		else			 	ps <= #1 ns;
	end
	//BRA BRW
	assign w_change = {3'b0, w_q} - 1;
	assign k_change = {ir_q[8], ir_q[8], ir_q[8:0]} - 1;
	
	assign d = ~ir_q[7];
	
	always_comb
	begin
		load_mar = 0;
		load_ir = 0;
		load_pc = 0;
		load_w = 0;
		ns = 0;
		sel_pc = 0;
		sel_alu = 0;
		ram_en = 0;
		op = 0;
		sel_bus = 0;
		sel_RAM_mux = 0;
		load_port_b = 0;
		push = 0;
		pop = 0;
		reset_ir = 0;
		//addr_port_b = 0;
		//aluout_zero = 0;
		
		case(ps)
			T0:
			begin
				ns		=	T1;
			end
			T1:
			begin
				//load_mar = 1;
				//sel_pc = 1;
				//load_pc = 1;
				ns		=	T2;
			end
			T2:
			begin
				ns		=	T3;
			end
			T3:
			begin
				//load_ir = 1;
				ns		=	T4;
			end
			T4:
			begin
				load_mar = 1;
				sel_pc = 2'b00;
				load_pc = 1;
				if(ADDWF)
					begin
						op = 0;
						sel_alu = 1;
						if(d)	load_w = 1;
						else 	ram_en = 1;
					end
				else if (ADDLW)
					begin
						op = 0;
						load_w = 1;
					end
				else if(SUBLW)
					begin
						op = 1;
						load_w = 1;
					end
				else if(ANDWF) 
					begin
						op = 2;
						sel_alu = 1;
						if(d)	load_w = 1;
						else 	ram_en = 1;
					end
				else if(IORLW) 
					begin
						op = 3;
						load_w = 1;
					end
				else if(XORLW)
					begin
						op = 4;
						load_w = 1;
					end
				else if(MOVLW)
					begin
						op = 5;
						load_w = 1;
					end
				else if(COMF ) 
					begin
						op = 6;
						sel_alu = 1;
						ram_en = 1;
					end
				else if(DECF) 
					begin
						op = 7;
						sel_alu = 1;
						ram_en = 1;
					end
				else if(CLRF)
					begin
						op = 8;
						ram_en = 1;
					end
				else if(CLRW )
					begin
						op = 8;
						load_w = 1;
					end
				else if(COMF )
					begin
						op = 9;
						sel_alu = 1;
						ram_en = 1;
					end
				else if (INCF)
					begin
						op = 6;
						sel_alu = 1;
						if(d) 
						begin
							load_w = 1;
						end
						else if(~d)
						begin
							ram_en = 1;
							sel_bus = 0;
						end
					end
				else if (IORWF)
					begin
						op = 3;
						sel_alu = 1;
						if (d)
						begin
							load_w = 1;	
						end
						else 
						begin
							ram_en = 1;
							sel_bus = 0;
						end
					end
				else if (MOVF)
					begin
						op = 5;
						sel_alu = 1;
						if(d)
						begin
							load_w = 1;
						end
						else if (~d)
							begin
								ram_en = 1;
								sel_bus = 0;
							end
					end
				else if (MOVWF)
					begin
						sel_bus = 1;
						if (addr_port_b == 1) load_port_b = 1;
						else ram_en = 1;
					end
				else if (SUBWF)
					begin
						op = 1;
						sel_alu = 1;
						if(d) 
							begin
								load_w = 1;
							end
						else if (~d)
							begin
								ram_en = 1;
								sel_bus = 0;
							end
					end
				else if (XORWF)
				begin
					op = 4;
					sel_alu = 1;
					if(d)
						begin	
							load_w = 1;
						end
					else if(~d)
						begin
							ram_en = 1;
							sel_bus = 0;
						end
				end
				else if (BCF)
				begin
					sel_alu = 1;
					sel_RAM_mux = 1;
					op[3:0] = 5;
					sel_bus = 0;
					ram_en = 1;
				end
				else if (BSF)
				begin
					sel_alu = 1;
					sel_RAM_mux = 2;
					op[3:0] = 5;
					sel_bus = 0;
					ram_en = 1;
				end
				else if (ASRF)
				begin
					sel_alu = 1;
					sel_RAM_mux = 0;
					op = 4'hA;
					if (d) load_w = 1;
					else if (~d)
					begin
						sel_bus = 0;
						ram_en = 1;
					end
				end
				else if (LSLF)
				begin
					sel_alu = 1;
					sel_RAM_mux = 0;
					op = 4'hB;
					if (d) load_w = 1;
					else if (~d)
					begin
						sel_bus = 0;
						ram_en = 1;
					end
				end
				else if (LSRF)
				begin
					sel_alu = 1;
					sel_RAM_mux = 0;
					op = 4'hC;
					if (d) load_w = 1;
					else if (~d)
					begin
						sel_bus = 0;
						ram_en = 1;
					end
				end
				else if (RLF)
				begin
					sel_alu = 1;
					sel_RAM_mux = 0;
					op = 4'hD;
					if (d) load_w = 1;
					else if (~d)
					begin
						sel_bus = 0;
						ram_en = 1;
					end
				end
				else if (RRF)
				begin
					sel_alu = 1;
					sel_RAM_mux = 0;
					op = 4'hE;
					if (d) load_w = 1;
					else if (~d)
					begin
						sel_bus = 0;
						ram_en = 1;
					end
				end
				else if (SWAPF)
				begin
					sel_alu = 1;
					sel_RAM_mux = 0;
					op = 4'hF;
					if (d) load_w = 1;
					else if (~d)
					begin
						sel_bus = 0;
						ram_en = 1;
					end
				end
				else if (CALL)
				begin
					push = 1;
				end
				ns		=	T5;
			end
			T5:
			begin
				if(GOTO )
				begin
					sel_pc = 1;
					load_pc = 1;
				end
				else if (CALL)
				begin
					//push = 1;
					sel_pc = 1;
					load_pc = 1;
				end
				else if (RETURN)
				begin
					sel_pc = 2;
					load_pc = 1;
					pop = 1;
				end
				else if (BRA)
				begin
					load_pc = 1;
					sel_pc = 3;
				end
				else if (BRW)
				begin
					load_pc = 1;
					sel_pc  = 4;
				end
				ns		=	T6;
			end
			T6:
			begin
			load_ir = 1;
				if(GOTO )
				begin
					reset_ir = 1;
				end
				else if (CALL)
				begin
					reset_ir = 1;
				end
				else if (RETURN)
				begin
					reset_ir = 1;
				end
				else if (DECFSZ)
				begin
					op = 7;
					sel_alu = 1;
					if (d)
					begin
						load_w = 1;
					end
					else if (~d)
					begin
						sel_bus = 0;
						ram_en = 1;
					end
					if (aluout_zero == 1) 
					begin
						reset_ir = 1;
					end
				end
				else if (INCFSZ)
				begin
					op = 6;
					sel_alu = 1;
					if(d)
					begin
						load_w = 1;
					end
					else if (~d)
					begin
						sel_bus = 0;
						ram_en = 1;
					end
					if (aluout_zero == 1)
					begin
						reset_ir = 1;
					end
				end
				else if (BTFSC)
				begin
					if (btfsc_btfss_skip_bit == 1)
					begin
						reset_ir = 1;
					end
				end
				else if (BTFSS)
				begin
					if (btfsc_btfss_skip_bit == 1)
					begin
						reset_ir = 1;
					end	
				end
				else if (BRA)
				begin
					reset_ir = 1;
				end
				else if (BRW)
				begin
					reset_ir = 1;
				end
				ns		=	T4;
			end
		endcase
	end
	
endmodule