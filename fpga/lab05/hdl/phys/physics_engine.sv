`default_nettype none
`define SF 16
`define SF_DEC 5
`define DF 32
`define DF_DEC 11
`define SFIX16(x) (x << `SF_DEC)
`define SFIX32(x) (x << `DF_DEC)

`define OBJ_WIDTH 103
`define OBJ_PART_WIDTH 66
`define OBJ_DYN_WIDTH 64 // MEMORYIO: pos and vel is [63-0] bits of object

module physics_engine #(OBJ_COUNT=8, MAX_ITER=64)(
    input wire sys_clk,
    input wire sys_rst,
    input wire frame_start_in,
    output enum logic [2:0] {IDLE, LOADING, COLLISION, UPDATING, SAVING} state_out,
    output logic frame_end_out
  );
  localparam OBJ_COUNT_LOG = $clog2(OBJ_COUNT+1); // one more bit for null value = OBJ_COUNT

  logic [`DF-1:0] left_time, time_step; // TODO - leave only deciamls
  logic [7:0] iter_count; // up to 64 iterations
  logic [OBJ_COUNT_LOG:0] obj_index_i, obj_index_j;
  // logic [`OBJ_WIDTH-1:0] obj_i1, obj_i2, obj_j1, obj_j2
  logic [`OBJ_WIDTH-1:0] objects[OBJ_COUNT-1:0];
  logic [`OBJ_DYN_WIDTH-1:0] obj_dyn_next[OBJ_COUNT-1:0];
  logic [9:0] cooldown;

  // for LOADING
  logic do_save;
  logic [6:0] save_addr;
  logic [3:0] do_load;
  logic [3:0][6:0] load_addr;
  logic [3:0] load_finished;

  logic save_is_static;
  logic [1:0] save_id_bits;
  logic [35:0] save_params;
  logic [15:0] save_pos_x;
  logic [15:0] save_pos_y;
  logic [15:0] save_vel_x;
  logic [15:0] save_vel_y;

  logic [3:0] loaded_is_static;
  logic [3:0][1:0] loaded_id_bits;
  logic [3:0][35:0] loaded_params;
  logic [3:0][15:0] loaded_pos_x;
  logic [3:0][15:0] loaded_pos_y;
  logic [3:0][15:0] loaded_vel_x;
  logic [3:0][15:0] loaded_vel_y;

  // object_storage memory( // TODO IO with top_level
  //                  .clk_in(sys_clk),
  //                  .rst_in(sys_rst),

  //                  .write_valid_in(do_save),
  //                  .save_addr_in(save_addr),
  //                  .is_static_in(save_is_static),
  //                  .id_bits_in(save_id_bits),
  //                  .params_in(save_params),
  //                  .pos_x_in(save_pos_x),
  //                  .pos_y_in(save_pos_y),
  //                  .vel_x_in(save_vel_x),
  //                  .vel_y_in(save_vel_y),

  //                  .read_valid_in(do_load),
  //                  .load_addr_in(load_addr), // was current_addr
  //                  .is_static_out(loaded_is_static),
  //                  .id_bits_out(loaded_id_bits),
  //                  .params_out(loaded_params),
  //                  .pos_x_out(loaded_pos_x),
  //                  .pos_y_out(loaded_pos_y),
  //                  .vel_x_out(loaded_vel_x),
  //                  .vel_y_out(loaded_vel_y),
  //                  .is_valid_out(load_finished)
  //                );

  // for UPDATING
  generate
    genvar i;
    for (i=0; i<OBJ_COUNT; i=i+1)
    begin
      update_pos_vel upv_i(
                       .obj_dyn_in(objects[i][`OBJ_DYN_WIDTH-1:0]), // MEMORYIO
                       .time_step(time_step[`DF_DEC+1:0]),
                       .obj_pos_out(obj_dyn_next[i][`OBJ_DYN_WIDTH-1: `OBJ_DYN_WIDTH-2*`SF])
                     );
    end
  endgenerate

  always_ff @(posedge sys_clk)
  begin
    if (sys_rst)
    begin
      state_out <= IDLE;
      frame_end_out <= 1'b0;

      left_time <= 0;
      time_step <= 0;
      iter_count <= 0;
      obj_index_i <= 0;
      obj_index_j <= 0;
      cooldown <= 0;

      for (int i=0; i<OBJ_COUNT; i=i+1)
      begin
        objects[i] <= 0;
      end
    end
    else
    begin
      case (state_out)
        IDLE:
        begin
          // wait for the frame_start_in signal
          //  if so, initialize variables and go to LOADING

          frame_end_out <= 1'b0;

          left_time <= `SFIX32(1);
          time_step <= `SFIX32(1);
          iter_count <= 0;
          obj_index_i <= 0;
          obj_index_j <= 0;
          cooldown <= 0;

          if (frame_start_in)
          begin
            state_out <= LOADING;
          end
        end

        LOADING: /* loading from BRAM */
        begin
          // load all objects from BRAM to registers
          //  and go to COLLISION
          // pipeline?

          if (cooldown < 4)
          begin
            cooldown <= cooldown + 1;
          end
          else
          begin
            // if i'm expecting results, fetch and save
            if (obj_index_i > 0)
            begin
              for (int i=0; i<OBJ_COUNT; i=i+1)
              begin
                objects[obj_index_i - 4 + i] <= {loaded_is_static[i], loaded_id_bits[i], loaded_params[i], loaded_pos_x[i], loaded_pos_y[i], loaded_vel_x[i], loaded_vel_y[i]};
              end
            end

            // if we've done all, move to next state. otherwise, update index
            if (obj_index_i == OBJ_COUNT)
            begin
              state_out <= COLLISION;
              cooldown <= 0;
              obj_index_i <= 0;
            end
            else
            begin
              // fill the memory read instructions and start waiting again
              do_load <= 4'b1111;
              load_addr[0] <= obj_index_i;
              load_addr[1] <= obj_index_i + 1;
              load_addr[2] <= obj_index_i + 2;
              load_addr[3] <= obj_index_i + 3;

              obj_index_i <= obj_index_i + 4;
              cooldown <= 0;
            end
          end
        end

        COLLISION:  /* main loop */
        begin
          // iterate through all objects with i,j, get the earliest collision time
          //  and then go to UPDATING

          state_out <= UPDATING; // not implemented yet
          cooldown <= 0;


          /*
          if (cooldown < 512) // TODO ??
          begin
            cooldown <= cooldown + 1;
          end
          else
          begin
            // coll_AB(obj_i, obj_i+1)
            // coll_AC(obj_i, obj_j)
            // coll_AD(obj_i, obj_j+1)
            // coll_BC(obj_i+1, obj_j)
            // coll_BD(obj_i+1, obj_j+1)
            // coll_CD(obj_j, obj_j+1)

            if (obj_index_i == OBJ_COUNT)
            begin
              state_out <= UPDATING;
              obj_index_i <= 0;
              obj_index_j <= 0;
            end
            else
            begin
              if (obj_index_j == OBJ_COUNT)
              begin
                obj_index_i <= obj_index_i + 2;
                obj_index_j <= obj_index_i + 4;
              end
              else
              begin
                obj_index_j <= obj_index_j + 2;
              end
            end
          end

          cooldown <= 0;
          */
        end

        UPDATING: /* updating positions and velocities */
        begin
          // update positions and velocities of all objects for time_step,
          //  update velocity of collision pair, only to registers
          //  if left_time is 0, go to SAVING

          if (cooldown < 2)
          begin // wait until all objects are updated (is this needed?)
            cooldown <= cooldown + 1;
          end
          else
          begin
            for (int i=0; i<OBJ_COUNT; i=i+1)
            begin
              objects[i] <= {objects[i][`OBJ_WIDTH-1:`OBJ_DYN_WIDTH], obj_dyn_next[i]}; // MEMORYIO
            end

            if (left_time <= time_step)
            begin // frame is completed
              state_out <= SAVING;
              cooldown <= 0;
              left_time <= 0;
            end
            else
            begin // continue updating
              state_out <= COLLISION;
              cooldown <= 0;
              left_time <= left_time - time_step;
              iter_count <= iter_count + 1;
            end
          end
        end

        SAVING: /* saving to BRAM */
        begin
          // save all objects from registers to BRAM
          //  then send frame_end_out signal, and go to IDLE

          if (cooldown < 4)
          begin
            cooldown <= cooldown + 1;
          end
          else
          begin
            if (obj_index_i >= OBJ_COUNT)
            begin
              //
              frame_end_out <= 1'b1;
              state_out <= IDLE;
              cooldown <= 0;
              obj_index_i <= 0;
            end
            else
            begin
              // fill the memory write instructions and start waiting again
              do_save <= 1;
              save_addr <= obj_index_i;
              save_is_static <= objects[obj_index_i][0];
              save_id_bits <= objects[obj_index_i][2:1];
              save_params <= objects[obj_index_i][38:3];
              save_pos_x <= objects[obj_index_i][54:39];
              save_pos_y <= objects[obj_index_i][70:55];
              save_vel_x <= objects[obj_index_i][86:81];
              save_vel_y <= objects[obj_index_i][102:87];

              obj_index_i <= obj_index_i + 1;
              cooldown <= 0;
            end
          end
        end
      endcase
    end
  end // end of always_ff



endmodule
