module Top(
	
	 //////////// CLOCK //////////
   input 	MAX10_CLK1_50,
	
	////////////// VGA /////////////////
	output o_hsync,      		// horizontal sync
	output o_vsync,	     		// vertical sync
	output [3:0] o_red,	
	output [3:0] o_blue,
	output [3:0] o_green,
	
   //////////// 7SEG //////////
   output		     [7:0]		HEX0,
   output		     [7:0]		HEX1,
   output		     [7:0]		HEX2,
   output		     [7:0]		HEX3,
   output		     [7:0]		HEX4,
   output		     [7:0]		HEX5,
	
   //////////// PB //////////
   input 		     [1:0]		PB,

   //////////// LED //////////
   output		     [9:0]		LEDR,

   //////////// SW //////////
   input 		     [9:0]		SW,

   //////////// Accelerometer ports //////////
   output		          		GSENSOR_CS_N,
   input 		     [2:1]		GSENSOR_INT,
   output		          		GSENSOR_SCLK,
   inout 		          		GSENSOR_SDI,
   inout 		          		GSENSOR_SDO
	);
	

///////////////////CONWAY GAME OF LIFE SIMULATION MATRIX SETTINGS////////////////////////////
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// CONWAY GAME OF LIFE - GRID DENSITY ////////////////////////////////////////////////////
	parameter rows = 30 ;/////////////////////////////////////////////////////////////////////
	parameter cols = 40 ; // change to modify density of grid/////////////////////////////////
	parameter matrixIndexLimit = 12; // how many bits to index all cells in matrix?///////////
	//////////////////////////////////////////////////////////////////////////////////////////	

	// GRID CREATION and INDEXING
	wire [rows*cols-1:0] matrix;
	reg [7:0]xindex = 8'd0;	// the indexing for reading from the matrix
	reg [7:0]yindex = 8'd0;
	
	
	wire [3:0] game_fps;
	wire game_clk;
	
	VariableClockDivider vcd(PB[1], clk, game_clk, game_fps); // CHANGES SPEED BASED ON SELECTION
	
	MemoryGrid #(rows, cols, matrixIndexLimit) game(	game_clk, 
													SW[1],		//  SELECT PRESET && CLR GRID
													SW[0],		// GAME ENABLE
													~PB[0] & (SW[9]|SW[1]), 		// WRITE ENABLE (but accelorometer must also be on)
													write_row,
													write_col,
													1,
													matrix,
													SW[5:3]);	// PRESET SELECTION
	
	
	
