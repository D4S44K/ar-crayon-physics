import cocotb
import os
import sys
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge
from cocotb.runner import get_runner

async def reset(dut):
    """ Reset the DUT """
    dut.rst_in.value = 1
    await ClockCycles(dut.clk_in, 3)
    dut.rst_in.value = 0
    await ClockCycles(dut.clk_in, 2)

@cocotb.test()
async def test_center_of_mass(dut):
    """Cocotb test for center_of_mass module."""
    dut._log.info("Starting center_of_mass test...")
    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())

    # reset
    await reset(dut)

    # set initial values
    dut.x_in.value = 0
    dut.y_in.value = 0
    dut.valid_in.value = 0
    dut.tabulate_in.value = 0

    # pixel position set
    dut._log.info("Accumulating pixel positions...")
    for i in range(1, 500):
        dut.x_in.value = 100 + i
        dut.y_in.value = 50 + i
        dut.valid_in.value = 1
        await ClockCycles(dut.clk_in, 1)
        dut.valid_in.value = 0
        await ClockCycles(dut.clk_in, 1)

    # trigger tabulation
    dut.tabulate_in.value = 1
    await ClockCycles(dut.clk_in, 1000)
    dut.tabulate_in.value = 0

    # wait for computation
    dut._log.info("Waiting for computation...")
    await ClockCycles(dut.clk_in, 1000)

    # assert
    assert dut.x_out.value == 350, f"Expected x_out to be 350, but got {dut.x_out.value}"
    assert dut.y_out.value == 300, f"Expected y_out to be 300, but got {dut.y_out.value}"
    assert dut.valid_out.value == 1, "Expected valid_out to be 1 after computation is complete."

    dut._log.info("Test completed successfully.")


    ################ TEST 1 PIXEL #################
    # reset
    await reset(dut)

    # set initial values
    dut.x_in.value = 0
    dut.y_in.value = 0
    dut.valid_in.value = 0
    dut.tabulate_in.value = 0

    # pixel position set
    dut._log.info("Accumulating pixel positions...")
    dut.x_in.value = 100
    dut.y_in.value = 50
    dut.valid_in.value = 1
    await ClockCycles(dut.clk_in, 1)
    dut.valid_in.value = 0
    await ClockCycles(dut.clk_in, 1)

    # trigger tabulation
    dut.tabulate_in.value = 1
    await ClockCycles(dut.clk_in, 1000)
    dut.tabulate_in.value = 0

    # wait for computation
    dut._log.info("Waiting for computation...")
    await ClockCycles(dut.clk_in, 1000)

    # assert
    assert dut.x_out.value == 100, f"Expected x_out to be 100, but got {dut.x_out.value}"
    assert dut.y_out.value == 50, f"Expected y_out to be 50, but got {dut.y_out.value}"
    assert dut.valid_out.value == 1, "Expected valid_out to be 1 after computation is complete."

    dut._log.info("Test completed successfully.")

    ################ 1024 x 768 #################
    await reset(dut)

    # set initial values
    dut.x_in.value = 0
    dut.y_in.value = 0
    dut.valid_in.value = 0
    dut.tabulate_in.value = 0

    # pixel position set
    dut._log.info("Accumulating pixel positions...")
    for i in range(1024):
        dut.x_in.value = i
        for j in range(768):
            dut.y_in.value = j
            dut.valid_in.value = 1
            await ClockCycles(dut.clk_in, 1)
            dut.valid_in.value = 0
            await ClockCycles(dut.clk_in, 1)

    # trigger tabulation
    dut.tabulate_in.value = 1
    await ClockCycles(dut.clk_in, 1000)
    dut.tabulate_in.value = 0

    # wait for computation
    dut._log.info("Waiting for computation...")
    await ClockCycles(dut.clk_in, 1000)

    # assert
    assert dut.x_out.value == 511, f"Expected x_out to be 511, but got {dut.x_out.value}"
    assert dut.y_out.value == 383, f"Expected y_out to be 383, but got {dut.y_out.value}"
    assert dut.valid_out.value == 1, "Expected valid_out to be 1 after computation is complete."

    dut._log.info("Test completed successfully.")


def center_of_mass_runner():
    """Runner for center_of_mass test."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "center_of_mass.sv", proj_path / "hdl" / "divider.sv"]
    build_test_args = ["-Wall"]
    parameters = {}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="center_of_mass",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale=('1ns', '1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="center_of_mass",
        test_module="test_center_of_mass",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    center_of_mass_runner()
