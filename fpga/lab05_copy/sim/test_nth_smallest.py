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
    # 0000 0110101010 110101010 1000110011 1000100
    #     0110101010010001001010001100110001000100
    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())
    dut.rst_in = 1
    await ClockCycles(dut.clk_in, 2, rising=False)
    dut.rst_in = 0
    for index in range(4):
        # for ind, num in enumerate(numbers):
        #     print("ind: ", ind, "num: ", num)
        #     dut.numbers[ind].value = num
        dut.numbers.value = int(f"{numbers[3]:010b}{numbers[2]:010b}{numbers[1]:010b}{numbers[0]:010b}", 2)
        print("this is numbers value: ", int(f"{numbers[3]:b}{numbers[2]:b}{numbers[1]:b}{numbers[0]:b}", 2))
        dut.valid_in.value = 1
        dut.index.value = index
        await RisingEdge(dut.clk_in)
        print("this is index: ", index, " this is numbers: ", numbers, " this is dut.numbers.value: ", dut.numbers.value, " this is valid_in: ", dut.valid_in.value)
        print("this is dut.valid_out.value: ", dut.valid_out.value)
        await RisingEdge(dut.valid_out)
        await FallingEdge(dut.clk_in)
        # await ClockCycles(dut.clk_in, 20)
        # assert dut.valid_in.value == 1, f'expected valid out to be 1 because of combinational logic'
        assert dut.nth_min.value == sorted_numbers[index], f'expected nth_min to be {bin(sorted_numbers[index])}, got {dut.nth_min.value}.'
        sorted_value = dut.sorted.value
        whole_sorted = f"{bin(sorted_value)}"[2:]
        print("numbers: ", numbers, "\nmanually sorted: ", sorted_numbers, "\nalgo sorted: [", whole_sorted[0:10], whole_sorted[10:20], whole_sorted[20:30], whole_sorted[30:40], "\nnth_min: ", dut.nth_min.value.integer, "\nindex: ", index, "\nnum of mins: ", dut.num_of_mins.value.integer)
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
