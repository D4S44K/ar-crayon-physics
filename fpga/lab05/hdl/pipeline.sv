`default_nettype none
module pipeline #(
  parameter WIDTH=8,
  parameter STAGES)(
    input wire clk_pixel,
    input wire [WIDTH-1: 0] signal,
    // input wire [4:0] stages,
    output logic [WIDTH-1:0] delayed_signal
);
    logic [WIDTH-1:0] delayed_pipe [STAGES-1:0];

    always_ff @(posedge clk_pixel)begin
        delayed_pipe[0] <= signal;
        for (int i=1; i<STAGES; i = i+1)begin
            delayed_pipe[i] <= delayed_pipe[i-1];
        end
    end

    assign delayed_signal = delayed_pipe[STAGES-1];

endmodule

`default_nettype wire
