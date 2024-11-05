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
from PIL import Image
full_im_output = Image.new('RGB', (256, 256))
# im_not_done = True
@cocotb.test()
async def test_a(dut):
    """cocotb test for convolution"""
    dut._log.info("Starting...")
    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())
    # cocotb.start_soon(monitor_output(dut, "my_output_signal"))
    # false tabulate
    dut.rst_in.value = 0
    await ClockCycles(dut.clk_in, 1)
    dut.rst_in.value = 1
            # input wire [KERNEL_SIZE-1:0][15:0] data_in,
            # input wire [10:0] hcount_in,
            # input wire [9:0] vcount_in,
            # input wire data_valid_in,
            # output logic data_valid_out,
            # output logic [10:0] hcount_out,
            # output logic [9:0] vcount_out,
            # output logic [15:0] line_out
    data = [[0x10, 0x1, 0x3], [0x0, 0x1, 0x1], [0x2, 0x7, 0x5], [0x0, 0x8, 0x9], [0xA, 0xA, 0xA]]

    await ClockCycles(dut.clk_in, 1)
    dut.rst_in.value = 0
    # create a blank image with dimensions (w,h)
    # im_output = Image.new('RGB',(3,5))
    # with Image.open("pop_cat.png") as img:
    #     # print("img.mode: ", img.mode)
    #     for hcount in range(img.width):
    #         for vcount in range(img.height):
    #             dut.hcount_in.value = hcount
    #             dut.vcount_in.value = vcount
    #             dut.data_valid_in.value = 1
    #             pixel_data = img.getpixel((hcount, vcount))
    #             red = int(pixel_data[0] * 31/255)
    #             green = int(pixel_data[1] * 63/255)
    #             blue = int(pixel_data[2] * 31/255)
    #             # print("rgb: ", red, green, blue)
    #             pixel = (red << 11) | (green << 5) | (blue)
    #             # print("this is pixel: ", bin(pixel))
    #             dut.data_in.value = pixel
    #             await ClockCycles(dut.clk_in, 1)
    # dut.data_valid_in = 0
    # await ClockCycles(dut.clk_in, 10)



    # # write RGB values (r,g,b) [range 0-255] to coordinate (x,y)
    # # im_output.putpixel((x,y),(r,g,b))
    # # save image to a file
    # # im_output.save('output.png','PNG')
    for vcount in range(5):
        for hcount in range(3):
            dut.hcount_in.value = hcount
            dut.vcount_in.value = vcount
            dut.data_valid_in.value = 1
            # im_output.putpixel((hcount,vcount),(data[vcount][0],data[vcount][1], data[vcount][2]))
            pixel = ((data[vcount][0]) << 11) | ((data[vcount][1]) << 5) | ((data[vcount][2]))
            # pixel = hex(data[vcount][0])[2:].zfill(4) + hex(data[vcount][1])[2:].zfill(4) + hex(data[vcount][2])[2:].zfill(4)
            # pixel = "{%04}{%04}{%04}"
            # pixel.format(hex(data[vcount][0])[2], hex(data[vcount][1])[2], hex(data[vcount][2])[2])
            # pixel = str(format(hex(data[vcount][0])[2], '04')) + str(format(data[vcount][1], '04')) + str(format(data[vcount][2], '04'))
            print("this is pixel: ", pixel, bin(pixel))
            dut.data_in.value = pixel
            # dut.pixel_data_in = data[vcount][hcount]
            await ClockCycles(dut.clk_in, 1)
    dut.data_valid_in = 0
    await ClockCycles(dut.clk_in, 10)
    # im_output.save('output.png','PNG')
      
# @cocotb.coroutine
# def monitor_output(dut, signal_name):
#     print("here")
#     while True:
#         yield FallingEdge(dut.clk_in)
#         hcount = dut.hcount_out.value
#         vcount = dut.vcount_out.value
#         # print("hcount: ", hcount, "vcount: ", vcount)
#         # if(int(vcount == 255)
#         # if(int(hcount) == 255 & int(vcount) == 255):
#         #     im_not_done = False
#         #     full_im_output.save("full_output.png")
#         # else:
#         #     im_not_done = True
#         is_valid = dut.data_valid_out.value
#         line_out = dut.line_out.value
#         # print("data in: ", dut.data_valid_in.value)
#         # print("this is line out: ", line_out)
#         # print("this is is_valid: " , is_valid)
#         if(is_valid):
#             red = line_out >> 11
#             green = (line_out >> 5) & 0b111111
#             blue = line_out & 0b11111
#             # print("this is rgb: ", red, green, blue, int(red), int(green), int(blue))
#             # print("this is converted: ", (int(int(red)*255/31), int(int(green)*255/63), int(int(blue)*255/31)))
#             full_im_output.putpixel((hcount, vcount), (int(int(red)*255/31), int(int(green)*255/63), int(int(blue)*255/31)))
#             full_im_output.save("full_output.png")

def is_runner():
    """Image Sprite Tester."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "convolution.sv"]
    sources += [proj_path / "hdl" / "kernels.sv"]
    sources += [proj_path / "hdl" / "xilinx_true_dual_port_read_first_1_clock_ram.v"]
    build_test_args = ["-Wall"]
    parameters = {"K_SELECT": 0}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="convolution",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="convolution",
        test_module="test_convolution",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    is_runner()
