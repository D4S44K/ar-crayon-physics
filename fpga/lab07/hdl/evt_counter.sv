`default_nettype none
module evt_counter #(MAX_COUNT = 1_000_000_000)
  ( input wire          clk_in,
    input wire          rst_in,
    input wire          evt_in,
    output logic[$clog2(MAX_COUNT):0]  count_out
  );
 
  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      count_out <= 16'b0;
    end else begin
      if (evt_in == 1) begin
        if(count_out == MAX_COUNT - 1) count_out <= 0;
        else count_out <= count_out + 1;
      end
    end
  end
endmodule
`default_nettype wire