`default_nettype none

module update_pos_vel(
    input wire [`OBJ_DYN_WIDTH-1:0] obj_dyn_in,
    input wire signed [`DF_DEC+1:0] time_step,
    output wire [2 * `SF - 1:0] obj_pos_out
  );

  wire signed [`SF-1:0] pos_x;
  wire signed [`SF-1:0] pos_y;
  wire signed [`SF-1:0] vel_x;
  wire signed [`SF-1:0] vel_y;
  assign {pos_x, pos_y, vel_x, vel_y} = obj_dyn_in; // signed?


  wire signed [`SF-1:0] new_pos_x;
  wire signed [`SF-1:0] df_x;
  assign df_x = (vel_x * time_step) >>> `DF_DEC;
  assign new_pos_x = pos_x + df_x;
  wire signed [`SF-1:0] new_pos_y;
  wire signed [`SF-1:0] df_y;
  assign df_y = (vel_y * time_step) >>> `DF_DEC;
  assign new_pos_y = pos_y + df_y;

  assign obj_pos_out = {new_pos_y, new_pos_x};

endmodule
