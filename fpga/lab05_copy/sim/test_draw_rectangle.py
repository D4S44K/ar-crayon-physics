import cocotb
import os
import sys
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge
from cocotb.runner import get_runner

@cocotb.test()
async def test_draw_rectangle(dut):
    """Cocotb test for draw_rectangle module."""
    dut._log.info("draw_rectangle test")

    # set coordinates
    x_in_1, y_in_1 = 20, 20
    x_in_2, y_in_2 = 100, 100
    COLOR = 0xFFFFFF

    # set inputs
    dut.x_in_1.value = x_in_1
    dut.y_in_1.value = y_in_1
    dut.x_in_2.value = x_in_2
    dut.y_in_2.value = y_in_2

    # define min and max bounds for the rectangle
    x_min, x_max = min(x_in_1, x_in_2), max(x_in_1, x_in_2)
    y_min, y_max = min(y_in_1, y_in_2), max(y_in_1, y_in_2)

    # helper to check if pixel is black or white
    def check_color(hcount, vcount):
        in_sprite = (x_min <= hcount and hcount < x_max) and (y_min <= vcount and vcount < y_max)
        if in_sprite:
            assert dut.red_out.value == 255, f"expected red at ({hcount},{vcount})"
            assert dut.green_out.value == 255, f"expected green at ({hcount},{vcount})"
            assert dut.blue_out.value == 255, f"expected blue at ({hcount},{vcount})"
        else:
            assert dut.red_out.value == 0, f"Expected black but got red at ({hcount},{vcount})"
            assert dut.green_out.value == 0, f"Expected black but got green at ({hcount},{vcount})"
            assert dut.blue_out.value == 0, f"Expected black but got blue at ({hcount},{vcount})"

    # test every pixel in a 128x128
    for hcount in range(128):
        for vcount in range(128):
            dut.hcount_in.value = hcount
            dut.vcount_in.value = vcount
            check_color(hcount, vcount)

def is_runner():
    """Draw Rectangle Tester."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim"))
    sources = [
        proj_path / "hdl" / "draw_rectangle.sv",
    ]
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="draw_rectangle",
        always=True,
        timescale=('1ns', '1ps'),
        waves=True
    )
    runner.test(
        hdl_toplevel="draw_rectangle",
        test_module="test_draw_rectangle",
        waves=True
    )

if __name__ == "__main__":
    is_runner()
