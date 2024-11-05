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
     logic to_tabulate;
     logic [31:0] x_sum, y_sum;
     logic [31:0] count;
     logic x_done;
     logic y_done;
     logic x_valid;
     logic y_valid;
     logic x_error;
     logic y_error;
     logic x_busy;
     logic y_busy;
     logic [31:0] x_quotient;
     logic [31:0] done_x_quotient;
     logic [31:0] x_remainder;
     logic [31:0] y_quotient;
     logic [31:0] done_y_quotient;
     logic [31:0] y_remainder;
    divider divide_x(.clk_in(clk_in),
                    .rst_in(rst_in),
                    .dividend_in(x_sum),
                    .divisor_in(count),
                    .data_valid_in(to_tabulate),
                    .quotient_out(x_quotient),
                    .remainder_out(x_remainder),
                    .data_valid_out(x_valid),
                    .error_out(x_error),
                    .busy_out(x_busy));
    divider divide_y(.clk_in(clk_in),
                    .rst_in(rst_in),
                    .dividend_in(y_sum),
                    .divisor_in(count),
                    .data_valid_in(to_tabulate),
                    .quotient_out(y_quotient),
                    .remainder_out(y_remainder),
                    .data_valid_out(y_valid),
                    .error_out(y_error),
                    .busy_out(y_busy));

     always_ff@(posedge clk_in) begin
        if(rst_in) begin
            x_out <= 0;
            y_out <= 0;
            valid_out <= 0;
            x_sum <= 0;
            y_sum <= 0;
            count <= 0;
            x_done <= 0;
            y_done <= 0;
            to_tabulate <= 0;
            done_x_quotient <= 0;
            done_y_quotient <= 0;
        end
        else begin

            // tabulate_in              -- ready to divide
            //  count != 0              -- error-free input
            // x_busy || y_busy         -- still dividing
            //  !x_busy                 -- x_done
            //  !y_busy                 -- y_done
            // x_done && y_done         -- valid_out, reset
            // otherwise                -- tabulate
            if(tabulate_in) begin 
                if(count) to_tabulate <= 1;
                valid_out <= 0;
            end
            else if(x_valid && y_valid) begin
                valid_out <= 1;
                x_out <= x_quotient;
                y_out <= y_quotient;
                x_sum <= 0;
                y_sum <= 0;
                count <= 0;
                x_done <= 0;
                y_done <= 0;
                to_tabulate <= 0;
                done_x_quotient <= 0;
                done_y_quotient <= 0;
            end
            else if(x_valid) begin
                x_done <= 1;
                done_x_quotient <= 1;
                valid_out <= 0;
                to_tabulate <= 0;
            end
            else if(y_valid) begin
                y_done <= 1;
                done_y_quotient <= y_quotient;
                valid_out <= 0;
                to_tabulate <= 0;
                end
            else if(x_done && y_done) begin
                valid_out <= 1;
                x_out <= x_quotient;
                y_out <= y_quotient;
                x_sum <= 0;
                y_sum <= 0;
                count <= 0;
                x_done <= 0;
                y_done <= 0;
                to_tabulate <= 0;
                done_x_quotient <= 0;
                done_y_quotient <= 0;
            end
            else if(valid_in && !x_busy && !y_busy) begin
                x_sum <= x_sum + x_in;
                y_sum <= y_sum + y_in;
                count <= count + 1;
                valid_out <= 0;
                to_tabulate <= 0;
            end
            else begin
                valid_out <= 0;
                to_tabulate <= 0;
            end
        end
     end
endmodule

`default_nettype wire
