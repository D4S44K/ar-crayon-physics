`default_nettype none
`define CLAMP(x, min, max) (x < min ? min : (x > max ? max : x))
`define SF_MIN -2**(`SF-1)
`define SF_MAX 2**(`SF-1)-1
`define OBJ_DYN_WIDTH 64
`define OBJ_WIDTH 115
`define SF 16
`define SF_DEC 5
`define DF 32
`define DF_DEC 11

module update_pos_vel(
    input wire sys_clk,
    input wire [`OBJ_WIDTH-1:0] obj_in,
    input wire signed [`DF_DEC+1:0] time_step,
    output logic [`OBJ_WIDTH-1:0] obj_out
  );
  localparam MULT_WIDTH = `OBJ_DYN_WIDTH + `DF_DEC + 1; // signed

  wire signed [`SF-1:0] pos_x;
  wire signed [`SF-1:0] pos_y;
  wire signed [`SF-1:0] vel_x;
  wire signed [`SF-1:0] vel_y;
  assign {pos_x, pos_y, vel_x, vel_y} = obj_in[`OBJ_DYN_WIDTH-1:0];

  wire is_static;
  wire [1:0] obj_type;
  assign is_static = obj_in[`OBJ_WIDTH-1];
  assign obj_type = obj_in[`OBJ_WIDTH-2:`OBJ_WIDTH-3];
  logic should_update;
  assign should_update = (obj_type != 2'b00) && !is_static;

  wire signed [MULT_WIDTH-1:0] new_pos_x;
  wire signed [MULT_WIDTH-1:0] df_x;
  assign df_x = (vel_x * time_step) >>> `DF_DEC;
  assign new_pos_x = `CLAMP(pos_x + df_x, `SF_MIN, `SF_MAX);
  wire signed [MULT_WIDTH-1:0] new_pos_y;
  wire signed [MULT_WIDTH-1:0] df_y;
  assign df_y = (vel_y * time_step) >>> `DF_DEC;
  assign new_pos_y = `CLAMP(pos_y + df_y, `SF_MIN, `SF_MAX);

  wire signed [`SF-1:0] new_vel_y;
  assign new_vel_y = vel_y + (time_step >>> (`DF_DEC - `SF_DEC)); // gravity

  // assign obj_pos_out  = {new_pos_x[`SF-1:0], new_pos_y[`SF-1:0]};
  // assign obj_dyn_out = {new_pos_x[`SF-1:0], new_pos_y[`SF-1:0], vel_x, new_vel_y};
  assign obj_out = should_update ? {obj_in[`OBJ_WIDTH-1:`OBJ_DYN_WIDTH], new_pos_x[`SF-1:0], new_pos_y[`SF-1:0], vel_x, new_vel_y} : obj_in;

endmodule