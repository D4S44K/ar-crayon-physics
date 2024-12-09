module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/dishakohli/6205_python/ar-crayon-physics/fpga/lab05/sim/sim_build/draw_rectangle.fst");
    $dumpvars(0, draw_rectangle);
end
endmodule
