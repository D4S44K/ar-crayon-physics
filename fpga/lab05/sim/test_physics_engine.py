import cocotb
import os
import sys
from math import log
import logging
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import (
    Timer,
    ClockCycles,
    RisingEdge,
    FallingEdge,
    ReadOnly,
    with_timeout,
)
from cocotb.utils import get_sim_time as gst
from cocotb.runner import get_runner


# module physics_engine #(OBJ_COUNT=8, MAX_ITER=64)(
#     input wire sys_clk,
#     input wire sys_rst,
#     input wire frame_start_in,
#     output enum logic [2:0] {IDLE, LOADING, COLLISION, UPDATING, SAVING} state_out,
#     output wire frame_end_out
#   );


@cocotb.test()
async def test_a(dut):
    dut._log.info("Starting...")
    cocotb.start_soon(Clock(dut.sys_clk, 10, units="ns").start())
    dut.sys_rst.value = 1
    await ClockCycles(dut.sys_clk, 1)
    dut.sys_rst.value = 0
    await ClockCycles(dut.sys_clk, 5)

    await ClockCycles(dut.sys_clk, 100)


def is_runner():
    """Image Sprite Tester."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "phys" / "physics_engine.sv"]
    sources += [proj_path / "hdl" / "phys" / "update_pos_vel.sv"]
    sources += [proj_path / "hdl" / "xilinx_single_port_ram_read_first.v"]
    build_test_args = ["-Wall"]
    parameters = {}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="physics_engine",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale=("1ns", "1ps"),
        waves=True,
        verbose=True,
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="physics_engine",
        test_module="test_physics_engine",
        test_args=run_test_args,
        waves=True,
    )


if __name__ == "__main__":
    is_runner()
