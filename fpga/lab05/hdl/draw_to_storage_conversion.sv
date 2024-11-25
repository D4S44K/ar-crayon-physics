module draw_to_storage_conversion (
    // input:  (is_static) (id_bits) (point_one) (point_two) (point_three/trailing-zeroes)
    // output: (is_static) (id_bits) (params) (pos_y) (pos_x) (vel_x) (vel_y)
    input wire clk_in,
    input logic valid_in,
    input logic [82:0] draw_props, // 63 bits (actually, let's do 83 bits, using all four rectangle points)
    output logic is_static, // 1 bit
    output logic [1:0] id_bits, // 2 bits
    output logic [35:0] params, // 36 bits
    output logic [10:0] pos_x, // 101bits
    output logic [9:0] pos_y, // 10 bits
    output logic [15:0] vel_x, // 16 bits
    output logic [15:0] vel_y, // 16 bits
    output logic valid_out, // 1 bit
  );
  logic [10:0] point_one_x;
  logic [9:0] point_one_y;
  logic [10:0] point_two_x;
  logic [9:0] point_two_y;
  logic [10:0] point_three_x;
  logic [9:0] point_three_y;
  logic [10:0] point_four_x;
  logic [9:0] point_four_y;
  logic is_circle;
  logic is_rectangle;
  // logic [3:0][10:0] composite_x;
  // logic [3:0][9:0] composite_y;
  logic [3:0][19:0] composite_points;
  logic [3:0][19:0] sorted_points;
  logic [19:0] composite_min;
  logic [10:0] min_x;
  logic [9:0] min_y;
  logic [1:0] num_same_x;
  logic [9:0] min_1;
  logic [9:0] min_2;
  logic first_clockwise_found;
  logic second_clockwise_found;
  logic [10:0] first_clockwise_x;
  logic [9:0] first_clockwise_y;
  logic [10:0] second_clockwise_x;
  logic [9:0] second_clockwise_y;
  // assign composite_x = {point_one_x, point_two_x, point_three_x, point_four_x};
  // assign composite_y = {point_one_y, point_two_y, point_three_y, point_four_y};
  assign composite_points = {point_one_x, point_one_y, point_two_x, point_two_y, point_three_x, point_three_y, point_four_x, point_four_y};
  // logic [31:0] radius;
  always_comb begin
    if(valid_in) begin
      point_one_x = draw_props[79:70];
      point_one_y = draw_props[69:60];
      point_two_x = draw_props[59:50];
      point_two_y = draw_props[49:40];
      point_three_x = draw_props[39:30];
      point_three_y = draw_props[29:20];
      point_four_x = draw_props[19:9];
      point_four_y = draw_props[9:0];
      is_static = draw_props[62:62];
      id_bits = draw_props[61:60];
      case(id_bits)
        // not defined
        2'b00: begin
          params = 0;
          pos_x = 0;
          pos_y = 0;
          valid_out = 1;
        end
        // circle: params has radius
        2'b01: begin
          is_circle = 1;
          pos_x = (point_one_x + point_two_x) >> 2;
          pos_y = (point_one_y + point_two_y) >> 2;
        end
        // line
        2'b10: begin
          pos_x = point_one_x;
          pos_y = point_one_y;
          params = {point_two_x, point_two_y};
          valid_out = 1;
        end
        // rectangle
        // schema: pos_x and pos_y are point_one x and y, 
        2'b11: begin
          is_rectangle = 1;
          // pos_x = point_one_x;
          // pos_y = point_one_y;
          // params = {point_two_x, point_two_y, 16'b0};
          valid_out = 1;
          pos_x = composite_min[19:10];
          pos_y = composite_min[9:0];
          if(!first_clockwise_found && sorted_points[0][9:0] > pos_y) begin
            first_clockwise_found = 1;
            first_clockwise_x = sorted_points[0][19:10];
            first_clockwise_y = sorted_points[0][9:0];
          end 
          else if(!second_clockwise_found && sorted_points[0][9:0] > pos_y) begin
            second_clockwise_found = 1;
            second_clockwise_x = sorted_points[0][19:10];
            second_clockwise_y = sorted_points[0][9:0];
          end 

          if(!first_clockwise_found && sorted_points[1][9:0] > pos_y) begin
            first_clockwise_found = 1;
            first_clockwise_x = sorted_points[1][19:10];
            first_clockwise_y = sorted_points[1][9:0];
          end 
          else if(!second_clockwise_found && sorted_points[1][9:0] > pos_y) begin
            second_clockwise_found = 1;
            second_clockwise_x = sorted_points[1][19:10];
            second_clockwise_y = sorted_points[1][9:0];
          end

          if(!first_clockwise_found && sorted_points[2][9:0] > pos_y) begin
            first_clockwise_found = 1;
            first_clockwise_x = sorted_points[2][19:10];
            first_clockwise_y = sorted_points[2][9:0];
          end 
          else if(!second_clockwise_found && sorted_points[2][9:0] > pos_y) begin
            second_clockwise_found = 1;
            second_clockwise_x = sorted_points[2][19:10];
            second_clockwise_y = sorted_points[2][9:0];
          end

          if(!first_clockwise_found && sorted_points[3][9:0] > pos_y) begin
            first_clockwise_found = 1;
            first_clockwise_x = sorted_points[3][19:10];
            first_clockwise_y = sorted_points[3][9:0];
          end 
          else if(!second_clockwise_found && sorted_points[3][9:0] > pos_y) begin
            second_clockwise_found = 1;
            second_clockwise_x = sorted_points[3][19:10];
            second_clockwise_y = sorted_points[3][9:0];
          end

          params = {$signed(first_clockwise_x - pos_x), $signed(first_clockwise_y - pos_y), $signed(second_clockwise_y-first_clockwise_y)};
        end
        default: valid_out = 0;
      endcase
    end
  end

sqrt circle_sqrt(
  .valid_in(is_circle),
  .clk_in(clk_in),
  .rst_in(rst_in),
  .input_val(pos_x * pos_x + pos_y * pos_y),
  .result(params)
  .valid_out(valid_out)
);

nth_smallest #(.MAX_NUM_SIZE(20)) min_rect_pt(
  .valid_in(is_rectangle),
  .index(0),
  .numbers(composite_points),
  .min_number(composite_min),
  .valid_out(valid_out),
  .num_of_mins(num_same_x),
  .sorted(sorted_points),
);



endmodule
