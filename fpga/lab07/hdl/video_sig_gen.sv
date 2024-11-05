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


// active draw height + vertical fron porch + vertical sync width + vertical back porch
  localparam TOTAL_PIXELS = ACTIVE_H_PIXELS + H_FRONT_PORCH + H_SYNC_WIDTH + H_BACK_PORCH; //figure this out
  localparam TOTAL_LINES = ACTIVE_LINES + V_FRONT_PORCH + V_SYNC_WIDTH + V_BACK_PORCH; //figure this out
  always_comb begin
    // if(rst_in == 1)begin
    //   assign hcount_out = 0;
    //   assign vcount_out = 0;
    //   assign ad_out = 0;
    //   assign nf_out = 0;
    //   assign fc_out = 0;
    // end
    if(hcount_out < ACTIVE_H_PIXELS && vcount_out < ACTIVE_LINES) ad_out = 1;
    else ad_out = 0;
    vs_out = (vcount_out >= (ACTIVE_LINES + V_FRONT_PORCH) && vcount_out < (ACTIVE_LINES + V_FRONT_PORCH + V_SYNC_WIDTH)) ? 1 : 0;
    hs_out = (hcount_out >= (ACTIVE_H_PIXELS + H_FRONT_PORCH) && hcount_out < (ACTIVE_H_PIXELS + H_FRONT_PORCH + H_SYNC_WIDTH)) ? 1 : 0;
  end
  always_ff@(posedge pixel_clk_in)begin
    if(rst_in == 1) begin
      hcount_out <= 0;
      vcount_out <= 0;
      nf_out <= 0;
      fc_out <= 0;
    end
    else begin
      if(hcount_out < TOTAL_PIXELS - 1) hcount_out <= hcount_out + 1;
      else begin
        hcount_out <= 0;
        if(vcount_out < TOTAL_LINES - 1) vcount_out <= vcount_out + 1;
        else vcount_out <= 0;
      end
      if(hcount_out == ACTIVE_H_PIXELS - 1 && vcount_out == ACTIVE_LINES) begin
        nf_out <= 1;
        if(fc_out == FPS - 1) fc_out <= 0;
        else fc_out <= fc_out + 1;
      end
      else nf_out <= 0;
    end
  end



  //   else if(hcount_out < TOTAL_LINES - 1 && vcount_out < TOTAL_PIXELS - 1) begin
  //     hcount_out <= hcount_out + 1;
  //     if(hcount_out == ACTIVE_H_PIXELS - 1 && vcount_out == ACTIVE_LINES - 1) begin
  //       nf_out <= 1;
  //       if(fc_out == FPS - 1) fc_out <= 0;
  //       else fc_out <= fc_out + 1;
  //     end
  //   end
  //   else begin
  //     if(hcount_out == TOTAL_LINES - 1) hcount_out <= 0;
  //     if(vcount_out == TOTAL_PIXELS - 1) vcount_out <= 0;
  //   end
  //   else if(hcount_out == TOTAL_LINES - 1 && vcount_out < TOTAL_PIXELS - 1) begin
  //     hcount_out <= 0;
  //     vcount_out <= vcount_out + 1;
  //   end
  //   else if(hcount_out == TOTAL_LINES - 1 && vcount_out == TOTAL_PIXELS - 1) begin
  //     hcount_out <= 0;
  //     vcount_out <= 0;
  //   end
  // end
  //your code here

endmodule