///////////////////// VGA ///////////////////////////////////////
	
	reg [9:0] counter_x = 0;  // horizontal counter
	reg [9:0] counter_y = 0;  // vertical counter
	reg [3:0] r_red = 0;
	reg [3:0] r_blue = 0;
	reg [3:0] r_green = 0;
	
	parameter xVGA = 799;	// number of clock cycles the vga requires horizontally
	parameter yVGA = 525;	// number of clock cycles the vga requires vertically
	
	wire clk25MHz;
	reg reset = 0;  // for PLL
	ip ip1(.areset(reset),.inclk0(MAX10_CLK1_50),.c0(clk25MHz),.locked());  
	
	always @(posedge clk25MHz) begin
		if (counter_x < 799)				counter_x <= counter_x + 10'd1;
		else									counter_x <= 10'd0;              
	end
	always @ (posedge clk25MHz) begin 
			if (counter_x == 799)
				begin
					if (counter_y < 525)	counter_y <= counter_y + 10'd1;						
					else						counter_y <= 10'd0;              
			end
	end
	
	// hsync and vsync output assignments
	assign o_hsync = (counter_x < 96) ? 1:0;  // hsync high for 96 counts                                                 
	assign o_vsync = (counter_y < 2) ? 1:0;   // vsync high for 2 counts
	// end hsync and vsync output assignments
	
	// BORDER MODIFICATIONS
	parameter ymargin = 20; // border on screen without grid
	parameter xmargin = 20;
	
	// SCREEN VGA LIMITS
	parameter leftEdge = 144;
	parameter rightEdge = 783;
	parameter topEdge = 35;
	parameter bottomEdge = 514;
	
	// // CONWAY GAME OF LIFE GRID - WRITABLE DIMENSIONS
	parameter xstart = leftEdge + xmargin;	
	parameter xend = 	rightEdge - xmargin;
	parameter ystart = topEdge + ymargin;
	parameter yend = bottomEdge - ymargin;
	
	// VISUAL DIMENSIONS ON SCREEN
	parameter cell_sizeX = (xend-xstart)/cols; // since 400 is the total vertical length
	parameter cell_sizeY = (yend-ystart)/rows;
	
	// ACCELOROMETER CELL SELECTION
	reg [5:0] write_row, write_col;
	always @( dataX , dataY) begin
		write_row = dataY;
		write_col = dataX;	
	end
	reg accel_sel;
	
	
	// WRITE TO SCREEN VIA RGB REGISTERS
	always@(posedge clk) begin
		if( counter_y <  yend 	
			& counter_y > ystart 
			& counter_x > xstart 
			& counter_x < xend	) begin

			xindex = (counter_x-xstart)/(cell_sizeX+1);	
			yindex = (counter_y-ystart)/(cell_sizeY+1);			
			
			accel_sel = (yindex == dataY & xindex == dataX);
			
			// DISPLAY VGA COLOR CODE
			r_red = accel_sel * 4'h9 * SW[9]; 
			r_blue = matrix[(cols*yindex)+(xindex)] * 4'h9;
			r_green =  4'h0;
		
		end else begin
			r_red <= 4'hF;    // white
			r_blue <= 4'hF;
			r_green <= 4'hF;
		end
	end

	// only output the colors if the counters are within the adressable video time constraints
	assign o_red = (counter_x > leftEdge && counter_x <= rightEdge && counter_y > topEdge && counter_y <= bottomEdge) ? r_red : 4'h0;
	assign o_blue = (counter_x > leftEdge && counter_x <= rightEdge && counter_y > topEdge && counter_y <= bottomEdge) ? r_blue : 4'h0;
	assign o_green = (counter_x > leftEdge && counter_x <= rightEdge && counter_y > topEdge && counter_y <= bottomEdge) ? r_green : 4'h0;
	
	
////////////////////////// GENERATION CALCULATOR ////////////////////////
reg [3:0] onesDigitGenCalc;
reg [3:0] tensDigitGenCalc;

always@( posedge game_clk) begin
	if( SW[0] ) begin // SW0 == game enable
		
		onesDigitGenCalc  = onesDigitGenCalc == 4'hF ? 0 : onesDigitGenCalc + 4'h1;
		tensDigitGenCalc  = onesDigitGenCalc == 4'hF ? tensDigitGenCalc + 4'h1 : tensDigitGenCalc;
		
	end
end	

////////////////////////// LIVE CELL COUNTER ///////////////////////////

	reg[3:0] cellCount;
	reg[matrixIndexLimit : 0] i;
	always@( posedge game_clk ) begin
		if( SW[0] ) begin // sw0 = game enable
			
			cellCount = 4'h0;
			i = 0;
			// some for loop that calculates stuff maybe?
			
			for( i = 0; i < rows*cols ; i=i+1 )  begin
				cellCount = cellCount + matrix[i];
			end
		
		end
	end
////////////////////////// 7 SEGMENT DISPLAYS ///////////////////////////
	
	SevenSegEncoder w_row(dataX, HEX5); // write row
	SevenSegEncoder w_col(dataY, HEX4); // write col waz here
	
	SevenSegEncoder generationNumberTens ( tensDigitGenCalc, HEX3);
	SevenSegEncoder generationNumberOnes ( onesDigitGenCalc, HEX2);
	
	SevenSegEncoder lifeCount (  cellCount, HEX1);
	
	SevenSegEncoder fps_disp(game_fps, HEX0);
	
/////////////////////////////////////////////////////////////////////////
	//                    ACCELEROMETER 
