module object_storage (
    // input:  (is_static) (id_bits) (point_one) (point_two) (point_three) (point_four)
    // output: (is_static) (id_bits) (params) (pos_y) (pos_x) (vel_x) (vel_y)
    input logic [32:0] object_props, // 1 + 2 + 10 + 10 + 10 = 33
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
  logic [102:0] storage_props; // 1 + 2 + 36 + 16 + 16 + 16 + 16 = 103
  logic [3:0][102:0] storage_out;
  logic [1:0] read_write_flag_buffer;

  assign is_static = {storage_out[3:3][102:102], storage_out[2:2][102:102], storage_out[1:1][102:102], storage_out[0:0][102:102]};
  assign id_bits = {storage_out[3:3][101:100], storage_out[2:2][101:100], storage_out[1:1][101:100], storage_out[0:0][101:100]};
  assign params = {storage_out[3:3][99:64], storage_out[2:2][99:64], storage_out[1:1][99:64], storage_out[0:0][99:64]};
  assign pos_x = {storage_out[3:3][63:48], storage_out[2:2][63:48], storage_out[1:1][63:48], storage_out[0:0][63:48]};
  assign pos_y = {storage_out[3:3][47:32], storage_out[2:2][47:32], storage_out[1:1][47:32], storage_out[0:0][47:32]};
  assign vel_x = {storage_out[3:3][31:16], storage_out[2:2][31:16], storage_out[1:1][31:16], storage_out[0:0][31:16]};
  assign vel_y = {storage_out[3:3][15:0], storage_out[2:2][15:0], storage_out[1:1][15:0], storage_out[0:0][15:0]};
  assign is_valid_out = read_write_flag_buffer[2];

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

  always_ff@posedge(clk_in) begin
    read_write_flag_buffer[0] <= read_valid_in || write_valid_in;
    read_write_flag_buffer[1] <= read_write_flag_buffer[0];
    read_write_flag_buffer[2] <= read_write_flag_buffer[1];
  end

  assign storage_props = {is_static, id_bits, params, pos_x, pos_y, vel_x, vel_y};
// one module: takes critical points and object type --> stores it into the brams

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(103),                       // Specify RAM data width
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
    .RAM_WIDTH(103),                       // Specify RAM data width
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
    .RAM_WIDTH(103),                       // Specify RAM data width
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
    .RAM_WIDTH(103),                       // Specify RAM data width
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
