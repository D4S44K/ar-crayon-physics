module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/danielvargas/Desktop/MIT/6.205/ar-crayon-physics/sim_build/sqrt.fst");
    $dumpvars(0, sqrt);
end
endmodule
