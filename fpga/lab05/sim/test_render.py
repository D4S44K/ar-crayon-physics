# input wire clk_in,
#     input wire valid_in,
#     input wire rst_in,
#     // parameters for up to four objects at a time being passed in from object storage
#     input wire [3:0] is_static,
#     input wire [3:0][1:0] id_bits,
#     input wire [3:0][35:0] params,
#     input wire [3:0][15:0] pos_x,
#     input wire [3:0][15:0] pos_y,
#     input wire [3:0][15:0] vel_x,
#     input wire [3:0][15:0] vel_y,

#     // pixel coordinate that we are querying
#     input wire [10:0] hcount_in,
#     input wire [9:0] vcount_in,

#     // resulting color
#     output logic [1:0] color_bits,

#     // write location to frame buffer
#     output logic [18:0] write_address,

#     // output logic busy_out, // todo remove
#     output logic valid_out

import cocotb
import os
import sys
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge
from cocotb.runner import get_runner

async def reset(dut):
    """ Reset the DUT """
    dut.rst_in.value = 1
    await ClockCycles(dut.clk_in, 3)
    dut.rst_in.value = 0
    await ClockCycles(dut.clk_in, 2)

# display one object
is_static = 0b1000
id_bits = 0b00000001
pos_x = 400
pos_y = 500
vel_x = 0
vel_y = 0
params = 100

@cocotb.test()
async def test_render(dut):
    """Cocotb test for render module."""
    dut._log.info("Starting render test...")
    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())

    alt = 0

    # reset
    await reset(dut)
    for hcount in range(400, 405):
        for vcount in range(500, 503):
            if(alt % 2 == 0):
                dut.is_static.value = is_static
                dut.id_bits.value = id_bits
                dut.pos_x.value = pos_x
                dut.pos_y.value = pos_y
                dut.vel_x.value = vel_x
                dut.vel_y.value = vel_y
                dut.params.value = params
            else:
                dut.is_static.value = 0
                dut.id_bits.value = 0
                dut.pos_x.value = 0
                dut.pos_y.value = 0
                dut.vel_x.value = 0
                dut.vel_y.value = 0
                dut.params.value = 0
                # await RisingEdge(dut.valid_out)
                # await FallingEdge(dut.clk_in)
            dut.hcount_in.value = hcount
            dut.vcount_in.value = vcount
            dut.valid_in.value = 1
            alt = not alt
            print(dut.valid_out.value, " ", dut.color_bits.value, " ", dut.write_address.value)
            await ClockCycles(dut.clk_in, 1)
    await ClockCycles(dut.clk_in, 20)
    
            # # assert dut.write_address.value == hcount/2 + 640 * vcount/2
            # is_in_shape = (hcount - pos_x)**2 + (vcount - pos_y)**2 <= params
            # if(is_in_shape):
            #     assert dut.color_bits.value == 2, "is static, so value should be 2"
            # else:
            #     assert dut.color_bits.value == 3
            # # await ClockCycles(dut.clk_in, 5)

    dut._log.info("Test completed successfully.")


def render_runner():
    """Runner for render test."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "render.sv", proj_path / "hdl" / "draw_circle.sv",
               proj_path / "hdl" / "draw_line.sv", proj_path / "hdl" / "draw_rectangle.sv",
               proj_path / "hdl" / "utils.sv"]
    build_test_args = ["-Wall"]
    parameters = {}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="render",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale=('1ns', '1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="render",
        test_module="test_render",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    render_runner()
