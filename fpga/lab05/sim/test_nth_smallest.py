import cocotb
import os
import sys
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge
from cocotb.runner import get_runner

@cocotb.test()
async def test_nth_smallest(dut):
    """Cocotb test for nth_smallest module."""
    dut._log.info("nth_smallest test")
    # # all numbers different
    # numbers = [0b0001000100, 0b1000110011, 0b0100010010, 0b0110101010]
    # sorted_numbers = [0b0001000100, 0b0100010010, 0b0110101010, 0b1000110011]
    # two non-min numbers same
    numbers = [0b0001000100, 0b1000110011, 0b0110101010, 0b0110101010]
    sorted_numbers = [0b0001000100, 0b0110101010, 0b0110101010, 0b1000110011]
    # # two min numbers same
    # numbers = [0b0001000100, 0b1000110011, 0b0001000100, 0b0110101010]
    # sorted_numbers = [0b0001000100, 0b0001000100, 0b0110101010, 0b1000110011]
    # sorted_numbers = sorted(numbers)
    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())

    for index in range(4):
        for ind, num in enumerate(numbers):
            print("ind: ", ind, "num: ", num)
            dut.numbers[ind].value = num
        dut.valid_in.value = 1
        dut.index.value = index
        print("this is index: ", index, " this is numbers: ", numbers, " this is dut.numbers.value: ", dut.numbers.value, " this is valid_in: ", dut.valid_in.value)
        print("this is dut.valid_out.value: ", dut.valid_out.value)
        await ClockCycles(dut.clk_in, 1)
        await FallingEdge(dut.clk_in)
        assert dut.valid_in.value == 1, f'expected valid out to be 1 because of combinational logic'
        assert dut.min_number.value == sorted_numbers[index], f'expected min_number to be {bin(sorted_numbers[index])}, got {dut.min_number.value}.'
        print("numbers: ", numbers, "\nsorted: ", sorted_numbers, "\nmin_number: ", dut.min_number.value, "\nindex: ", index, "\nnum of mins: ", dut.num_of_mins.value)
        # assert dut.num_of_mins == 1, f'all non-min numbers different'
def is_runner():
    """nth smallest Tester."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim"))
    sources = [
        proj_path / "hdl" / "utils.sv",
    ]
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        parameters={'MAX_NUM_SIZE': 10},
        hdl_toplevel="nth_smallest",
        always=True,
        timescale=('1ns', '1ps'),
        waves=True
    )
    runner.test(
        hdl_toplevel="nth_smallest",
        test_module="test_nth_smallest",
        waves=True
    )

if __name__ == "__main__":
    is_runner()
