//******************************************************************************//
////////////////  				Registro de Fila LCD           		////////////////
//******************************************************************************//

module Registro_LCD(
    // Entradas
	 input 				CLK,
    input 				Reset,
	 input 				LCD_RS,
    input 	 [159:0] DB,							// Registro de 160 bits por fila (20x8)
    input 				Write,						// Iniciar la Impresion en Pantalla
	 //input 				Cambio_Fila,
	 input				Lista,
	 // Salidas
    output 				Lista2,
	 output				Escribir,
	 output 		[7:0]	Dato_E_LCD
    );
	 
//**************************************************************************
//  Declaración de los Estados (Asignación Dato a Dato):
	
	 parameter	Encender		=	'd0,
					Espera_T		=	'd21,
					Terminar		=	'd22,
					En_Espera	=	'd23,
					Cambio_2b	=	'd24;
	
	 reg  	[7:0]	Reg_DB [0:19];
	 reg  	[5:0]	EstadoActual = 5'd0,
						EstadoSiguiente;
	 
	 always @ (EstadoActual, Write, Lista, /*Cambio_Fila, */LCD_RS) begin
		case (EstadoActual)
		
			Encender:	EstadoSiguiente	<=	En_Espera;
			
			En_Espera:	if(Write)
								EstadoSiguiente	<=	5'd1;
							else
								/*if(Cambio_Fila)
									EstadoSiguiente	<=	Cambio_2b;
								else*/
									EstadoSiguiente	<=	En_Espera;
			/*Cambio_2b:	if(Write)
								EstadoSiguiente	<=	5'd1;
							else
								EstadoSiguiente	<=	Cambio_2b;*/
			5'd1:			if (Lista) begin
								Reg_DB [0]			<= DB[159:152];
								Reg_DB [1]			<= DB[151:144];
								Reg_DB [2]			<= DB[143:136];
								Reg_DB [3]			<= DB[135:128];
								Reg_DB [4]			<= DB[127:120];
								Reg_DB [5]			<= DB[119:112];
								Reg_DB [6]			<= DB[111:104];
								Reg_DB [7]			<= DB[103:96];
								Reg_DB [8]			<= DB[95:88];
								Reg_DB [9]			<= DB[87:80];
								Reg_DB [10]			<= DB[79:72];
								Reg_DB [11]			<= DB[71:64];
								Reg_DB [12]			<= DB[63:56];
								Reg_DB [13]			<= DB[55:48];
								Reg_DB [14]			<= DB[47:40];
								Reg_DB [15]			<= DB[39:32];
								Reg_DB [16]			<= DB[31:24];
								Reg_DB [17]			<= DB[23:16];
								Reg_DB [18]			<= DB[15:8];
								Reg_DB [19]			<= DB[7:0];
								EstadoSiguiente	<=	5'd2;
							end
							else
								EstadoSiguiente	<=	5'd1;
			5'd2:			if (Lista)
								EstadoSiguiente	<=	5'd3;
							else
								EstadoSiguiente	<=	5'd2;	
			5'd3:			if (Lista)
								EstadoSiguiente	<=	5'd4;
							else
								EstadoSiguiente	<=	5'd3;
			5'd4:			if (Lista)
								EstadoSiguiente	<=	5'd5;
							else
								EstadoSiguiente	<=	5'd4;	
			5'd5:			if (Lista)
								EstadoSiguiente	<=	5'd6;
							else
								EstadoSiguiente	<=	5'd5;
			5'd6:			if (Lista)
								EstadoSiguiente	<=	5'd7;
							else
								EstadoSiguiente	<=	5'd6;	
			5'd7:			if (Lista)
								EstadoSiguiente	<=	5'd8;
							else
								EstadoSiguiente	<=	5'd7;	
			5'd8:			if (Lista)
								EstadoSiguiente	<=	5'd9;
							else
								EstadoSiguiente	<=	5'd8;
			5'd9:			if (Lista)
								EstadoSiguiente	<=	5'd10;
							else
								EstadoSiguiente	<=	5'd9;		
			5'd10:		if (Lista)
								EstadoSiguiente	<=	5'd11;
							else
								EstadoSiguiente	<=	5'd10;
			5'd11:		if (Lista)
								EstadoSiguiente	<=	5'd12;
							else
								EstadoSiguiente	<=	5'd11;
			5'd12:		if (Lista)
								EstadoSiguiente	<=	5'd13;
							else
								EstadoSiguiente	<=	5'd12;	
			5'd13:		if (Lista)
								EstadoSiguiente	<=	5'd14;
							else
								EstadoSiguiente	<=	5'd13;
			5'd14:		if (Lista)
								EstadoSiguiente	<=	5'd15;
							else
								EstadoSiguiente	<=	5'd14;
			5'd15:		if (Lista)
								EstadoSiguiente	<=	5'd16;
							else
								EstadoSiguiente	<=	5'd15;		
			5'd16:		if (Lista)
								EstadoSiguiente	<=	5'd17;
							else
								EstadoSiguiente	<=	5'd16;
			5'd17:		if (Lista)
								EstadoSiguiente	<=	5'd18;
							else
								EstadoSiguiente	<=	5'd17;
			5'd18:		if (Lista)
								EstadoSiguiente	<=	5'd19;
							else
								EstadoSiguiente	<=	5'd18;		
			5'd19:		if (Lista)
								EstadoSiguiente	<=	5'd20;
							else
								EstadoSiguiente	<=	5'd19;	
			5'd20:		if (Lista)
								EstadoSiguiente	<=	Espera_T;
							else
								EstadoSiguiente	<=	5'd20;	
			Espera_T:	if (~LCD_RS)
								EstadoSiguiente	<=	Terminar;
							else 
								EstadoSiguiente	<=	Espera_T;		        	 
			Terminar:	EstadoSiguiente	<=	En_Espera;
			
		endcase
	 end

	 always @ (negedge CLK or posedge Reset) begin
		if (Reset)
			EstadoActual <= Encender;
		else
			EstadoActual <= EstadoSiguiente;
	 end
	
	 assign	Dato_E_LCD	= ((EstadoActual >  5'd0)&
									(EstadoActual <  5'd21))	? Reg_DB [EstadoActual-1] : 8'd0;

	 assign 	Escribir		= ((EstadoActual >  5'd0)&
									(EstadoActual <  5'd21))	? 1'b1 : 1'b0;
									
	assign 	Lista2		=	(EstadoActual == Terminar)	?	1'b1 : 1'b0;
	 
endmodule 
