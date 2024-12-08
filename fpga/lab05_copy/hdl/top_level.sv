`timescale 1ns / 1ps
`default_nettype none

module top_level
  (
   input wire          clk_100mhz,
   output logic [15:0] led,
  //  // camera bus
  //  input wire [7:0]    camera_d, // 8 parallel data wires
  //  output logic        cam_xclk, // XC driving camera
  //  input wire          cam_hsync, // camera hsync wire
  //  input wire          cam_vsync, // camera vsync wire
  //  input wire          cam_pclk, // camera pixel clock
  //  inout wire          i2c_scl, // i2c inout clock
  //  inout wire          i2c_sda, // i2c inout data
   input wire [15:0]   sw,
  input wire [3:0]    btn
  //  output logic [2:0]  rgb0,
  //  output logic [2:0]  rgb1,
  //  // seven segment
  //  output logic [3:0]  ss0_an,//anode control for upper four digits of seven-seg display
  //  output logic [3:0]  ss1_an,//anode control for lower four digits of seven-seg display
  //  output logic [6:0]  ss0_c, //cathode controls for the segments of upper four digits
  //  output logic [6:0]  ss1_c, //cathod controls for the segments of lower four digits
  //  // hdmi port
  //  output logic [2:0]  hdmi_tx_p, //hdmi output signals (positives) (blue, green, red)
  //  output logic [2:0]  hdmi_tx_n, //hdmi output signals (negatives) (blue, green, red)
  //  output logic        hdmi_clk_p, hdmi_clk_n //differential hdmi clock
   );

  logic rst_in;
  // shut up those RGBs

  assign rst_in = btn[0];
  assign led = circle_x1s[0] + circle_x2s[1] + circle_y1s[2] + circle_y2s[3] + circle_red[4] + circle_green[5] + circle_blue[6] +
                line_x1[0] + line_x2[1] + line_y1[2] + line_y2[3] + line_red[4] + line_green[5] + line_blue[6] + 
                rect_x1[0] + rect_x2[1] + rect_y1[2] + rect_y2[3] + rect_red[4] + rect_green[5] + rect_blue[6];
 
  logic [7:0][10:0] circle_x1s;
  logic [7:0][10:0] circle_x2s;
  logic [7:0][9:0] circle_y1s;
  logic [7:0][9:0] circle_y2s;
  logic [7:0][7:0] circle_red;
  logic [7:0][7:0] circle_green;
  logic [7:0][7:0] circle_blue;

  logic [6:0][10:0] line_x1;
  logic [6:0][10:0] line_x2;
  logic [6:0][9:0] line_y1;
  logic [6:0][9:0] line_y2;
  logic [6:0][7:0] line_red;
  logic [6:0][7:0] line_green;
  logic [6:0][7:0] line_blue;

  logic [6:0][10:0] rect_x1;
  logic [6:0][10:0] rect_x2;
  logic [6:0][9:0] rect_y1;
  logic [6:0][9:0] rect_y2;
  logic [6:0][7:0] rect_red;
  logic [6:0][7:0] rect_green;
  logic [6:0][7:0] rect_blue;


