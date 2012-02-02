//**************************************************************************//  	
////////////////  Escribir y Cambiar Fila de la LCD           ////////////////	
//**************************************************************************//
module LCD(
    // Entradas
	 input 				CLK,
    input 				Reset,
    input 		[7:0] DB,
    input 				Write,
    input 				Linea2,
    input 				Limpiar,
	 // Bidirs
	 inout 				Lista,
	 // Salidas LCD
    output 				LCD_RS,
    output 				LCD_E,
    output 		[7:0]	LCD_DB
    );
	 
// Parametro de Division de Frecuencia	 
	 parameter 	N 	= 30000;									// 0.6 ms
//	 parameter 	N 	= 250;
	 
//**************************************************************************
//  Declaración de los Estados (Escribir y Cambiar Filas):

	 parameter 	Iniciar 			= 3'd0,
					EnEspera 		= 3'd1,
					EscribirDato 	= 3'd2,
					Escribir_Hecho = 3'd3,
					EscribirF2 		= 3'd4,
					EscribirF3 		= 3'd5,
					EscribirF4 		= 3'd6,
					Escribir01 		= 3'd7;
					
	 reg 	[2:0] EstadoActual,
					EstadoFuturo;
					
// Señales Internas
	 reg 		[7:0] DB_Reg;
	 reg 		[1:0] ContadorFila;
	 wire 	[7:0] Dato;
	 wire   [15:0] Contador;
	 wire 			Inicio_Hecho;
	 
	 initial
		ContadorFila <= 2'b00;
	 
// Encender y Configurar LCD 
	 Encender Encendido_LCD	(
		.CLK						(CLK),
		.Reset					(Reset),
		.Habilitar_Contador	(Lista), 
		.Dato						(Dato), 
		.Cuenta					(Contador), 
		.Hecho					(Inicio_Hecho)
		);
		
	 always @ (EstadoActual, Contador, ContadorFila, Write, Inicio_Hecho) begin
		case (EstadoActual)
			Iniciar:				if (Inicio_Hecho) 
										if (Linea2) begin
											if (ContadorFila == 2'b01)
												EstadoFuturo <= EscribirF2;
											if (ContadorFila == 2'b10)
												EstadoFuturo <= EscribirF3;
											if (ContadorFila == 2'b11)
												EstadoFuturo <= EscribirF4;
											if (ContadorFila == 2'b00)
												EstadoFuturo <= EscribirDato;
										end
										else 
											EstadoFuturo <= EnEspera;
									else 
										EstadoFuturo <= Iniciar;
			EnEspera:			if (Limpiar) 
										EstadoFuturo <= Escribir01;
									else 
										if (Linea2) begin
											if (ContadorFila == 2'b01)
												EstadoFuturo <= EscribirF2;
											if (ContadorFila == 2'b10)
												EstadoFuturo <= EscribirF3;
											if (ContadorFila == 2'b11)
												EstadoFuturo <= EscribirF4;
											if (ContadorFila == 2'b00)
												EstadoFuturo <= EscribirDato;
										end
										else
											if (Write) 
												EstadoFuturo <= EscribirDato;
											else 
												EstadoFuturo <= EnEspera;
			EscribirDato:		if (Contador >= N)
										EstadoFuturo <= Escribir_Hecho;
									else
										EstadoFuturo <= EscribirDato;								 
			EscribirF2:			if (Contador >= N) 
										EstadoFuturo <= Escribir_Hecho;
									else
										EstadoFuturo <= EscribirF2;
			EscribirF3:			if (Contador >= N) 
										EstadoFuturo <= Escribir_Hecho;
									else
										EstadoFuturo <= EscribirF3;
			EscribirF4:			if (Contador >= N) 
										EstadoFuturo <= Escribir_Hecho;
									else 
										EstadoFuturo <= EscribirF4;
			Escribir01:			if (Contador >= N) 
										EstadoFuturo <= Escribir_Hecho;
									else
										EstadoFuturo <= Escribir01;
			Escribir_Hecho:	EstadoFuturo <= EnEspera;
		endcase
	 end

	 always @ (negedge CLK or posedge Reset) begin
		if (Reset) begin
			EstadoActual 	<= Iniciar;
			DB_Reg 			<= 0; 
		end
		else begin 
			EstadoActual 	<= EstadoFuturo;
			if (Write & Lista) DB_Reg <= DB;
		end
		end

	 always @ (posedge Linea2 or posedge Reset) begin
		if (Reset)
			ContadorFila 	<= 2'b00;
		else
			ContadorFila	<=	ContadorFila + 1;
	 end

	 assign 	Lista 	= 	(EstadoActual == EnEspera) ? 1'b1 : 1'b0;

	 assign 	LCD_DB 	= 	(EstadoActual == EscribirF2) 	? 'hC0 :
								(EstadoActual == EscribirF3) 	? 'h94 : 
								(EstadoActual == EscribirF4) 	? 'hD4 : 						
								(EstadoActual == Escribir01) 	? 'h01 : 
								(Inicio_Hecho) 					? DB_Reg : Dato;						

	 assign 	LCD_RS 	= 	(EstadoActual == EscribirDato)	? 1'b1 : 1'b0;

	 assign 	LCD_E 	= 	(Contador == 5) 					? 1'b1 : 1'b0;
endmodule
