module render 
(
    input wire clk_in,
    input wire valid_in,
    input wire rst_in,
    // parameters for up to four objects at a time being passed in from object storage
    input wire [3:0] is_static,
    input wire [3:0][6:0] current_addresses,
    input wire [3:0][1:0] id_bits,
    input wire [3:0][35:0] params,
    input wire [3:0][15:0] pos_x,
    input wire [3:0][15:0] pos_y,
    input wire [3:0][15:0] vel_x,
    input wire [3:0][15:0] vel_y,

    // pixel coordinate that we are querying
    input wire [10:0] hcount_in,
    input wire [9:0] vcount_in,

    // resulting color
    // output logic [7:0] red_out,
    // output logic [7:0] green_out,
    // output logic [7:0] blue_out,
    output logic [1:0] color_bits,

    // write location to frame buffer
    output logic [18:0] write_address,

    // output logic busy_out, // todo remove
    output logic valid_out
);

    localparam STATIC_COLOR = 24'h11_11_11;
    localparam NOT_STATIC_COLOR = 24'h77_77_77;

    logic [11:0][10:0] x_in_1s;
    logic [11:0][9:0] y_in_1s;
    logic [11:0][10:0] x_in_2s;
    logic [11:0][9:0] y_in_2s;
    // 00: black, 01: color it static, 10: color it movable, 11: n/a right now
    logic [3:0][23:0] colors;
    logic [11:0][7:0] reds_out;
    logic [11:0][7:0] greens_out;
    logic [11:0][7:0] blues_out;
    logic [11:0][83:0] obj_coord;
    

    draw_circle #(.COLORS(colors[0])) ball(
    .is_valid_in(is_shape_ready[0]),
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in_1(x_in_1s[0]),
    .y_in_1(y_in_1s[0]),
    .x_in_2(x_in_2s[0]),
    .y_in_2(y_in_2s[0]),
    .circle_coord(obj_coord[0]),
    .red_out(reds_out[0]),
    .green_out(greens_out[0]),
    .blue_out(reds_out[0]),
    .is_valid_out(is_shape_drawn[0])
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
    .is_valid_in(id_bits[0] == b01 && valid_in),
    .x_in_1(x_in_1s[0]),
    .y_in_1(y_in_1s[0]),
    .x_in_2(x_in_2s[0]),
    .y_in_2(y_in_2s[0]),
    .is_valid_out(is_shape_ready[0])
  );

    draw_circle #(.COLORS(colors[1])) ball2(
    .is_valid_in(is_shape_ready[1]),
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in_1(x_in_1s[1]),
    .y_in_1(y_in_1s[1]),
    .x_in_2(x_in_2s[1]),
    .y_in_2(y_in_2s[1]),
    .circle_coord(obj_coord[1]),
    .red_out(reds_out[1]),
    .green_out(greens_out[1]),
    .blue_out(reds_out[1]),
    .is_valid_out(is_shape_drawn[1])
  );

    circle_converter ball2_converter (
    .is_static(is_static[1] && valid_in),
    .is_valid_in(id_bits[1] == b01),
    .x_in_1(x_in_1s[1]),
    .y_in_1(y_in_1s[1]),
    .x_in_2(x_in_2s[1]),
    .y_in_2(y_in_2s[1]),
    .is_valid_out(is_shape_ready[1])
  );

    draw_circle #(.COLORS(colors[2])) ball3(
    .is_valid_in(is_shape_ready[2]),
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in_1(x_in_1s[2]),
    .y_in_1(y_in_1s[2]),
    .x_in_2(x_in_2s[2]),
    .y_in_2(y_in_2s[2]),
    .circle_coord(obj_coord[2]),
    .red_out(reds_out[2]),
    .green_out(greens_out[2]),
    .blue_out(reds_out[2]),
    .is_valid_out(is_shape_drawn[2])
  );

    circle_converter ball3_converter (
    .is_static(is_static[2]),
    .is_valid_in(id_bits[2] == b01 && valid_in),
    .x_in_1(x_in_1s[2]),
    .y_in_1(y_in_1s[2]),
    .x_in_2(x_in_2s[2]),
    .y_in_2(y_in_2s[2]),
    .is_valid_out(is_shape_ready[2])
  );

    draw_circle #(.COLORS(colors[3])) ball4(
    .is_valid_in(is_shape_ready[3]),
    .clk_in(clk_100mhz),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in_1(x_in_1s[3]),
    .y_in_1(y_in_1s[3]),
    .x_in_2(x_in_2s[3]),
    .y_in_2(y_in_2s[3]),
    .circle_coord(obj_coord[3]),
    .red_out(reds_out[3]),
    .green_out(greens_out[3]),
    .blue_out(reds_out[3]),
    .is_valid_out(is_shape_drawn[3])
  );

    circle_converter ball4_converter (
    .is_static(is_static[3]),
    .is_valid_in(id_bits[3] == b01 && valid_in),
    .x_in_1(x_in_1s[3]),
    .y_in_1(y_in_1s[3]),
    .x_in_2(x_in_2s[3]),
    .y_in_2(y_in_2s[3]),
    .is_valid_out(is_shape_drawn[3])
  );

//     draw_line #(.COLORS(colors[0])) line(
//     .is_valid_in(is_shape_ready[4] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[4]),
//     .y_in_1(y_in_1s[4]),
//     .x_in_2(x_in_2s[4]),
//     .y_in_2(y_in_2s[4]),
//     .line_coord(obj_coord[4]),
//     .red_out(reds_out[4]),
//     .green_out(greens_out[4]),
//     .blue_out(reds_out[4]),
//     .is_valid_out(is_shape_drawn[4])
//   );

