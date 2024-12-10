// `default_nettype none
// module get_earliest_collision #(OBJ_WIDTH=128, PART_WIDTH=66, DF=32, SF=16)(
//     input wire sys_clk,
//     input wire sys_rst,
//     input wire data_valid_in,
//     input wire [OBJ_WIDTH-1:0] obj_a,
//     input wire [OBJ_WIDTH-1:0] obj_b,

//     output wire data_valid_out,
//     output wire [DF-1:0] col_time,
//     output wire [2:0] a_part_index,
//     output wire [2:0] b_part_index
//   );

//   logic [PART_WIDTH-1:0] a_part[7:0];
//   logic [PART_WIDTH-1:0] b_part[7:0];

//   parse_parts parse_parts_a(
//                 .obj(obj_a),
//                 .part(a_part)
//               );
//   parse_parts parse_parts_b(
//                 .obj(obj_b),
//                 .part(b_part)
//               );

//   logic [SF-1:0] rv_x;
//   logic [SF-1:0] rv_y;
//   // obj_a vel - obj_b vel

//   always_ff @(posedge sys_clk)
//   begin
//     if (sys_rst)
//     begin
//       data_valid_out <= 1'b0;
//       col_time <= 0;
//       a_part_index <= 0;
//       b_part_index <= 0;
//     end
//     else
//     begin
//       // 8 lines of get_part_collision, iterate 8 times
//     end
//   end



// endmodule
