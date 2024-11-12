`default_nettype none
module center_of_mass (
                         input wire clk_in,
                         input wire rst_in,
                         input wire [10:0] x_in,
                         input wire [9:0]  y_in,
                         input wire valid_in,
                         input wire tabulate_in,
                         output logic [10:0] x_out,
                         output logic [9:0] y_out,
                         output logic valid_out);
	 // your code here

  // store x and y sums, pixel count
  logic [31:0] x_sum;
  logic [31:0] y_sum;
  logic [31:0] pixel_count;

  // divider inputs and outputs
  logic [31:0] x_quotient, y_quotient;
  logic [31:0] remainder_x;
  logic [31:0] remainder_y;
  logic data_valid_div_x, data_valid_div_y;
  logic busy_div_x, busy_div_y;
  logic error_div_x, error_div_y;

  logic data_valid_div_x_tracker, data_valid_div_y_tracker;

  logic start_div;

  // registers to store calculated average positions
  logic [10:0] avg_x;
  logic [9:0] avg_y;

  // states
  localparam IDLE = 2'b00;
  localparam DIVIDE = 2'b01;
  localparam DONE = 2'b11;

  logic [1:0] state;

  // reset and accumulation logic
  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      x_sum <= 32'd0;
      y_sum <= 32'd0;
      pixel_count <= 20'd0;
      avg_x <= 11'd0;
      avg_y <= 10'd0;
      state <= IDLE;
      valid_out <= 1'b0;
    end else begin

      // next_state <= state;

      case (state)
        IDLE: begin
          if (valid_in) begin
            // accumulate valid x and y positions and increment pixel count
            x_sum <= x_sum + x_in;
            y_sum <= y_sum + y_in;
            pixel_count <= pixel_count + 1;
          end
          if (tabulate_in && pixel_count > 0) begin
            state <= DIVIDE;
            start_div <= 1'b1;
            valid_out <= 1'b0;
          end
        end

        DIVIDE: begin
          start_div <= 1'b0;
          if (data_valid_div_x) begin
            x_out <= x_quotient[10:0];
            data_valid_div_x_tracker <= 1;
            if (data_valid_div_y_tracker) begin
              state <= DONE;
            end
          end
          if (data_valid_div_y) begin
            y_out <= y_quotient[9:0];
            data_valid_div_y_tracker <= 1;
            if (data_valid_div_x_tracker) begin
              state <= DONE;
            end
          end
        end

        DONE: begin
          state <= IDLE;  // go back to IDLE once results are read
          valid_out <= 1;
          data_valid_div_x_tracker <= 0;
          data_valid_div_y_tracker <= 0;
          // x_out <= avg_x;
          // y_out <= avg_y;
          pixel_count <= 0;
          start_div <= 1'b0;
          x_sum <= 0;
          y_sum <= 0;
        end
      endcase

      // if (data_valid_div_x) begin
      //   avg_x <= x_quotient[10:0];  // Truncate to 11-bit value for x_out
      // end

      // if (data_valid_div_y) begin
      //   avg_y <= y_quotient[9:0];  // Truncate to 10-bit value for y_out
      // end
    end
  end

  // divide x sum
  divider #(.WIDTH(32)) x_div (
      .clk_in(clk_in),
      .rst_in(rst_in),
      .dividend_in(x_sum),
      .divisor_in(pixel_count),
      .data_valid_in(start_div),
      .quotient_out(x_quotient),
      .remainder_out(remainder_x),
      .data_valid_out(data_valid_div_x),
      .error_out(error_div_x),
      .busy_out(busy_div_x)
  );

  // divide y sum
  divider #(.WIDTH(32)) y_div (
      .clk_in(clk_in),
      .rst_in(rst_in),
      .dividend_in(y_sum),
      .divisor_in(pixel_count),
      .data_valid_in(start_div),
      .quotient_out(y_quotient),
      .remainder_out(remainder_y),
      .data_valid_out(data_valid_div_y),
      .error_out(error_div_y),
      .busy_out(busy_div_y)
  );

  // output
  // assign x_out = avg_x;
  // assign y_out = avg_y;
endmodule

`default_nettype wire
