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

sys.path.append(str(Path(__file__).resolve().parent.parent.parent.parent / "phys_py"))
import simulate as phys_sim
from primitives import SFIX16, SFIX32

# module update_pos_vel(
#     input wire [`OBJ_DYN_WIDTH-1:0] obj_dyn_in,
#     input wire signed [`DF_DEC+1:0] time_step,
#     output wire [2 * `SF - 1:0] obj_pos_out
#   );


def sfix16(val):
    intval = int(val * (2**5))
    return intval & 0xFFFF


def sfix32(val):
    intval = int(val * (2**11))
    return intval & 0xFFFFFFFF


def sfix16_to_float(val):
    if val & 0x8000:
        val = val - 0x10000
    return val / (2**5)


def sfix32_to_float(val):
    if val & 0x80000000:
        val = val - 0x100000000
    return val / (2**11)


# def parse_pos(pos_out):
#     pos_x = sfix16_to_float((pos_out >> 16) & 0xFFFF)
#     pos_y = sfix16_to_float(pos_out & 0xFFFF)
#     return pos_x, pos_y


def parse_dyn(obj_dyn):
    pos_x = sfix16_to_float((obj_dyn >> 48) & 0xFFFF)
    pos_y = sfix16_to_float((obj_dyn >> 32) & 0xFFFF)
    vel_x = sfix16_to_float((obj_dyn >> 16) & 0xFFFF)
    vel_y = sfix16_to_float(obj_dyn & 0xFFFF)
    return pos_x, pos_y, vel_x, vel_y


def mul(a, t):
    return (int(a * t * (2**16)) // (2**11)) / (2**5)


async def test_set(dut, _pos_x, _pos_y, _vel_x, _vel_y, _time_step):
    pos_x = SFIX16(_pos_x)
    pos_y = SFIX16(_pos_y)
    vel_x = SFIX16(_vel_x)
    vel_y = SFIX16(_vel_y)
    time_step = SFIX32(_time_step)

    dut.obj_in.value = (
        1 << 113
        | pos_x.get_int_repr() << 48
        | pos_y.get_int_repr() << 32
        | vel_x.get_int_repr() << 16
        | vel_y.get_int_repr()
    )
    dut.time_step.value = time_step.get_int_repr()
    await ClockCycles(dut.sys_clk, 1)

    new_dyn = dut.obj_out.value
    _new_pos_x, _new_pos_y, _new_vel_x, _new_vel_y = parse_dyn(new_dyn)

    exp_pos, exp_vel = phys_sim.update_pos_vel(
        (pos_x, pos_y), (vel_x, vel_y), SFIX16(1), time_step
    )

    # print(f"pos = ({_pos_x}, {_pos_y}) -> ({_new_pos_x}, {_new_pos_y})")
    # print(f"Should be ({exp_pos[0].get_float()}, {exp_pos[1].get_float()})")
    # print(f"vel = ({vel_x}, {vel_y}) -> ({_new_vel_x}, {_new_vel_y})")
    # print(f"Should be ({exp_vel[0].get_float()}, {exp_vel[1].get_float()})")
    # print("\n")

    assert _new_pos_x == exp_pos[0].get_float()
    assert _new_pos_y == exp_pos[1].get_float()
    assert _new_vel_x == exp_vel[0].get_float()
    assert _new_vel_y == exp_vel[1].get_float()


@cocotb.test()
async def test_a(dut):
    dut._log.info("Starting...")
    # new independent clock signal
    cocotb.start_soon(Clock(dut.sys_clk, 10, units="ns").start())
    await ClockCycles(dut.sys_clk, 1)

    pos_x = 23 / 32
    pos_y = 531 / 32
    vel_x = 102 / 32
    vel_y = 39 / 32
    time_step = 1
    await test_set(dut, pos_x, pos_y, vel_x, vel_y, time_step)
    await ClockCycles(dut.sys_clk, 10)

    await test_set(dut, 0, -54 / 32, -13 / 32, 0, 1.0)
    await ClockCycles(dut.sys_clk, 10)

    await test_set(dut, -1532 / 32, 6342 / 32, -421 / 32, 531 / 32, 634 / 2048)
    await ClockCycles(dut.sys_clk, 10)

    await test_set(
        dut, -998 * 32 / 32, 1010 * 31 / 32, -938 * 29 / 32, 1020 * 30 / 32, 1733 / 2048
    )
    await ClockCycles(dut.sys_clk, 10)


def is_runner():
    """Image Sprite Tester."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "physics_engine.sv"]
    sources += [proj_path / "hdl" / "update_pos_vel.sv"]
    sources += [proj_path / "hdl" / "xilinx_single_port_ram_read_first.v"]
    build_test_args = ["-Wall"]
    parameters = {}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="update_pos_vel",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale=("1ns", "1ps"),
        waves=True,
        verbose=True,
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="update_pos_vel",
        test_module="test_update_pos_vel",
        test_args=run_test_args,
        waves=True,
    )


if __name__ == "__main__":
    is_runner()