//     line_converter line_converter (
//     .is_static(is_static[0]),
//     .is_valid_in(id_bits[0] == b10 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[4]),
//     .y_in_1(y_in_1s[4]),
//     .x_in_2(x_in_2s[4]),
//     .y_in_2(y_in_2s[4]),
//     .is_valid_out(is_shape_ready[4])
//   );

//     draw_line #(.COLORS(colors[1])) line2(
//     .is_valid_in(is_shape_ready[5] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[5]),
//     .y_in_1(y_in_1s[5]),
//     .x_in_2(x_in_2s[5]),
//     .y_in_2(y_in_2s[5]),
//     .line_coord(obj_coord[5]),
//     .red_out(reds_out[5]),
//     .green_out(greens_out[5]),
//     .blue_out(reds_out[5]),
//     .is_valid_out(is_shape_drawn[5])
//   );

//     line_converter line2_converter (
//     .is_static(is_static[1]),
//     .is_valid_in(id_bits[1] == b10 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[5]),
//     .y_in_1(y_in_1s[5]),
//     .x_in_2(x_in_2s[5]),
//     .y_in_2(y_in_2s[5]),
//     .is_valid_out(is_shape_ready[5])
//   );

//     draw_line #(.COLORS(colors[2])) line3(
//     .is_valid_in(is_shape_ready[6] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[6]),
//     .y_in_1(y_in_1s[6]),
//     .x_in_2(x_in_2s[6]),
//     .y_in_2(y_in_2s[6]),
//     .line_coord(obj_coord[6]),
//     .red_out(reds_out[6]),
//     .green_out(greens_out[6]),
//     .blue_out(reds_out[6]),
//     .is_valid_out(is_shape_drawn[6])
//   );

//     line_converter line3_converter (
//     .is_static(is_static[2]),
//     .is_valid_in(id_bits[2] == b10 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[6]),
//     .y_in_1(y_in_1s[6]),
//     .x_in_2(x_in_2s[6]),
//     .y_in_2(y_in_2s[6]),
//     .is_valid_out(is_shape_ready[6])
//   );

//     draw_line #(.COLORS(colors[3])) line4(
//     .is_valid_in(is_shape_ready[7] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[7]),
//     .y_in_1(y_in_1s[7]),
//     .x_in_2(x_in_2s[7]),
//     .y_in_2(y_in_2s[7]),
//     .line_coord(obj_coord[7]),
//     .red_out(reds_out[7]),
//     .green_out(greens_out[7]),
//     .blue_out(reds_out[7]),
//     .is_valid_out(is_shape_drawn[7])
//   );

//     line_converter line4_converter (
//     .is_static(is_static[3]),
//     .is_valid_in(id_bits[3] == b10 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[7]),
//     .y_in_1(y_in_1s[7]),
//     .x_in_2(x_in_2s[7]),
//     .y_in_2(y_in_2s[7]),
//     .is_valid_out(is_shape_ready[7])
//   );

//     draw_rect #(.COLORS(colors[0])) rect(
//     .is_valid_in(is_shape_ready[8] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[8]),
//     .y_in_1(y_in_1s[8]),
//     .x_in_2(x_in_2s[8]),
//     .y_in_2(y_in_2s[8]),
//     .rect_coord(obj_coord[8]),
//     .red_out(reds_out[8]),
//     .green_out(greens_out[8]),
//     .blue_out(reds_out[8]),
//     .is_valid_out(is_shape_drawn[8])
//   );

//     rect_converter rect_converter (
//     .is_static(is_static[0]),
//     .is_valid_in(id_bits[0] == b11 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[8]),
//     .y_in_1(y_in_1s[8]),
//     .x_in_2(x_in_2s[8]),
//     .y_in_2(y_in_2s[8]),
//     .is_valid_out(is_shape_ready[8])
//   );

//     draw_rect #(.COLORS(colors[1])) rect2(
//     .is_valid_in(is_shape_ready[9] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[9]),
//     .y_in_1(y_in_1s[9]),
//     .x_in_2(x_in_2s[9]),
//     .y_in_2(y_in_2s[9]),
//     .rect_coord(obj_coord[9]),
//     .red_out(reds_out[9]),
//     .green_out(greens_out[9]),
//     .blue_out(reds_out[9]),
//     .is_valid_out(is_shape_drawn[9])
//   );

//     rect_converter rect2_converter (
//     .is_static(is_static[1]),
//     .is_valid_in(id_bits[1] == b11 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[9]),
//     .y_in_1(y_in_1s[9]),
//     .x_in_2(x_in_2s[9]),
//     .y_in_2(y_in_2s[9]),
//     .is_valid_out(is_shape_ready[9])
//   );

//     draw_rect #(.COLORS(colors[2])) rect3(
//     .is_valid_in(is_shape_ready[10] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[10]),
//     .y_in_1(y_in_1s[10]),
//     .x_in_2(x_in_2s[10]),
//     .y_in_2(y_in_2s[10]),
//     .rect_coord(obj_coord[10]),
//     .red_out(reds_out[10]),
//     .green_out(greens_out[10]),
//     .blue_out(reds_out[10]),
//     .is_valid_out(is_shape_drawn[10])
//   );

