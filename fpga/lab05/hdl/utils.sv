module circle_converter
(
    input wire [114:0] object_props,
    input wire is_valid_in,
    output logic is_static,
    output logic [10:0] x_in_1,
    output logic [9:0] y_in_1,
    output logic [10:0] x_in_2,
    output logic [9:0] y_in_2,
    output logic is_valid_out
);
logic [15:0] radius;
logic [15:0] center_x;
logic [15:0] center_y;
always_comb begin
    is_static = object_props[114:114];
    center_x = object_props[111:96];
    center_y = object_props[95:80];
    radius = object_props[47:32];
    x_in_1 = center_x - radius;
    y_in_1 = center_y;
    x_in_2 = center_x + radius;
    y_in_2 = center_y;
    is_valid_out = is_valid_in;
end

endmodule

module rect_converter
(
    input wire clk_in,
    input wire is_valid_in,
    input wire rst_in,
    input wire [114:0] object_props,
    output logic is_static,
    output logic [10:0] x_in_1,
    output logic [9:0] y_in_1,
    output logic [10:0] x_in_2,
    output logic [9:0] y_in_2,
    output logic busy_out,
    output logic is_valid_out
);
logic signed [15:0] dx_1;
logic signed[15:0] dy_1;
logic signed [15:0] dy_2;
logic signed [15:0] dx_2;
logic [31:0] dx_2_temp;
logic [31:0] remainder; 
logic is_divide_done;
logic has_error;
logic is_busy_out;
always_comb begin
    is_static = object_props[114:114];
    x_in_1 = object_props[110:100];
    y_in_1 = object_props[94:85];
    dx_1 = object_props[79:64];
    dy_1 = object_props[63:48];
    dy_2 = object_props[47:32];
    // dx_2 = {1'b0, dx_2_temp[9:0], 5'b0};
    y_in_2 = y_in_1 + dy_1 + dy_2;
    x_in_2 = x_in_1 + dx_1;
end

// divider dx_2_calc 
// (
//     .clk_in(clk_in),
//     .rst_in(rst_in),
//     .dividend_in(-dy_1 * dy_2),
//     .divisor_in(dx_1),
//     .data_valid_in(!has_started && is_valid_in),
//     .quotient_out(dx_2_temp),
//     .remainder_out(remainder),
//     .data_valid_out(is_divide_done),
//     .error_out(has_error),
//     .busy_out(is_busy_out)
// );

// always_ff@(posedge clk_in) begin
//     if(rst_in) begin
//         is_valid_out <= 0;
//         busy_out <= 0;
//     end
//     else if(!has_started) begin 
//         has_started <= 1;
//         busy_out <= 1;
//     end
//     else if(is_divide_done) begin
//         x_in_2 <= x_in_1 + dx_1 + dx_2;
//         is_valid_out <= !has_error;
//         busy_out <= 0;
//     end
// end

endmodule

module line_converter
(
    input wire [114:0] object_props,
    input wire is_valid_in,
    output logic is_static,
    output logic [10:0] x_in_1,
    output logic [9:0] y_in_1,
    output logic [10:0] x_in_2,
    output logic [9:0] y_in_2,
    output logic is_valid_out
);
always_comb begin
    is_static = object_props[114:114];
    x_in_1 = object_props[110:100];
    y_in_1 = object_props[94:85];
    x_in_2 = object_props[63:48];
    y_in_2 = object_props[47:32];
    is_valid_out = is_valid_in;
end
endmodule


module nth_smallest #(parameter MAX_NUM_SIZE = 32) 
(
    input logic [3:0][MAX_NUM_SIZE-1:0] numbers,
    // delete after testing
    input wire clk_in,
    input wire valid_in,
    input wire rst_in,
    input logic [1:0] index,
    output logic [MAX_NUM_SIZE-1:0] nth_min,
    output logic [1:0] num_of_mins,
    output logic [3:0][MAX_NUM_SIZE-1:0] sorted,
    output logic busy_out,
    output logic valid_out
);

logic [MAX_NUM_SIZE-1:0] first_1;
logic [MAX_NUM_SIZE-1:0] second_1;
logic [MAX_NUM_SIZE-1:0] third_1;
logic [MAX_NUM_SIZE-1:0] fourth_1;

