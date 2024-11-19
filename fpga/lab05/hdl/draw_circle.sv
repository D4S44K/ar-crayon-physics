module draw_circle #(
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

  logic[10:0] x_center;
  logic[9:0] y_center;
  logic[10:0] radius;

  logic[10:0] x_diff;
  logic[9:0] y_diff;

  logic in_circle;

  logic[31:0] x_prod;
  logic[31:0] y_prod;
  logic[31:0] radius_prod;

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
        radius <= (x_2 - x_1) >> 1;
        x_center <= (x_1 + x_2) >> 1;//fix
        y_center <= y_1;

        // stage 3
        x_diff <= (hcount_in >= x_center) ? hcount_in - x_center : x_center - hcount_in;
        y_diff <= (vcount_in >= y_center) ? vcount_in - y_center : y_center - vcount_in;

        // stage 4
        x_prod <= (x_diff * x_diff);
        y_prod <= (y_diff * y_diff);
        radius_prod <= (radius * radius);

        // stage 5
        in_circle <= (x_prod + y_prod <= radius_prod);
    end
  end

  assign red_out =    in_circle ? COLOR[23:16] : 0;
  assign green_out =  in_circle ? COLOR[15:8] : 0;
  assign blue_out =   in_circle ? COLOR[7:0] : 0;
endmodule
