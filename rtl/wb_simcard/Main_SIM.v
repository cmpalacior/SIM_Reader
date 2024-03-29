`timescale 1ns / 1ps

module Main_SIM (
	 // Entradas
	 input				CLK,
	 input 				Reset,
	 input				Habilitar,
	 // Salidas (SIM)
	 output				SIM_VPP,
	 output				SIM_VCC,
	 output				SIM_CLK,
	 output				SIM_RST,
	 // Bidirs (SIM)
	 inout				SIM_IO,
	 //
	 output 	 [159:0]	Dato_LCD,
	 input		[1:0]	DatoW,
	 output				Hecho
    );
	 
	 wire			[7:0] Dato_SIM;
	 wire					Dato_Valido;
	 
	 simcard SIM (
		.RST			(Reset),
		.CLK_FPGA	(CLK),
		.SIM_VPP		(SIM_VPP),
		.SIM_VCC		(SIM_VCC),
		.SIM_CLK		(SIM_CLK),
		.SIM_RST		(SIM_RST),
		.SIM_IO		(SIM_IO),
		.Dato_Valido(Dato_Valido),
		.Hecho		(Hecho),
		.Habilitar	(Habilitar),
		.Salida		(Dato_SIM)
		);
		
//**************************************************************************
//  Salida de Prueba
//**************************************************************************	 
	 reg	[7:0]	ram_atr [0:63];
	 reg	[5:0]	cont_ram = 0;
	 
	 always @ (posedge Dato_Valido) begin
		ram_atr [cont_ram]	<=	Dato_SIM;
		cont_ram <= cont_ram + 1;
	 end
	 
	 wire	  [39:0]	Num_Temp;
	 wire		[7:0]	Num [0:9];
	 
	 assign		Num_Temp	=	{ram_atr[17], ram_atr[18], ram_atr[19], ram_atr[20], ram_atr[21]};
	 assign		Num [0]	=	{4'h3, Num_Temp [35:32]};
	 assign		Num [1]	=	{4'h3, Num_Temp [39:36]};
	 assign		Num [2]	=	{4'h3, Num_Temp [27:24]};
	 assign		Num [3]	=	{4'h3, Num_Temp [31:28]};
	 assign		Num [4]	=	{4'h3, Num_Temp [19:16]};
	 assign		Num [5]	=	{4'h3, Num_Temp [23:20]};
	 assign		Num [6]	=	{4'h3, Num_Temp [11:8]};
	 assign		Num [7]	=	{4'h3, Num_Temp [15:12]};
	 assign		Num [8]	=	{4'h3, Num_Temp [3:0]};
	 assign		Num [9]	=	{4'h3, Num_Temp [7:4]};
	 
	 wire	  [39:0]	Num_Temp2;
	 wire		[7:0]	Num2 [0:9];
	 
	 assign		Num_Temp2	=	{ram_atr[47], ram_atr[48], ram_atr[49], ram_atr[50], ram_atr[51]};
	 assign		Num2 [0]	=	{4'h3, Num_Temp2 [35:32]};
	 assign		Num2 [1]	=	{4'h3, Num_Temp2 [39:36]};
	 assign		Num2 [2]	=	{4'h3, Num_Temp2 [27:24]};
	 assign		Num2 [3]	=	{4'h3, Num_Temp2 [31:28]};
	 assign		Num2 [4]	=	{4'h3, Num_Temp2 [19:16]};
	 assign		Num2 [5]	=	{4'h3, Num_Temp2 [23:20]};
	 assign		Num2 [6]	=	{4'h3, Num_Temp2 [11:8]};
	 assign		Num2 [7]	=	{4'h3, Num_Temp2 [15:12]};
	 assign		Num2 [8]	=	{4'h3, Num_Temp2 [3:0]};
	 assign		Num2 [9]	=	{4'h3, Num_Temp2 [7:4]};
	 
	 assign		Dato_LCD	=	(DatoW == 0)	?	{64'h4E6F6D6272653A20, ram_atr[1], ram_atr[2], ram_atr[3],ram_atr[4], ram_atr[5], ram_atr[6], ram_atr[7], ram_atr[8], ram_atr[9], ram_atr[10], ram_atr[11], ram_atr[12]}				:
									(DatoW == 1)	?	{24'h233A20, Num[0], Num[1], Num[2], Num[3], Num[4], Num[5], Num[6], Num[7], Num[8], Num[9], {7{8'h20}}}																										:
									(DatoW == 2)	?	{64'h4E6F6D6272653A20, ram_atr[31], ram_atr[32], ram_atr[33],ram_atr[34], ram_atr[35], ram_atr[36], ram_atr[37], ram_atr[38], ram_atr[39], ram_atr[40], ram_atr[41], ram_atr[42]}	:
									(DatoW == 3)	?	{24'h233A20, Num2[0], Num2[1], Num2[2], Num2[3], Num2[4], Num2[5], Num2[6], Num2[7], Num2[8], Num2[9], {7{8'h20}}}																						:	0;
	 
endmodule
