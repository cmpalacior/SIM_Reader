//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------
`timescale 1 ns / 100 ps

module system_tb;

//----------------------------------------------------------------------------
// Parameter (may differ for physical synthesis)
//----------------------------------------------------------------------------
parameter tck              = 20;       // clock period in ns
parameter uart_baud_rate   = 1152000;  // uart baud rate for simulation 

parameter clk_freq = 1000000000 / tck; // Frequenzy in HZ
//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------
reg        clk;
reg        rst;
wire       led;

//----------------------------------------------------------------------------
// UART STUFF (testbench uart, simulating a comm. partner)
//----------------------------------------------------------------------------
wire         uart_rxd;
wire         uart_txd;


//----------------------------------------------------------------------------
// Device Under Test 
//----------------------------------------------------------------------------
system #(
	.clk_freq(           clk_freq         ),
	.uart_baud_rate(     uart_baud_rate   )
) dut  (
	.clk(          clk    ),
	// Debug
	.rst(          rst    ),
	.led(          led    ),
	// Keyboard
	.key_column(	key_column   ),
	.key_row(	key_row      ),

	// Uart
	.uart_rxd(  uart_rxd  ),
	.uart_txd(  uart_txd  )
);

/* Clocking device */
initial         clk <= 0;
always #(tck/2) clk <= ~clk;

	// Inputs
	reg [3:0] key_row;

	// Outputs
	wire [3:0] key_column;
/* Simulation setup */

initial begin
	key_row = 0;
	#60000;
	key_row = 4'b0100;
	#40000;
	key_row = 0;
	#150000;
	key_row = 4'b0100;
	#50000;
	key_row = 0;
	#150000;
	key_row = 4'b0100;
	#50000;
	key_row = 0;
	#150000;
	key_row = 4'b0100;
	#50000;
	key_row = 0;
	#150000;
	key_row = 4'b0100;
	#50000;
	key_row = 0;
	#150000;
	key_row = 4'b0100;
	#30000;
	key_row = 0;
	#4500;
	key_row = 0;
	#50000;
	key_row = 0;
	end

initial begin
	$dumpfile("system_tb.vcd");
	//$monitor("%b,%b,%b,%b",clk,rst,uart_txd,uart_rxd);
	$dumpvars(-1, dut);
	//$dumpvars(-1,clk,rst,wb_adr_i,wb_dat_i,Registro_LCD);
	// reset
	#0  rst <= 1;
	#80 rst <= 0;

	#(tck*50000) $finish;
end
	



endmodule
