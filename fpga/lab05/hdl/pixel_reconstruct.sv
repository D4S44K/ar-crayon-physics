`timescale 1ns / 1ps
`default_nettype none

module pixel_reconstruct
	#(
	 parameter HCOUNT_WIDTH = 11,
	 parameter VCOUNT_WIDTH = 10
	 )
	(
	 input wire 										 clk_in,
	 input wire 										 rst_in,
	 input wire 										 camera_pclk_in,
	 input wire 										 camera_hs_in,
	 input wire 										 camera_vs_in,
	 input wire [7:0] 							 camera_data_in,
	 output logic 									 pixel_valid_out,
	 output logic [HCOUNT_WIDTH-1:0] pixel_hcount_out,
	 output logic [VCOUNT_WIDTH-1:0] pixel_vcount_out,
	 output logic [15:0] 						 pixel_data_out
	 );

	 // your code here! and here's a handful of logics that you may find helpful to utilize.

	 // previous value of PCLK
	 logic 													 pclk_prev;

	 // can be assigned combinationally:
	 //  true when pclk transitions from 0 to 1
	 logic 													 camera_sample_valid;
	 assign camera_sample_valid = (camera_pclk_in == 1 && pclk_prev == 0); // TODO: fix this assign

	 // previous value of camera data, from last valid sample!
	 // should NOT update on every cycle of clk_in, only
	 // when samples are valid.
	 logic 													 last_sampled_hs;
	 logic [7:0] 										 last_sampled_data;

	 // flag indicating whether the last byte has been transmitted or not.
	 logic 													 half_pixel_ready;

	 // horizontal and vertical counters
     logic [HCOUNT_WIDTH-1:0] hcount;
     logic [VCOUNT_WIDTH-1:0] vcount;

     // pixel output valid flag

     // counter and pixel registers
    //  assign pixel_hcount_out = hcount;
    //  assign pixel_vcount_out = vcount;

	 always_ff@(posedge clk_in) begin
          if (rst_in) begin
              pclk_prev <= 0;
              hcount <= 0;
              vcount <= 0;
              pixel_data_out <= 16'b0;
              last_sampled_hs <= 0;
              last_sampled_data <= 0;
              half_pixel_ready <= 0;
          end else begin
			  pixel_valid_out <= 0;
              pclk_prev <= camera_pclk_in;

              if (camera_sample_valid) begin
                  last_sampled_hs <= camera_hs_in;
                  last_sampled_data <= camera_data_in;

                  if (!camera_vs_in) begin
                      // reset vcount if vsync is active
                      vcount <= 0;
                      hcount <= 0;
                  end
				  if (!camera_hs_in) begin
                      // reset hcount on hsync
                      if (last_sampled_hs && camera_vs_in) begin
						hcount <= 0;
						vcount <= vcount + 1;
						half_pixel_ready <= 0;
					  end
                  end
				  if (camera_hs_in && camera_vs_in) begin
                      if (!half_pixel_ready) begin
							// pixel_data_out <= {camera_data_in, last_sampled_data[7:0]};
                          pixel_data_out[15:8] <= camera_data_in;
                          half_pixel_ready <= 1;
                      end else begin
							// pixel_data_out <= {last_sampled_data[15:8], camera_data_in};
                          pixel_data_out[7:0] <= camera_data_in;
                          half_pixel_ready <= 0;
                          hcount <= hcount + 1;
						  pixel_valid_out <= 1;
						  pixel_hcount_out <= hcount;
						  pixel_vcount_out <= vcount;
                      end
                  end
              end
          end
     end

endmodule

`default_nettype wire
