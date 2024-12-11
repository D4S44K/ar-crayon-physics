module draw_rectangle #(
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
  output logic [83:0] rect_coord,
  output logic in_rect,
  output logic valid_out);

  logic[10:0] x_1;
  logic[9:0] y_1;

  logic[10:0] x_2;
  logic[9:0] y_2;

  logic [3:0] in_rect_pipeline;
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
        in_rect_pipeline[0] <= ((hcount_in >= x_1 && hcount_in < x_2) &&
                      (vcount_in >= y_1 && vcount_in < y_2));

        valid_out_pipeline[1] <= valid_out_pipeline[0];

        // stage 3
        in_rect_pipeline[1] <= in_rect_pipeline[0];

        valid_out_pipeline[2] <= valid_out_pipeline[1];

        // stage 4
        in_rect_pipeline[2] <= in_rect_pipeline[1];

        valid_out_pipeline[3] <= valid_out_pipeline[2];

        // stage 5
        in_rect_pipeline[3] <= in_rect_pipeline[2];

        valid_out_pipeline[4] <= valid_out_pipeline[3];
    end
  end

  assign rect_coord = {{x_1, y_1}, {x_2, y_1}, {x_1, y_2}, {x_2, y_2}};
  assign in_rect = in_rect_pipeline[3];
  assign valid_out = valid_out_pipeline[4];
endmodule
