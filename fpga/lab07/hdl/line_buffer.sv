`default_nettype none

module line_buffer (
            input wire clk_in, //system clock
            input wire rst_in, //system reset

            input wire [10:0] hcount_in, //current hcount being read
            input wire [9:0] vcount_in, //current vcount being read
            input wire [15:0] pixel_data_in, //incoming pixel
            input wire data_valid_in, //incoming  valid data signal

            output logic [KERNEL_SIZE-1:0][15:0] line_buffer_out, //output pixels of data
            output logic [10:0] hcount_out, //current hcount being read
            output logic [9:0] vcount_out, //current vcount being read
            output logic data_valid_out //valid data out signal
  );
  parameter HRES = 1280;
  parameter VRES = 720;

  localparam KERNEL_SIZE = 3;
  reg [KERNEL_SIZE:0][15:0] first_stage_data;
  logic [10:0] first_hcount_data;
  logic [9:0] first_vcount_data; // -2
  logic first_data_valid_in;
  reg [KERNEL_SIZE-1:0][15:0] second_stage_data;
  logic [10:0] second_hcount_data;
  logic [9:0] second_vcount_data; // -2
  logic second_data_valid_in;
  // logic [KERNEL_SIZE-1:0][15:0] second_stage_data;
  logic [$clog2(KERNEL_SIZE-1):0] write_enable;
  logic [15:0] first;
  logic [15:0] second;
  logic [15:0] third;
  logic [15:0] fourth;
  
  // to help you get started, here's a bram instantiation.
  // you'll want to create one BRAM for each row in the kernel, plus one more to
  // buffer incoming data from the wire:
  generate
    genvar i;
    for(i = 0; i <= KERNEL_SIZE; i = i + 1) begin
      xilinx_true_dual_port_read_first_1_clock_ram #(
        .RAM_WIDTH(16),
        .RAM_DEPTH(HRES),
        .RAM_PERFORMANCE("HIGH_PERFORMANCE")) line_buffer_ram (
        .clka(clk_in),     // Clock
        //writing port:
        .addra(hcount_in),   // Port A address bus,
        .dina(pixel_data_in),     // Port A RAM input data
        .wea(data_valid_in && i == write_enable),       // Port A write enable
        //reading port:
        .addrb(hcount_in),   // Port B address bus,
        .doutb(first_stage_data[i]),    // Port B RAM output data,
        .douta(),   // Port A RAM output data, width determined from RAM_WIDTH
        .dinb(16'd0),     // Port B RAM input data, width determined from RAM_WIDTH
        .web(1'b0),       // Port B write enable
        .ena(1'b1),       // Port A RAM Enable
        .enb(1'b1),       // Port B RAM Enable,
        .rsta(rst_in),     // Port A output reset
        .rstb(rst_in),     // Port B output reset
        .regcea(1'b1), // Port A output register enable
        .regceb(1'b1) // Port B output register enable
      );
    end
  endgenerate

  always_comb begin
      if(write_enable == 2'b00) begin
        line_buffer_out = {first_stage_data[1], first_stage_data[2], first_stage_data[3]};
        first = first_stage_data[1];
        second = first_stage_data[2];
        third = first_stage_data[3];
      end
      else if(write_enable == 2'b01) begin
        line_buffer_out = {first_stage_data[2], first_stage_data[3], first_stage_data[0]};
        first = first_stage_data[2];
        second = first_stage_data[3];
        third = first_stage_data[0];
      end
      else if(write_enable == 2'b10) begin
        line_buffer_out = {first_stage_data[3], first_stage_data[0], first_stage_data[1]};
        first = first_stage_data[3];
        second = first_stage_data[0];
        third = first_stage_data[1];
      end
      else begin
        line_buffer_out = {first_stage_data[0], first_stage_data[1], first_stage_data[2]};
        first = first_stage_data[0];
        second = first_stage_data[1];
        third = first_stage_data[2];
      end
      write_enable = vcount_out[1:0];
  end

  always_ff@(posedge clk_in) begin
    if(rst_in) begin
      // write_enable <= 0;
      // first_stage_data <= 0;
      // second_stage_data <= 0;
      data_valid_out <= 0;
      hcount_out <= 0;
      vcount_out <= 0;
      first_hcount_data <= 0;
      first_vcount_data <= 0;
      first_data_valid_in <= 0;
      // second_data_valid_in <= 0;
      // second_hcount_data <= 0;
      // second_stage_data <= 0;
      // second_vcount_data <= 0;
    end
    else begin
      // data_valid_in_detected <= 0; // fix
      first_data_valid_in <= data_valid_in;
      // second_data_valid_in <= first_data_valid_in;
      data_valid_out <= first_data_valid_in;
      // if(data_valid_in && hcount_in == HRES - 1) begin
      //   if(write_enable == (KERNEL_SIZE)) write_enable <= 0;
      //   else write_enable <= write_enable + 1;
      // end
      first_hcount_data <= hcount_in;
      // second_hcount_data <= first_hcount_data;
      hcount_out <= first_hcount_data;
      first_vcount_data <= vcount_in;
      // second_vcount_data <= first_vcount_data;
      if(first_vcount_data < 2) vcount_out <= (VRES + first_vcount_data - 2);
      else vcount_out <= first_vcount_data - 2;
      // update this
      // line_buffer_out <= second_stage_data;
      // line_buffer_out <= first_stage_data;
    end
  end

endmodule


`default_nettype wire

