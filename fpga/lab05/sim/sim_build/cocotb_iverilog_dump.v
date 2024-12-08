module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/dishakohli/6205_python/ar-crayon-physics/fpga/lab05/sim/sim_build/sqrt.fst");
    $dumpvars(0, sqrt);
end
endmodule
