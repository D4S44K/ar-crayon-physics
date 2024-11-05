`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module tmds_encoder(
  input wire clk_in,
  input wire rst_in,
  input wire [7:0] data_in,  // video data (red, green or blue)
  input wire [1:0] control_in, //for blue set to {vs,hs}, else will be 0
  input wire ve_in,  // video data enable, to choose between control or video signal
  output logic [9:0] tmds_out
);
 
  logic [8:0] q_m;
  logic [4:0] tally;
  logic [4:0] num_1;
  logic [4:0] num_0;
 
  tm_choice mtm(
    .data_in(data_in),
    .qm_out(q_m));

  always_comb begin
    num_0 = 0;
    num_1 = 0;
    for(int i = 0; i <= 7; i = i + 1) begin
        if(q_m[i] == 1) num_1 = num_1 + 1;
        else num_0 = num_0 + 1;
    end
  end
 
  always_ff@(posedge clk_in) begin
    if(rst_in == 1) tally <= 0;
    else if(ve_in == 0) begin
        tally <= 0;
        if(control_in == 2'b00) tmds_out <= 10'b1101010100;
        else if(control_in == 2'b01) tmds_out <= 10'b0010101011;
        else if(control_in == 2'b10) tmds_out <= 10'b0101010100;
        else tmds_out <= 10'b1010101011;
    end
    else begin
        if(tally == 0 || (num_0 == num_1)) begin
            tmds_out[9] <= (q_m[8] == 0) ? 1 : 0;
            tmds_out[8] <= q_m[8];
            tmds_out[7:0] <= (q_m[8] == 1) ? q_m[7:0] : ~q_m[7:0];
            tally <= (q_m[8] == 0) ? tally + num_0 - num_1 : tally + num_1 - num_0;
        end
        else begin
            if((tally[4] == 0 && (num_1 > num_0)) || (tally[4] == 1 && (num_0 > num_1))) begin
                tmds_out[9] <= 1;
                tmds_out[8] <= q_m[8];
                tmds_out[7:0] <= ~q_m[7:0];
                tally <= tally + q_m[8] + q_m[8] + (num_0 - num_1);
            end
            else begin
                tmds_out[9] <= 0;
                tmds_out[8] <= q_m[8];
                tmds_out[7:0] <= q_m[7:0];
                tally <= tally - ((q_m[8] == 0) ? 2 : 0) + (num_1 - num_0);
            end
        end
    end
  end
 
endmodule
 
`default_nettype wire