module storage_breakdown (
    // input:  (is_static) (id_bits) (point_one) (point_two) (point_three/trailing-zeroes)
    // output: (is_static) (id_bits) (params) (pos_y) (pos_x) (vel_x) (vel_y)
    input logic valid_in,
    input [71:0] logic draw_props,
    output logic is_static,
    output logic id_bits,
    output logic params,
    output logic pos_x,
    output logic pos_y,
    output logic vel_x,
    output logic vel_y,
    output logic valid_out

  );


endmodule