//   input wire clk_in,
//   input wire rst_in,
//   input wire [10:0] hcount_in,
//   input wire [9:0] vcount_in,
//   input wire [10:0] x_in_1,
//   input wire [9:0]  y_in_1,
//   input wire [10:0] x_in_2,
//   input wire [9:0]  y_in_2,
//   input wire place_obj,
//   output logic [10:0] circle_x1,
//   output logic [9:0]  circle_y1,
//   output logic [10:0] circle_x2,
//   output logic [9:0]  circle_y2,
//   output logic [7:0] red_out,
//   output logic [7:0] green_out,
//   output logic [7:0] blue_out

  draw_circle ball(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .circle_x1(circle_x1s[0]),
    .circle_y1(circle_y1s[0]),
    .circle_x2(circle_x2s[0]),
    .circle_y2(circle_y2s[0]),
    .red_out(circle_red[0]),
    .green_out(circle_green[0]),
    .blue_out(circle_blue[0])
  );

    draw_circle ball2(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .circle_x1(circle_x1s[1]),
    .circle_y1(circle_y1s[1]),
    .circle_x2(circle_x2s[1]),
    .circle_y2(circle_y2s[1]),
    .red_out(circle_red[1]),
    .green_out(circle_green[1]),
    .blue_out(circle_blue[1])
  );

    draw_circle ball3(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .circle_x1(circle_x1s[2]),
    .circle_y1(circle_y1s[2]),
    .circle_x2(circle_x2s[2]),
    .circle_y2(circle_y2s[2]),
    .red_out(circle_red[2]),
    .green_out(circle_green[2]),
    .blue_out(circle_blue[2])
  );

    draw_circle ball4(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .circle_x1(circle_x1s[3]),
    .circle_y1(circle_y1s[3]),
    .circle_x2(circle_x2s[3]),
    .circle_y2(circle_y2s[3]),
    .red_out(circle_red[3]),
    .green_out(circle_green[3]),
    .blue_out(circle_blue[3])
  );

    draw_circle ball5(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .circle_x1(circle_x1s[4]),
    .circle_y1(circle_y1s[4]),
    .circle_x2(circle_x2s[4]),
    .circle_y2(circle_y2s[4]),
    .red_out(circle_red[4]),
    .green_out(circle_green[4]),
    .blue_out(circle_blue[4])
  );

    draw_circle ball6(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .circle_x1(circle_x1s[5]),
    .circle_y1(circle_y1s[5]),
    .circle_x2(circle_x2s[5]),
    .circle_y2(circle_y2s[5]),
    .red_out(circle_red[5]),
    .green_out(circle_green[5]),
    .blue_out(circle_blue[5])
  );

    draw_circle ball7(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .circle_x1(circle_x1s[6]),
    .circle_y1(circle_y1s[6]),
    .circle_x2(circle_x2s[6]),
    .circle_y2(circle_y2s[6]),
    .red_out(circle_red[6]),
    .green_out(circle_green[6]),
    .blue_out(circle_blue[6])
  );

    draw_circle ball8(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .circle_x1(circle_x1s[7]),
    .circle_y1(circle_y1s[7]),
    .circle_x2(circle_x2s[7]),
    .circle_y2(circle_y2s[7]),
    .red_out(circle_red[7]),
    .green_out(circle_green[7]),
    .blue_out(circle_blue[7])
  );

