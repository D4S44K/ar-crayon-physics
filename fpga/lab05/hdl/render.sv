module render 
(
    input wire clk_in,
    input wire valid_in,
    input wire rst_in,
    input wire [3:0] is_static,
    input wire [3:0][6:0] current_addresses,
    input wire [3:0][1:0] id_bits,
    input wire [3:0][35:0] params,
    input wire [3:0][15:0] pos_x,
    input wire [3:0][15:0] pos_y,
    input wire [3:0][15:0] vel_x,
    input wire [3:0][15:0] vel_y,
    
    output logic busy_out,
    output logic valid_out
);

    enum e_states = {IDLE, PROCESSING_FIRST_SET, DONE_FIRST_SET, PROCESSING_SECOND_SET};
    e_states state;
    logic [3:0][10:0] x_in_1s;
    logic [3:0][9:0] y_in_1s;
    logic [3:0][10:0] x_in_2s;
    logic [3:0][9:0] y_in_2s;

    draw_circle ball(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .valid_in(ball_1_ready),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in_1(x_in_1s[0]),
    .y_in_1(y_in_1s[0]),
    .x_in_2(x_in_2s[0]),
    .y_in_2(y_in_2s[0]),
    .place_obj(1),
    .circle_x1(circle_x1s[0]),
    .circle_y1(circle_y1s[0]),
    .circle_x2(circle_x2s[0]),
    .circle_y2(circle_y2s[0]),
    .red_out(circle_red[0]),
    .green_out(circle_green[0]),
    .blue_out(circle_blue[0]),
    .valid_out(ball_1_drawn)
  );

  /*
      input wire [114:0] object_props,
    output logic is_static,
    output logic [10:0] x_in_1,
    output logic [9:0] y_in_1,
    output logic [10:0] x_in_2,
    output logic [9:0] y_in_2
  */

  circle_converter ball_converter (
    .is_static(is_static[0]),
    .is_valid_in(id_bits[0] == b01),
    .x_in_1(x_in_1s[0]),
    .y_in_1(y_in_1s[0]),
    .x_in_2(x_in_2s[0]),
    .y_in_2(y_in_2s[0]),
    .is_valid_out(ball_1_ready)
  );

    draw_circle ball2(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
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

    circle_converter ball2_converter (
    .is_static(is_static[1]),
    .is_valid_in(id_bits[1] == b01),
    .x_in_1(x_in_1s[1]),
    .y_in_1(y_in_1s[1]),
    .x_in_2(x_in_2s[1]),
    .y_in_2(y_in_2s[1]),
    .is_valid_out(ball_2_ready)
  );

    draw_circle ball3(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
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

    circle_converter ball_converter (
    .is_static(is_static[0]),
    .is_valid_in(id_bits[0] == b01),
    .x_in_1(x_in_1s[0]),
    .y_in_1(y_in_1s[0]),
    .x_in_2(x_in_2s[0]),
    .y_in_2(y_in_2s[0]),
    .is_valid_out(ball_1_ready)
  );

    draw_circle ball4(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
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

    circle_converter ball_converter (
    .is_static(is_static[0]),
    .is_valid_in(id_bits[0] == b01),
    .x_in_1(x_in_1s[0]),
    .y_in_1(y_in_1s[0]),
    .x_in_2(x_in_2s[0]),
    .y_in_2(y_in_2s[0]),
    .is_valid_out(ball_1_ready)
  );

  draw_line line(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
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

    circle_converter ball_converter (
    .is_static(is_static[0]),
    .is_valid_in(id_bits[0] == b01),
    .x_in_1(x_in_1s[0]),
    .y_in_1(y_in_1s[0]),
    .x_in_2(x_in_2s[0]),
    .y_in_2(y_in_2s[0]),
    .is_valid_out(ball_1_ready)
  );

    draw_line line2(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
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

    circle_converter ball_converter (
    .is_static(is_static[0]),
    .is_valid_in(id_bits[0] == b01),
    .x_in_1(x_in_1s[0]),
    .y_in_1(y_in_1s[0]),
    .x_in_2(x_in_2s[0]),
    .y_in_2(y_in_2s[0]),
    .is_valid_out(ball_1_ready)
  );

    draw_line line3(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
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

    circle_converter ball_converter (
    .is_static(is_static[0]),
    .is_valid_in(id_bits[0] == b01),
    .x_in_1(x_in_1s[0]),
    .y_in_1(y_in_1s[0]),
    .x_in_2(x_in_2s[0]),
    .y_in_2(y_in_2s[0]),
    .is_valid_out(ball_1_ready)
  );

    draw_line line4(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
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

    circle_converter ball_converter (
    .is_static(is_static[0]),
    .is_valid_in(id_bits[0] == b01),
    .x_in_1(x_in_1s[0]),
    .y_in_1(y_in_1s[0]),
    .x_in_2(x_in_2s[0]),
    .y_in_2(y_in_2s[0]),
    .is_valid_out(ball_1_ready)
  );

  draw_rectangle rect(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
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

    circle_converter ball_converter (
    .is_static(is_static[0]),
    .is_valid_in(id_bits[0] == b01),
    .x_in_1(x_in_1s[0]),
    .y_in_1(y_in_1s[0]),
    .x_in_2(x_in_2s[0]),
    .y_in_2(y_in_2s[0]),
    .is_valid_out(ball_1_ready)
  );

      draw_rectangle rect2(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
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

    circle_converter ball_converter (
    .is_static(is_static[0]),
    .is_valid_in(id_bits[0] == b01),
    .x_in_1(x_in_1s[0]),
    .y_in_1(y_in_1s[0]),
    .x_in_2(x_in_2s[0]),
    .y_in_2(y_in_2s[0]),
    .is_valid_out(ball_1_ready)
  );

      draw_rectangle rect3(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
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

    circle_converter ball_converter (
    .is_static(is_static[0]),
    .is_valid_in(id_bits[0] == b01),
    .x_in_1(x_in_1s[0]),
    .y_in_1(y_in_1s[0]),
    .x_in_2(x_in_2s[0]),
    .y_in_2(y_in_2s[0]),
    .is_valid_out(ball_1_ready)
  );

      draw_rectangle rect4(
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
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

    circle_converter ball_converter (
    .is_static(is_static[0]),
    .is_valid_in(id_bits[0] == b01),
    .x_in_1(x_in_1s[0]),
    .y_in_1(y_in_1s[0]),
    .x_in_2(x_in_2s[0]),
    .y_in_2(y_in_2s[0]),
    .is_valid_out(ball_1_ready)
  );

    always_comb begin

    end
    
    always_ff@(posedge clk_in) begin
        // initialize 12 modules at a time
        // based on the four shapes that come in, pass into the correct module with hcount/vcount
        // every few cycles, get out a color answer. render module will store values for isstatic/notisstatic
        // hold this unitl you get the second output (so this is blocking / state machine setup)
        // or the outputs of every shape
        // spit out the color value and send to outer hdmi/render connector module
        // map to hcount/2, vcount/2 (store at hc + 320vc) and store in frame buffer
        // in hdmi/render connector module, we map the address back up to full resolution and put in the color.
    end


    
    // finite state machine checking whether or not new data can be received / if we have reached the end of addresses.
    // every time a new set of four addresses is received, check the id type and pass it to the appropriate render_type module.
    // each render_type module writes to the frame buffer as all of the points in the 
endmodule