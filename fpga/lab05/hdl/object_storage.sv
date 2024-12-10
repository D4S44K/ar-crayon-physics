`default_nettype none

`define OBJ_WIDTH 115
`define OBJ_COUNT 4
`define OBJ_ADDR_WIDTH 8

module object_storage (
    input wire clk_in,
    input wire rst_in,

    input wire write_valid_in,
    input wire [`OBJ_ADDR_WIDTH-1:0] write_addr_in,
    input wire [`OBJ_WIDTH-1:0] write_object_in,
    output logic write_valid_out,

    input wire read_valid_in,
    input wire [`OBJ_ADDR_WIDTH-1:0] read_addrs_in[3:0],
    output logic [`OBJ_WIDTH-1:0] read_objects_out[3:0],
    output logic read_valid_out
  );

  // {is_static, id_bits, params, pos_x, pos_y, vel_x, vel_y};

  genvar i;
  generate
    for(i = 0; i < 4; i = i + 1)
    begin
      // A for read, B for write
      xilinx_true_dual_port_read_first_2_clock_ram
        #(
          .RAM_WIDTH(`OBJ_WIDTH),                     // Specify RAM data width
          .RAM_DEPTH(`OBJ_COUNT),                     // Specify RAM depth (number of entries)
          .RAM_PERFORMANCE("HIGH_PERFORMANCE") // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
        ) bram_interface (
          .addra(read_addrs_in[i]),
          .addrb(write_addr_in),
          .dina(0),
          .dinb(write_object_in),
          .clka(clk_in),
          .clkb(clk_in),
          .wea(0),
          .web(write_valid_in),
          .ena(1),
          .enb(1),
          .rsta(rst_in),
          .rstb(rst_in),
          .regcea(1),
          .regceb(1),
          .douta(read_objects_out[i]),
          .doutb()
        );
    end
  endgenerate

endmodule
`default_nettype wire
