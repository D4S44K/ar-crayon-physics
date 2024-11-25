module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/dishakohli/6205_python/ar-crayon-physics/fpga/lab05/sim/sim_build/nth_smallest.fst");
    $dumpvars(0, nth_smallest);
end
endmodule
