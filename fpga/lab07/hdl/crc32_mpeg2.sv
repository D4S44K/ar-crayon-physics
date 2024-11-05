module crc32_mpeg2(
            input wire clk_in,
            input wire rst_in,
            input wire data_valid_in,
            input wire data_in,
            output logic [31:0] data_out);
 
  //your code here
  // logic [31:0] quotient;
  // logic [31:0] remainder;
  // logic [31:0] dividend;
  logic xor_bit;
  // logic [31:0] to_xor;
  always_comb begin
    xor_bit = data_valid_in ? (data_out[31] ^ data_in) : xor_bit;
  end
  always_ff@(posedge clk_in) begin
    if(rst_in) begin
        data_out <= 32'hFFFF_FFFF;
        // quotient <= 0;
        // remainder <= 0;
    end
    else if(data_valid_in) begin
      data_out[0] <= xor_bit;
      data_out[31] <= data_out[30];
      data_out[30] <= data_out[29];
      data_out[29] <= data_out[28];
      data_out[28] <= data_out[27];
      data_out[27] <= data_out[26];
      data_out[26] <= data_out[25] ^ xor_bit;
      data_out[25] <= data_out[24];
      data_out[24] <= data_out[23];
      data_out[23] <= data_out[22] ^ xor_bit;
      data_out[22] <= data_out[21] ^ xor_bit;
      data_out[21] <= data_out[20];
      data_out[20] <= data_out[19];
      data_out[19] <= data_out[18];
      data_out[18] <= data_out[17];
      data_out[17] <= data_out[16];
      data_out[16] <= data_out[15] ^ xor_bit;
      data_out[15] <= data_out[14];
      data_out[14] <= data_out[13];
      data_out[13] <= data_out[12];
      data_out[12] <= data_out[11] ^ xor_bit;
      data_out[11] <= data_out[10] ^ xor_bit;
      data_out[10] <= data_out[9] ^ xor_bit;
      data_out[9] <= data_out[8];
      data_out[8] <= data_out[7] ^ xor_bit;
      data_out[7] <= data_out[6] ^ xor_bit;
      data_out[6] <= data_out[5];
      data_out[5] <= data_out[4] ^ xor_bit;
      data_out[4] <= data_out[3] ^ xor_bit;
      data_out[3] <= data_out[2];
      data_out[2] <= data_out[1] ^ xor_bit;
      data_out[1] <= data_out[0] ^ xor_bit;
    end
  end
endmodule