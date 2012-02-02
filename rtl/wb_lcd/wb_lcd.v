//---------------------------------------------------------------------------
// Wishbone LCD 
//
// Register Description:
//
//    0xF0010000 LCD_CR      [ 0 | 0 | 0 | lcd_busy | 0 | 0 | 0 | lcd_ready ]
//    0xF0010004 DATA0
//    0xF0010008 DATA1
//    0xF001000C DATA2
//    0xF0010010 DATA3
//    0xF0010014 DATA4
//    0xF0010018 LCD_INS     [ 0 | 0 | 0 | lcd_chrow | 0 | 0 | lcd_clear | lcd_write ]
//
//---------------------------------------------------------------------------

module wb_lcd #(
	parameter          clk_freq = 50000000,
	parameter          baud     = 115200
) (
	input              clk,
	input              reset,
	// Wishbone interface
	input              wb_stb_i,
	input              wb_cyc_i,
	output             wb_ack_o,
	input              wb_we_i,
	input       [31:0] wb_adr_i,
	input        [3:0] wb_sel_i,
	input       [31:0] wb_dat_i,
	output reg  [31:0] wb_dat_o,
	// LCD Wires
	output             lcd_rs,
	output             lcd_e,
	output       [7:0] lcd_data
);

//---------------------------------------------------------------------------
// Actual LCD
//---------------------------------------------------------------------------
wire		Limpiar;
wire		Escribir;
wire		Cambiar_Fila;
reg 	[159:0] Registro_LCD;
wire		Hecho_LCD;

Main_LCD lcd0 (
	.CLK			(clk),
	.Reset			(reset),
	.Limpiar		(Limpiar),
	.Escribir		(Escribir),
	.Cambio_Fila		(Cambiar_Fila),
	.Dato_LCD		(Registro_LCD),
	.Done		(Hecho_LCD),
	.LCD_RS			(lcd_rs),
	.LCD_E			(lcd_e),
	.LCD_DB			(lcd_data)
);

//---------------------------------------------------------------------------
// 
//---------------------------------------------------------------------------
wire [7:0] lcd_cr = { 6'b0, ~Hecho_LCD, Hecho_LCD };
reg  [7:0] lcd_ins = 8'h00;

assign Escribir = 	lcd_ins[0];
assign Cambiar_Fila = 	lcd_ins[4];
assign Limpiar 	=	lcd_ins[1];

wire wb_rd = wb_stb_i & wb_cyc_i & ~wb_we_i;
wire wb_wr = wb_stb_i & wb_cyc_i &  wb_we_i & wb_sel_i[0];

reg  ack;
reg [31:0] dato0 = 32'h20202020;
reg [31:0] dato1 = 32'h20202020;
reg [31:0] dato2 = 32'h20202020;
reg [31:0] dato3 = 32'h20202020;
reg [31:0] dato4 = 32'h20202020;

assign wb_ack_o       = wb_stb_i & wb_cyc_i & ack;

always @(posedge clk)
begin
	if (reset) begin
		wb_dat_o[31:0] <= 32'b0;
		ack    <= 0;
		lcd_ins <= 8'h00;
	end else begin
		wb_dat_o[31:0] <= 32'b0;
		ack    <= 0;
		lcd_ins <= 8'h00;
		if (wb_rd & ~ack) begin
			ack <= 1;

			case (wb_adr_i[5:2])
			4'b0000: begin
				  wb_dat_o[7:0] <= lcd_cr;
			end
			default: begin
				  wb_dat_o[7:0] <= 8'b0;
			end
			endcase
		end else if (wb_wr & ~ack ) begin
			ack <= 1;

			case (wb_adr_i[5:2])
			4'h1: begin
				dato0 <= wb_dat_i;
			end
			4'h2: begin
				dato1 <= wb_dat_i;
			end
			4'h3: begin
				dato2 <= wb_dat_i;
			end
			4'h4: begin
				dato3 <= wb_dat_i;
			end
			4'h5: begin
				dato4 <= wb_dat_i;
			end
			4'h6: begin
				lcd_ins <= wb_dat_i[7:0];
			end
			default: begin
				dato0 <= 32'h20202020;
				dato1 <= 32'h20202020;
				dato2 <= 32'h20202020;
				dato3 <= 32'h20202020;
				dato4 <= 32'h20202020;
				lcd_ins	<= 8'h00;
			end
			endcase
			Registro_LCD <= {dato0, dato1, dato2, dato3, dato4};
		end
	end
end


endmodule