//     rect_converter rect3_converter (
//     .is_static(is_static[2]),
//     .is_valid_in(id_bits[2] == b11 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[10]),
//     .y_in_1(y_in_1s[10]),
//     .x_in_2(x_in_2s[10]),
//     .y_in_2(y_in_2s[10]),
//     .is_valid_out(is_shape_ready[10])
//   );

//     draw_rect #(.COLORS(colors[3])) rect4(
//     .is_valid_in(is_shape_ready[11] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[11]),
//     .y_in_1(y_in_1s[11]),
//     .x_in_2(x_in_2s[11]),
//     .y_in_2(y_in_2s[11]),
//     .rect_coord(obj_coord[11]),
//     .red_out(reds_out[11]),
//     .green_out(greens_out[11]),
//     .blue_out(reds_out[11]),
//     .is_valid_out(is_shape_drawn[11])
//   );

//     rect_converter rect4_converter (
//     .is_static(is_static[3]),
//     .is_valid_in(id_bits[3] == b11 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[11]),
//     .y_in_1(y_in_1s[11]),
//     .x_in_2(x_in_2s[11]),
//     .y_in_2(y_in_2s[11]),
//     .is_valid_out(is_shape_ready[11])
//   );

    logic [3:0][7:0] held_reds;
    logic [3:0][7:0] held_greens;
    logic [3:0][7:0] held_blues;
    logic [4:0][18:0] held_write_address;
    logic [18:0] cycle_delay_write_address;
    logic [4:0][3:0] held_valid;
    logic [4:0][1:0] held_id_bits;
    logic [4:0] held_is_second_set;

    logic [3:0][7:0] current_reds;
    logic [3:0][7:0] current_greens;
    logic [3:0][7:0] current_blues;

    logic [7:0] red_or;
    logic [7:0] green_or;
    logic [7:0] blue_or;
 
// cycle 0: inputs taken / converters calculated / inputs passed into draw_ module
// cycle 1: next set of inputs taken / converts calculated / inputs passed into draw_ module,   1d for first set    0d second set
// cycle 2: next set of inputs taken / converts calculated / inputs passed into draw_ module,   2d for first set    1d second set
// cycle 3: next set of inputs taken / converts calculated / inputs passed into draw_ module,   3d for first set    2d second set
// cycle 4: next set of inputs taken / converts calculated / inputs passed into draw_ module,   4d for first set    3d second set
// cycle 5: next set of inputs taken / converts calculated / inputs passed into draw_ module,   5d for first set    4d second set   first set held
    always_comb begin
        for(int obj_num = 0; obj_num < 4; obj_num = obj_num + 1) begin
            case(id_bits[obj_num])
                2'b00: begin
                    current_reds[i] = 0;
                    current_greens[i] = 0;
                    current_blues[i] = 0;
                end
                2'b01: begin
                    current_reds[i] = reds_out[i];
                    current_greens[i] = greens_out[i];
                    current_blues[i] = blues_out[i];
                end
                2'b10: begin
                    current_reds[i] = reds_out[i + 4];
                    current_greens[i] = greens_out[i + 4];
                    current_blues[i] = blues_out[i + 4];
                end
                2'b11: begin
                    current_reds[i] = reds_out[i + 8];
                    current_greens[i] = greens_out[i + 8];
                    current_blues[i] = blues_out[i + 8];
                end
                default: begin
                    current_reds[i] = 0;
                    current_greens[i] = 0;
                    current_blues[i] = 0;
                end
            endcase
        end
        red_or = current_reds[0] || held_reds[0] ||
                current_reds[1] || held_reds[1] ||
                current_reds[2] || held_reds[2] ||
                current_reds[3] || held_reds[3];
        green_or = current_greens[0] || held_greens[0] ||
                current_greens[1] || held_greens[1] ||
                current_greens[2] || held_greens[2] ||
                current_greens[3] || held_greens[3];
        blue_or = current_blues[0] || held_blues[0] ||
                current_blues[1] || held_blues[1] ||
                current_blues[2] || held_blues[2] ||
                current_blues[3] || held_blues[3];
    end

    always_ff@(posedge clk_in) begin
        if(rst_in) begin
            valid_out <= 0;
            held_reds <= 0;
            held_greens <= 0;
            held_blues <= 0;
            is_second_set <= 0;
            held_is_second_set <= 0;
        end
        else if(valid_in) begin
            is_first_set <= !is_first_set;
            for(int i = 0; i <= 3; i = i + 1) begin
                held_is_second_set[i + 1] <= held_is_second_set[i];
                held_id_bits[i + 1] <= held_id_bits[i];
                held_write_address[i + 1] <= held_write_address[i];
            end
            held_is_second_set[0] <= is_second_set;
            held_id_bits[0] <= id_bits[0];
            held_write_address[0] <= (hcount_in >> 1) + (640 * (vcount_in >> 1));
            
            if(!held_is_second_set[4]) begin
                cycle_delay_write_address <= held_write_address[4];
                for(int obj_num = 0; obj_num < 4; obj_num = obj_num + 1) begin
                    case(id_bits[obj_num])
                        2'b00: begin
                            held_reds[i] <= 0;
                            held_greens[i] <= 0;
                            held_blues[i] <= 0;
                        end
                        2'b01: begin
                            held_reds[i] <= reds_out[i];
                            held_greens[i] <= greens_out[i];
                            held_blues[i] <= blues_out[i];
                        end
                        2'b10: begin
                            held_reds[i] <= reds_out[i + 4];
                            held_greens[i] <= greens_out[i + 4];
                            held_blues[i] <= blues_out[i + 4];
                        end
                        2'b11: begin
                            held_reds[i] <= reds_out[i + 8];
                            held_greens[i] <= greens_out[i + 8];
                            held_blues[i] <= blues_out[i + 8];
                        end
                        default: begin
                            held_reds[i] <= 0;
                            held_greens[i] <= 0;
                            held_blues[i] <= 0;
                        end
                    endcase
                end

            end
            else begin
               color_bits <= {reds_out, greens_out, blues_out} == STATIC_COLOR ? 0 : 1;
               valid_out <= 1;
               write_address <= cycle_delay_write_address;
                
            end

        end
        // else begin
        //     for(int i = 0; i <= 4; i = i + 1) begin
        //             held_reds[i] <= reds_out[i];
        //             held_greens[i] <= greens_out[i];
        //             held_blues[i] <= blues_out[i];
        //             held_valid[i + 1] <= heldvalid[i];
        //             if(i != 4) begin 
        //                 held_write_address[i+1] <= held_write_address[i];
        //             end
        //     end
        //     held_write_address[0] <= (hcount_in >> 1) + (640 * vcount_in >> 1);
        //     held_valid[0] <= valid_in;
        //     if(held_valid[5] && held_valid[4]) begin
                
        //     end
        // end
    end

