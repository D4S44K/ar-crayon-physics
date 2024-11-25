module nth_smallest #(parameter MAX_NUM_SIZE = 32) 
(
    input logic [MAX_NUM_SIZE-1:0] numbers [3:0],
    // delete after testing
    input wire clk_in,
    input wire valid_in,
    input logic [1:0] index,
    output logic [MAX_NUM_SIZE-1:0] min_number,
    output logic valid_out
);

logic [MAX_NUM_SIZE-1:0] first_1;
logic [MAX_NUM_SIZE-1:0] second_1;
logic [MAX_NUM_SIZE-1:0] third_1;
logic [MAX_NUM_SIZE-1:0] fourth_1;

logic [MAX_NUM_SIZE-1:0] first_2;
logic [MAX_NUM_SIZE-1:0] second_2;
logic [MAX_NUM_SIZE-1:0] third_2;
logic [MAX_NUM_SIZE-1:0] fourth_2; 

logic [MAX_NUM_SIZE-1:0] first_3;
logic [MAX_NUM_SIZE-1:0] second_3;
logic [MAX_NUM_SIZE-1:0] third_3;
logic [MAX_NUM_SIZE-1:0] fourth_3;
always_comb begin
    if(valid_in) begin
        // ascending sort 1-2
        first_1 = (numbers[0] < numbers[1]) ? numbers[0] : numbers[1];
        second_1 = (numbers[0] > numbers[1]) ? numbers[0] : numbers[1];
        // descending sort 3-4
        third_1 = (numbers[2] > numbers[3]) ? numbers[2] : numbers[3];
        fourth_1 = (numbers[2] < numbers[3]) ? numbers[2] : numbers[3];
        // ascending sort 1-3
        first_2 = (first_1 < third_1) ? first_1 : third_1;
        third_2 = (first_1 > third_1) ? first_1 : third_1;
        // ascending sort 2-4
        second_2 = (second_1 < fourth_1) ? second_1 : fourth_1;
        fourth_2 = (second_1 > fourth_1) ? second_1 : fourth_1;
        // ascending sort 1-2
        first_3 = (first_2 < second_2) ? first_2 : second_2;
        second_3 = (first_2 > second_2) ? first_2 : second_2;
        // ascending sort 3-4
        third_3 = (third_2 < fourth_2) ? third_2 : fourth_2;
        fourth_3 = (third_2 > fourth_2) ? third_2 : fourth_2;
        // pick correct index
        case(index)
            2'b00 : min_number = first_3;
            2'b01 : min_number = second_3;
            2'b10 : min_number = third_3;
            2'b11 : min_number = fourth_3;
            default: min_number = 0;
        endcase
    end
    valid_out = valid_in;
end

endmodule