module MemoryGrid(clk, clr, game_enable, Write_enable, Write_row, Write_col, Data_in, states, preset_sel);
		parameter nr = 20;
		parameter nc = 20;
		parameter addr_len = 6;
		input clk, clr, game_enable, Write_enable, Data_in;
		input [addr_len-1:0] Write_row, Write_col;
		input [1:0] preset_sel;
//		input [addr_len-1:0] Read_row, Read_col;
		
		output wire [nr*nc-1:0]states;
		
//		output Data_out = states[n*Read_row+Read_col];
	
		wire [nr*nc-1:0]preset;
		Presets #(nr, nc) pset(preset_sel, preset);
	
		
		genvar row, col;
	  generate
			for (row=0; row<nr; row=row+1) begin:row_loop
				 for (col=0; col<nc; col=col+1) begin:column_loop
					  // making the grid wrap around
					  reg [addr_len-1:0] row_plus_1 = row==nr-1 ? 0 : row+1;
					  reg [addr_len-1:0] row_minus_1 = row==0 ? nr-1 : row-1;
					  reg [addr_len-1:0] col_plus_1 = col==nc-1 ? 0 : col+1;
					  reg [addr_len-1:0] col_minus_1 = col==0 ? nc-1 : col-1;

					  wire [3:0]neighbor_count = 
										states[nc*row_minus_1+col_minus_1] + states[nc*row_minus_1+col] + states[nc*row_minus_1+col_plus_1]+
										states[nc*row+col_minus_1]                      +                states[nc*row+col_plus_1]        +
										states[nc*row_plus_1+col_minus_1]  + states[nc*row_plus_1+col]  + states[nc*row_plus_1+col_plus_1];
					  Cell test(clk, clr, game_enable, (Write_enable && row==Write_row && col==Write_col), Data_in, preset[nc*row+col], neighbor_count, states[nc*row+col]);
				 end
			end
	  endgenerate
endmodule

module Cell(input clk, clr, game_enable, write_enable, data_in, preset, input [3:0]neighbor_count, output reg state);
	always @(posedge clk, negedge clr) begin
		if (clr==0) state <= preset;
		else if (write_enable) state <= data_in;
		else if (game_enable) begin
			 case(neighbor_count)
				  2: state <= state;
				  3: state <= 1;
				  default: state <= 0;
			 endcase
		end
	end
endmodule



