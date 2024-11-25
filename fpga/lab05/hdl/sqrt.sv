`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module sqrt #(
  parameter INTEGER_BITS=20, FRACTIONAL_BITS=11)(
  input valid_in,
  input wire clk_in,
  input wire rst_in,
  input wire [31:0] input_val,  // 1 sign bit, 20 integer bits, 11 decimal bits
  output logic [31:0] result,
  output logic valid_out,
);

  logic [31:0] low, high, mid, square;
  logic [31:0] closest_result;

  logic mid_calc;
  logic square_calc;
  logic check;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      low <= 0;
      high <= input_val;
      result <= 0;
      closest_result <= 0;
      check <= 0;
      mid_calc <= 1;
      square_calc <= 0;
    end
    else if(valid_out) valid_out <= 0;
    else if(valid_in) begin
      else if (mid_calc) begin
          mid <= (low + high) >> 1;
          mid_calc <= 0;
          square_calc <= 1;
      end
      else if (square_calc) begin
          // shift back to fixed point
          square <= (mid * mid) >> FRACTIONAL_BITS;
          square_calc <= 0;
          check <= 1;
      end
      else if (check) begin
        if (low <= high) begin
          if (square == input_val) begin
            result <= mid;
            // stop calculation sqrt found
            check <= 0;
            valid_out <= 1;
          end
          else if (square < input_val) begin
            low <= mid + 1;
            // track closest approximation
            closest_result <= mid;
            mid_calc <= 1;
            check <= 0;
          end
          else begin
            high <= mid - 1;
            mid_calc <= 1;
            check <= 0;
          end
        end
        else begin
          result <= closest_result;
          valid_out <= 1;
          check <= 0;
        end
      end
    end
  end
endmodule

`default_nettype wire
