`timescale 1ns / 1ps
`default_nettype none

module tmds_encoder(
  input wire clk_in,
  input wire rst_in,
  input wire [7:0] data_in,  // video data (red, green or blue)
  input wire [1:0] control_in, //for blue set to {vs,hs}, else will be 0
  input wire ve_in,  // video data enable, to choose between control or video signal
  output logic [9:0] tmds_out
);

  logic [8:0] q_m;
  //you can assume a functioning (version of tm_choice for you.)
  tm_choice mtm(
    .data_in(data_in),
    .qm_out(q_m));

  //your code here.
  // running tally of 1s and 0s
  logic signed [4:0] tally;

  logic signed [4:0] ones_count;
  logic signed [4:0] zeros_count;

  // Determine the final 10-bit TMDS encoded output
  always_ff @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
      // reset its tally to 0 and should set the output to be all 0's
      tally <= 0;
      tmds_out <= 10'b0000000000;
    end else begin

      if (ve_in) begin
        // get 1s and 0s
        ones_count = $countones(q_m[7:0]);
        zeros_count = 4'b1000 - ones_count;

        if (tally == 0 || ones_count == zeros_count) begin
            tmds_out <= {~q_m[8], q_m[8], (q_m[8]) ? q_m[7:0] : ~q_m[7:0]};
            tally <= (q_m[8] == 0) ? (tally + zeros_count - ones_count) : (tally + ones_count - zeros_count);
        end else begin
          // choose whether to invert or not
          if ((tally > 0 && ones_count > zeros_count) || (tally < 0 && zeros_count > ones_count)) begin
            // invert q_m[7:0] and set MSB to 1
            tmds_out <= {1'b1, q_m[8], ~q_m[7:0]};
            tally <= tally + {q_m[8], 1'b0} + zeros_count - ones_count;
          end else begin
            // no inversion, set MSB to 0
            tmds_out <= {1'b0, q_m[8], q_m[7:0]};
            tally <= tally - {~q_m[8], 1'b0} + ones_count - zeros_count;
          end
        end


      end else begin
        // if ve_in is 0, the output of the module should take on one of four values based on what control_in is
        case (control_in)
          2'b00: tmds_out <= 10'b1101010100;
          2'b01: tmds_out <= 10'b0010101011;
          2'b10: tmds_out <= 10'b0101010100;
          2'b11: tmds_out <= 10'b1010101011;
          default: tmds_out <= 10'b0000000000;
        endcase
        tally <= 0;
      end
    end
  end

endmodule //end tmds_encoder
`default_nettype wire
