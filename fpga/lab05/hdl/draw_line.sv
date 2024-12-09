module draw_line #(
    parameter WIDTH=128, HEIGHT=128, COLOR=24'hFF_FF_FF)(
      input wire clk_in,
      input wire rst_in,
      input wire is_valid_in,
      input wire [10:0] hcount_in,
      input wire [9:0] vcount_in,
      input wire [10:0] x_in_1,
      input wire [9:0]  y_in_1,
      input wire [10:0] x_in_2,
      input wire [9:0]  y_in_2,
      output logic [83:0] line_coord,
      output logic [7:0] red_out,
      output logic [7:0] green_out,
      output logic [7:0] blue_out,
      output logic is_valid_out);

  logic[10:0] x_1;
  logic[9:0] y_1;

  logic[10:0] x_2;
  logic[9:0] y_2;

  logic in_line;


  logic signed[11:0] hcount_diff;
  logic signed[10:0] vcount_diff;

  logic signed[11:0] x_diff;
  logic signed[10:0] y_diff;

  logic signed[32:0] slope_mul_1;
  logic signed[32:0] slope_mul_2;

  logic within_500_greater;
  logic within_500_less;

  logic [1:0][10:0] hcount_pipelined;
  logic [1:0][9:0] vcount_pipelined;

  logic [3:0] valid_in_pipelined;

  logic [83:0] line_coord_pipeline;
  logic [7:0] red_out_pipeline;
  logic [7:0] green_out_pipeline;
  logic [7:0] blue_out_pipeline;

  always_comb
  begin
    slope_mul_1 = vcount_diff * x_diff;
    slope_mul_2 = hcount_diff * y_diff;

    within_500_greater = (slope_mul_1 >= slope_mul_2) ? slope_mul_1 - 500 <= slope_mul_2 : 0;
    within_500_less = (slope_mul_1 <= slope_mul_2) ? slope_mul_1 + 500 >= slope_mul_2 : 0;
    in_line = (hcount_pipelined[1] >= x_1 && hcount_pipelined[1] <= x_2) ? within_500_greater || within_500_less : 0;
  end

  always_ff@(posedge clk_in)
  begin
    if(rst_in)
    begin
      is_valid_out <= 0;
      valid_in_pipelined[0] <= 0;
      valid_in_pipelined[1] <= 0;
      valid_in_pipelined[2] <= 0;
      valid_in_pipelined[3] <= 0;
      valid_in_pipelined[4] <= 0;
    end
    else if(is_valid_in)
    begin
      hcount_pipelined[1] <= hcount_pipelined[0];
      hcount_pipelined[0] <= hcount_in;

      vcount_pipelined[1] <= vcount_pipelined[0];
      vcount_pipelined[0] <= vcount_in;

      valid_in_pipelined[0] <= is_valid_in;
      valid_in_pipelined[1] <= valid_in_pipelined[0];
      valid_in_pipelined[2] <= valid_in_pipelined[1];
      valid_in_pipelined[3] <= valid_in_pipelined[2];
      is_valid_out <= valid_in_pipelined[3];
      // stage 1
      x_1 <= (x_in_1 <= x_in_2) ? x_in_1 : x_in_2;
      x_2 <= (x_in_1 > x_in_2) ? x_in_1 : x_in_2;
    end

    // stage 2
    y_1 <= (x_1 == x_in_1) ? y_in_1 : y_in_2;
    y_2 <= (x_2 == x_in_2) ? y_in_2 : y_in_1;

    // stage 3
    if ((hcount_pipelined[1] >= x_1 && hcount_pipelined[1] <= x_2))
    begin
      hcount_diff <= hcount_pipelined[1] - x_1;
      x_diff <= x_2 - x_1;
      vcount_diff <= vcount_pipelined[1] - y_1;
      y_diff <= y_2 - y_1;
    end
    // stage 4
    line_coord_pipeline <= {{x_1, y_1}, {x_2, y_2}, 42'b0};
    red_out_pipeline    <= in_line ? COLOR[23:16] : 0;
    green_out_pipeline  <= in_line ? COLOR[15:8] : 0;
    blue_out_pipeline   <= in_line ? COLOR[7:0] : 0;

    // stage 5
    line_coord <= line_coord_pipeline;
    red_out <= red_out_pipeline;
    green_out <= green_out_pipeline;
    blue_out <= blue_out_pipeline;
  end

  // assign line_coord = {{x_1, y_1}, {x_2, y_2}, 42'b0};
  // assign red_out   = in_line ? COLOR[23:16] : 0;
  // assign green_out = in_line ? COLOR[15:8] : 0;
  // assign blue_out  = in_line ? COLOR[7:0] : 0;
endmodule
