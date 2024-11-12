module tm_choice (
  input wire [7:0] data_in,
  output logic [8:0] qm_out
  );


  // Count the number of 1s in the input byte
  logic [3:0] num_1s;
  logic lsb;

  always_comb begin
    num_1s = 0;

    // count number of 1s
    for (int i = 0; i < 8; i = i + 1) begin
      if (data_in[i] == 1) begin
        num_1s = num_1s + 1;
      end
    end

    // get lsb
    lsb = data_in[0];

    // option 2 check
    if (num_1s > 4 || (num_1s == 4 && lsb == 0)) begin
      qm_out[0] = data_in[0];
      for (int i = 1; i < 8; i = i + 1) begin
        qm_out[i] = ~(data_in[i] ^ qm_out[i - 1]);
      end
      // set 9th bit to 0 for option 2
      qm_out[8] = 0;
    // else, use option 1
    end else begin
      qm_out[0] = data_in[0];
      for (int i = 1; i < 8; i = i + 1) begin
        qm_out[i] = data_in[i] ^ qm_out[i - 1];
      end
      // set 9th bit to 1 for option 1
      qm_out[8] = 1;
    end
  end

endmodule
