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
from pprint import pprint

phys_path = Path(__file__).resolve().parent.parent.parent.parent / "phys_py"
sys.path.append(str(phys_path))
import simulate as phys_sim
import main as phys_main
import input as phys_input
from my_types import ResultVideo
from primitives import SFIX16, SFIX32

# module physics_engine #(OBJ_COUNT=8, MAX_ITER=64)(
#     input wire sys_clk,
#     input wire sys_rst,
#     input wire frame_start_in,

#     output enum logic [2:0] {IDLE, LOADING, COLLISION, UPDATING, SAVING} state_out,
#     output logic frame_end_out,

#     output logic [3:0] load_signal_out,
#     input wire [`OBJ_WIDTH-1:0] load_object_data_in[3:0],
#     output logic [9:0] load_object_index_out[3:0],

#     output logic save_signal_out,
#     output logic [9:0] save_object_index_out,
#     output logic [`OBJ_WIDTH-1:0] save_object_data_out
#   );


def get_id_bits(type_str):
    if not type_str:
        return 0
    if type_str == "circle":
        return 1
    elif type_str == "line":
        return 2
    elif type_str == "rect":
        return 3
    else:
        raise ValueError(f"Unsupported shape type {type_str}")


def get_shape_type(id_bits):
    if id_bits == 0:
        return None
    if id_bits == 1:
        return "circle"
    elif id_bits == 2:
        return "line"
    elif id_bits == 3:
        return "rect"
    else:
        raise ValueError(f"Unsupported id_bits {id_bits}")


def serialize_params(params):
    if not params:
        return 0
    return SFIX16(params[0]).get_int_repr()  # for now, only circle


def serialize(obj):
    if not obj:
        return 0
    is_static = 1 if obj["static"] else 0
    id_bits = get_id_bits(obj["shape_type"])
    params = serialize_params(obj["params"])
    pos_x = SFIX16(obj["position"][0]).get_int_repr()
    pos_y = SFIX16(obj["position"][1]).get_int_repr()
    vel_x = SFIX16(obj["velocity"][0]).get_int_repr()
    vel_y = SFIX16(obj["velocity"][1]).get_int_repr()

    res = 0
    res = res | is_static
    res = (res << 2) | id_bits
    res = (res << 36) | params
    res = (res << 16) | pos_x
    res = (res << 16) | pos_y
    res = (res << 16) | vel_x
    res = (res << 16) | vel_y

    return res


def parse_sfix16(val):
    val = val & 0xFFFF
    if val & 0x8000:
        val = val - 0x10000
    return int(val) / (2**5)


def deserialize(obj_bits):
    if obj_bits == 0:
        return None
    obj = {}
    obj["velocity"] = [parse_sfix16(obj_bits >> 16), parse_sfix16(obj_bits)]
    obj_bits = obj_bits >> 32
    obj["position"] = [parse_sfix16(obj_bits >> 16), parse_sfix16(obj_bits)]
    obj_bits = obj_bits >> 32
    obj["params"] = [parse_sfix16(obj_bits)]  # TODO
    obj_bits = obj_bits >> 36
    obj["shape_type"] = get_shape_type(obj_bits & 0b11)
    obj_bits = obj_bits >> 2
    obj["static"] = obj_bits == 1
    return obj


async def init_module(dut):
    dut._log.info("Starting...")
    cocotb.start_soon(Clock(dut.sys_clk, 10, units="ns").start())
    dut.frame_start_in.value = 0
    dut.sys_rst.value = 1
    dut.load_object_data_in.value = 0  # all 4 values
    await ClockCycles(dut.sys_clk, 3)
    dut.sys_rst.value = 0
    await ClockCycles(dut.sys_clk, 5)


async def run_single_frame(dut, obj_dict_list):
    new_obj_dict_list = []

    await FallingEdge(dut.sys_clk)
    dut.frame_start_in.value = 1
    await FallingEdge(dut.sys_clk)
    dut.frame_start_in.value = 0

    while dut.state_out.value == 0:  # IDLE
        await FallingEdge(dut.sys_clk)

    while dut.state_out.value == 1:  # LOADING
        while dut.load_signal_out.value != 15:
            await FallingEdge(dut.sys_clk)
        await FallingEdge(dut.sys_clk)
        await FallingEdge(dut.sys_clk)
        load_data_in = [0, 0, 0, 0]
        index_out = dut.load_object_index_out.value
        load_index = []
        for i in range(4):
            x = index_out & (2**10 - 1)
            load_index.append(x)
            index_out = index_out >> 10
            if x < len(obj_dict_list):
                obj_bits = serialize(obj_dict_list[x])
                load_data_in[i] = obj_bits

        res = 0
        for i in range(4):
            res = res | (load_data_in[i] << (i * 103))
        dut.load_object_data_in.value = res

    while dut.state_out.value == 2:  # COLLISION
        await FallingEdge(dut.sys_clk)

    while dut.state_out.value == 3:  # UPDATING
        await FallingEdge(dut.sys_clk)

    cur_idx = 0
    while dut.state_out.value == 4:  # SAVING
        await FallingEdge(dut.sys_clk)
        if dut.save_signal_out.value == 0:
            continue
        save_index = dut.save_object_index_out.value
        save_data = dut.save_object_data_out.value
        assert save_index == cur_idx
        obj_dict = deserialize(save_data)
        new_obj_dict_list.append(obj_dict)

        cur_idx += 1

    assert dut.state_out.value == 0
    assert dut.frame_end_out.value == 1
    await ClockCycles(dut.sys_clk, 10)

    return new_obj_dict_list


