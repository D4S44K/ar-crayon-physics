`timescale 1ns / 1ps
`default_nettype none


module convolution (
    input wire clk_in,
    input wire rst_in,
    input wire [KERNEL_SIZE-1:0][15:0] data_in,
    input wire [10:0] hcount_in,
    input wire [9:0] vcount_in,
    input wire data_valid_in,
    output logic data_valid_out,
    output logic [10:0] hcount_out,
    output logic [9:0] vcount_out,
    output logic [15:0] line_out
    );

    parameter K_SELECT = 0;
    localparam KERNEL_SIZE = 3;
    logic signed [2:0][2:0][7:0] coeffs;
    logic signed [7:0] shift;
    logic [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0][15:0] stored_data_in;
    logic signed [2:0][2:0][19:0] reds;
    logic signed [2:0][2:0][19:0] greens;
    logic signed [2:0][2:0][19:0] blues;
    logic signed [19:0] red_sum;
    logic signed [19:0] green_sum;
    logic signed [19:0] blue_sum;
    logic signed [19:0] red_divide;
    logic signed [19:0] green_divide;
    logic signed [19:0] blue_divide;
    logic [4:0] red_clipped;
    logic [5:0] green_clipped;
    logic [4:0] blue_clipped;

    logic [2:0] hold_valid;
    logic [2:0][10:0] hold_hcount;
    logic [2:0][9:0] hold_vcount;

    kernels #(.K_SELECT(K_SELECT)) kernel (.rst_in(rst_in), .coeffs(coeffs), .shift(shift));
//   module kernels #(
//   parameter K_SELECT=0)(
//   input wire rst_in,
//   output logic signed [2:0][2:0][7:0] coeffs,
//   output logic signed [7:0] shift);

    assign data_valid_out = rst_in ? 0 : hold_valid[2];
    assign hcount_out = rst_in ? 0 : hold_hcount[2];
    assign vcount_out = rst_in ? 0 : hold_vcount[2];
    assign line_out = rst_in ? 0 : {red_clipped, green_clipped, blue_clipped};

    assign red_sum = reds[0][0] + reds[0][1] + reds[0][2] + reds[1][0] + reds[1][1] + reds[1][2] + reds[2][0] + reds[2][1] + reds[2][2];
    assign green_sum = greens[0][0] + greens[0][1] + greens[0][2] + greens[1][0] + greens[1][1] + greens[1][2] + greens[2][0] + greens[2][1] + greens[2][2];
    assign blue_sum = blues[0][0] + blues[0][1] + blues[0][2] + blues[1][0] + blues[1][1] + blues[1][2] + blues[2][0] + blues[2][1] + blues[2][2];


    // Your code here!

    /* Note that the coeffs output of the kernels module
     * is packed in all dimensions, so coeffs should be
     * defined as `logic signed [2:0][2:0][7:0] coeffs`
     *
     * This is because iVerilog seems to be weird about passing
     * signals between modules that are unpacked in more
     * than one dimension - even though this is perfectly
     * fine Verilog.
     */

     generate
        genvar i;
        genvar j;
        for(i = 0; i < KERNEL_SIZE; i = i + 1) begin
            for(j = 0; j < KERNEL_SIZE; j = j + 1) begin
                always_ff@(posedge clk_in) begin
                    reds[i][j] <= $signed(coeffs[i][j]) * $signed({1'b0, stored_data_in[i][j][15:11]});
                    greens[i][j] <= $signed(coeffs[i][j])* $signed({1'b0, stored_data_in[i][j][10:5]});
                    blues[i][j] <= $signed(coeffs[i][j]) * $signed({1'b0, stored_data_in[i][j][4:0]});
                end
            end
        end
     endgenerate

    always_ff @(posedge clk_in) begin
      // Make sure to have your output be set with registered logic!
      // Otherwise you'll have timing violations.
    //   if(rst_in) begin
    //     hcount_out <= 0;
    //     vcount_out <= 0;
    //   end
      if(rst_in) begin
        stored_data_in[0][0] <= 0;
        stored_data_in[0][1] <= 0;
        stored_data_in[0][2] <= 0;
        stored_data_in[1][0] <= 0;
        stored_data_in[1][1] <= 0;
        stored_data_in[1][2] <= 0;
        stored_data_in[2][0] <= 0;
        stored_data_in[2][1] <= 0;
        stored_data_in[2][2] <= 0;
        // for(int i = 0; i < KERNEL_SIZE; i = i + 1) begin
        //     for(int j = 0; j < KERNEL_SIZE; j = j + 1) begin
        //         stored_data_in[i][j] <= 0;
        //     end
        // end
      end
      else begin
            hold_hcount[0] <= hcount_in;
            hold_hcount[1] <= hold_hcount[0];
            hold_hcount[2] <= hold_hcount[1];

            hold_vcount[0] <= vcount_in;
            hold_vcount[1] <= hold_vcount[0];
            hold_vcount[2] <= hold_vcount[1];

            hold_valid[0] <= data_valid_in;
            hold_valid[1] <= hold_valid[0];
            hold_valid[2] <= hold_valid[1];
        if(data_valid_in) begin
            stored_data_in[0] <= stored_data_in[1];
            stored_data_in[1] <= stored_data_in[2];
            stored_data_in[2] <= data_in;
            // add at 2
        end
        red_divide <= red_sum >>> shift;
        green_divide <= green_sum >>> shift;
        blue_divide <= blue_sum >>> shift;

        if($signed(red_divide) < 'sd0) red_clipped <= 0;
        else if(red_divide > {15'b0, 5'b11111}) red_clipped <= 5'b11111;
        else red_clipped <= red_divide[4:0];

        if($signed(green_divide) < 'sd0) green_clipped <= 0;
        else if(green_divide > {14'b0, 6'b111111}) green_clipped <= 6'b111111;
        else green_clipped <= green_divide[5:0];

        if($signed(blue_divide) < 'sd0) blue_clipped <= 0;
        else if(blue_divide > {15'b0, 5'b11111}) blue_clipped <= 5'b11111;
        else blue_clipped <= blue_divide[4:0];
      end
    end

    


endmodule

`default_nettype wire

