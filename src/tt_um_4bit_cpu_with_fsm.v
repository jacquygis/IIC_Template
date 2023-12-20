`default_nettype none

//converting the 8-Bit-Input to a 4-bit-input-signal via MSB
/*module EightToFourBitConverter( 
	input [7:0] eightBitInput,
	output [3:0] fourBitOutput,
	input clk,
	input rst
);

always @(posedge clk or posedge rst) begin
	//MSB put in 4-Bit-Output
	fourBitOutput <= eightBitInput[7:4];
end
endmodule

//converting the 4-bit-output-signal to a 8-bit-output 
module FourToEightBitConverter(
	input reg [3:0] fourBitInput,
	output reg [7:0] eightBitOutput,
	input clk,
	input rst
);

always @(posedge clk or posedge rst) begin
	//4-bit-input put on MSB of 8-bit-output
	eightBitOutput <= {fourBitInput, 4'b0000};
end
endmodule*/


module tt_um_4bit_cpu_with_fsm (
    input  wire [7:0] in_data_eightBit,  // input data
    input  wire [7:0] in_addr_eightBit,  // storage addresses
    input  wire [7:0] in_opcode_eightBit, //opcode for chosing operations
    output reg [7:0] out_data_eightBit, // output data
    input  wire       ena,// high when writing for storage is active
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    //signals for converting
    wire rst = ! rst_n;
    wire [3:0] in_data = in_data_eightBit[7:4];
    wire [3:0] in_addr = in_addr_eightBit[7:4];
    wire [3:0] in_opcode = in_opcode_eightBit[7:4];
    reg [3:0] out_data;

    //declaration register for accumulator, memory, Flip_Flops for write-enabling and for FSM-state
    reg [3:0] accumulator;	//accumulator
    reg [3:0] next_accumulator;
    reg [3:0] memory [0:15];	//Storage -array of registers
    reg [3:0] next_memory [0:15];
    reg write_enable_ff;	//Flip-Flop for write-enabling
    reg [3:0] operand_a;	//operand A for ALU
    reg [3:0] next_operand_a;
    reg [3:0] operand_b;	//operand B for ALU
    reg [3:0] next_operand_b;
    
    reg [2:0]fsm_state, next_fsm_state;
    localparam IDLE	= 3'b000;
    localparam LOAD	= 3'b001;
    localparam STORE	= 3'b010;
    localparam ADD_SUB	= 3'b011;
    localparam LOGIC	= 3'b100;
    localparam SHIFT	= 3'b101;

    //definition of 'CPUState' for FSM-states, each state is represented by a 3-bit-code
    /*typedef enum logic [2:0] {
	    IDLE,	//state for command execution
	    LOAD,	//state for LOAD operation
	    STORE,	//state for STORE operation
	    ADD_SUB,	//state for ADD or SUB operation
	    LOGIC,	//state for logic operations (AND, OR, XOR, NOT)
	    SHIFT	//state for shift operations (shift left, shift right)
	  } fsm_state, next_fsm_state;*/

    /*EightToFourBitConverter mod_inst1(
	    .eightBitInput(in_data_eightBit),
	    .fourBitOutput(in_data),
	    .clk(clk),
	    .rst(rst)
    );

    EightToFourBitConverter mod_inst2(
	    .eightBitInput(in_addr_eightBit),
	    .fourBitOutput(in_addr),
	    .clk(clk),
	    .rst(rst)
    );

    EightToFourBitConverter mod_inst3(
	    .eightBitInput(in_opcode_eightBit),
	    .fourBitOutput(in_opcode),
	    .clk(clk),
	    .rst(rst)
    );

    FourToEightBitConverter mod_inst4(
	    .fourBitInput(out_data),
	    .eightBitOutput(out_data_eightBit),
	    .clk(clk),
	    .rst(rst)
    );*/

    //Regproc
    always @(posedge clk or posedge rst) begin
	    if (rst) begin
		    accumulator <= 4'b0000;
		    write_enable_ff <= 1'b0;
		    fsm_state <= IDLE;
		    for (integer i=0 ; i<15 ; i = i+1)
		    begin
			    memory[i] <= 4'b0000;
		    end;
	    end else begin
		    write_enable_ff <= ena;
		    fsm_state <= next_fsm_state;
		    operand_a <= next_operand_a;
		    operand_b <= next_operand_b;
		    accumulator <= next_accumulator;
		    for (integer i=0; i<15; i = i+1)
		    begin
			    memory[i] <= next_memory[i];
		    end;
		    out_data <= accumulator;
		    out_data_eightBit <= {out_data, 4'b0000};
	    end;
    end;

    //FSM Logik
    always @(posedge clk) begin
	    case(fsm_state)
		    IDLE:	next_fsm_state <=	(in_opcode == 4'b0011) ? LOAD	:
			    				(in_opcode == 4'b0010) ? STORE	:
							(in_opcode == 4'b0000 || in_opcode == 4'b0001) ? ADD_SUB:
							(in_opcode == 4'b0100 || in_opcode == 4'b0101 || in_opcode == 4'b0110 || in_opcode == 4'b0111) ? LOGIC:
							(in_opcode == 4'b1000 || in_opcode == 4'b1001) ? SHIFT  :
							IDLE;
						
		    LOAD: 	next_fsm_state <= IDLE;
		    STORE:	next_fsm_state <= IDLE;
		    ADD_SUB:	next_fsm_state <= IDLE;
		    LOGIC:	next_fsm_state <= IDLE;
		    SHIFT:	next_fsm_state <= IDLE;
		    default:	next_fsm_state <= IDLE;
	    endcase;
    end;

    //chose operand with MUX
    always @(posedge clk) begin
	    case(in_opcode)
		    4'b0001, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010: 
		    begin
			    next_operand_a <= accumulator;
		    	    next_operand_b <= in_data;
		    end
		    default: 
		    begin
			    next_operand_a <= accumulator;
		    	    next_operand_b <= 4'b0000;
		    end
	    endcase;
    end;

    //Accumulator-Logic Operations depending on FSM-state
    always @(posedge clk) begin
	    case(fsm_state)
		    IDLE: next_accumulator <= accumulator;
		    LOAD: next_accumulator <= memory[in_addr];
		    STORE: if (write_enable_ff) next_memory[in_addr] <= accumulator; //store if writing is enabled
		    ADD_SUB: next_accumulator <= (in_opcode == 4'b0000) ? operand_a + operand_b: //ADD
			    		    (in_opcode == 4'b0001) ? operand_a - operand_b: //SUB
					    accumulator;
		    LOGIC: next_accumulator <=	(in_opcode == 4'b0101) ? operand_a & operand_b: //AND
						(in_opcode == 4'b0110) ? operand_a | operand_b: //OR
						(in_opcode == 4'b0111) ? operand_a ^ operand_b: //XOR
						(in_opcode == 4'b1000) ? ~operand_a: //NOT
						accumulator;
		    SHIFT: next_accumulator <= 	(in_opcode == 4'b1001) ? operand_a << 1: //SHIFT LEFT
						(in_opcode == 4'b1010) ? operand_a >> 1: //SHIFT LEFT
						accumulator;
		    default: next_accumulator <= accumulator;
	    endcase;
    end;
    
    // instantiate segment display
    //seg7 seg7(.counter(digit), .segments(led_out));

endmodule
