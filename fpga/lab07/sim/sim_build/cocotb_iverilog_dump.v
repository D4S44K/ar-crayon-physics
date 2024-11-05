module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/dishakohli/6205_python/lab07/sim/sim_build/convolution.fst");
    $dumpvars(0, convolution);
end
endmodule
