`default_nettype none
module update_pos_vel(
    input wire data_valid_in,
    input wire [`OBJ_DYN_WIDTH-1:0] obj_dyn_in,
    input wire signed [`DF_DEC+1:0] time_step,
    output wire [2 * `SF - 1:0] obj_pos_out
  );

  wire signed [`SF-1:0] pos_x;
  wire signed [`SF-1:0] pos_y;
  wire signed [`SF-1:0] vel_x;
  wire signed [`SF-1:0] vel_y;
  {pos_x, pos_y, vel_x, vel_y} <= obj_dyn_in; // signed?

  wire signed [`SF-1:0] new_pos_x;
  assign new_pos_x = pos_x + ((vel_x * time_step) >>> `DF_DEC)[`SF-1:0]; // signed?
  wire signed [`SF-1:0] new_pos_y;
  assign new_pos_y = pos_y + ((vel_y * time_step) >>> `DF_DEC)[`SF-1:0];

  assign obj_pos_out = data_valid_in ? {new_pos_y, new_pos_x} : 0;

endmodule