//     typedef enum {IDLE, PROCESSING_FIRST_SET, DONE_FIRST_SET, PROCESSING_SECOND_SET} e_states;
//     localparam STATIC_COLOR = 24'h11_11_11;
//     localparam NOT_STATIC_COLOR = 24'h77_77_77;
//     e_states state;
//     logic [11:0][10:0] x_in_1s;
//     logic [11:0][9:0] y_in_1s;
//     logic [11:0][10:0] x_in_2s;
//     logic [11:0][9:0] y_in_2s;
//     logic [3:0][23:0] colors;
//     logic [11:0][7:0] reds_out;
//     logic [11:0][7:0] greens_out;
//     logic [11:0][7:0] blues_out;
//     logic [11:0][83:0] obj_coord;
//     logic [11:0] is_shape_ready;
//     logic [11:0] is_shape_drawn;

//     logic [3:0][7:0] first_set_reds;
//     logic [3:0][7:0] first_set_greens;
//     logic [3:0][7:0] first_set_blues;

//     logic [3:0][7:0] second_set_reds;
//     logic [3:0][7:0] second_set_greens;
//     logic [3:0][7:0] second_set_blues;

//     logic is_obj_1_done;
//     logic is_obj_2_done;
//     logic is_obj_3_done;
//     logic is_obj_4_done;

//     draw_circle #(.COLORS(colors[0])) ball(
//     .is_valid_in(is_shape_ready[0] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[0]),
//     .y_in_1(y_in_1s[0]),
//     .x_in_2(x_in_2s[0]),
//     .y_in_2(y_in_2s[0]),
//     .circle_coord(obj_coord[0]),
//     .red_out(reds_out[0]),
//     .green_out(greens_out[0]),
//     .blue_out(reds_out[0]),
//     .is_valid_out(is_shape_drawn[0])
//   );

//   /*
//       input wire [114:0] object_props,
//     output logic is_static,
//     output logic [10:0] x_in_1,
//     output logic [9:0] y_in_1,
//     output logic [10:0] x_in_2,
//     output logic [9:0] y_in_2
//   */

//   circle_converter ball_converter (
//     .is_static(is_static[0]),
//     .is_valid_in(id_bits[0] == b01 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[0]),
//     .y_in_1(y_in_1s[0]),
//     .x_in_2(x_in_2s[0]),
//     .y_in_2(y_in_2s[0]),
//     .is_valid_out(is_shape_ready[0])
//   );

//     draw_circle #(.COLORS(colors[1])) ball2(
//     .is_valid_in(is_shape_ready[1] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[1]),
//     .y_in_1(y_in_1s[1]),
//     .x_in_2(x_in_2s[1]),
//     .y_in_2(y_in_2s[1]),
//     .circle_coord(obj_coord[1]),
//     .red_out(reds_out[1]),
//     .green_out(greens_out[1]),
//     .blue_out(reds_out[1]),
//     .is_valid_out(is_shape_drawn[1])
//   );

//     circle_converter ball2_converter (
//     .is_static(is_static[1] && state == IDLE || state == DONE_FIRST_SET),
//     .is_valid_in(id_bits[1] == b01),
//     .x_in_1(x_in_1s[1]),
//     .y_in_1(y_in_1s[1]),
//     .x_in_2(x_in_2s[1]),
//     .y_in_2(y_in_2s[1]),
//     .is_valid_out(is_shape_ready[1])
//   );

//     draw_circle #(.COLORS(colors[2])) ball3(
//     .is_valid_in(is_shape_ready[2] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[2]),
//     .y_in_1(y_in_1s[2]),
//     .x_in_2(x_in_2s[2]),
//     .y_in_2(y_in_2s[2]),
//     .circle_coord(obj_coord[2]),
//     .red_out(reds_out[2]),
//     .green_out(greens_out[2]),
//     .blue_out(reds_out[2]),
//     .is_valid_out(is_shape_drawn[2])
//   );

//     circle_converter ball3_converter (
//     .is_static(is_static[2]),
//     .is_valid_in(id_bits[2] == b01 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[2]),
//     .y_in_1(y_in_1s[2]),
//     .x_in_2(x_in_2s[2]),
//     .y_in_2(y_in_2s[2]),
//     .is_valid_out(is_shape_ready[2])
//   );

