module nth_smallest #(MAX_NUM_SIZE = 32, NUM_OF_NUMS = 4) 
(
    input [MAX_OF_NUMS-1:0][MAX_NUM_SIZE-1:0] logic numbers,
    input wire valid_in,
    input [$clog2(MAX_NUM_SIZE):0] index,
    output [MAX_NUM_SIZE-1:0] logic min_number,
    output wire valid_out
);

/*
    // given an array arr of length n, this code sorts it in place
    // all indices run from 0 to n-1
    for (k = 2; k <= n; k *= 2) // k is doubled every iteration
        for (j = k/2; j > 0; j /= 2) // j is halved at every iteration, with truncation of fractional parts
            for (i = 0; i < n; i++)
                l = bitwiseXOR (i, j); // in C-like languages this is "i ^ j"
                if (l > i)
                    if (  (bitwiseAND (i, k) == 0) AND (arr[i] > arr[l])
                       OR (bitwiseAND (i, k) != 0) AND (arr[i] < arr[l]) )
                          swap the elements arr[i] and arr[l]
*/
logic [MAX_NUM_SIZE] temp;
always_comb begin
    if(valid_in) begin
        for(int k = 0; k < NUM_OF_NUMS; k = k * 2) begin
            for(int j = k >> 1; j > 0; j = j >> 1) begin
                for(int i = 0; i < NUM_OF_NUMS; i = i + 1) begin
                    if(i ^ j > i) begin
                        if((i & k == 0 && numbers[i] > numbers[i ^ j]) || (i & k != 0) && (numbers[i] < numbers[i ^ j])) begin
                            temp = numbers[i];
                            numbers[i] = numbers[j];
                            numbers[j] = numbers[i];
                        end
                    end
                end
            end
        end
        min_number = numbers[index];
    end
    valid_out = valid_in;
end

endmodule