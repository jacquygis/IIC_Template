`default_nettype none
`timescale 1ns/1ps

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

// testbench is controlled by test.py
module tb ();

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
        #1;
    end

    // wire up the inputs and outputs
    input  wire [7:0] in_data_eightBit,  // input data
    input  wire [7:0] in_addr_eightBit,  // storage addresses
    input  wire [7:0] in_opcode_eightBit, //opcode for chosing operations
    output reg [7:0] out_data_eightBit, // output data
    input  wire       ena,// high when writing for storage is active
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset

    tt_um_4bit_cpu_with_fsm tt_um_4bit_cpu_with_fsm (
    // include power ports for the Gate Leveltest
    `ifdef GL_TEST
        .VPWR( 1'b1),
        .VGND( 1'b0),
    `endif
        .in_data_eightBit     (in_data_eightBit),    // Dedicated inputs
        .in_addr_eightBit     (in_addr_eightBit),   // Dedicated outputs
        .in_opcode_eightBit     (in_opcode_eightBit),   // IOs: Input path
        .out_data_eightBit    (out_data_eightBit),  // IOs: Output path
        .uio_oe     (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
        .ena        (ena),      // enable - goes high when design is selected
        .clk        (clk),      // clock
        .rst_n      (rst_n)     // not reset
        );

endmodule