//   input wire clk_in,
//   input wire rst_in,
//   input wire [10:0] hcount_in,
//   input wire [9:0] vcount_in,
//   input wire [10:0] x_in_1,
//   input wire [9:0]  y_in_1,
//   input wire [10:0] x_in_2,
//   input wire [9:0]  y_in_2,
//   input wire place_obj,
//   output logic [10:0] line_x1,
//   output logic [9:0]  line_y1,
//   output logic [10:0] line_x2,
//   output logic [9:0]  line_y2,
//   output logic [7:0] red_out,
//   output logic [7:0] green_out,
//   output logic [7:0] blue_out

  draw_line line(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .line_x1(line_x1[0]),
    .line_y1(line_y1[0]),
    .line_x2(line_x2[0]),
    .line_y2(line_y2[0]),
    .red_out(line_red[0]),
    .green_out(line_green[0]),
    .blue_out(line_blue[0])
  );

    draw_line line2(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .line_x1(line_x1[1]),
    .line_y1(line_y1[1]),
    .line_x2(line_x2[1]),
    .line_y2(line_y2[1]),
    .red_out(line_red[1]),
    .green_out(line_green[1]),
    .blue_out(line_blue[1])
  );

    draw_line line3(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .line_x1(line_x1[2]),
    .line_y1(line_y1[2]),
    .line_x2(line_x2[2]),
    .line_y2(line_y2[2]),
    .red_out(line_red[2]),
    .green_out(line_green[2]),
    .blue_out(line_blue[2])
  );

    draw_line line4(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .line_x1(line_x1[3]),
    .line_y1(line_y1[3]),
    .line_x2(line_x2[3]),
    .line_y2(line_y2[3]),
    .red_out(line_red[3]),
    .green_out(line_green[3]),
    .blue_out(line_blue[3])
  );

    draw_line line5(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .line_x1(line_x1[4]),
    .line_y1(line_y1[4]),
    .line_x2(line_x2[4]),
    .line_y2(line_y2[4]),
    .red_out(line_red[4]),
    .green_out(line_green[4]),
    .blue_out(line_blue[4])
  );

    draw_line line6(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .line_x1(line_x1[5]),
    .line_y1(line_y1[5]),
    .line_x2(line_x2[5]),
    .line_y2(line_y2[5]),
    .red_out(line_red[5]),
    .green_out(line_green[5]),
    .blue_out(line_blue[5])
  );

    draw_line line7(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .line_x1(line_x1[6]),
    .line_y1(line_y1[6]),
    .line_x2(line_x2[6]),
    .line_y2(line_y2[6]),
    .red_out(line_red[6]),
    .green_out(line_green[6]),
    .blue_out(line_blue[6])
  );

    draw_rectangle rect(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .rect_x1(rect_x1[0]),
    .rect_y1(rect_y1[0]),
    .rect_x2(rect_x2[0]),
    .rect_y2(rect_y2[0]),
    .red_out(rect_red[0]),
    .green_out(rect_green[0]),
    .blue_out(rect_blue[0])
  );

      draw_rectangle rect2(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .rect_x1(rect_x1[1]),
    .rect_y1(rect_y1[1]),
    .rect_x2(rect_x2[1]),
    .rect_y2(rect_y2[1]),
    .red_out(rect_red[1]),
    .green_out(rect_green[1]),
    .blue_out(rect_blue[1])
  );

      draw_rectangle rect3(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .rect_x1(rect_x1[2]),
    .rect_y1(rect_y1[2]),
    .rect_x2(rect_x2[2]),
    .rect_y2(rect_y2[2]),
    .red_out(rect_red[2]),
    .green_out(rect_green[2]),
    .blue_out(rect_blue[2])
  );

      draw_rectangle rect4(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .rect_x1(rect_x1[3]),
    .rect_y1(rect_y1[3]),
    .rect_x2(rect_x2[3]),
    .rect_y2(rect_y2[3]),
    .red_out(rect_red[3]),
    .green_out(rect_green[3]),
    .blue_out(rect_blue[3])
  );

      draw_rectangle rect5(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .rect_x1(rect_x1[4]),
    .rect_y1(rect_y1[4]),
    .rect_x2(rect_x2[4]),
    .rect_y2(rect_y2[4]),
    .red_out(rect_red[4]),
    .green_out(rect_green[4]),
    .blue_out(rect_blue[4])
  );

      draw_rectangle rect6(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .rect_x1(rect_x1[5]),
    .rect_y1(rect_y1[5]),
    .rect_x2(rect_x2[5]),
    .rect_y2(rect_y2[5]),
    .red_out(rect_red[5]),
    .green_out(rect_green[5]),
    .blue_out(rect_blue[5])
  );

      draw_rectangle rect7(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(sw[10:0]),
    .vcount_in(sw[9:0]),
    .x_in_1(sw[10:0]),
    .y_in_1(sw[9:0]),
    .x_in_2(sw[10:0]),
    .y_in_2(sw[9:0]),
    .place_obj(1),
    .rect_x1(rect_x1[6]),
    .rect_y1(rect_y1[6]),
    .rect_x2(rect_x2[6]),
    .rect_y2(rect_y2[6]),
    .red_out(rect_red[6]),
    .green_out(rect_green[6]),
    .blue_out(rect_blue[6])
  );

endmodule // top_level


`default_nettype wire
