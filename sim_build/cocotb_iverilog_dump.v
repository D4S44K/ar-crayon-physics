module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/danielvargas/Desktop/MIT/6.205/ar-crayon-physics/sim_build/draw_rectangle.fst");
    $dumpvars(0, draw_rectangle);
end
endmodule
