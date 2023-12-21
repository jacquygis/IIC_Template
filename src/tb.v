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
    reg  clk;
    reg  rst_n;
    reg  ena;
    reg  [7:0] ui_in;
    reg  [7:0] uio_in;

    wire [6:0] segments = uo_out[6:0];
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    tt_um_seven_segment_seconds tt_um_seven_segment_seconds (
    // include power ports for the Gate Level test
    `ifdef GL_TEST
        .VPWR( 1'b1),
        .VGND( 1'b0),
    `endif
        .in_data	  (ui_in[7:4]),		// data-input
	.in_addr	  (ui_in[3:0]),		// storage addresses inputs
        .uo_out		  (uo_out),		// Dedicated outputs
        .in_opcode	  (uio_in[7:4]),	// IOs: Input path opcode inputs
	.in_write_enable  (uio_in[0],		// IOs: Input path write enable input
	.inputs_not_used  (uio_in[3:1]),	// IOs: Input path not used input signals
        .outputs_not_used (uio_out),  		// IOs: Output path not used output signals
        .uio_oe     	  (uio_oe),		// IOs: Enable path (active high: 0=input, 1=output)
        .ena        (ena),      // enable - goes high when design is selected
        .clk        (clk),      // clock
        .rst_n      (rst_n)     // not reset
        );

endmodule