//     draw_circle #(.COLORS(colors[3])) ball4(
//     .is_valid_in(is_shape_ready[3] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[3]),
//     .y_in_1(y_in_1s[3]),
//     .x_in_2(x_in_2s[3]),
//     .y_in_2(y_in_2s[3]),
//     .circle_coord(obj_coord[3]),
//     .red_out(reds_out[3]),
//     .green_out(greens_out[3]),
//     .blue_out(reds_out[3]),
//     .is_valid_out(is_shape_drawn[3])
//   );

//     circle_converter ball4_converter (
//     .is_static(is_static[3]),
//     .is_valid_in(id_bits[3] == b01 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[3]),
//     .y_in_1(y_in_1s[3]),
//     .x_in_2(x_in_2s[3]),
//     .y_in_2(y_in_2s[3]),
//     .is_valid_out(is_shape_drawn[3])
//   );

//     draw_line #(.COLORS(colors[0])) line(
//     .is_valid_in(is_shape_ready[4] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[4]),
//     .y_in_1(y_in_1s[4]),
//     .x_in_2(x_in_2s[4]),
//     .y_in_2(y_in_2s[4]),
//     .line_coord(obj_coord[4]),
//     .red_out(reds_out[4]),
//     .green_out(greens_out[4]),
//     .blue_out(reds_out[4]),
//     .is_valid_out(is_shape_drawn[4])
//   );

//     line_converter line_converter (
//     .is_static(is_static[0]),
//     .is_valid_in(id_bits[0] == b10 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[4]),
//     .y_in_1(y_in_1s[4]),
//     .x_in_2(x_in_2s[4]),
//     .y_in_2(y_in_2s[4]),
//     .is_valid_out(is_shape_ready[4])
//   );

//     draw_line #(.COLORS(colors[1])) line2(
//     .is_valid_in(is_shape_ready[5] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[5]),
//     .y_in_1(y_in_1s[5]),
//     .x_in_2(x_in_2s[5]),
//     .y_in_2(y_in_2s[5]),
//     .line_coord(obj_coord[5]),
//     .red_out(reds_out[5]),
//     .green_out(greens_out[5]),
//     .blue_out(reds_out[5]),
//     .is_valid_out(is_shape_drawn[5])
//   );

//     line_converter line2_converter (
//     .is_static(is_static[1]),
//     .is_valid_in(id_bits[1] == b10 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[5]),
//     .y_in_1(y_in_1s[5]),
//     .x_in_2(x_in_2s[5]),
//     .y_in_2(y_in_2s[5]),
//     .is_valid_out(is_shape_ready[5])
//   );

//     draw_line #(.COLORS(colors[2])) line3(
//     .is_valid_in(is_shape_ready[6] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[6]),
//     .y_in_1(y_in_1s[6]),
//     .x_in_2(x_in_2s[6]),
//     .y_in_2(y_in_2s[6]),
//     .line_coord(obj_coord[6]),
//     .red_out(reds_out[6]),
//     .green_out(greens_out[6]),
//     .blue_out(reds_out[6]),
//     .is_valid_out(is_shape_drawn[6])
//   );

//     line_converter line3_converter (
//     .is_static(is_static[2]),
//     .is_valid_in(id_bits[2] == b10 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[6]),
//     .y_in_1(y_in_1s[6]),
//     .x_in_2(x_in_2s[6]),
//     .y_in_2(y_in_2s[6]),
//     .is_valid_out(is_shape_ready[6])
//   );

//     draw_line #(.COLORS(colors[3])) line4(
//     .is_valid_in(is_shape_ready[7] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[7]),
//     .y_in_1(y_in_1s[7]),
//     .x_in_2(x_in_2s[7]),
//     .y_in_2(y_in_2s[7]),
//     .line_coord(obj_coord[7]),
//     .red_out(reds_out[7]),
//     .green_out(greens_out[7]),
//     .blue_out(reds_out[7]),
//     .is_valid_out(is_shape_drawn[7])
//   );

//     line_converter line4_converter (
//     .is_static(is_static[3]),
//     .is_valid_in(id_bits[3] == b10 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[7]),
//     .y_in_1(y_in_1s[7]),
//     .x_in_2(x_in_2s[7]),
//     .y_in_2(y_in_2s[7]),
//     .is_valid_out(is_shape_ready[7])
//   );

//     draw_rect #(.COLORS(colors[0])) rect(
//     .is_valid_in(is_shape_ready[8] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[8]),
//     .y_in_1(y_in_1s[8]),
//     .x_in_2(x_in_2s[8]),
//     .y_in_2(y_in_2s[8]),
//     .rect_coord(obj_coord[8]),
//     .red_out(reds_out[8]),
//     .green_out(greens_out[8]),
//     .blue_out(reds_out[8]),
//     .is_valid_out(is_shape_drawn[8])
//   );

//     rect_converter rect_converter (
//     .is_static(is_static[0]),
//     .is_valid_in(id_bits[0] == b11 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[8]),
//     .y_in_1(y_in_1s[8]),
//     .x_in_2(x_in_2s[8]),
//     .y_in_2(y_in_2s[8]),
//     .is_valid_out(is_shape_ready[8])
//   );

