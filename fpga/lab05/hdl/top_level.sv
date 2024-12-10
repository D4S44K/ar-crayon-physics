`timescale 1ns / 1ps
`default_nettype none

module top_level
  (
   input wire          clk_100mhz,
   output logic [15:0] led,
   // camera bus
   input wire [7:0]    camera_d, // 8 parallel data wires
   output logic        cam_xclk, // XC driving camera
   input wire          cam_hsync, // camera hsync wire
   input wire          cam_vsync, // camera vsync wire
   input wire          cam_pclk, // camera pixel clock
   inout wire          i2c_scl, // i2c inout clock
   inout wire          i2c_sda, // i2c inout data
   input wire [15:0]   sw,
   input wire [3:0]    btn,
   output logic [2:0]  rgb0,
   output logic [2:0]  rgb1,
   // seven segment
   output logic [3:0]  ss0_an,//anode control for upper four digits of seven-seg display
   output logic [3:0]  ss1_an,//anode control for lower four digits of seven-seg display
   output logic [6:0]  ss0_c, //cathode controls for the segments of upper four digits
   output logic [6:0]  ss1_c, //cathod controls for the segments of lower four digits
   // hdmi port
   output logic [2:0]  hdmi_tx_p, //hdmi output signals (positives) (blue, green, red)
   output logic [2:0]  hdmi_tx_n, //hdmi output signals (negatives) (blue, green, red)
   output logic        hdmi_clk_p, hdmi_clk_n //differential hdmi clock
   );

  // shut up those RGBs
  assign rgb0 = 0;
  assign rgb1 = 0;

  // Clock and Reset Signals
  logic          sys_rst_camera;
  logic          sys_rst_pixel;

  logic          clk_camera;
  logic          clk_pixel;
  logic          clk_5x;
  logic          clk_xc;

  logic          clk_100_passthrough;

  // clocking wizards to generate the clock speeds we need for our different domains
  // clk_camera: 200MHz, fast enough to comfortably sample the cameera's PCLK (50MHz)
  cw_hdmi_clk_wiz wizard_hdmi
    (.sysclk(clk_100_passthrough),
     .clk_pixel(clk_pixel),
     .clk_tmds(clk_5x),
     .reset(0));

  cw_fast_clk_wiz wizard_migcam
    (.clk_in1(clk_100mhz),
     .clk_camera(clk_camera),
     .clk_xc(clk_xc),
     .clk_100(clk_100_passthrough),
     .reset(0));

  // assign camera's xclk to pmod port: drive the operating clock of the camera!
  // this port also is specifically set to high drive by the XDC file.
  assign cam_xclk = sw[0] ? clk_xc : 1'b0;

  assign sys_rst_camera = btn[0]; //use for resetting camera side of logic
  assign sys_rst_pixel = btn[0]; //use for resetting hdmi/draw side of logic


  // video signal generator signals
  logic          hsync_hdmi;
  logic          vsync_hdmi;
  logic [10:0]  hcount_hdmi;
  logic [9:0]    vcount_hdmi;
  logic          active_draw_hdmi;
  logic          new_frame_hdmi;
  logic [5:0]    frame_count_hdmi;
  logic          nf_hdmi;

  // rgb output values
  logic [7:0]          red,green,blue;

  // ** Handling input from the camera **

  // synchronizers to prevent metastability
  logic [7:0]    camera_d_buf [1:0];
  logic          cam_hsync_buf [1:0];
  logic          cam_vsync_buf [1:0];
  logic          cam_pclk_buf [1:0];

  always_ff @(posedge clk_camera) begin
     camera_d_buf <= {camera_d, camera_d_buf[1]};
     cam_pclk_buf <= {cam_pclk, cam_pclk_buf[1]};
     cam_hsync_buf <= {cam_hsync, cam_hsync_buf[1]};
     cam_vsync_buf <= {cam_vsync, cam_vsync_buf[1]};
  end

  logic [10:0] camera_hcount;
  logic [9:0]  camera_vcount;
  logic [15:0] camera_pixel;
  logic        camera_valid;

  // your pixel_reconstruct module, from the exercise!
  // hook it up to buffered inputs.
  pixel_reconstruct
    (.clk_in(clk_camera),
     .rst_in(sys_rst_camera),
     .camera_pclk_in(cam_pclk_buf[0]),
     .camera_hs_in(cam_hsync_buf[0]),
     .camera_vs_in(cam_vsync_buf[0]),
     .camera_data_in(camera_d_buf[0]),
     .pixel_valid_out(camera_valid),
     .pixel_hcount_out(camera_hcount),
     .pixel_vcount_out(camera_vcount),
     .pixel_data_out(camera_pixel));


  //two-port BRAM used to hold image from camera.
  //The camera is producing video at 720p and 30fps, but we can't store all of that
  //we're going to down-sample by a factor of 4 in both dimensions
  //so we have 320 by 180.  this is kinda a bummer, but we'll fix it
  //in future weeks by using off-chip DRAM.
  //even with the down-sample, because our camera is producing data at 30fps
  //and  our display is running at 720p at 60 fps, there's no hope to have the
  //production and consumption of information be synchronized in this system.
  //even if we could line it up once, the clocks of both systems will drift over time
  //so to avoid this sync issue, we use a conflict-resolution device...the frame buffer
  //instead we use a frame buffer as a go-between. The camera sends pixels in at
  //its own rate, and we pull them out for display at the 720p rate/requirement
  //this avoids the whole sync issue. It will however result in artifacts when you
  //introduce fast motion in front of the camera. These lines/tears in the image
  //are the result of unsynced frame-rewriting happening while displaying. It won't
  //matter for slow movement
  localparam FB_DEPTH = 320*180;
  localparam FB_SIZE = $clog2(FB_DEPTH);
  logic [FB_SIZE-1:0] addra; //used to specify address to write to in frame buffer

  logic valid_camera_mem; //used to enable writing pixel data to frame buffer
  logic [15:0] camera_mem; //used to pass pixel data into frame buffer


  //TO DO in camera part 1:
  always_ff @(posedge clk_camera)begin
    //create logic to handle wriiting of camera.
    //we want to down sample the data from the camera by a factor of four in both
    //the x and y dimensions! TO DO
    if (camera_valid) begin
      addra <= (camera_hcount) + ((camera_vcount) * 320);
      camera_mem <= camera_pixel;
      valid_camera_mem <= 1; // Enable memory write
    end else begin
      valid_camera_mem <= 0;
    end
  end

  //frame buffer from IP
  blk_mem_gen_0 frame_buffer (
    .addra(addra), //pixels are stored using this math
    .clka(clk_camera),
    .wea(valid_camera_mem),
    .dina(camera_mem),
    .ena(1'b1),
    .douta(), //never read from this side
    .addrb(addrb),//transformed lookup pixel
    .dinb(16'b0),
    .clkb(clk_pixel),
    .web(1'b0),
    .enb(1'b1),
    .doutb(frame_buff_raw)
  );
  logic [15:0] frame_buff_raw; //data out of frame buffer (565)
  logic [FB_SIZE-1:0] addrb; //used to lookup address in memory for reading from buffer
  logic good_addrb; //used to indicate within valid frame for scaling


  //TO DO in camera part 1:
  // Scale pixel coordinates from HDMI to the frame buffer to grab the right pixel
  //scaling logic!!! You need to complete!!! We want 1X, 2X, and 4X!
  always_ff @(posedge clk_pixel)begin
    //default: delete:
    // addrb <= (319-hcount_hdmi) + 320*vcount_hdmi;
    // good_addrb <= (hcount_hdmi<320)&&(vcount_hdmi<180);
    //use structure below to do scaling
    if (btn[1])begin //1X scaling from frame buffer
      addrb <= hcount_hdmi + vcount_hdmi * 320; //change me
      good_addrb <= (hcount_hdmi < 320) && (vcount_hdmi < 180); //change me
    end else if (!sw[0])begin //2X scaling from frame buffer
      addrb <= (hcount_hdmi >> 1) + (vcount_hdmi >> 1) * 320; //change me
      good_addrb <= (hcount_hdmi < 640) && (vcount_hdmi < 360); //change me
    end else begin //4X scaling from frame buffer
      addrb <= (hcount_hdmi >> 2) + (vcount_hdmi >> 2) * 320; // change me
      good_addrb <= (hcount_hdmi < 1280) && (vcount_hdmi < 720); //change me
    end
  end

  //split fame_buff into 3 8 bit color channels (5:6:5 adjusted accordingly)
  //remapped frame_buffer outputs with 8 bits for r, g, b
  logic [7:0] fb_red, fb_green, fb_blue;
  always_ff @(posedge clk_pixel)begin
    fb_red <= good_addrb?{frame_buff_raw[15:11],3'b0}:8'b0;
    fb_green <= good_addrb?{frame_buff_raw[10:5], 2'b0}:8'b0;
    fb_blue <= good_addrb?{frame_buff_raw[4:0],3'b0}:8'b0;
  end
  // Pixel Processing pre-HDMI output

  // RGB to YCrCb

  //output of rgb to ycrcb conversion (10 bits due to module):
  logic [9:0] y_full, cr_full, cb_full; //ycrcb conversion of full pixel
  //bottom 8 of y, cr, cb conversions:
  logic [7:0] y, cr, cb; //ycrcb conversion of full pixel
  //Convert RGB of full pixel to YCrCb
  //See lecture 07 for YCrCb discussion.
  //Module has a 3 cycle latency
  rgb_to_ycrcb rgbtoycrcb_m(
    .clk_in(clk_pixel),
    .r_in(fb_red),
    .g_in(fb_green),
    .b_in(fb_blue),
    .y_out(y_full),
    .cr_out(cr_full),
    .cb_out(cb_full)
  );

  //channel select module (select which of six color channels to mask):
  // logic [2:0] channel_sel;
  logic [7:0] selected_channel; //selected channels
  //selected_channel could contain any of the six color channels depend on selection

  //threshold module (apply masking threshold):
  logic [7:0] lower_threshold;
  logic [7:0] upper_threshold;
  logic mask; //Whether or not thresholded pixel is 1 or 0

  //Center of Mass variables (tally all mask=1 pixels for a frame and calculate their center of mass)fb_red
  logic [10:0] x_com, x_com_calc; //long term x_com and output from module, resp
  logic [9:0] y_com, y_com_calc; //long term y_com and output from module, resp
  logic new_com; //used to know when to update x_com and y_com ...

  //channel select module (select which of six color channels to mask) FOR COM_2:
  // logic [2:0] channel_sel_2;
  logic [7:0] selected_channel_2; //selected channels
  //selected_channel could contain any of the six color channels depend on selection

  //threshold module (apply masking threshold) FOR COM_2:
  // logic [7:0] lower_threshold_2;
  // logic [7:0] upper_threshold_2;
  logic mask_2; //Whether or not thresholded pixel is 1 or 0

  //Center of Mass variables FOR COM_2 (tally all mask=1 pixels for a frame and calculate their center of mass)fb_red
  logic [10:0] x_com_2, x_com_calc_2; //long term x_com and output from module, resp
  logic [9:0] y_com_2, y_com_calc_2; //long term y_com and output from module, resp
  logic new_com_2; //used to know when to update x_com and y_com ...

  //take lower 8 of full outputs.
  // treat cr and cb as signed numbers, invert the MSB to get an unsigned equivalent ( [-128,128) maps to [0,256) )
  assign y = y_full[7:0];
  assign cr = {!cr_full[7],cr_full[6:0]};
  assign cb = {!cb_full[7],cb_full[6:0]};

  // PIPELINE LOGIC
  //vary the packed width based on signal
  //vary the unpacked width based on pipelining depth needed

  logic [7:0] fb_red_delayed_ps1;
  pipeline #(
    .WIDTH(8), .STAGES(3))
    fb_red_pipeline_ps1(
    .clk_pixel(clk_pixel),
    .signal(fb_red),
    //.stages(3),
    .delayed_signal(fb_red_delayed_ps1)
  );

  logic [7:0] fb_green_delayed_ps1;
  pipeline #(
    .WIDTH(8), .STAGES(3))
    fb_green_pipeline_ps1(
    .clk_pixel(clk_pixel),
    .signal(fb_green),
    //.stages(3),
    .delayed_signal(fb_green_delayed_ps1)
  );

  logic [7:0] fb_blue_delayed_ps1;
  pipeline #(
    .WIDTH(8), .STAGES(3))
    fb_blue_pipeline_ps1(
    .clk_pixel(clk_pixel),
    .signal(fb_blue),
    //.stages(3),
    .delayed_signal(fb_blue_delayed_ps1)
  );

  // assign channel_sel = 3'b101;

  // assign channel_sel_2 = 3'b110;
  // * 3'b000: green
  // * 3'b001: red
  // * 3'b010: blue
  // * 3'b011: not valid
  // * 3'b100: y (luminance)
  // * 3'b101: Cr (Chroma Red)
  // * 3'b110: Cb (Chroma Blue)
  // * 3'b111: not valid
  //Channel Select: Takes in the full RGB and YCrCb information and
  // chooses one of them to output as an 8 bit value
  // channel_select mcs(
  //    .sel_in(channel_sel),
  //    .r_in(fb_red_delayed_ps1),    //TODO: needs to use pipelined signal (PS1)
  //    .g_in(fb_green_delayed_ps1),  //TODO: needs to use pipelined signal (PS1)
  //    .b_in(fb_blue_delayed_ps1),   //TODO: needs to use pipelined signal (PS1)
  //    .y_in(y),
  //    .cr_in(cr),
  //    .cb_in(cb),
  //    .channel_out(selected_channel)
  // );

  // channel_select mcs_2(
  //    .sel_in(channel_sel_2),
  //    .r_in(fb_red_delayed_ps1),    //TODO: needs to use pipelined signal (PS1)
  //    .g_in(fb_green_delayed_ps1),  //TODO: needs to use pipelined signal (PS1)
  //    .b_in(fb_blue_delayed_ps1),   //TODO: needs to use pipelined signal (PS1)
  //    .y_in(y),
  //    .cr_in(cr),
  //    .cb_in(cb),
  //    .channel_out(selected_channel_2)
  // );

  assign selected_channel = cr;
  assign selected_channel_2 = cb;

  //threshold values used to determine what value  passes:
  assign lower_threshold = {4'b1010,4'b0};
  assign upper_threshold = {4'b1111,4'b0};
  //Thresholder: Takes in the full selected channedl and
  //based on upper and lower bounds provides a binary mask bit
  // * 1 if selected channel is within the bounds (inclusive)
  // * 0 if selected channel is not within the bounds
  threshold mt(
     .clk_in(clk_pixel),
     .rst_in(sys_rst_pixel),
     .pixel_in(selected_channel),
     .lower_bound_in(lower_threshold),
     .upper_bound_in(upper_threshold),
     .mask_out(mask) //single bit if pixel within mask.
  );

  threshold mt_2(
     .clk_in(clk_pixel),
     .rst_in(sys_rst_pixel),
     .pixel_in(selected_channel_2),
     .lower_bound_in(lower_threshold),
     .upper_bound_in(upper_threshold),
     .mask_out(mask_2) //single bit if pixel within mask.
  );


  logic [6:0] ss_c;
  //modified version of seven segment display for showing
  // thresholds and selected channel
  // special customized version
  lab05_ssc mssc(.clk_in(clk_pixel),
                 .rst_in(sys_rst_pixel),
                 .lt_in(lower_threshold),
                 .ut_in(upper_threshold),
                 .channel_sel_in(3'b101),
                 .cat_out(ss_c),
                 .an_out({ss0_an, ss1_an})
  );
  assign ss0_c = ss_c; //control upper four digit's cathodes!
  assign ss1_c = ss_c; //same as above but for lower four digits!

  logic [10:0] hcount_delayed_ps3;
  pipeline #(
    .WIDTH(11), .STAGES(8))
    hcount_pipeline_ps3(
    .clk_pixel(clk_pixel),
    .signal(hcount_hdmi),
    //.stages(8),
    .delayed_signal(hcount_delayed_ps3)
  );

  logic [9:0] vcount_delayed_ps3;
  pipeline #(
    .WIDTH(10), .STAGES(8))
    vcount_pipeline_ps3(
    .clk_pixel(clk_pixel),
    .signal(vcount_hdmi),
    //.stages(8),
    .delayed_signal(vcount_delayed_ps3)
  );

  //Center of Mass Calculation: (you need to do)
  //using x_com_calc and y_com_calc values
  //Center of Mass:
  center_of_mass com_m(
    .clk_in(clk_pixel),
    .rst_in(sys_rst_pixel),
    .x_in(hcount_delayed_ps3),  //TODO: needs to use pipelined signal! (PS3)
    .y_in(vcount_delayed_ps3), //TODO: needs to use pipelined signal! (PS3)
    .valid_in(mask), //aka threshold
    .tabulate_in((nf_hdmi)),
    .x_out(x_com_calc),
    .y_out(y_com_calc),
    .valid_out(new_com)
  );

  center_of_mass com_m_2(
    .clk_in(clk_pixel),
    .rst_in(sys_rst_pixel),
    .x_in(hcount_delayed_ps3),  //TODO: needs to use pipelined signal! (PS3)
    .y_in(vcount_delayed_ps3), //TODO: needs to use pipelined signal! (PS3)
    .valid_in(mask_2), //aka threshold
    .tabulate_in((nf_hdmi)),
    .x_out(x_com_calc_2),
    .y_out(y_com_calc_2),
    .valid_out(new_com_2)
  );
  //grab logic for above
  //update center of mass x_com, y_com based on new_com signal
  always_ff @(posedge clk_pixel)begin
    if (sys_rst_pixel)begin
      x_com <= 0;
      y_com <= 0;
    end
    else if(new_com)begin
      x_com <= x_com_calc;
      y_com <= y_com_calc;
    end
    if (sys_rst_pixel)begin
      x_com_2 <= 0;
      y_com_2 <= 0;
    end
    else if(new_com_2)begin
      x_com_2 <= x_com_calc_2;
      y_com_2 <= y_com_calc_2;
    end
  end

  //rectangle output:
  logic [7:0] rect_red, rect_green, rect_blue;
  logic [83:0] rect_coord;

  //circle output:
  logic [7:0] circle_red, circle_green, circle_blue;
  logic [83:0] circle_coord;

  //line output:
  logic [7:0] line_red, line_green, line_blue;
  logic [83:0] line_coord;

  logic [10:0] hcount_delayed_ps1;
  pipeline #(
    .WIDTH(11), .STAGES(3))
    hcount_pipeline_ps1(
    .clk_pixel(clk_pixel),
    .signal(hcount_hdmi),
    //.stages(3),
    .delayed_signal(hcount_delayed_ps1)
  );

  logic [9:0] vcount_delayed_ps1;
  pipeline #(
    .WIDTH(10), .STAGES(3))
    vcount_pipeline_ps1(
    .clk_pixel(clk_pixel),
    .signal(vcount_hdmi),
    //.stages(3),
    .delayed_signal(vcount_delayed_ps1)
  );

  draw_rectangle #(
    .WIDTH(256),
    .HEIGHT(256),
    .COLOR(24'hFF_FF_FF))
    rectangle (
    .clk_in(clk_pixel),
    .rst_in(sys_rst_pixel),
    .hcount_in(hcount_delayed_ps1),
    .vcount_in(vcount_delayed_ps1),
    .x_in_1(x_com),
    .y_in_1(y_com),
    .x_in_2(x_com_2),
    .y_in_2(y_com_2),
    .rect_coord(rect_coord),
    .red_out(rect_red),
    .green_out(rect_green),
    .blue_out(rect_blue));


  draw_circle #(
    .WIDTH(256),
    .HEIGHT(256),
    .COLOR(24'hFF_FF_FF))
    circle (
    .clk_in(clk_pixel),
    .rst_in(sys_rst_pixel),
    .hcount_in(hcount_delayed_ps1),
    .vcount_in(vcount_delayed_ps1),
    .is_valid_in(1),
    .x_in_1(x_com),
    .y_in_1(y_com),
    .x_in_2(x_com_2),
    .y_in_2(y_com_2),
    .circle_coord(circle_coord),
    .red_out(circle_red),
    .green_out(circle_green),
    .blue_out(circle_blue),
    .is_valid_out());


  draw_line #(
    .WIDTH(256),
    .HEIGHT(256),
    .COLOR(24'hFF_FF_FF))
    line (
    .clk_in(clk_pixel),
    .rst_in(sys_rst_pixel),
    .hcount_in(hcount_delayed_ps1),
    .vcount_in(vcount_delayed_ps1),
    .x_in_1(x_com),
    .y_in_1(y_com),
    .x_in_2(x_com_2),
    .y_in_2(y_com_2),
    .line_coord(line_coord),
    .red_out(line_red),
    .green_out(line_green),
    .blue_out(line_blue));

  // object_storage obj_storage(
  //   .object_props(0),
  //   .clk_in(clk_in),
  //   .write_valid_in(0),
  //   .read_valid_in(4'b1111),
  //   .current_addr(current_addresses),
  //   .rst_in(rst_in),
  //   .is_static(is_static),
  //   .id_bits(id_bits),
  //   .params(params),
  //   .pos_x(pos_x),
  //   .pos_y(pos_y),
  //   .vel_x(vel_x),
  //   .vel_y(vel_y),
  //   .is_valid_out(is_valid_out)
  // );

  

  // object coordinate setting logic
  logic [86:0] obj_coord;
  always_comb begin
    if (btn[2]) begin
      case (sw[7:6])
        2'b00: obj_coord = 87'b0;
        2'b01: obj_coord = {sw[2], sw[7:6], circle_coord};
        2'b10: obj_coord = {sw[2], sw[7:6], line_coord};
        2'b11: obj_coord = {sw[2], sw[7:6], rect_coord};
        default: obj_coord = 87'b0;
      endcase
    end
  end

  //crosshair output:
  logic [7:0] ch_red, ch_green, ch_blue;

  //Create Crosshair patter on center of mass:
  //0 cycle latency
  //TODO: Should be using output of (PS3)
  always_comb begin
    ch_red   = ((vcount_delayed_ps3==y_com) || (hcount_delayed_ps3==x_com) || (vcount_delayed_ps3==y_com_2) || (hcount_delayed_ps3==x_com_2))?8'hFF:8'h00;
    ch_green = ((vcount_delayed_ps3==y_com) || (hcount_delayed_ps3==x_com) || (vcount_delayed_ps3==y_com_2) || (hcount_delayed_ps3==x_com_2))?8'hFF:8'h00;
    ch_blue  = ((vcount_delayed_ps3==y_com) || (hcount_delayed_ps3==x_com) || (vcount_delayed_ps3==y_com_2) || (hcount_delayed_ps3==x_com_2))?8'hFF:8'h00;
  end


  // HDMI video signal generator
   video_sig_gen vsg
     (
      .pixel_clk_in(clk_pixel),
      .rst_in(sys_rst_pixel),
      .hcount_out(hcount_hdmi),
      .vcount_out(vcount_hdmi),
      .vs_out(vsync_hdmi),
      .hs_out(hsync_hdmi),
      .nf_out(nf_hdmi),
      .ad_out(active_draw_hdmi),
      .fc_out(frame_count_hdmi)
      );


  // Video Mux: select from the different display modes based on switch values
  //used with switches for display selections
  logic [1:0] display_choice;
  logic [1:0] target_choice;

  assign display_choice = sw[5:4];
  assign target_choice =  sw[7:6];

  //choose what to display from the camera:
  // * 'b00:  normal camera out
  // * 'b01:  selected channel image in grayscale
  // * 'b10:  masked pixel (all on if 1, all off if 0)
  // * 'b11:  chroma channel with mask overtop as magenta
  //
  //then choose what to use with center of mass:
  // * 'b00: nothing
  // * 'b01: crosshair
  // * 'b10: sprite on top
  // * 'b11: nothing

  logic [7:0] fb_red_delayed_ps2;
  pipeline #(
    .WIDTH(8), .STAGES(4))
    fb_red_pipeline_ps2(
    .clk_pixel(clk_pixel),
    .signal(fb_red),
    //.stages(4),
    .delayed_signal(fb_red_delayed_ps2)
  );

  logic [7:0] fb_green_delayed_ps2;
  pipeline #(
    .WIDTH(8), .STAGES(4))
    fb_green_pipeline_ps2(
    .clk_pixel(clk_pixel),
    .signal(fb_green),
    //.stages(4),
    .delayed_signal(fb_green_delayed_ps2)
  );

  logic [7:0] fb_blue_delayed_ps2;
  pipeline #(
    .WIDTH(8), .STAGES(4))
    fb_blue_pipeline_ps2(
    .clk_pixel(clk_pixel),
    .signal(fb_blue),
    //.stages(4),
    .delayed_signal(fb_blue_delayed_ps2)
  );

  logic [7:0] y_delayed_ps6;
  pipeline #(
    .WIDTH(8), .STAGES(1))
    y_pipeline_ps6(
    .clk_pixel(clk_pixel),
    .signal(y),
    //.stages(1),
    .delayed_signal(y_delayed_ps6)
  );

  logic [7:0] selected_channel_delayed_ps5;
  pipeline #(
    .WIDTH(8), .STAGES(1))
    selected_channel_pipeline_ps5(
    .clk_pixel(clk_pixel),
    .signal(selected_channel),
    //.stages(1),
    .delayed_signal(selected_channel_delayed_ps5)
  );

  logic [7:0] ch_red_delayed_ps8;
  pipeline #(
    .WIDTH(8), .STAGES(8))
    ch_red_pipeline_ps8(
    .clk_pixel(clk_pixel),
    .signal(ch_red),
    //.stages(8),
    .delayed_signal(ch_red_delayed_ps8)
  );

  logic [7:0] ch_green_delayed_ps8;
  pipeline #(
    .WIDTH(8), .STAGES(8))
    ch_green_pipeline_ps8(
    .clk_pixel(clk_pixel),
    .signal(ch_green),
    //.stages(8),
    .delayed_signal(ch_green_delayed_ps8)
  );

  logic [7:0] ch_blue_delayed_ps8;
  pipeline #(
    .WIDTH(8), .STAGES(8))
    ch_blue_pipeline_ps8(
    .clk_pixel(clk_pixel),
    .signal(ch_blue),
    //.stages(8),
    .delayed_signal(ch_blue_delayed_ps8)
  );

  // logic [7:0] rect_red_delayed_ps9;
  // pipeline #(
  //   .WIDTH(8), .STAGES(4))
  //   rect_red_pipeline_ps9(
  //   .clk_pixel(clk_pixel),
  //   .signal(rect_red),
  //   //.stages(4),
  //   .delayed_signal(rect_red_delayed_ps9)
  // );

  // logic [7:0] rect_green_delayed_ps9;
  // pipeline #(
  //   .WIDTH(8), .STAGES(4))
  //   rect_green_pipeline_ps9(
  //   .clk_pixel(clk_pixel),
  //   .signal(rect_green),
  //   //.stages(4),
  //   .delayed_signal(rect_green_delayed_ps9)
  // );

  // logic [7:0] rect_blue_delayed_ps9;
  // pipeline #(
  //   .WIDTH(8), .STAGES(4))
  //   rect_blue_pipeline_ps9(
  //   .clk_pixel(clk_pixel),
  //   .signal(rect_blue),
  //   //.stages(4),
  //   .delayed_signal(rect_blue_delayed_ps9)
  // );

  // logic [7:0] circle_red_delayed_ps9;
  // pipeline #(
  //   .WIDTH(8), .STAGES(4))
  //   circle_red_pipeline_ps9(
  //   .clk_pixel(clk_pixel),
  //   .signal(circle_red),
  //   //.stages(4),
  //   .delayed_signal(circle_red_delayed_ps9)
  // );

  // logic [7:0] circle_green_delayed_ps9;
  // pipeline #(
  //   .WIDTH(8), .STAGES(4))
  //   circle_green_pipeline_ps9(
  //   .clk_pixel(clk_pixel),
  //   .signal(circle_green),
  //   //.stages(4),
  //   .delayed_signal(circle_green_delayed_ps9)
  // );

  // logic [7:0] circle_blue_delayed_ps9;
  // pipeline #(
  //   .WIDTH(8), .STAGES(4))
  //   circle_blue_pipeline_ps9(
  //   .clk_pixel(clk_pixel),
  //   .signal(circle_blue),
  //   //.stages(4),
  //   .delayed_signal(circle_blue_delayed_ps9)
  // );

  // logic [7:0] line_red_delayed_ps9;
  // pipeline #(
  //   .WIDTH(8), .STAGES(4))
  //   line_red_pipeline_ps9(
  //   .clk_pixel(clk_pixel),
  //   .signal(line_red),
  //   //.stages(4),
  //   .delayed_signal(line_red_delayed_ps9)
  // );

  // logic [7:0] line_green_delayed_ps9;
  // pipeline #(
  //   .WIDTH(8), .STAGES(4))
  //   line_green_pipeline_ps9(
  //   .clk_pixel(clk_pixel),
  //   .signal(line_green),
  //   //.stages(4),
  //   .delayed_signal(line_green_delayed_ps9)
  // );

  // logic [7:0] line_blue_delayed_ps9;
  // pipeline #(
  //   .WIDTH(8), .STAGES(4))
  //   line_blue_pipeline_ps9(
  //   .clk_pixel(clk_pixel),
  //   .signal(line_blue),
  //   //.stages(4),
  //   .delayed_signal(line_blue_delayed_ps9)
  // );

  video_mux mvm(
    .bg_in(display_choice), //choose background
    .target_in(target_choice), //choose target
    .camera_pixel_in({fb_red_delayed_ps2, fb_green_delayed_ps2, fb_blue_delayed_ps2}), //TODO: needs (PS2)
    .camera_y_in(y_delayed_ps6), //luminance TODO: needs (PS6)
    .channel_in(selected_channel_delayed_ps5), //current channel being drawn TODO: needs (PS5)
    .thresholded_pixel_in(mask), //one bit mask signal TODO: needs (PS4)
    .crosshair_in({ch_red_delayed_ps8, ch_green_delayed_ps8, ch_blue_delayed_ps8}), //TODO: needs (PS8)
    .rect_pixel_in({rect_red, rect_green, rect_blue}), //TODO: needs (PS9) maybe?
    .circle_pixel_in({circle_red, circle_green, circle_blue}),
    .line_pixel_in({line_red, line_green, line_blue}),
    .pixel_out({red,green,blue}) //output to tmds
  );

   // HDMI Output: just like before!

   logic [9:0] tmds_10b [0:2]; //output of each TMDS encoder!
   logic       tmds_signal [2:0]; //output of each TMDS serializer!

   //three tmds_encoders (blue, green, red)
   //note green should have no control signal like red
   //the blue channel DOES carry the two sync signals:
   //  * control_in[0] = horizontal sync signal
   //  * control_in[1] = vertical sync signal

   tmds_encoder tmds_red(
       .clk_in(clk_pixel),
       .rst_in(sys_rst_pixel),
       .data_in(red),
       .control_in(2'b0),
       .ve_in(active_draw_hdmi),
       .tmds_out(tmds_10b[2]));

   tmds_encoder tmds_green(
         .clk_in(clk_pixel),
         .rst_in(sys_rst_pixel),
         .data_in(green),
         .control_in(2'b0),
         .ve_in(active_draw_hdmi),
         .tmds_out(tmds_10b[1]));

   tmds_encoder tmds_blue(
        .clk_in(clk_pixel),
        .rst_in(sys_rst_pixel),
        .data_in(blue),
        .control_in({vsync_hdmi,hsync_hdmi}),
        .ve_in(active_draw_hdmi),
        .tmds_out(tmds_10b[0]));


   //three tmds_serializers (blue, green, red):
   //MISSING: two more serializers for the green and blue tmds signals.
   tmds_serializer red_ser(
         .clk_pixel_in(clk_pixel),
         .clk_5x_in(clk_5x),
         .rst_in(sys_rst_pixel),
         .tmds_in(tmds_10b[2]),
         .tmds_out(tmds_signal[2]));
   tmds_serializer green_ser(
         .clk_pixel_in(clk_pixel),
         .clk_5x_in(clk_5x),
         .rst_in(sys_rst_pixel),
         .tmds_in(tmds_10b[1]),
         .tmds_out(tmds_signal[1]));
   tmds_serializer blue_ser(
         .clk_pixel_in(clk_pixel),
         .clk_5x_in(clk_5x),
         .rst_in(sys_rst_pixel),
         .tmds_in(tmds_10b[0]),
         .tmds_out(tmds_signal[0]));

   //output buffers generating differential signals:
   //three for the r,g,b signals and one that is at the pixel clock rate
   //the HDMI receivers use recover logic coupled with the control signals asserted
   //during blanking and sync periods to synchronize their faster bit clocks off
   //of the slower pixel clock (so they can recover a clock of about 742.5 MHz from
   //the slower 74.25 MHz clock)
   OBUFDS OBUFDS_blue (.I(tmds_signal[0]), .O(hdmi_tx_p[0]), .OB(hdmi_tx_n[0]));
   OBUFDS OBUFDS_green(.I(tmds_signal[1]), .O(hdmi_tx_p[1]), .OB(hdmi_tx_n[1]));
   OBUFDS OBUFDS_red  (.I(tmds_signal[2]), .O(hdmi_tx_p[2]), .OB(hdmi_tx_n[2]));
   OBUFDS OBUFDS_clock(.I(clk_pixel), .O(hdmi_clk_p), .OB(hdmi_clk_n));


   // Nothing To Touch Down Here:
   // register writes to the camera

   // The OV5640 has an I2C bus connected to the board, which is used
   // for setting all the hardware settings (gain, white balance,
   // compression, image quality, etc) needed to start the camera up.
   // We've taken care of setting these all these values for you:
   // "rom.mem" holds a sequence of bytes to be sent over I2C to get
   // the camera up and running, and we've written a design that sends
   // them just after a reset completes.

   // If the camera is not giving data, press your reset button.

   logic  busy, bus_active;
   logic  cr_init_valid, cr_init_ready;

   logic  recent_reset;
   always_ff @(posedge clk_camera) begin
      if (sys_rst_camera) begin
         recent_reset <= 1'b1;
         cr_init_valid <= 1'b0;
      end
      else if (recent_reset) begin
         cr_init_valid <= 1'b1;
         recent_reset <= 1'b0;
      end else if (cr_init_valid && cr_init_ready) begin
         cr_init_valid <= 1'b0;
      end
   end

   logic [23:0] bram_dout;
   logic [7:0]  bram_addr;

   // ROM holding pre-built camera settings to send
   xilinx_single_port_ram_read_first
     #(
       .RAM_WIDTH(24),
       .RAM_DEPTH(256),
       .RAM_PERFORMANCE("HIGH_PERFORMANCE"),
       .INIT_FILE("rom.mem")
       ) registers
       (
        .addra(bram_addr),     // Address bus, width determined from RAM_DEPTH
        .dina(24'b0),          // RAM input data, width determined from RAM_WIDTH
        .clka(clk_camera),     // Clock
        .wea(1'b0),            // Write enable
        .ena(1'b1),            // RAM Enable, for additional power savings, disable port when not in use
        .rsta(sys_rst_camera), // Output reset (does not affect memory contents)
        .regcea(1'b1),         // Output register enable
        .douta(bram_dout)      // RAM output data, width determined from RAM_WIDTH
        );

   logic [23:0] registers_dout;
   logic [7:0]  registers_addr;
   assign registers_dout = bram_dout;
   assign bram_addr = registers_addr;

   logic       con_scl_i, con_scl_o, con_scl_t;
   logic       con_sda_i, con_sda_o, con_sda_t;

   // NOTE these also have pullup specified in the xdc file!
   // access our inouts properly as tri-state pins
   IOBUF IOBUF_scl (.I(con_scl_o), .IO(i2c_scl), .O(con_scl_i), .T(con_scl_t) );
   IOBUF IOBUF_sda (.I(con_sda_o), .IO(i2c_sda), .O(con_sda_i), .T(con_sda_t) );

   // provided module to send data BRAM -> I2C
   camera_registers crw
     (.clk_in(clk_camera),
      .rst_in(sys_rst_camera),
      .init_valid(cr_init_valid),
      .init_ready(cr_init_ready),
      .scl_i(con_scl_i),
      .scl_o(con_scl_o),
      .scl_t(con_scl_t),
      .sda_i(con_sda_i),
      .sda_o(con_sda_o),
      .sda_t(con_sda_t),
      .bram_dout(registers_dout),
      .bram_addr(registers_addr));

   // a handful of debug signals for writing to registers
   assign led[0] = crw.bus_active;
   assign led[1] = cr_init_valid;
   assign led[2] = cr_init_ready;
   assign led[15:3] = 0;

endmodule // top_level


`default_nettype wire