/////////////////////////////////////////////////////////////////////////
	
//===== Declarations
   localparam SPI_CLK_FREQ  = 200;  // SPI Clock (Hz)
   localparam UPDATE_FREQ   = 1;    // Sampling frequency (Hz)

   // clks and reset
   wire reset_n;
   wire clk, spi_clk, spi_clk_out;

   // output data
   wire data_update;
   wire [15:0] data_x, data_y;

//===== Phase-locked Loop (PLL) instantiation. Code was copied from a module
//      produced by Quartus' IP Catalog tool.
pll pll_inst (
   .inclk0 ( MAX10_CLK1_50 ),
   .c0 ( clk ),                 // 25 MHz, phase   0 degrees
   .c1 ( spi_clk ),             //  2 MHz, phase   0 degrees
   .c2 ( spi_clk_out )          //  2 MHz, phase 270 degrees
   );

//===== Instantiation of the spi_control module which provides the logic to 
//      interface to the accelerometer.
spi_control #(     // parameters
      .SPI_CLK_FREQ   (SPI_CLK_FREQ),
      .UPDATE_FREQ    (UPDATE_FREQ))
   spi_ctrl (      // port connections
      .reset_n    (reset_n),
      .clk        (clk),
      .spi_clk    (spi_clk),
      .spi_clk_out(spi_clk_out),
      .data_update(data_update),
      .data_x     (data_x),
      .data_y     (data_y),
      .SPI_SDI    (GSENSOR_SDI),
      .SPI_SDO    (GSENSOR_SDO),
      .SPI_CSN    (GSENSOR_CS_N),
      .SPI_CLK    (GSENSOR_SCLK),
      .interrupt  (GSENSOR_INT)
   );

//===== Main block
//      To make the module do something visible, the 16-bit data_x is 
//      displayed on four of the HEX displays in hexadecimal format.

// Flipping last switch freezes the accelerometer's output
assign reset_n = SW[9];

reg [3:0]dataY;
reg [3:0]dataX;
parameter sensitivity = 16'd100;	// ACCELEROMETER SENSITIVITY
wire slowclk;
AccelClockDivider acd ( spi_clk , slowclk);

// LOGIC TO MOVE CURSOR ON SCREEN
always@( posedge spi_clk ) begin
	
	if( data_y[15:0] < sensitivity || data_y[15:0] > -sensitivity ) begin
		if(slowclk )dataY = dataY;
	end else if( data_y[15] == 1'b1 ) begin
		if(slowclk )dataY = dataY - 4'b0001;
	end else if( data_y[15] == 1'b0 )begin
		if(slowclk )dataY = dataY + 4'b0001;
	end
	if( data_x[15:0] < sensitivity || data_x[15:0] > -sensitivity ) begin
		if(slowclk) dataX = dataX;
	end else if( data_x[15] == 1'b1 ) begin
		if(slowclk) dataX = dataX + 4'b0001;
	end else if( data_x[15] == 1'b0 )begin
		if(slowclk) dataX = dataX - 4'b0001;
	end
	
end


/////////////////////////SWITCH -> LIGHT ////////////////////////////////
	reg [9:0]sw;
	always@( SW ) begin
		sw[9:0] = SW[9:0];		
	end
	assign LEDR[9:0] = sw[9:0];	// Light will show if a switch is on (helps with demostration and video purposes)


endmodule








module AccelClockDivider(cin, cout);			// SEPERATE CLOCK DIVIDER FOr POINTER SPEED
	input cin;
	output cout;
	reg[19:0] count = 20'd0;                // initializing a register count for 32 bits
	parameter D = 32'd50000000;

	always @( posedge cin)                    // make the following code sensitive to change in cin
	begin
		 count <= count + 20'd15;                // add 1 to the counter
		 if (count > D)                        // if the counter has reached 50 Mil + 1, then set value to 0
			  count <= 20'd0;
	end
	assign cout = (count == 0) ? 1'b1 : 1'b0; // if count is < 25 mil, output 0, else 1

endmodule
