module VariableClockDivider(clk_bttn, cin, cout, game_fpsOut);

    input cin, clk_bttn;
    output cout;
    output [3:0]game_fpsOut;           // for display


    reg[31:0] count = 32'd0;                // initializing a register count for 32 bits
    parameter D = 32'd50000000;

    reg [31:0]game_fps = 32'd1;
    always @(posedge clk_bttn) begin
         case(game_fps)
              32'd1: game_fps = 32'd3;
              32'd3: game_fps = 32'd5;
              32'd5: game_fps = 32'd9;
              32'd9: game_fps = 32'd15;
              32'd15: game_fps = 32'd31;
              32'd31: game_fps = 32'd63;
              32'd63: game_fps = 32'd127;
              32'd127: game_fps = 32'd199;
              32'd199: game_fps = 32'd255;
              32'd255: game_fps = 32'd1;
         endcase
    end


    always @( posedge cin)                    // make the following code sensitive to change in cin
    begin
         count <= count + game_fps;                // add 1 to the counter
         if (count > D)                        // if the counter has reached 50 Mil + 1, then set value to 0
              count <= 32'd0;
    end

    assign cout = (count == 0) ? 1'b1 : 1'b0; // if count is < 25 mil, output 0, else 1
    assign game_fpsOut = game_fps[3:0];    // display

endmodule