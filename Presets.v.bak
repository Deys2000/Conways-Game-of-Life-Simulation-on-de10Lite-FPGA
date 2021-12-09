module Presets(sel, grid);
	parameter gsr = 20;	//grid size
	parameter gsc = 20;
	parameter addr_len = 8;
	input [1:0] sel;
	output reg [gsr*gsc:0] grid;
	
	wire [addr_len-1:0]hgs_r = gsr/2; //half grid size
	wire [addr_len-1:0]hgs_c = gsc/2;

	always @(sel) begin
		grid = 0;
		case (sel)
			00: begin
			end
			01: begin
				//glider
				grid[gsc*(hgs_r+0) + (0+hgs_c)] = 1;
				grid[gsc*(hgs_r+0) + (1+hgs_c)] = 1;
				grid[gsc*(hgs_r+1) + (0+hgs_c)] = 1;
				grid[gsc*(hgs_r+1) + (2+hgs_c)] = 1;
				grid[gsc*(hgs_r+2) + (0+hgs_c)] = 1;
			end
			10: begin
//				grid[gsc*(hgs_r+0) + (24+hgs_c)] = 1;
//				grid[gsc*(hgs_r+1) + (22+hgs_c)] = 1;
//				grid[gsc*(hgs_r+1) + (24+hgs_c)] = 1;
//				grid[gsc*(hgs_r+2) + (12+hgs_c)] = 1;
//				grid[gsc*(hgs_r+2) + (13+hgs_c)] = 1;
//				grid[gsc*(hgs_r+2) + (20+hgs_c)] = 1;
//				grid[gsc*(hgs_r+2) + (21+hgs_c)] = 1;
//				grid[gsc*(hgs_r+2) + (34+hgs_c)] = 1;
//				grid[gsc*(hgs_r+2) + (35+hgs_c)] = 1;
//				grid[gsc*(hgs_r+3) + (11+hgs_c)] = 1;
//				grid[gsc*(hgs_r+3) + (15+hgs_c)] = 1;
//				grid[gsc*(hgs_r+3) + (20+hgs_c)] = 1;
//				grid[gsc*(hgs_r+3) + (21+hgs_c)] = 1;
//				grid[gsc*(hgs_r+3) + (34+hgs_c)] = 1;
//				grid[gsc*(hgs_r+3) + (35+hgs_c)] = 1;
//				grid[gsc*(hgs_r+4) + (0+hgs_c)] = 1;
//				grid[gsc*(hgs_r+4) + (1+hgs_c)] = 1;
//				grid[gsc*(hgs_r+4) + (10+hgs_c)] = 1;
//				grid[gsc*(hgs_r+4) + (16+hgs_c)] = 1;
//				grid[gsc*(hgs_r+4) + (20+hgs_c)] = 1;
//				grid[gsc*(hgs_r+4) + (21+hgs_c)] = 1;
//				grid[gsc*(hgs_r+5) + (0+hgs_c)] = 1;
//				grid[gsc*(hgs_r+5) + (1+hgs_c)] = 1;
//				grid[gsc*(hgs_r+5) + (10+hgs_c)] = 1;
//				grid[gsc*(hgs_r+5) + (14+hgs_c)] = 1;
//				grid[gsc*(hgs_r+5) + (16+hgs_c)] = 1;
//				grid[gsc*(hgs_r+5) + (17+hgs_c)] = 1;
//				grid[gsc*(hgs_r+5) + (22+hgs_c)] = 1;
//				grid[gsc*(hgs_r+5) + (24+hgs_c)] = 1;
//				grid[gsc*(hgs_r+6) + (10+hgs_c)] = 1;
//				grid[gsc*(hgs_r+6) + (16+hgs_c)] = 1;
//				grid[gsc*(hgs_r+6) + (24+hgs_c)] = 1;
//				grid[gsc*(hgs_r+7) + (11+hgs_c)] = 1;
//				grid[gsc*(hgs_r+7) + (15+hgs_c)] = 1;
//				grid[gsc*(hgs_r+8) + (12+hgs_c)] = 1;
//				grid[gsc*(hgs_r+8) + (13+hgs_c)] = 1;
			end
			default: begin end
		endcase
	end
endmodule