//---------------------------------------------------------------------------
// Wishbone SIM Card 
//
// Register Description:
//
//    0xF0030000 SC_CR      [ 0 | 0 | 0 | 0 | 0 | 0 | sc_busy | sc_done ]
//    0xF0030004 DATA0
//    0xF0030008 DATA1
//    0xF003000C DATA2
//    0xF0030010 DATA3
//    0xF0030014 DATA4
//    0xF0030018 SC_REG     [ 0 | 0 | 0 | sc_en | 0 | 0 | sc_dw[1] | sc_dw[0] ]
//    
//---------------------------------------------------------------------------

module wb_simcard #(
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
	// Sim Card Pins
	output             sc_vcc,
	output             sc_vpp,
	output             sc_rst,
	output             sc_clk,
	output		   sc_done,
	inout              sc_io
);

//---------------------------------------------------------------------------
// Actual SIM Card
//---------------------------------------------------------------------------
wire sc_en;
//wire sc_done;
wire [1:0] sc_dw;
wire [159:0] sc_data;

Main_SIM sim0 (
	.CLK(       clk      ),
	.Reset(     reset    ),
	//
	.Habilitar(  sc_en ),
	.SIM_VPP(  sc_vpp ),
	.SIM_VCC(  sc_vcc ),
	.SIM_RST(  sc_rst ),
	.SIM_CLK(  sc_clk ),
	.SIM_IO(   sc_io  ),
	.Dato_LCD(  sc_data ),
	.DatoW(     sc_dw ),
	.Hecho(  sc_done )
	//
);

//---------------------------------------------------------------------------
// 
//---------------------------------------------------------------------------
wire [7:0] sc_cr = { 6'b0, ~sc_done, sc_done };
reg  [7:0] sc_reg = 8'b0;

wire wb_rd = wb_stb_i & wb_cyc_i & ~wb_we_i;
wire wb_wr = wb_stb_i & wb_cyc_i &  wb_we_i & wb_sel_i[0];

reg  ack;

assign sc_en = sc_reg[4];
assign sc_dw = sc_reg[1:0];

assign wb_ack_o       = wb_stb_i & wb_cyc_i & ack;

always @(posedge clk)
begin
	if (reset) begin
		wb_dat_o[31:0] <= 32'b0;
		sc_reg		<= 8'b0;
		ack    <= 0;
	end else begin
		wb_dat_o[31:0] <= 32'b0;
		ack    <= 0;
		if (wb_rd & ~ack) begin
			ack <= 1;

			case (wb_adr_i[4:2])
			3'b000: begin
				wb_dat_o[7:0] <= sc_cr;
			end
			3'b001: begin
				wb_dat_o[31:0] <= sc_data[159:128];
			end
			3'b010: begin
				wb_dat_o[31:0] <= sc_data[127:96];
			end
			3'b011: begin
				wb_dat_o[31:0] <= sc_data[95:64];
			end
			3'b100: begin
				wb_dat_o[31:0] <= sc_data[63:32];
			end
			3'b101: begin
				wb_dat_o[31:0] <= sc_data[31:0];
			end
			default: begin
				wb_dat_o[31:0] <= 32'b0;
			end
			endcase
		end else if (wb_wr & ~ack ) begin
			ack <= 1;

			case (wb_adr_i[4:2])
			3'b110: begin
				sc_reg <= wb_dat_i[7:0];
			end
			default: begin
				sc_reg <= 8'b0;
			end
			endcase
			end
	end
end


endmodule
