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

input = 0xdeadbeef
def reverse_bits(n,size):
    # reversed_n = 0
    # reversed_list = []
    # for i in range(size):
    #     reversed_n = (reversed_n << 1) | (n & 1)
    #     # reversed_list.append(reversed_n)
    #     n >>= 1
    # return reversed_list
    # reversed_list = []
    # return str(input)[::-1]
    print("n: ", bin(n))
    reversed_n = 0
    for i in range(size):
        reversed_n = (reversed_n << 1) | (n & 1)
        n >>= 1
    print("n: ", bin(n), "reversed_n: ", bin(reversed_n), "type: ", type(reversed_n))
    return bin(reversed_n)
    

@cocotb.test()
async def test_a(dut):
    """cocotb test for crc32_mpeg2"""
    dut._log.info("Starting...")
    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())
    # reversed_input = reverse_bits(input, 32)[2:]
    # reversed_input = chr(hex(reverse_bits(input, 32))).decode("utf-8")
    reversed_input = bin(input)[2:]
    print("this is reversed input: ", reversed_input)
    dut.rst_in.value = 0
    await ClockCycles(dut.clk_in, 1)
    dut.rst_in.value = 1
    dut.data_valid_in.value = 0
    await ClockCycles(dut.clk_in, 3)
    dut.rst_in.value = 0
    print("reversed_input: ", reversed_input)
    for bit in reversed_input:
        dut.data_valid_in.value = 1
        print("bit: ", bit)
        dut.data_in.value = int(bit)
        await ClockCycles(dut.clk_in, 1)
    dut.data_valid_in.value = 0
    await ClockCycles(dut.clk_in, 5)



def is_runner():
    """Image Sprite Tester."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "crc32_mpeg2.sv"]
    # sources += [proj_path / "hdl" / "xilinx_single_port_ram_read_first.sv"]
    build_test_args = ["-Wall"]
    parameters = {}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="crc32_mpeg2",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="crc32_mpeg2",
        test_module="test_crc32_mpeg2",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    is_runner()