//     draw_rect #(.COLORS(colors[1])) rect2(
//     .is_valid_in(is_shape_ready[9] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[9]),
//     .y_in_1(y_in_1s[9]),
//     .x_in_2(x_in_2s[9]),
//     .y_in_2(y_in_2s[9]),
//     .rect_coord(obj_coord[9]),
//     .red_out(reds_out[9]),
//     .green_out(greens_out[9]),
//     .blue_out(reds_out[9]),
//     .is_valid_out(is_shape_drawn[9])
//   );

//     rect_converter rect2_converter (
//     .is_static(is_static[1]),
//     .is_valid_in(id_bits[1] == b11 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[9]),
//     .y_in_1(y_in_1s[9]),
//     .x_in_2(x_in_2s[9]),
//     .y_in_2(y_in_2s[9]),
//     .is_valid_out(is_shape_ready[9])
//   );

//     draw_rect #(.COLORS(colors[2])) rect3(
//     .is_valid_in(is_shape_ready[10] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[10]),
//     .y_in_1(y_in_1s[10]),
//     .x_in_2(x_in_2s[10]),
//     .y_in_2(y_in_2s[10]),
//     .rect_coord(obj_coord[10]),
//     .red_out(reds_out[10]),
//     .green_out(greens_out[10]),
//     .blue_out(reds_out[10]),
//     .is_valid_out(is_shape_drawn[10])
//   );

//     rect_converter rect3_converter (
//     .is_static(is_static[2]),
//     .is_valid_in(id_bits[2] == b11 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[10]),
//     .y_in_1(y_in_1s[10]),
//     .x_in_2(x_in_2s[10]),
//     .y_in_2(y_in_2s[10]),
//     .is_valid_out(is_shape_ready[10])
//   );

//     draw_rect #(.COLORS(colors[3])) rect4(
//     .is_valid_in(is_shape_ready[11] && state == IDLE || state == DONE_FIRST_SET),
//     .clk_in(clk_100mhz),
//     .rst_in(rst_in),
//     .hcount_in(hcount_in),
//     .vcount_in(vcount_in),
//     .x_in_1(x_in_1s[11]),
//     .y_in_1(y_in_1s[11]),
//     .x_in_2(x_in_2s[11]),
//     .y_in_2(y_in_2s[11]),
//     .rect_coord(obj_coord[11]),
//     .red_out(reds_out[11]),
//     .green_out(greens_out[11]),
//     .blue_out(reds_out[11]),
//     .is_valid_out(is_shape_drawn[11])
//   );

//     rect_converter rect4_converter (
//     .is_static(is_static[3]),
//     .is_valid_in(id_bits[3] == b11 && state == IDLE || state == DONE_FIRST_SET),
//     .x_in_1(x_in_1s[11]),
//     .y_in_1(y_in_1s[11]),
//     .x_in_2(x_in_2s[11]),
//     .y_in_2(y_in_2s[11]),
//     .is_valid_out(is_shape_ready[11])
//   );

//     always_comb begin
//         colors[0] = is_static[0] ? STATIC_COLOR : NOT_STATIC_COLOR;
//     end
    
//     always_ff@(posedge clk_in) begin
//         // initialize 12 modules at a time
//         // based on the four shapes that come in, pass into the correct module with hcount/vcount
//         // every few cycles, get out a color answer. render module will store values for isstatic/notisstatic
//         // hold this unitl you get the second output (so this is blocking / state machine setup)
//         // or the outputs of every shape
//         // spit out the color value and send to outer hdmi/render connector module
//         // map to hcount/2, vcount/2 (store at hc + 320vc) and store in frame buffer
//         // in hdmi/render connector module, we map the address back up to full resolution and put in the color.
//         if(rst_in) begin
//             busy_out <= 0;
//             valid_out <= 0;
//             state <= IDLE;

