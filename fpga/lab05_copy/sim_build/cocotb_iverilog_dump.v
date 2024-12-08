module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/danielvargas/Desktop/MIT/6.205/lab05/sim_build/center_of_mass.fst");
    $dumpvars(0, center_of_mass);
end
endmodule
