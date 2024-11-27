`default_nettype none
module parse_parts #(OBJ_WIDTH=128, PART_WIDTH=66, DF=32, SF=16)(
    input wire [OBJ_WIDTH-1:0] obj,
    output wire [PART_WIDTH-1:0] part[7:0]
  );
  // 00: nothing, 01: circle, 10: line, 11: unused



endmodule
