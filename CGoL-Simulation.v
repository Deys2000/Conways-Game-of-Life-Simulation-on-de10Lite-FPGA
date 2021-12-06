`timescale 1ns / 1ps

module Top(
	input clk,           // 50 MHz
	input reset_bttn,
	input clk_bttn,
	input game_enable,
	input write_enable,
	input row_col_sw,
	input [4:0]cell_addr,
	input [1:0]preset_sel,
	output o_hsync,      		// horizontal sync
	output o_vsync,	     		// vertical sync
	output [3:0] o_red,	
	output [3:0] o_blue,
	output [3:0] o_green,
	output [6:0] disp_write_row,
	output [6:0] disp_write_col,
	output [6:0] disp_game_fps
);

	reg [9:0] counter_x = 0;  // horizontal counter
	reg [9:0] counter_y = 0;  // vertical counter
	reg [3:0] r_red = 0;
	reg [3:0] r_blue = 0;
	reg [3:0] r_green = 0;
	
	reg reset = 0;  // for PLL
	
	
	parameter xVGA = 799;	// number of clock cycles the vga requires horizontally
	parameter yVGA = 525;	// number of clock cycles the vga requires vertically
	
	wire clk25MHz;
//	
	ip ip1(.areset(reset),.inclk0(clk),.c0(clk25MHz),.locked());  
	
	
//	always @(posedge clk25MHz) begin		
//		if (counter_x == xVGA) begin
//				counter_x <= 0;
//				if (counter_y < yVGA)			
//					counter_y <= counter_y + 1;						
//				else												
//					counter_y <= 0;              
//		end 
//		else	begin
//			counter_x <= counter_x + 1;				              	
//		end
//	end
	always @(posedge clk25MHz) begin
		
		if (counter_x < 799)
				counter_x <= counter_x + 1;
		else
				counter_x <= 0;              
	
	end
	
	always @ (posedge clk25MHz) begin 
		 
			if (counter_x == 799)
				begin
					if (counter_y < 525)
						counter_y <= counter_y + 1;						
					else
						counter_y <= 0;              
			end
		
	end
	
	// hsync and vsync output assignments
	assign o_hsync = (counter_x < 96) ? 1:0;  // hsync high for 96 counts                                                 
	assign o_vsync = (counter_y < 2) ? 1:0;   // vsync high for 2 counts
	// end hsync and vsync output assignments

	
	
	
	// GRID DENSITY AND BORDER MODIFICATIONS
	parameter ymargin = 20; // border on screen without grid
	parameter xmargin = 20;
	
	parameter xstart = 144 + xmargin;	// writable dimensions
	parameter xend = 	783 - xmargin;
	parameter ystart = 35 + ymargin;
	parameter yend = 514 - ymargin;
	
	
	parameter rows = 30 ;
	parameter cols = 40 ; // change to modify density of grid
	parameter cell_sizeX = (xend-xstart)/cols; // since 400 is the total vertical length
	parameter cell_sizeY = (yend-ystart)/rows;
	
	reg [rows*cols:0] matrix;
	
	// GRID MATRIX CONNECTION TESTING VARIABLES
	reg [7:0]xindex = 8'd0;	// the indexing for reading from the matrix
	reg [7:0]yindex = 8'd0;
//	reg [7:0]xCounter = 8'd0;
//	reg [7:0]yCounter = 8'd0; // used as a counter to set xindex and yindex above
//	
//	reg [7:0]x1 = 8'd0;
//	reg [7:0]y1 = 8'd0;	
//	reg [7:0]x2 = 8'd0;
//	reg [7:0]y2 = 8'd0;
	
	
	reg [5:0] write_row, write_col;
	always @( cell_addr ) begin
		if (row_col_sw == 0) write_row = cell_addr;
		else write_col = cell_addr;
	end
	
	SevenSegEncoder w_row(write_row, disp_write_row);
	SevenSegEncoder w_col(write_col, disp_write_col);
	SevenSegEncoder fps_disp(game_fps, disp_game_fps);
	
	wire game_clk;
	VariableClockDivider(clk_bttn, clk, game_clk, game_fps);
	MemoryGrid #(rows, cols) game(game_clk, reset_bttn, game_enable, write_enable, write_row, write_col, 1, matrix, preset_sel);
	
	reg cell_sel;
	always@(posedge clk) begin
		
//		if(clk1Hz == 1) begin
//			x2 = x1;
//			y2 = y1;
//			
//			if( pb == 0)begin			
//			x1 = x1 + 1; y1 = y1 + 1;
//			end else begin
//			x1 = x1 - 1; y1 = y1 + 1;
//			end								
//			
//			x1 = (x1 == 0)? cell_count: x1;
//			y1 = (y1 == 0)? cell_count: y1;
//			x1 = (x1 > cell_count)? 0: x1;
//			y1 = (y1 > cell_count)? 0: y1;
//			
//			
//		end

		if( counter_y <  yend 	
			& counter_y > ystart 
			& counter_x > xstart 
			& counter_x < xend	) begin
				
																				//if((counter_x-144-xmargin-1) % cell_size == 0)
			xindex = (counter_x-xstart)/cell_sizeX;	
																				//if((counter_y-35-ymargin-1) % cell_size == 0)
			yindex = (counter_y-ystart)/cell_sizeY;			
			
			cell_sel = (yindex==write_row & xindex==write_col);
			
			
			// DISPLAY VGA COLOR CODE
			r_red = 0;   
			r_blue = matrix[(cols*yindex)+(xindex)] * 4'h9;
			r_green = cell_sel * 4'h9;
		
		end else begin
			r_red <= 4'hF;    // white
			r_blue <= 4'hF;
			r_green <= 4'hF;
		end
	end
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// color output assignments
	// only output the colors if the counters are within the adressable video time constraints
	assign o_red = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_red : 4'h0;
	assign o_blue = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_blue : 4'h0;
	assign o_green = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_green : 4'h0;
	// end color output assignments
	
endmodule  // VGA_image_gen


			
//			// INDEXING CODE
//				// RUNS ONCE OUT OF CELL SIZE NUMBER OF TIMES WHEN X VARIABLE INCREMENTS
//						// increment for the reading from the matrix
//						if(xindex > cell_count) begin // if we have traversed horizontally
//								xindex <= 0;
//								
//								// RUNS ONCE OUT OF CELL SIZE NUMBER OF TIMES WHEN Y VARIABLE INCREMENTS
//								// increment for the reading from the matrix
//								if(yCounter > cell_size) begin 
//									yCounter <= 0;
//									yindex <= yindex+1;
//								end else if (counter_y > yhold) begin
//									yCounter <= yCounter + 1;
//								end
//						
//						end
//						else if(xCounter > cell_size) begin /// if we are near the end of a cell
//							xCounter <= 0;
//							xindex <= xindex + 1;
//						end 
//						else if( counter_x > xhold) begin								// if we are within a cell
//							xCounter <= xCounter + 1;
//						end
//						xhold = counter_x;
//						yhold = counter_y;
