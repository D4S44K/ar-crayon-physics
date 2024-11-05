import cocotb
import os
import sys
from math import log
import logging
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge, ReadOnly,with_timeout
from cocotb.utils import get_sim_time as gst
from cocotb.runner import get_runner

@cocotb.test()
async def test_a(dut):
    """cocotb test for line buffer"""
    dut._log.info("Starting...")
    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())
    # false tabulate
    dut.rst_in.value = 0
    await ClockCycles(dut.clk_in, 1)
    dut.rst_in.value = 1
            # input wire [10:0] hcount_in, //current hcount being read
            # input wire [9:0] vcount_in, //current vcount being read
            # input wire [15:0] pixel_data_in, //incoming pixel
            # input wire data_valid_in, //incoming  valid data signal
    data = [[8, 1, 3], [0, 1, 1], [2, 7, 5], [0, 8, 9], [10, 10, 10]]
    await ClockCycles(dut.clk_in, 1)
    dut.rst_in.value = 0
    for vcount in range(5):
        for hcount in range(3):
            dut.hcount_in = hcount
            dut.vcount_in = vcount
            dut.data_valid_in = 1
            dut.pixel_data_in = data[vcount][hcount]
            await ClockCycles(dut.clk_in, 1)
    dut.data_valid_in = 0
    await ClockCycles(dut.clk_in, 10)
    

def is_runner():
    """Image Sprite Tester."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "line_buffer.sv"]
    # sources += [proj_path / "hdl" / "divider.sv"]
    sources += [proj_path / "hdl" / "xilinx_true_dual_port_read_first_1_clock_ram.v"]
    build_test_args = ["-Wall"]
    parameters = {"HRES": 3, "VRES": 5}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="line_buffer",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="line_buffer",
        test_module="test_line_buffer",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    is_runner()
