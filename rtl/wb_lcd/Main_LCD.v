
module Main_LCD(
	 // Entradas
	 input 				CLK,
    input 				Reset,
	 input 				Limpiar,
    input 				Escribir,
	 input				Cambio_Fila,
	 input	 [159:0]	Dato_LCD,
	 // Salidas
    output				Done,
	 output 				LCD_RS,
    output 				LCD_E,
    output 		[7:0]	LCD_DB
    );
	 
	 parameter		Inicio			=	'd0,
						Esperar			=	'd1,
						Escribir_LCD	=	'd2,
						Cambiar_Fila	=	'd3,
						Terminar			=	'd4;
						
	 reg		[3:0]	EstadoActual = 0,
						EstadoFuturo;
							
	 wire				Lista;
	 wire		[7:0]	Dato_E_LCD;
	 wire				Write,
						EscribirLCD,
						ListaLCD,
						Lista_Temp,
						Next_Row;
	 
	 Registro_LCD LCD_Ram(
		.CLK					(CLK),
		.Reset				(Reset),
		.DB					(Dato_LCD),
		.Write				(Write),
		.Lista				(ListaLCD),
		.Lista2				(Lista),
		.Escribir			(EscribirLCD),
		.LCD_RS				(LCD_RS),
		.Dato_E_LCD			(Dato_E_LCD)
	 );
	 
	 LCD Write_LCD(
		.CLK 			(CLK),
		.Reset 		(Reset),
		.DB			(Dato_E_LCD),
		.Write 		(EscribirLCD),
		.Linea2 		(Next_Row),
		.Limpiar 	(Limpiar),
		.Lista 		(ListaLCD),
		.LCD_RS 		(LCD_RS),
		.LCD_E 		(LCD_E),
		.LCD_DB 		(LCD_DB)
		);
	 
	 always @ (EstadoActual, Escribir, Lista, LCD_E, Cambio_Fila) begin
		case(EstadoActual)
		Inicio:					EstadoFuturo	<=	Esperar;
		Esperar:				if(Cambio_Fila)
									EstadoFuturo	<=	Cambiar_Fila;
								else
									if(Escribir)
										EstadoFuturo	<=	Escribir_LCD;
									else
										EstadoFuturo	<=	Esperar;
		Escribir_LCD:		if(Lista)
									EstadoFuturo	<=	Terminar;
								else
									EstadoFuturo	<=	Escribir_LCD;
		Cambiar_Fila:		if(~LCD_E)
									EstadoFuturo	<=	Terminar;
								else
									EstadoFuturo	<=	Cambiar_Fila;
		Terminar:			if(Escribir | Cambio_Fila)
									EstadoFuturo	<=	Terminar;
								else
									EstadoFuturo	<=	Esperar;
		endcase
	 end
	 
	 always @ (negedge CLK or posedge Reset)
		if (Reset)
			EstadoActual <= Inicio;
		else
			EstadoActual <= EstadoFuturo;
	 
	 assign	Write	=		(EstadoActual == Escribir_LCD)	?	1'b1 : 1'b0;
	 assign	Next_Row	=	(EstadoActual == Cambiar_Fila)	?	1'b1 : 1'b0;
	 assign	Lista_Temp	=	(EstadoActual == Esperar)	?	1'b1 : 1'b0;
	 assign	Done		=	ListaLCD & Lista_Temp;

endmodule