//         end
//         else if(state == IDLE) begin
//             if(valid_in) begin
//                 busy_out <= 1;
//                 state <= PROCESSING_FIRST_SET;
//                 // don't wait for the object to get done if it doesn't exist
//                 if(id_bits[0] == 2'b00) is_obj_1_done <= 1;
//                 if(id_bits[1] == 2'b00) is_obj_2_done <= 1;
//                 if(id_bits[2] == 2'b00) is_obj_3_done <= 1;
//                 if(id_bits[3] == 2'b00) is_obj_4_done <= 1;
//             end
//         end
//         // else if(state == PROCESSING_FIRST_CONVERTER) begin
//         //     if()
//         //     // if any of them are done, start storing in temp registers
//         //     // when all of them are done, pass into processing first set (so no need to pipeline that, they'll all be 5 cycles)
//         // end
//         else if(state == PROCESSING_FIRST_SET) begin
//             // wait 5 cycles
//             // once 5 cycles are done, store the four relevant rgb values in temp register and set state to done_first_set
//             if(id_bits[0] == 2'b00) is_obj_1_done <= 1;
//             else is_obj_1_done <= (is_obj_1_done == 1) ? 1 : (is_shape_drawn[0] || is_shape_drawn[4] || is_shape_drawn[8]);
//             if(is_obj_1_done) begin
//                 case(id_bits[0])
//                     2'b00: begin
//                         first_set_reds[0] <= 0;
//                         first_set_greens[0] <= 0;
//                         first_set_blues[0] <= 0;
//                     end
//                     2'b01: begin
//                         first_set_reds[0] <= reds_out[0];
//                         first_set_greens[0] <= greens_out[0];
//                         first_set_blues[0] <= blues_out[0];
//                     end
//                     2'b10: begin
//                         first_set_reds[0] <= reds_out[4];
//                         first_set_greens[0] <= greens_out[4];
//                         first_set_blues[0] <= blues_out[4];
//                     end
//                     2'b11: begin
//                         first_set_reds[0] <= reds_out[8];
//                         first_set_greens[0] <= greens_out[8];
//                         first_set_blues[0] <= blues_out[8];
//                     end
//                 endcase
//             end
//             if(id_bits[1] == 2'b00) is_obj_2_done <= 1;
//             else is_obj_2_done <= (is_obj_2_done == 1) ? 1 : (is_shape_drawn[1] || is_shape_drawn[5] || is_shape_drawn[9]);
//             if(is_obj_2_done) begin
//                 case(id_bits[1])
//                         2'b00: begin
//                             first_set_reds[1] <= 0;
//                             first_set_greens[1] <= 0;
//                             first_set_blues[1] <= 0;
//                         end
//                         2'b01: begin
//                             first_set_reds[1] <= reds_out[1];
//                             first_set_greens[1] <= greens_out[1];
//                             first_set_blues[1] <= blues_out[1];
//                         end
//                         2'b10: begin
//                             first_set_reds[1] <= reds_out[5];
//                             first_set_greens[1] <= greens_out[5];
//                             first_set_blues[1] <= blues_out[5];
//                         end
//                         2'b11: begin
//                             first_set_reds[1] <= reds_out[9];
//                             first_set_greens[1] <= greens_out[9];
//                             first_set_blues[1] <= blues_out[9];
//                         end
//                 endcase
//             end
//             if(id_bits[2] == 2'b00) is_obj_3_done <= 1;
//             else is_obj_3_done <= (is_obj_3_done == 1) ? 1 : (is_shape_drawn[2] || is_shape_drawn[6] || is_shape_drawn[10]);
//             if(is_obj_3_done) begin
//                 case(id_bits[2])
//                         2'b00: begin
//                             first_set_reds[2] <= 0;
//                             first_set_greens[2] <= 0;
//                             first_set_blues[2] <= 0;
//                         end
//                         2'b01: begin
//                             first_set_reds[2] <= reds_out[2];
//                             first_set_greens[2] <= greens_out[2];
//                             first_set_blues[2] <= blues_out[2];
//                         end
//                         2'b10: begin
//                             first_set_reds[2] <= reds_out[6];
//                             first_set_greens[2] <= greens_out[6];
//                             first_set_blues[2] <= blues_out[6];
//                         end
//                         2'b11: begin
//                             first_set_reds[2] <= reds_out[10];
//                             first_set_greens[2] <= greens_out[10];
//                             first_set_blues[2] <= blues_out[10];
//                         end
//                 endcase
//             end
//             if(id_bits[3] == 2'b00) is_obj_4_done <= 1;
//             else is_obj_4_done <= (is_obj_4_done == 1) ? 1 : (is_shape_drawn[3] || is_shape_drawn[7] || is_shape_drawn[11]);
//             if(is_obj_4_done) begin
//                 case(id_bits[4])
//                         2'b00: begin
//                             first_set_reds[4] <= 0;
//                             first_set_greens[4] <= 0;
//                             first_set_blues[4] <= 0;
//                         end
//                         2'b01: begin
//                             first_set_reds[4] <= reds_out[3];
//                             first_set_greens[4] <= greens_out[3];
//                             first_set_blues[4] <= blues_out[3];
//                         end
//                         2'b10: begin
//                             first_set_reds[4] <= reds_out[7];
//                             first_set_greens[4] <= greens_out[7];
//                             first_set_blues[4] <= blues_out[7];
//                         end
//                         2'b11: begin
//                             first_set_reds[4] <= reds_out[11];
//                             first_set_greens[4] <= greens_out[11];
//                             first_set_blues[4] <= blues_out[11];
//                         end
//                 endcase
//             end
//             if(is_obj_1_done && is_obj_2_done && is_obj_3_done && is_obj_4_done) begin
//                 if(reds_out[0] || greens_out[0] || blues_out[0] ||
//                     reds_out[1] || greens_out[1] || blues_out[1] ||
//                     reds_out[2] || greens_out[2] || blues_out[2] ||
//                     reds_out[3] || greens_out[3] || blues_out[3]) begin
//                         red_out <= reds_out[0] || reds_out[1] || reds_out[2] || reds_out[3];
//                         green_out <= greens_out[0] || greens_out[1] || greens_out[2] || greens_out[3];
//                         blue_out <= blues_out[0] || blues_out[1] || blues_out[2] || blues_out[3];
//                         is_valid_out <= 1;
//                         is_busy_out <= 0;
//                         write_address <= hcount_in >> 1 + 360 * vcount_in >> 1;

