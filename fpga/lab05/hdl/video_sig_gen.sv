`timescale 1ns / 1ps
`default_nettype none

module video_sig_gen
#(
  parameter ACTIVE_H_PIXELS = 1280,
  parameter H_FRONT_PORCH = 110,
  parameter H_SYNC_WIDTH = 40,
  parameter H_BACK_PORCH = 220,
  parameter ACTIVE_LINES = 720,
  parameter V_FRONT_PORCH = 5,
  parameter V_SYNC_WIDTH = 5,
  parameter V_BACK_PORCH = 20,
  parameter FPS = 60)
(
  input wire pixel_clk_in,
  input wire rst_in,
  output logic [$clog2(TOTAL_PIXELS)-1:0] hcount_out,
  output logic [$clog2(TOTAL_LINES)-1:0] vcount_out,
  output logic vs_out, //vertical sync out
  output logic hs_out, //horizontal sync out
  output logic ad_out,
  output logic nf_out, //single cycle enable signal
  output logic [5:0] fc_out); //frame

  // calculate total pixels
  localparam TOTAL_PIXELS = ACTIVE_H_PIXELS + H_FRONT_PORCH + H_SYNC_WIDTH + H_BACK_PORCH; //figure this out
  // calculate total lines
  localparam TOTAL_LINES = ACTIVE_LINES + V_FRONT_PORCH + V_SYNC_WIDTH + V_BACK_PORCH; //figure this out

  //your code here
  // frame counter
  logic [5:0] frame_count;

  // Horizontal and vertical counters
  always_ff @(posedge pixel_clk_in) begin
    if (rst_in) begin
      // set rastor cursor to 0
      hcount_out <= 0;
      vcount_out <= 0;
      nf_out <= 0;
      frame_count <= 0;
    end else begin
      // horizontal counter
      if (hcount_out == TOTAL_PIXELS - 1) begin
        hcount_out <= 0;

        // vertical counter
        if (vcount_out == TOTAL_LINES - 1) begin
          vcount_out <= 0;
          // // start of a new frame
          // nf_out <= 1;

          // // next frame
          // frame_count <= frame_count + 1;
        end else begin
          vcount_out <= vcount_out + 1;
          nf_out <= 0;
        end
      end else begin
        hcount_out <= hcount_out + 1;
        nf_out <= 0;
      end

      if (hcount_out == ACTIVE_H_PIXELS - 1 && vcount_out == ACTIVE_LINES) begin
        // start of a new frame
        nf_out <= 1;

        // next frame
        // frame_count <= frame_count + 1;
        if (fc_out == FPS - 1) begin
          fc_out <= 0;
        end
        else begin
          fc_out <= fc_out + 1;
        end
      end
      if (nf_out) begin
        nf_out <= 0;
      end

      // // horizontal sync signal
      // hs_out <= (hcount_out < ACTIVE_H_PIXELS + H_FRONT_PORCH + H_SYNC_WIDTH) && (hcount_out >= ACTIVE_H_PIXELS + H_FRONT_PORCH);

      // // vertical sync signal
      // vs_out <= (vcount_out < ACTIVE_LINES + V_FRONT_PORCH + V_SYNC_WIDTH) && (vcount_out >= ACTIVE_LINES + V_FRONT_PORCH);

      // // active display signal
      // ad_out <= (hcount_out < ACTIVE_H_PIXELS) && (vcount_out < ACTIVE_LINES);

      // frame complete output
    end
  end

  always_comb begin
      // horizontal sync signal
      hs_out = (hcount_out < ACTIVE_H_PIXELS + H_FRONT_PORCH + H_SYNC_WIDTH) && (hcount_out >= ACTIVE_H_PIXELS + H_FRONT_PORCH);

      // vertical sync signal
      vs_out = (vcount_out < ACTIVE_LINES + V_FRONT_PORCH + V_SYNC_WIDTH) && (vcount_out >= ACTIVE_LINES + V_FRONT_PORCH);

      // active display signal
      ad_out = (hcount_out < ACTIVE_H_PIXELS) && (vcount_out < ACTIVE_LINES);
  end

endmodule

`default_nettype wire