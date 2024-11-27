module draw_to_storage_conversion (
    // input:  (is_static) (id_bits) (point_one) (point_two) (point_three/trailing-zeroes)
    // output: (is_static) (id_bits) (params) (pos_y) (pos_x) (vel_x) (vel_y)
    input wire clk_in,
    input logic valid_in,
    input logic [86:0] draw_props, // 63 bits (actually, let's do 83 bits, using all four rectangle points)
    output logic is_static, // 1 bit
    output logic [1:0] id_bits, // 2 bits
    output logic [35:0] params, // 36 bits
    output logic [10:0] pos_x, // 101bits
    output logic [9:0] pos_y, // 10 bits
    output logic [15:0] vel_x, // 16 bits
    output logic [15:0] vel_y, // 16 bits
    output logic valid_out, // 1 bit
    output logic busy_out
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
  logic sqrt_valid;
  logic sqrt_busy;
  logic has_sqrt_run;
  logic is_sqrt_stage_1;
  logic is_sqrt_stage_2;
  logic nth_busy;
  logic nth_valid;
  logic has_nth_run;
  logic [20:0] prod_x;
  logic [20:0] prod_y;
  logic prod_valid;
  logic is_point_1_bigger;
  logic is_point_2_bigger;
  logic is_point_3_bigger;
  logic calculations_valid;
  // assign composite_x = {point_one_x, point_two_x, point_three_x, point_four_x};
  // assign composite_y = {point_one_y, point_two_y, point_three_y, point_four_y};
  assign composite_points = {point_one_x, point_one_y, point_two_x, point_two_y, point_three_x, point_three_y, point_four_x, point_four_y};
  // logic [31:0] radius;
  always_comb begin
    if(rst_in) begin
      valid_out <= 0;
      sqrt_valid <= 0;
      nth_valid <= 0;
      has_nth_run <= 0;
      has_sqrt_run <= 0;
    end
    if(valid_in) begin
      point_one_x = draw_props[83:73];
      point_one_y = draw_props[72:63];
      point_two_x = draw_props[62:52];
      point_two_y = draw_props[51:42];
      point_three_x = draw_props[41:31];
      point_three_y = draw_props[30:21];
      point_four_x = draw_props[20:10];
      point_four_y = draw_props[9:0];
      is_static = draw_props[86:86];
      id_bits = draw_props[85:84];
      busy_out = nth_busy || sqrt_busy;
      vel_x = 0;
      vel_y = 0;
      case(id_bits)
        // not defined
        2'b00: begin
          params = 0;
          pos_x = 0;
          pos_y = 0;
          valid_out = 0;
          is_rectangle = 0;
          is_circle = 0;
        end
        // circle: params has radius
        2'b01: begin
          is_circle = 1;
          pos_x = (point_one_x + point_two_x) >> 2;
          pos_y = (point_one_y + point_two_y) >> 2;
          valid_out = sqrt_valid;
          is_rectangle = 0;
          // if(sqrt_valid) has_sqrt_run = 1;
        end
        // line
        2'b10: begin
          pos_x = point_one_x;
          pos_y = point_one_y;
          params = {point_two_x, point_two_y};
          valid_out = 1;
          is_rectangle = 0;
          is_circle = 0;
        end
        // rectangle
        // schema: pos_x and pos_y are point_one x and y, 
        2'b11: begin
          is_rectangle = 1;
          // pos_x = point_one_x;
          // pos_y = point_one_y;
          // params = {point_two_x, point_two_y, 16'b0};
          valid_out = calculations_valid;
          pos_x = composite_min[19:10];
          pos_y = composite_min[9:0];
          is_rectangle = 0;
          is_circle = 0;

          if(!first_clockwise_found && is_point_1_bigger) begin
            first_clockwise_found = 1;
            first_clockwise_x = sorted_points[1][19:10];
            first_clockwise_y = sorted_points[1][9:0];
          end 
          else if(!second_clockwise_found && is_point_1_bigger) begin
            second_clockwise_found = 1;
            second_clockwise_x = sorted_points[1][19:10];
            second_clockwise_y = sorted_points[1][9:0];
          end

          if(!first_clockwise_found && is_point_2_bigger) begin
            first_clockwise_found = 1;
            first_clockwise_x = sorted_points[2][19:10];
            first_clockwise_y = sorted_points[2][9:0];
          end 
          else if(!second_clockwise_found && is_point_2_bigger) begin
            second_clockwise_found = 1;
            second_clockwise_x = sorted_points[2][19:10];
            second_clockwise_y = sorted_points[2][9:0];
          end

          if(!first_clockwise_found && is_point_3_bigger) begin
            first_clockwise_found = 1;
            first_clockwise_x = sorted_points[3][19:10];
            first_clockwise_y = sorted_points[3][9:0];
          end 
          else if(!second_clockwise_found && is_point_3_bigger) begin
            second_clockwise_found = 1;
            second_clockwise_x = sorted_points[3][19:10];
            second_clockwise_y = sorted_points[3][9:0];
          end

          params = {$signed(first_clockwise_x - pos_x), $signed(first_clockwise_y - pos_y), $signed(second_clockwise_y-first_clockwise_y)};
        end
        default: begin 
          valid_out = 0; 
          is_rectangle = 0;
          is_circle = 0;
          end
      endcase
    end
  end


// run sqrt only once
sqrt circle_sqrt(
  .valid_in(is_circle && prod_valid),
  .clk_in(clk_in),
  .rst_in(rst_in),
  // separate into two cycles
  .input_val(prod_x + prod_y),
  .result(params),
  .valid_out(sqrt_valid),
  .busy_out(sqrt_busy)
);

// run nth smallest only once
nth_smallest #(.MAX_NUM_SIZE(20)) min_rect_pt(
  .valid_in(is_rectangle && is_valid),
  .index(0),
  .numbers(composite_points),
  .min_number(composite_min),
  .valid_out(nth_valid),
  .num_of_mins(num_same_x),
  .sorted(sorted_points),
  .busy_out(nth_busy),
  .clk_in(clk_in),
  .rst_in(rst_in)
);

always_ff@(posedge clk_in) begin
  if(is_circle && is_valid) begin
    prod_x <= (pos_x - point_one_x) * (pos_x - point_one_x);
    prod_y <= (pos_y - point_one_y) * (pos_y - point_one_y);
    prod_valid <= is_valid;
  end
  else if(is_rectangle && nth_valid) begin
    is_point_1_bigger <= sorted_points[1][9:0] > pos_y;
    is_point_2_bigger <= sorted_points[2][9:0] > pos_y;
    is_point_3_bigger <= sorted_points[3][9:0] > pos_y;
    calculations_valid <= 1;
  end
end



endmodule
