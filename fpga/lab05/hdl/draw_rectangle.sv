module draw_rectangle #(
  parameter WIDTH=128, HEIGHT=128, COLOR=24'hFF_FF_FF)(
  input wire clk_in,
  input wire rst_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire [10:0] x_in_1,
  input wire [9:0]  y_in_1,
  input wire [10:0] x_in_2,
  input wire [9:0]  y_in_2,
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out);

  logic[10:0] x_1;
  logic[9:0] y_1;

  logic[10:0] x_2;
  logic[9:0] y_2;

  logic in_sprite;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
    //   red_out <= 0;
    //   green_out <= 0;
    //   blue_out <= 0;
    end else begin
        // stage 1
        x_1 <= (x_in_1 <= x_in_2) ? x_in_1 : x_in_2;
        y_1 <= (y_in_1 <= y_in_2) ? y_in_1 : y_in_2;

        x_2 <= (x_in_1 >= x_in_2) ? x_in_1 : x_in_2;
        y_2 <= (y_in_1 >= y_in_2) ? y_in_1 : y_in_2;

        // stage 2
        in_sprite <= ((hcount_in >= x_1 && hcount_in < x_2) &&
                      (vcount_in >= y_1 && vcount_in < y_2));
    end
  end

  assign red_out =    in_sprite ? COLOR[23:16] : 0;
  assign green_out =  in_sprite ? COLOR[15:8] : 0;
  assign blue_out =   in_sprite ? COLOR[7:0] : 0;
endmodule