logic [3:0][MAX_NUM_SIZE-1:0] local_copy;
logic [1:0] local_index;

logic one_is_min;
logic two_is_min;
logic three_is_min;
logic four_is_min;

typedef enum {IDLE, ROUND_1, ROUND_2, ROUND_3, TALLYING, RELEASE} e_states; 
e_states state;
always_comb begin
    $display("started comb");

    if(state == RELEASE) begin
        if(local_copy[0] == nth_min) one_is_min = 1;
        else one_is_min = 0;
        if(local_copy[1] == nth_min) two_is_min = 1;
        else two_is_min = 0;
        if(local_copy[2] == nth_min) three_is_min = 1;
        else three_is_min = 0;
        if(local_copy[3] == nth_min) four_is_min = 1;
        else four_is_min = 0;
        num_of_mins = one_is_min + two_is_min + three_is_min + four_is_min;
        state = IDLE;
    end
end

always_ff@(posedge clk_in) begin
    $display("started ff");
    if(rst_in) begin
        state <= IDLE;
        busy_out <= 0;
        valid_out <= 0;
    end
    else if(valid_out) valid_out <= 0;
    else if(state == IDLE && valid_in) begin
        state <= ROUND_1;
        busy_out <= 1;
        valid_out <= 0;
        local_index <= index;
    end
    else if(state == ROUND_1) begin
        state <= ROUND_2;
        // ascending sort 1-2
        local_copy[0] <= (numbers[0] < numbers[1]) ? numbers[0] : numbers[1];
        local_copy[1] <= (numbers[0] > numbers[1]) ? numbers[0] : numbers[1];
        // descending sort 3-4
        local_copy[2] <= (numbers[2] > numbers[3]) ? numbers[2] : numbers[3];
        local_copy[3] <= (numbers[2] < numbers[3]) ? numbers[2] : numbers[3];
        busy_out <= 1;
        valid_out <= 0;
    end
    else if(state == ROUND_2) begin
        state <= ROUND_3;
        // ascending sort 1-3
        local_copy[0] <= (local_copy[0] < local_copy[2]) ? local_copy[0] : local_copy[2];
        local_copy[2] <= (local_copy[0] > local_copy[2]) ? local_copy[0] : local_copy[2];
        // ascending sort 2-4
        local_copy[1] <= (local_copy[1] < local_copy[3]) ? local_copy[1] : local_copy[3];
        local_copy[3] <= (local_copy[1] > local_copy[3]) ? local_copy[1] : local_copy[3];
        busy_out <= 1;
        valid_out <= 0;
    end
    else if(state == ROUND_3) begin
        state <= TALLYING;
        // ascending sort 1-2
        local_copy[0] <= (local_copy[0] < local_copy[1]) ? local_copy[0] : local_copy[1];
        local_copy[1] <= (local_copy[0] > local_copy[1]) ? local_copy[0] : local_copy[1];
        // descending sort 3-4
        local_copy[2] <= (local_copy[2] < local_copy[3]) ? local_copy[2] : local_copy[3];
        local_copy[3] <= (local_copy[2] > local_copy[3]) ? local_copy[2] : local_copy[3];
        busy_out <= 1;
        valid_out <= 0; 
    end
    else if(state == TALLYING) begin
        // pick correct index
        state <= RELEASE;
        sorted[0] <= local_copy[0];
        sorted[1] <= local_copy[1];
        sorted[2] <= local_copy[2];
        sorted[3] <= local_copy[3];
        // nth_min <= local_copy[local_index];
        case(local_index)
            2'b00: begin nth_min <= local_copy[0]; valid_out <= 1; end
            2'b01: begin nth_min <= local_copy[1]; valid_out <= 1; end
            2'b10: begin nth_min <= local_copy[2]; valid_out <= 1; end
            2'b11: begin nth_min <= local_copy[3]; valid_out <= 1; end
            default: begin nth_min <= 0; valid_out <= 0; end
        endcase
        busy_out <= 0;
        valid_out <= 1;

    end
end

endmodule