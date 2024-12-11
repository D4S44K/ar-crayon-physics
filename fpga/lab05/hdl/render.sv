module render 
(
    input wire clk_in,
    input wire valid_in,
    input wire rst_in,
    // parameters for up to four objects at a time being passed in from object storage
    input wire [3:0] is_static,
    // input wire [3:0][6:0] current_addresses,
    input wire [3:0][1:0] id_bits,
    input wire [3:0][47:0] params,
    input wire [3:0][15:0] pos_x,
    input wire [3:0][15:0] pos_y,

    // pixel coordinate that we are querying
    input wire [10:0] hcount_in,
    input wire [9:0] vcount_in,

    // resulting color
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
    logic [11:0] in_shape_bits;
    logic [11:0][83:0] obj_coord;
    logic [11:0] is_shape_ready;
    logic [11:0] is_shape_drawn;
    

    draw_circle  ball(
    .valid_in(is_shape_ready[0]),
    .clk_in(clk_in ),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in_1(x_in_1s[0]),
    .y_in_1(y_in_1s[0]),
    .x_in_2(x_in_2s[0]),
    .y_in_2(y_in_2s[0]),
    .circle_coord(obj_coord[0]),
    .in_circle(in_shape_bits[0]),
    .valid_out(is_shape_drawn[0])
  );

  circle_converter ball_converter (
    // .is_static(is_static[0]),
    .is_valid_in(id_bits[0] == 2'b01 && valid_in),
    .pos_x(pos_x[0]),
    .pos_y(pos_y[0]),
    .params(params[0]),
    .x_in_1(x_in_1s[0]),
    .y_in_1(y_in_1s[0]),
    .x_in_2(x_in_2s[0]),
    .y_in_2(y_in_2s[0]),
    .is_valid_out(is_shape_ready[0])
  );

    draw_circle  ball2(
    .valid_in(is_shape_ready[1]),
    .clk_in(clk_in ),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in_1(x_in_1s[1]),
    .y_in_1(y_in_1s[1]),
    .x_in_2(x_in_2s[1]),
    .y_in_2(y_in_2s[1]),
    .circle_coord(obj_coord[1]),
    .in_circle(in_shape_bits[1]),
    .valid_out(is_shape_drawn[1])
  );

    circle_converter ball2_converter (
    // .is_static(is_static[1]),
    .is_valid_in(id_bits[1] == 2'b01 && valid_in),
    .pos_x(pos_x[1]),
    .pos_y(pos_y[1]),
    .params(params[1]),
    .x_in_1(x_in_1s[1]),
    .y_in_1(y_in_1s[1]),
    .x_in_2(x_in_2s[1]),
    .y_in_2(y_in_2s[1]),
    .is_valid_out(is_shape_ready[1])
  );

    draw_circle  ball3(
    .valid_in(is_shape_ready[2]),
    .clk_in(clk_in ),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in_1(x_in_1s[2]),
    .y_in_1(y_in_1s[2]),
    .x_in_2(x_in_2s[2]),
    .y_in_2(y_in_2s[2]),
    .circle_coord(obj_coord[2]),
    .in_circle(in_shape_bits[2]),
    .valid_out(is_shape_drawn[2])
  );

    circle_converter ball3_converter (
    // .is_static(is_static[2]),
    .is_valid_in(id_bits[2] == 2'b01 && valid_in),
    .pos_x(pos_x[2]),
    .pos_y(pos_y[2]),
    .params(params[2]),
    .x_in_1(x_in_1s[2]),
    .y_in_1(y_in_1s[2]),
    .x_in_2(x_in_2s[2]),
    .y_in_2(y_in_2s[2]),
    .is_valid_out(is_shape_ready[2])
  );

    draw_circle  ball4(
    .valid_in(is_shape_ready[3]),
    .clk_in(clk_in ),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in_1(x_in_1s[3]),
    .y_in_1(y_in_1s[3]),
    .x_in_2(x_in_2s[3]),
    .y_in_2(y_in_2s[3]),
    .circle_coord(obj_coord[3]),
    .in_circle(in_shape_bits[3]),
    .valid_out(is_shape_drawn[3])
  );

    circle_converter ball4_converter (
    // .is_static(is_static[3]),
    .is_valid_in(id_bits[3] == 2'b01 && valid_in),
    .pos_x(pos_x[3]),
    .pos_y(pos_y[3]),
    .params(params[3]),
    .x_in_1(x_in_1s[3]),
    .y_in_1(y_in_1s[3]),
    .x_in_2(x_in_2s[3]),
    .y_in_2(y_in_2s[3]),
    .is_valid_out(is_shape_ready[3])
  );

    draw_line  line(
    .valid_in(is_shape_ready[4] ),
    .clk_in(clk_in ),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in_1(x_in_1s[4]),
    .y_in_1(y_in_1s[4]),
    .x_in_2(x_in_2s[4]),
    .y_in_2(y_in_2s[4]),
    .line_coord(obj_coord[4]),
    .in_line(in_shape_bits[4]),
    .valid_out(is_shape_drawn[4])
  );

    line_converter line_converter (
    // .is_static(is_static[0]),
    .is_valid_in(id_bits[0] == 2'b10 && valid_in),
    .pos_x(pos_x[0]),
    .pos_y(pos_y[0]),
    .params(params[0]),
    .x_in_1(x_in_1s[4]),
    .y_in_1(y_in_1s[4]),
    .x_in_2(x_in_2s[4]),
    .y_in_2(y_in_2s[4]),
    .is_valid_out(is_shape_ready[4])
  );

    draw_line  line2(
    .valid_in(is_shape_ready[5] ),
    .clk_in(clk_in ),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in_1(x_in_1s[5]),
    .y_in_1(y_in_1s[5]),
    .x_in_2(x_in_2s[5]),
    .y_in_2(y_in_2s[5]),
    .line_coord(obj_coord[5]),
    .in_line(in_shape_bits[5]),
    .valid_out(is_shape_drawn[5])
  );

    line_converter line2_converter (
    // .is_static(is_static[1]),
    .is_valid_in(id_bits[1] == 2'b10 && valid_in),
    .pos_x(pos_x[1]),
    .pos_y(pos_y[1]),
    .params(params[1]),
    .x_in_1(x_in_1s[5]),
    .y_in_1(y_in_1s[5]),
    .x_in_2(x_in_2s[5]),
    .y_in_2(y_in_2s[5]),
    .is_valid_out(is_shape_ready[5])
  );

    draw_line  line3(
    .valid_in(is_shape_ready[6] ),
    .clk_in(clk_in ),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in_1(x_in_1s[6]),
    .y_in_1(y_in_1s[6]),
    .x_in_2(x_in_2s[6]),
    .y_in_2(y_in_2s[6]),
    .line_coord(obj_coord[6]),
    .in_line(in_shape_bits[6]),
    .valid_out(is_shape_drawn[6])
  );

    line_converter line3_converter (
    // .is_static(is_static[2]),
    .is_valid_in(id_bits[2] == 2'b10 && valid_in),
    .pos_x(pos_x[2]),
    .pos_y(pos_y[2]),
    .params(params[2]),
    .x_in_1(x_in_1s[6]),
    .y_in_1(y_in_1s[6]),
    .x_in_2(x_in_2s[6]),
    .y_in_2(y_in_2s[6]),
    .is_valid_out(is_shape_ready[6])
  );

    draw_line  line4(
    .valid_in(is_shape_ready[7] ),
    .clk_in(clk_in ),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in_1(x_in_1s[7]),
    .y_in_1(y_in_1s[7]),
    .x_in_2(x_in_2s[7]),
    .y_in_2(y_in_2s[7]),
    .line_coord(obj_coord[7]),
    .in_line(in_shape_bits[7]),
    .valid_out(is_shape_drawn[7])
  );

    line_converter line4_converter (
    // .is_static(is_static[3]),
    .is_valid_in(id_bits[3] == 2'b10 && valid_in),
    .pos_x(pos_x[3]),
    .pos_y(pos_y[3]),
    .params(params[3]),
    .x_in_1(x_in_1s[7]),
    .y_in_1(y_in_1s[7]),
    .x_in_2(x_in_2s[7]),
    .y_in_2(y_in_2s[7]),
    .is_valid_out(is_shape_ready[7])
  );

    draw_rectangle  rect(
    .valid_in(is_shape_ready[8] ),
    .clk_in(clk_in ),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in_1(x_in_1s[8]),
    .y_in_1(y_in_1s[8]),
    .x_in_2(x_in_2s[8]),
    .y_in_2(y_in_2s[8]),
    .rect_coord(obj_coord[8]),
    .in_rect(in_shape_bits[8]),
    .valid_out(is_shape_drawn[8])
  );

    rect_converter rect_converter (
    // .is_static(is_static[0]),
    .is_valid_in(id_bits[0] ==2'b11 && valid_in),
    .pos_x(pos_x[0]),
    .pos_y(pos_y[0]),
    .params(params[0]),
    .x_in_1(x_in_1s[8]),
    .y_in_1(y_in_1s[8]),
    .x_in_2(x_in_2s[8]),
    .y_in_2(y_in_2s[8]),
    .is_valid_out(is_shape_ready[8])
  );

    draw_rectangle  rect2(
    .valid_in(is_shape_ready[9] ),
    .clk_in(clk_in ),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in_1(x_in_1s[9]),
    .y_in_1(y_in_1s[9]),
    .x_in_2(x_in_2s[9]),
    .y_in_2(y_in_2s[9]),
    .rect_coord(obj_coord[9]),
    .in_rect(in_shape_bits[9]),
    .valid_out(is_shape_drawn[9])
  );

    rect_converter rect2_converter (
    // .is_static(is_static[1]),
    .is_valid_in(id_bits[1] == 2'b11 && valid_in),
    .pos_x(pos_x[1]),
    .pos_y(pos_y[1]),
    .params(params[1]),
    .x_in_1(x_in_1s[9]),
    .y_in_1(y_in_1s[9]),
    .x_in_2(x_in_2s[9]),
    .y_in_2(y_in_2s[9]),
    .is_valid_out(is_shape_ready[9])
  );

    draw_rectangle  rect3(
    .valid_in(is_shape_ready[10] ),
    .clk_in(clk_in ),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in_1(x_in_1s[10]),
    .y_in_1(y_in_1s[10]),
    .x_in_2(x_in_2s[10]),
    .y_in_2(y_in_2s[10]),
    .rect_coord(obj_coord[10]),
    .in_rect(in_shape_bits[10]),
    .valid_out(is_shape_drawn[10])
  );

    rect_converter rect3_converter (
    // .is_static(is_static[2]),
    .is_valid_in(id_bits[2] ==2'b11 && valid_in),
    .pos_x(pos_x[2]),
    .pos_y(pos_y[2]),
    .params(params[2]),
    .x_in_1(x_in_1s[10]),
    .y_in_1(y_in_1s[10]),
    .x_in_2(x_in_2s[10]),
    .y_in_2(y_in_2s[10]),
    .is_valid_out(is_shape_ready[10])
  );

    draw_rectangle  rect4(
    .valid_in(is_shape_ready[11] ),
    .clk_in(clk_in ),
    .rst_in(rst_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .x_in_1(x_in_1s[11]),
    .y_in_1(y_in_1s[11]),
    .x_in_2(x_in_2s[11]),
    .y_in_2(y_in_2s[11]),
    .rect_coord(obj_coord[11]),
    .in_rect(in_shape_bits[11]),
    .valid_out(is_shape_drawn[11])
  );

    rect_converter rect4_converter (
    // .is_static(is_static[3]),
    .is_valid_in(id_bits[3] == 2'b11 && valid_in),
    .pos_x(pos_x[3]),
    .pos_y(pos_y[3]),
    .params(params[3]),
    .x_in_1(x_in_1s[11]),
    .y_in_1(y_in_1s[11]),
    .x_in_2(x_in_2s[11]),
    .y_in_2(y_in_2s[11]),
    .is_valid_out(is_shape_ready[11])
  );

    logic [3:0] held_in_shape_bits;
    logic [4:0][18:0] held_write_address;
    logic [18:0] cycle_delay_write_address;
    // logic [4:0][3:0] held_valid;
    logic [5:0][3:0][1:0] held_id_bits_set_1;
    logic [4:0][3:0][1:0] held_id_bits_set_2;
    logic [5:0][3:0] held_static_bits_set_1;
    logic [4:0][3:0] held_static_bits_set_2;
    logic [4:0] held_is_second_set;
    logic [3:0] current_in_shape_bits;
    logic [1:0] final_color_bit;
    logic is_second_set;
 
    // determines whether the pointeger is in the second set of shapes
    always_comb begin
        for(integer obj_num = 0; obj_num < 4; obj_num = obj_num + 1) begin
            case(held_id_bits_set_2[obj_num])
              2'b00: current_in_shape_bits[obj_num] = 0;
              2'b01: current_in_shape_bits[obj_num] = in_shape_bits[obj_num];
              2'b10: current_in_shape_bits[obj_num] = in_shape_bits[obj_num + 4];
              2'b11: current_in_shape_bits[obj_num] = in_shape_bits[obj_num+8];
              default: current_in_shape_bits[obj_num] = 0;
            endcase
        end
    end

    always_ff@(posedge clk_in) begin
        if(rst_in) begin
            valid_out <= 0;
            held_in_shape_bits <= 0;
            is_second_set <= 0;
            held_is_second_set <= 0;
            held_id_bits_set_1 <= 0;
            held_id_bits_set_2 <= 0;
            held_static_bits_set_1 <= 0;
            held_static_bits_set_2 <= 0;
        end
        else if(valid_in) begin
            is_second_set <= !is_second_set;
            for(integer i = 0; i <= 3; i = i + 1) begin
                held_is_second_set[i + 1] <= held_is_second_set[i];
                held_id_bits_set_1[i + 1] <= held_id_bits_set_1[i];
                held_id_bits_set_2[i + 1] <= held_id_bits_set_2[i];
                held_write_address[i + 1] <= held_write_address[i];
                held_static_bits_set_1[i + 1] <= held_static_bits_set_1[i];
                held_static_bits_set_2[i + 1] <= held_static_bits_set_2[i];
            end
            held_is_second_set[0] <= is_second_set;
            if(!is_second_set) held_id_bits_set_1[0] <= id_bits;
            else held_id_bits_set_2[0] <= id_bits;
            if(is_second_set) held_static_bits_set_2[0] <= is_static;
            else held_static_bits_set_1[0] <= is_static;
            held_static_bits_set_1[5] <= held_static_bits_set_1[4];
            held_id_bits_set_1[5] <= held_id_bits_set_1[4];
            held_write_address[0] <= (hcount_in >> 1) + (640 * (vcount_in >> 1));
            
            if(!held_is_second_set[4]) begin
                cycle_delay_write_address <= held_write_address[4];
                for(integer obj_num = 0; obj_num < 4; obj_num = obj_num + 1) begin
                    case(held_id_bits_set_1[5][obj_num])
                        2'b00: held_in_shape_bits[obj_num] <= 0;
                        2'b01: held_in_shape_bits[obj_num] <= in_shape_bits[obj_num];
                        2'b10: held_in_shape_bits[obj_num] <= in_shape_bits[obj_num + 4];
                        2'b11: held_in_shape_bits[obj_num] <= in_shape_bits[obj_num+8];
                        default: held_in_shape_bits[obj_num] <= 0;
                    endcase
                end
                valid_out <= 0;

            end
            else begin
              if(held_in_shape_bits[0]) color_bits <= held_static_bits_set_1[0] ? 2'b10 : 2'b01;
              else if(held_in_shape_bits[1]) color_bits <= held_static_bits_set_1[1] ? 2'b10 : 2'b01;
              else if(held_in_shape_bits[2]) color_bits <= held_static_bits_set_1[2] ? 2'b10 : 2'b01;
              else if(held_in_shape_bits[3]) color_bits <= held_static_bits_set_1[3] ? 2'b10 : 2'b01;
              else if(current_in_shape_bits[0]) color_bits <= held_static_bits_set_2[0] ? 2'b10 : 2'b01;
              else if(current_in_shape_bits[1]) color_bits <= held_static_bits_set_2[1] ? 2'b10 : 2'b01;
              else if(current_in_shape_bits[2]) color_bits <= held_static_bits_set_2[2] ? 2'b10 : 2'b01;
              else if(current_in_shape_bits[3]) color_bits <= held_static_bits_set_2[3] ? 2'b10 : 2'b01;
              else color_bits <= 2'b11;
              valid_out <= 1;
              write_address <= cycle_delay_write_address;
            
            end

        end
    end
endmodule