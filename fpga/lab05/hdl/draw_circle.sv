module draw_circle #(
  parameter WIDTH=128, HEIGHT=128, COLOR=24'hFF_FF_FF)(
  input wire clk_in,
  input wire rst_in,
  input wire valid_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire [10:0] x_in_1,
  input wire [9:0]  y_in_1,
  input wire [10:0] x_in_2,
  input wire [9:0]  y_in_2,
  output logic [83:0] circle_coord,
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out,
  output logic valid_out);

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

  logic [4:0] valid_out_pipeline;

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

        valid_out_pipeline[0] <= valid_in;

        // stage 2
        radius <= (x_2 - x_1) >> 1;
        x_center <= (x_1 + x_2) >> 1;
        y_center <= (y_1 + y_2) >> 1;

        valid_out_pipeline[1] <= valid_out_pipeline[0];

        // stage 3
        x_diff <= (hcount_in >= x_center) ? hcount_in - x_center : x_center - hcount_in;
        y_diff <= (vcount_in >= y_center) ? vcount_in - y_center : y_center - vcount_in;

        valid_out_pipeline[2] <= valid_out_pipeline[1];

        // stage 4
        x_prod <= (x_diff * x_diff);
        y_prod <= (y_diff * y_diff);
        radius_prod <= (radius * radius);

        valid_out_pipeline[3] <= valid_out_pipeline[2];

        // stage 5
        in_circle <= (x_prod + y_prod <= radius_prod);

        valid_out_pipeline[4] <= valid_out_pipeline[3];
    end
  end

  assign circle_coord = {{x_1, y_1}, {x_2, y_2}, 42'b0};
  assign red_out =    in_circle ? COLOR[23:16] : 0;
  assign green_out =  in_circle ? COLOR[15:8] : 0;
  assign blue_out =   in_circle ? COLOR[7:0] : 0;
  assign valid_out = valid_out_pipeline[4];
endmodule
