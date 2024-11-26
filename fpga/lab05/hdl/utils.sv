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

// logic [MAX_NUM_SIZE-1:0] first_2;
// logic [MAX_NUM_SIZE-1:0] second_2;
// logic [MAX_NUM_SIZE-1:0] third_2;
// logic [MAX_NUM_SIZE-1:0] fourth_2; 

// logic [MAX_NUM_SIZE-1:0] first_3;
// logic [MAX_NUM_SIZE-1:0] second_3;
// logic [MAX_NUM_SIZE-1:0] third_3;
// logic [MAX_NUM_SIZE-1:0] fourth_3;

logic [3:0][MAX_NUM_SIZE-1:0] local_copy;
logic [1:0] local_index;

logic one_is_min;
logic two_is_min;
logic three_is_min;
logic four_is_min;

typedef enum {IDLE, ROUND_1, ROUND_2, ROUND_3, TALLYING, RELEASE} e_states; 
e_states state;
always_comb begin
    // if(valid_in && state == IDLE) begin
    //     local_copy[0] = numbers[0];
    //     local_copy[1] = numbers[1];
    //     local_copy[2] = numbers[2];
    //     local_copy[3] = numbers[3];
    //     local_index = index;
    // end
    // first_1 = local_copy[0];
    // second_1 = local_copy[1];
    // third_1 = local_copy[2];
    // fourth_1 = local_copy[3];

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
    // if(valid_in) begin
    //     // ascending sort 1-2
    //     first_1 = (numbers[0] < numbers[1]) ? numbers[0] : numbers[1];
    //     second_1 = (numbers[0] > numbers[1]) ? numbers[0] : numbers[1];
    //     // descending sort 3-4
    //     third_1 = (numbers[2] > numbers[3]) ? numbers[2] : numbers[3];
    //     fourth_1 = (numbers[2] < numbers[3]) ? numbers[2] : numbers[3];
    //     // ascending sort 1-3
    //     first_2 = (first_1 < third_1) ? first_1 : third_1;
    //     third_2 = (first_1 > third_1) ? first_1 : third_1;
    //     // ascending sort 2-4
    //     second_2 = (second_1 < fourth_1) ? second_1 : fourth_1;
    //     fourth_2 = (second_1 > fourth_1) ? second_1 : fourth_1;
    //     // ascending sort 1-2
    //     first_3 = (first_2 < second_2) ? first_2 : second_2;
    //     second_3 = (first_2 > second_2) ? first_2 : second_2;
    //     // ascending sort 3-4
    //     third_3 = (third_2 < fourth_2) ? third_2 : fourth_2;
    //     fourth_3 = (third_2 > fourth_2) ? third_2 : fourth_2;
    //     // pick correct index
    //     case(index)
    //         2'b00 : min_number = first_3;
    //         2'b01 : min_number = second_3;
    //         2'b10 : min_number = third_3;
    //         2'b11 : min_number = fourth_3;
    //         default: min_number = 0;
    //     endcase

    //     if(first_3 == min_number) one_is_min = 1;
    //     else one_is_min = 0;
    //     if(second_3 == min_number) two_is_min = 1;
    //     else two_is_min = 0;
    //     if(third_3 == min_number) three_is_min = 1;
    //     else three_is_min = 0;
    //     if(fourth_3 == min_number) four_is_min = 1;
    //     else four_is_min = 0;
    //     num_of_mins = one_is_min + two_is_min + three_is_min + four_is_min;
    //     sorted = {first_3, second_3, third_3, fourth_3};

    // end
    // valid_out = valid_in;
end

always_ff@(posedge clk_in) begin
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