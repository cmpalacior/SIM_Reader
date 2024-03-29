//---------------------------------------------------------------------------
// Wishbone Keyboard 
//
// Register Description:
//
//    0xF0020000 KEY_CR      [ 0 | 0 | 0 | 0 | 0 | 0 | 0 | irq ]
//    0xF0020001 KEY_DATA
//
//---------------------------------------------------------------------------

module wb_keyboard #(
	parameter          clk_freq = 50000000,
	parameter          baud     = 115200
) (
	input              clk,
	input		   reset,
	// Wishbone interface
	input              wb_stb_i,
	input              wb_cyc_i,
	output             wb_ack_o,
	input              wb_we_i,
	input       [31:0] wb_adr_i,
	input        [3:0] wb_sel_i,
	input       [31:0] wb_dat_i,
	output reg  [31:0] wb_dat_o,
	output		   intr,
	// Keyboard Wires
	output       [3:0] kb_column,
	input        [3:0] kb_row
);

//---------------------------------------------------------------------------
// Actual Matrix Keyboard
//---------------------------------------------------------------------------
wire presionar;
wire dato_valido;
wire  [3:0] dato;

	Keypad key0 (
		.clk			(clk),
		.filas			(kb_row),
		.dato_valido		(dato_valido),
		.dato			(dato),
		.presionar_db		(presionar),
		.columnas		(kb_column)
	);

//---------------------------------------------------------------------------
// 
//---------------------------------------------------------------------------
wire [7:0] key_cr = { 7'b0, dato_valido };

wire wb_rd = wb_stb_i & wb_cyc_i & ~wb_we_i;
wire wb_wr = wb_stb_i & wb_cyc_i &  wb_we_i & wb_sel_i[0];

reg  ack;

assign intr = dato_valido;

assign wb_ack_o = wb_stb_i & wb_cyc_i & ack;

always @(posedge clk)
begin
	if (reset) begin
		wb_dat_o[31:8] <= 24'b0;
		ack    <= 0;
	end else begin
		wb_dat_o[31:8] <= 24'b0;
		wb_dat_o[7:0] <= {4'h3, dato};
		ack    <= 0;
		if (wb_rd & ~ack) begin
			ack <= 1;

			case (wb_adr_i[3:2])
			2'b00: begin
				wb_dat_o[7:0] <= key_cr;
			end
			2'b01: begin
				wb_dat_o[7:0] <= {4'h3, dato};
			end
			default: begin
				wb_dat_o[7:0] <= 8'b0;
			end
			endcase
		end 
	end
end


endmodule
