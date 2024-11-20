import cocotb
import os
import sys
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge
from cocotb.runner import get_runner

async def reset(dut):
    """ Reset the DUT """
    dut.rst_in.value = 1
    await ClockCycles(dut.clk_in, 3)
    dut.rst_in.value = 0
    await ClockCycles(dut.clk_in, 2)

@cocotb.test()
async def test_sqrt(dut):
    """Cocotb test for sqrt module"""
    dut._log.info("Testing sqrt module")
    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())

    # reset
    await reset(dut)

    # format: 1 sign bit, 20 integer bits, and 11 fractional bits
    test_cases = [
        # input -> expected
        (0b0_00000000000000000000_00000000000, 0b0_00000000000000000000_00000000000),  # sqrt(0) -> 0
        (0b0_00000000000000000100_00000000000, 0b0_00000000000000000010_00000000000),  # sqrt(4) -> 2
        (0b0_00000000000000000100_01000000000, 2.0616*2048),  # sqrt(4.25) ~> 2.06
        (0b0_00000000000000001000_00000000000, 2.8284*2048),  # sqrt(8) ~> 2.8284
        (0b0_00000000000000010000_00000000000, 0b0_00000000000000000100_00000000000),  # sqrt(16) -> 4
        (0b0_00000000000000000001_00000000000, 0b0_00000000000000000001_00000000000),  # sqrt(1) -> 1
    ]

    # check within tolerance
    def check_approx(actual, expected, tolerance=0.01):
        difference = abs(actual - expected)
        return difference <= expected * tolerance

    for input_val, expected_output in test_cases:
        dut.input_val.value = input_val
        dut._log.info(f"Testing input value: {bin(input_val)}")

        await reset(dut)

        # await RisingEdge(dut.clk_in)
        await ClockCycles(dut.clk_in, 100)
        result = dut.result.value

        assert check_approx((int(result)/2048.0), (int(expected_output)/2048.0)), (
            f"Test failed for input {int(input_val) / 2048.0}: expected ~{int(expected_output) / 2048.0}, got {int(result) / 2048.0}"
        )

        dut._log.info(f"Result for input {int(input_val) / 2048.0} is {int(result) / 2048.0}, expected ~{int(expected_output) / 2048.0}")

def is_runner():
    """Square Root Tester."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim"))
    sources = [
        proj_path / "hdl" / "sqrt.sv",
    ]
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="sqrt",
        always=True,
        timescale=('1ns', '1ps'),
        waves=True
    )
    runner.test(
        hdl_toplevel="sqrt",
        test_module="test_sqrt",
        waves=True
    )

if __name__ == "__main__":
    is_runner()
