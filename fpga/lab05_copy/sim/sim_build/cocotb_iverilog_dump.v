module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/dishakohli/6205_python/ar-crayon-physics/fpga/lab05/sim/sim_build/draw_to_storage_conversion.fst");
    $dumpvars(0, draw_to_storage_conversion);
end
endmodule