//                     end
//                 state <= DONE_FIRST_SET;
//             end
//         end
//         else if(state == DONE_FIRST_SET) begin
//             // vaid for valid_in, move to processing_second_set
//             if(valid_in) begin
//                 state <= PROCESSING_SECOND_SET;
//                 // don't wait for the object to get done if it doesn't exist
//                 if(id_bits[0] == 2'b00) is_obj_1_done <= 1;
//                 if(id_bits[1] == 2'b00) is_obj_2_done <= 1;
//                 if(id_bits[2] == 2'b00) is_obj_3_done <= 1;
//                 if(id_bits[3] == 2'b00) is_obj_4_done <= 1;
//             end
//         end
//         else if(state == PROCESSING_SECOND_SET) begin
//             // once all 5 cycles are done, OR all the values to find the correct rgb and output, set to idle
//             if(id_bits[0] == 2'b00) is_obj_1_done <= 1;
//             else is_obj_1_done <= (is_obj_1_done == 1) ? 1 : (is_shape_drawn[0] || is_shape_drawn[4] || is_shape_drawn[8]);
//             if(is_obj_1_done) begin
//                 case(id_bits[0])
//                     2'b00: begin
//                         second_set_reds[0] <= 0;
//                         second_set_greens[0] <= 0;
//                         second_set_blues[0] <= 0;
//                     end
//                     2'b01: begin
//                         second_set_reds[0] <= reds_out[0];
//                         second_set_greens[0] <= greens_out[0];
//                         second_set_blues[0] <= blues_out[0];
//                     end
//                     2'b10: begin
//                         second_set_reds[0] <= reds_out[4];
//                         second_set_greens[0] <= greens_out[4];
//                         second_set_blues[0] <= blues_out[4];
//                     end
//                     2'b11: begin
//                         second_set_reds[0] <= reds_out[8];
//                         second_set_greens[0] <= greens_out[8];
//                         second_set_blues[0] <= blues_out[8];
//                     end
//                 endcase
//             end
//             if(id_bits[1] == 2'b00) is_obj_2_done <= 1;
//             else is_obj_2_done <= (is_obj_2_done == 1) ? 1 : (is_shape_drawn[1] || is_shape_drawn[5] || is_shape_drawn[9]);
//             if(is_obj_2_done) begin
//                 case(id_bits[1])
//                         2'b00: begin
//                             second_set_reds[1] <= 0;
//                             second_set_greens[1] <= 0;
//                             second_set_blues[1] <= 0;
//                         end
//                         2'b01: begin
//                             second_set_reds[1] <= reds_out[1];
//                             second_set_greens[1] <= greens_out[1];
//                             second_set_blues[1] <= blues_out[1];
//                         end
//                         2'b10: begin
//                             second_set_reds[1] <= reds_out[5];
//                             second_set_greens[1] <= greens_out[5];
//                             second_set_blues[1] <= blues_out[5];
//                         end
//                         2'b11: begin
//                             second_set_reds[1] <= reds_out[9];
//                             second_set_greens[1] <= greens_out[9];
//                             second_set_blues[1] <= blues_out[9];
//                         end
//                 endcase
//             end
//             if(id_bits[2] == 2'b00) is_obj_3_done <= 1;
//             else is_obj_3_done <= (is_obj_3_done == 1) ? 1 : (is_shape_drawn[2] || is_shape_drawn[6] || is_shape_drawn[10]);
//             if(is_obj_3_done) begin
//                 case(id_bits[2])
//                         2'b00: begin
//                             second_set_reds[2] <= 0;
//                             second_set_greens[2] <= 0;
//                             second_set_blues[2] <= 0;
//                         end
//                         2'b01: begin
//                             second_set_reds[2] <= reds_out[2];
//                             second_set_greens[2] <= greens_out[2];
//                             second_set_blues[2] <= blues_out[2];
//                         end
//                         2'b10: begin
//                             second_set_reds[2] <= reds_out[6];
//                             second_set_greens[2] <= greens_out[6];
//                             second_set_blues[2] <= blues_out[6];
//                         end
//                         2'b11: begin
//                             second_set_reds[2] <= reds_out[10];
//                             second_set_greens[2] <= greens_out[10];
//                             second_set_blues[2] <= blues_out[10];
//                         end
//                 endcase
//             end
//             if(id_bits[3] == 2'b00) is_obj_4_done <= 1;
//             else is_obj_4_done <= (is_obj_4_done == 1) ? 1 : (is_shape_drawn[3] || is_shape_drawn[7] || is_shape_drawn[11]);
//             if(is_obj_4_done) begin
//                 case(id_bits[4])
//                         2'b00: begin
//                             second_set_reds[4] <= 0;
//                             second_set_greens[4] <= 0;
//                             second_set_blues[4] <= 0;
//                         end
//                         2'b01: begin
//                             second_set_reds[4] <= reds_out[3];
//                             second_set_greens[4] <= greens_out[3];
//                             second_set_blues[4] <= blues_out[3];
//                         end
//                         2'b10: begin
//                             second_set_reds[4] <= reds_out[7];
//                             second_set_greens[4] <= greens_out[7];
//                             second_set_blues[4] <= blues_out[7];
//                         end
//                         2'b11: begin
//                             second_set_reds[4] <= reds_out[11];
//                             second_set_greens[4] <= greens_out[11];
//                             second_set_blues[4] <= blues_out[11];
//                         end
//                 endcase
//             end
//             if(is_obj_1_done && is_obj_2_done && is_obj_3_done && is_obj_4_done) begin
//                 red_out <= reds_out[0] || reds_out[1] || reds_out[2] || reds_out[3];
//                 green_out <= greens_out[0] || greens_out[1] || greens_out[2] || greens_out[3];
//                 blue_out <= blues_out[0] || blues_out[1] || blues_out[2] || blues_out[3];
//                 is_valid_out <= 1;
//                 is_busy_out <= 0;
//                 write_address <= hcount_in >> 1 + 360 * vcount_in >> 1;
//                 state <= IDLE;
//             end
//         end
//     end


    
    // finite state machine checking whether or not new data can be received / if we have reached the end of addresses.
    // every time a new set of four addresses is received, check the id type and pass it to the appropriate render_type module.
    // each render_type module writes to the frame buffer as all of the points in the 
endmodule