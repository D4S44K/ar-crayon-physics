`default_nettype none
module update_collision_vel #(OBJ_DYN_WIDTH=64, DF=32, SF=16)(
    input wire sys_clk,
    input wire sys_rst,
    input wire data_valid_in,
    input wire [OBJ_DYN_WIDTH-1:0] obj_in,
    input wire [DF-1:0] time_step,

    output wire data_valid_out,
    output wire [OBJ_DYN_WIDTH-1:0] obj_out
  );
  // should be completed in 2 cycles


endmodule
