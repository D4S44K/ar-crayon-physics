import cocotb
from cocotb.triggers import Timer, RisingEdge, ClockCycles
from cocotb.clock import Clock
import random
import os
from pathlib import Path
import sys
from cocotb.runner import get_runner

async def reset(dut, clk):
    """Helper function to issue a reset signal to the module"""
    dut.rst_in.value = 1
    await ClockCycles(clk, 3)
    dut.rst_in.value = 0
    await ClockCycles(clk, 2)

async def drive_camera_signals(dut, pclk, hs, vs, data, duration=1):
    """Drive camera signals with the given values for a specified duration."""
    for _ in range(duration):
        dut.camera_pclk_in.value = not dut.camera_pclk_in.value
        dut.camera_hs_in.value = hs
        dut.camera_vs_in.value = vs
        dut.camera_data_in.value = data
        await ClockCycles(dut.clk_in, 1)

@cocotb.test()
async def test_pixel_reconstruct(dut):
    """Test the pixel_reconstruct module with sample data."""

    # start the clock for clk_in
    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())

    # set to 0
    dut.camera_pclk_in.value = 0
    dut.camera_hs_in.value = 0
    dut.camera_vs_in.value = 0
    dut.camera_data_in.value = 0

    # reset
    await reset(dut, dut.clk_in)

    # simulate a sequence of camera inputs with VSYNC, HSYNC, and pixel data

    # frame 1, row 1
    # await drive_camera_signals(dut, pclk=1, hs=0, vs=1, data=0xAA, duration=2)  # VSYNC high (start of frame)
    # await drive_camera_signals(dut, pclk=0, hs=0, vs=0, data=0x00, duration=2)  # VSYNC low, idle state
    # await drive_camera_signals(dut, pclk=1, hs=1, vs=0, data=0x00, duration=2)  # HSYNC high (start of row)
    # await drive_camera_signals(dut, pclk=0, hs=0, vs=0, data=0x44, duration=2)  # First pixel high byte
    # await drive_camera_signals(dut, pclk=1, hs=0, vs=0, data=0x55, duration=2)  # First pixel low byte
    # await drive_camera_signals(dut, pclk=0, hs=0, vs=0, data=0x00, duration=2)  # Idle state

    await drive_camera_signals(dut, pclk=1, hs=1, vs=1, data=0x01, duration=2)  # VSYNC high (start of frame)
    await drive_camera_signals(dut, pclk=0, hs=1, vs=1, data=0x02, duration=2)  # VSYNC low, idle state
    await drive_camera_signals(dut, pclk=1, hs=1, vs=1, data=0x03, duration=2)  # HSYNC high (start of row)
    await drive_camera_signals(dut, pclk=0, hs=1, vs=1, data=0x04, duration=2)  # First pixel high byte
    await drive_camera_signals(dut, pclk=1, hs=1, vs=1, data=0x05, duration=2)  # First pixel low byte
    await drive_camera_signals(dut, pclk=0, hs=1, vs=1, data=0x06, duration=2)  # Idle state

    # frame 1, row 2
    await drive_camera_signals(dut, pclk=1, hs=1, vs=1, data=0x07, duration=2)  # HSYNC high (start of new row)
    await drive_camera_signals(dut, pclk=0, hs=1, vs=1, data=0x08, duration=2)  # Second row, first pixel high byte
    await drive_camera_signals(dut, pclk=1, hs=1, vs=1, data=0x09, duration=2)  # Second row, first pixel low byte

    # await drive_camera_signals(dut, pclk=1, hs=1, vs=0, data=0x07, duration=2)  # HSYNC high (start of new row)
    # await drive_camera_signals(dut, pclk=0, hs=0, vs=0, data=0x08, duration=2)  # Second row, first pixel high byte
    # await drive_camera_signals(dut, pclk=1, hs=0, vs=0, data=0x09, duration=2)  # Second row, first pixel low byte

    # assert the outputs after driving data
    # assert dut.pixel_valid_out.value == 1, "Pixel should be valid after complete byte pair."
    assert dut.pixel_data_out.value == 0x4455, f"Unexpected pixel data: {hex(dut.pixel_data_out.value)}"
    assert dut.pixel_hcount_out.value == 0, f"Unexpected HCOUNT: {dut.pixel_hcount_out.value}"
    assert dut.pixel_vcount_out.value == 0, f"Unexpected VCOUNT: {dut.pixel_vcount_out.value}"

def test_pixel_reconstruct_runner():
    """Run the pixel_reconstruct runner. Boilerplate code."""
    # import os
    # from pathlib import Path
    # import sys
    # from cocotb.runner import get_runner

    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "pixel_reconstruct.sv"]
    build_test_args = ["-Wall"]
    parameters = {}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="pixel_reconstruct",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="pixel_reconstruct",
        test_module="test_pixel_reconstruct",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    test_pixel_reconstruct_runner()
