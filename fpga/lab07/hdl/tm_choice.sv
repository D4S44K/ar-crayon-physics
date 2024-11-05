module tm_choice (
  input wire [7:0] data_in,
  output logic [8:0] qm_out
  );

  logic [4:0] counter;
//   logic  y_values[7:0];

//   logic bit_0;
//   logic bit_1;
//   logic bit_2;
//   logic bit_3;
//   logic bit_4;
//   logic bit_5;
//   logic bit_6;
//   logic bit_7;
//   logic bit_8;

  logic lsb;
  logic to_negate;
  
  assign lsb = data_in[0];
  always_comb begin
    counter = 0;
    for(int i = 0; i <= 7; i = i + 1) begin
        if(data_in[i] == 1) counter = counter + 1;
    end
    // bit_0 = data_in[1:0];
    if(counter > 4 || (counter == 4 && lsb == 0)) begin
        // Option 2
        // bit_1 = ~(data_in[2:1] ^ bit_0);
        // bit_2 = ~(data_in[3:2] ^ bit_1);
        // bit_3 = ~(data_in[4:3] ^ bit_2);
        // bit_4 = ~(data_in[5:4] ^ bit_3);
        // bit_5 = ~(data_in[6:5] ^ bit_4);
        // bit_6 = ~(data_in[7:6] ^ bit_5);
        // bit_7 = ~(data_in[8:7] ^ bit_6);
        // bit_8 = 0;
        // y_values[8] = 1;
        to_negate = 1;
    end
    else begin
        // Option 1
        // bit_1 = (data_in[2:1] ^ bit_0);
        // bit_2 = (data_in[3:2] ^ bit_1);
        // bit_3 = (data_in[4:3] ^ bit_2);
        // bit_4 = (data_in[5:4] ^ bit_3);
        // bit_5 = (data_in[6:5] ^ bit_4);
        // bit_6 = (data_in[7:6] ^ bit_5);
        // bit_7 = (data_in[8:7] ^ bit_6);
        // bit_8 = 1;
        // y_values[8] = 0;
        to_negate = 0;
    end
    
    // qm_out = {bit_8, bit_7, bit_6, bit_5, bit_4, bit_3, bit_2, bit_1, bit_0};
    

    for(int n = 0; n <= 8; n = n + 1)begin
        if(n == 0) qm_out[n] = lsb;
        else if(n == 8) qm_out[n] = ~to_negate;
        else begin
            logic temp_bit;
            temp_bit = data_in[n] ^ qm_out[n-1];
            if(to_negate == 1) qm_out[n] = ~temp_bit;
            else qm_out[n] = temp_bit;
        end
    end
    // qm_out = {to_negate, y_values};
    // qm_out = y_values;

  end
 
endmodule