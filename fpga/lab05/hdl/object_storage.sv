module object_storage (
    // input:  (is_static) (id_bits) (point_one) (point_two) (point_three/trailing-zeroes)
    // output: (is_static) (id_bits) (params) (pos_y) (pos_x) (vel_x) (vel_y)
    input logic [3:0][32:0] object_props, // 1 + 2 + 10 + 10 + 10 = 33
    input wire clk_in,
    // writing to brams
    input logic write_valid_in,
    // reading from brams
    input logic [3:0] read_valid_in,
    // stores read/write address
    input logic [3:0][6:0] current_addr, 
    input logic rst_in,
    output logic [3:0] is_static,
    output logic [3:0][1:0] id_bits,
    output logic [3:0][35:0] params,
    output logic [3:0][15:0] pos_x,
    output logic [3:0][15:0] pos_y,
    output logic [3:0][15:0] vel_x,
    output logic [3:0][15:0] vel_y,
    output logic [3:0] is_valid_out,
  );

// four dual port BRAMs
// four pos/vel BRAMs
// msb: is object static
// two bits: obj type (00 n/a 01 circle 10 rectangle 11 line)
  logic [90:0] storage_props; // 1 + 2 + 36 + 10 + 10 + 16 + 16 = 91
  logic [3:0][90:0] storage_out;

  draw_to_storage_conversion draw_converter(
    .clk_in(clk_in),
    .valid_in(write_valid_in),
    .draw_props(object_props[0])
    .is_static(is_static),
    .id_bits(id_bits),
    .params(params),
    .pos_x(pos_x[0]),
    .pos_y(pos_y[0]),
    .vel_x(vel_x[0]),
    .vel_y(vel_y[0]),
    .valid_out(is_valid_out),
  );

  storage_breakdown storage_req_1(
    .valid_in(read_valid_in[0]),
    .draw_props(storage_out[0])
    .is_static(is_static[0]),
    .id_bits(id_bits[0]),
    .params(params[0]),
    .pos_x(pos_x[0]),
    .pos_y(pos_y[0]),
    .valid_out(is_valid_out[0]),
  );

    storage_breakdown storage_req_2(
    .valid_in(read_valid_in[1]),
    .draw_props(storage_out[1])
    .is_static(is_static[1]),
    .id_bits(id_bits[1]),
    .params(params[1]),
    .pos_x(pos_x[1]),
    .pos_y(pos_y[1]),
    .valid_out(is_valid_out[1]),
  );

    storage_breakdown storage_req_3(
    .valid_in(read_valid_in[2]),
    .draw_props(storage_out[2])
    .is_static(is_static[2]),
    .id_bits(id_bits[2]),
    .params(params[2]),
    .pos_x(pos_x[2]),
    .pos_y(pos_y[2]),
    .valid_out(is_valid_out[2]),
  );

    storage_breakdown storage_req_4(
    .valid_in(read_valid_in[3]),
    .draw_props(storage_out[3])
    .is_static(is_static[3]),
    .id_bits(id_bits[3]),
    .params(params[3]),
    .pos_x(pos_x[3]),
    .pos_y(pos_y[3]),
    .valid_out(is_valid_out[3]),
  );

  assign storage_props = {is_static, id_bits, params, pos_x, pos_y, vel_x, vel_y};
// one module: takes critical points and object type --> stores it into the brams

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(91),                       // Specify RAM data width
    .RAM_DEPTH(100),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
  ) first_copy (
    .addra(current_addr[0]),
    .addrb(current_addr[0]),
    .dina(0),
    .dinb(storage_props),
    .clka(clk_in),
    .clkb(clk_in),
    .wea(0),
    .web(write_valid_in),
    .ena(read_valid_in[0]),
    .ena(write_valid_in),
    .rsta(read_valid_in[0] && rst_in),
    .rstb(write_valid_in && rst_in),
    .regcea(1),
    .regceb(1),
    .douta(storage_out[0]),
    .doutb(storage_out[0])
  );

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(91),                       // Specify RAM data width
    .RAM_DEPTH(100),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
  ) second_copy (
    .addra(current_addr[1]),
    .addrb(current_addr[1]),
    .dina(0),
    .dinb(storage_props),
    .clka(clk_in),
    .clkb(clk_in),
    .wea(0),
    .web(write_valid_in),
    .ena(read_valid_in[1]),
    .ena(write_valid_in),
    .rsta(read_valid_in[1] && rst_in),
    .rstb(write_valid_in && rst_in),
    .regcea(1),
    .regceb(1),
    .douta(storage_out[1]),
    .doutb(storage_out[1])
  );

    xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(91),                       // Specify RAM data width
    .RAM_DEPTH(100),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    ) third_copy (
    .addra(current_addr[2]),
    .addrb(current_addr[2]),
    .dina(0),
    .dinb(storage_props),
    .clka(clk_in),
    .clkb(clk_in),
    .wea(0),
    .web(write_valid_in),
    .ena(read_valid_in[2]),
    .ena(write_valid_in),
    .rsta(read_valid_in[2] && rst_in),
    .rstb(write_valid_in && rst_in),
    .regcea(1),
    .regceb(1),
    .douta(storage_out[2]),
    .doutb(storage_out[2])
  );

    xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(91),                       // Specify RAM data width
    .RAM_DEPTH(100),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    ) fourth_copy (
    .addra(current_addr[3]),
    .addrb(current_addr[3]),
    .dina(0),
    .dinb(storage_props),
    .clka(clk_in),
    .clkb(clk_in),
    .wea(0),
    .web(write_valid_in),
    .ena(read_valid_in[3]),
    .ena(write_valid_in),
    .rsta(read_valid_in[3] && rst_in),
    .rstb(write_valid_in && rst_in),
    .regcea(1),
    .regceb(1),
    .douta(storage_out[3]),
    .doutb(storage_out[3])
  );


endmodule