@cocotb.test()
async def test_static(dut):
    obj_dict_list = []
    obj_dict_list.append(
        {
            "shape_type": "circle",
            "mass": 1.0,
            "params": [5.0],
            "position": [150, 100],
            "velocity": [0.0, 0.0],
            "static": True,
        }
    )
    obj_dict_list.append(
        {
            "shape_type": "circle",
            "mass": 1.0,
            "params": [10.0],
            "position": [309.09375, 195.53125],
            "velocity": [0.0, 0.0],
            "static": True,
        }
    )

    await init_module(dut)

    for fr in range(10):
        new_obj_dict_list = await run_single_frame(dut, obj_dict_list)
        obj_list = [phys_input.load_object(od, i) for i, od in enumerate(obj_dict_list)]
        exp_obj_list = phys_main.physics_engine_single_frame(False, obj_list)
        exp_obj_dict_list = [phys_input.get_object(ol) for ol in exp_obj_list]

        # assert new_obj_dict_list == exp_obj_dict_list
        length = len(obj_dict_list)
        for i in range(length):
            # assert new_obj_dict_list[i] == exp_obj_dict_list[i]
            exp_obj = exp_obj_dict_list[i]
            new_obj = new_obj_dict_list[i]
            assert exp_obj["static"] == new_obj["static"]
            assert exp_obj["shape_type"] == new_obj["shape_type"]
            assert exp_obj["position"] == new_obj["position"]
            assert exp_obj["velocity"] == new_obj["velocity"]
            # assert exp_obj["params"] == new_obj["params"] # TODO

        obj_dict_list = [obj for obj in new_obj_dict_list if obj]


@cocotb.test()
async def test_dyn(dut):
    # input_file = phys_path / "test" / "sandbox.json"
    # info, obj_list = phys_input.load_obj_file(input_file)
    # for obj in obj_list:
    #     obj.mass = SFIX32(1.0)

    obj_dict_list = []
    obj_dict_list.append(
        {
            "shape_type": "circle",
            "mass": 1.0,
            "params": [5.0],
            "position": [200, 100],
            "velocity": [0.0, -1.25],
            "static": False,
        }
    )
    obj_dict_list.append(
        {
            "shape_type": "circle",
            "mass": 1.0,
            "params": [10.0],
            "position": [309.09375, 195.53125],
            "velocity": [10.0, 0.0],
            "static": False,
        }
    )
    obj_dict_list.append(
        {
            "shape_type": "circle",
            "mass": 1.0,
            "params": [20.0],
            "position": [123.34375, 279.78125],
            "velocity": [3.625, -5.25],
            "static": False,
        }
    )
    obj_dict_list.append(
        {
            "shape_type": "circle",
            "mass": 1.0,
            "params": [50.0],
            "position": [240, 310],
            "velocity": [0, 0],
            "static": True,
        }
    )
    await init_module(dut)
    await ClockCycles(dut.sys_clk, 100)

    video = ResultVideo("test")

    for fr in range(60):
        new_obj_dict_list = await run_single_frame(dut, obj_dict_list)
        obj_list = [phys_input.load_object(od, i) for i, od in enumerate(obj_dict_list)]
        exp_obj_list = phys_main.physics_engine_single_frame(False, obj_list, fr, video)
        exp_obj_dict_list = [phys_input.get_object(ol) for ol in exp_obj_list]

        # assert new_obj_dict_list == exp_obj_dict_list
        length = len(obj_dict_list)
        for i in range(length):
            # assert new_obj_dict_list[i] == exp_obj_dict_list[i]
            exp_obj = exp_obj_dict_list[i]
            new_obj = new_obj_dict_list[i]
            # pprint(f"orig    = {obj_dict_list[i]}")
            # pprint(f"exp_obj = {exp_obj}")
            # pprint(f"new_obj = {new_obj}")
            assert exp_obj["static"] == new_obj["static"]
            assert exp_obj["shape_type"] == new_obj["shape_type"]
            assert exp_obj["position"] == new_obj["position"]
            assert exp_obj["velocity"] == new_obj["velocity"]
            # assert exp_obj["params"] == new_obj["params"] # TODO

        obj_dict_list = [obj for obj in new_obj_dict_list if obj]

    video.export_as_gif()


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
