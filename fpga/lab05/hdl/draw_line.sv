module draw_line #(
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
  output logic [83:0] line_coord,
  output logic in_line,
  output logic valid_out);

  logic[10:0] x_1;
  logic[9:0] y_1;

  logic[10:0] x_2;
  logic[9:0] y_2;

  logic in_line_pipeline;

  logic signed[11:0] hcount_diff;
  logic signed[10:0] vcount_diff;

  logic signed[11:0] x_diff;
  logic signed[10:0] y_diff;

  logic signed[32:0] slope_mul_1;
  logic signed[32:0] slope_mul_2;

  logic within_500_greater;
  logic within_500_less;

  logic [4:0] valid_out_pipeline;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
    //   red_out <= 0;
    //   green_out <= 0;
    //   blue_out <= 0;
    end else begin
        // stage 1
        x_1 <= (x_in_1 <= x_in_2) ? x_in_1 : x_in_2;
        x_2 <= (x_in_1 > x_in_2) ? x_in_1 : x_in_2;

        valid_out_pipeline[0] <= valid_in;

        // stage 2
        y_1 <= (x_1 == x_in_1) ? y_in_1 : y_in_2;
        y_2 <= (x_2 == x_in_2) ? y_in_2 : y_in_1;

        valid_out_pipeline[1] <= valid_out_pipeline[0];

        // stage 3
        hcount_diff <= hcount_in - x_1;
        x_diff <= x_2 - x_1;
        vcount_diff <= vcount_in - y_1;
        y_diff <= y_2 - y_1;

        valid_out_pipeline[2] <= valid_out_pipeline[1];

        // stage 4
        slope_mul_1 <= vcount_diff * x_diff;
        slope_mul_2 <= hcount_diff * y_diff;

        valid_out_pipeline[3] <= valid_out_pipeline[2];

        // stage 5
        in_line_pipeline <= ((hcount_in >= x_1 && hcount_in <= x_2))
                   ? ((slope_mul_1 >= slope_mul_2) ? slope_mul_1 - 500 <= slope_mul_2 : 0) || ((slope_mul_1 <= slope_mul_2) ? slope_mul_1 + 500 >= slope_mul_2 : 0)
                   : 0;

        valid_out_pipeline[4] <= valid_out_pipeline[3];
    end
  end

  assign line_coord = {{x_1, y_1}, {x_2, y_2}, 42'b0};
  assign in_line = in_line_pipeline;
  assign valid_out = valid_out_pipeline[4];
endmodule
