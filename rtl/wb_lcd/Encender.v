//**************************************************************************//  	
////////////////  Encendido y configuracion pantalla LCD      ////////////////	
//**************************************************************************//
module Encender(
    // Entradas
	 input 				CLK,
    input 				Reset,
    input 				Habilitar_Contador,				// Inicia el Reloj de 1.67 KHz
	 // Salidas
    output 		[7:0] Dato,									// Envia los Comandos de Inicialización
    output 	  [15:0] Cuenta,
	 // Bidirs
    inout 				Hecho									// Avisa que el Proceso se ha Realizado
    );

// Parametro de Division de Frecuencia	 
	 parameter 	N 	= 30000;									// 0.6 ms
//	 parameter 	N 	= 250;

//**************************************************************************
//  Declaración de los Estados (Configuración Controlador LCD):
	 
	 parameter 	Encender 				= 4'd0,
					Funcion_Set_1 			= 4'd1,
					Funcion_Set_2 			= 4'd2,
					Funcion_Set_3 			= 4'd3,
					Funcion_Set_4 			= 4'd4,
					Display_On 				= 4'd5,
					Display_Clean 			= 4'd6,
					Entrar_M_Set 			= 4'd7,
					Fin_Iniciacion 		= 4'd8,
					INICIO_HECHO 			= 4'd9;
	 
	 reg 	[3:0] EstadoActual,
					EstadoSiguiente;

// Señales internas
	 reg [15:0]	Contador;
	 wire 		Temp;

// Inicio y Configuracion de la Pantalla LCD (Duracion aprox. 6 ms)
	 always @ (EstadoActual or Contador) begin
		case (EstadoActual)
			Encender:			if (Contador >= N)
										EstadoSiguiente 	<= Funcion_Set_1;
									else EstadoSiguiente <= Encender;
			Funcion_Set_1:		if (Contador >= N) 
										EstadoSiguiente 	<= Funcion_Set_2;
									else EstadoSiguiente <= Funcion_Set_1;
			Funcion_Set_2:		if (Contador >= N) 
										EstadoSiguiente 	<= Funcion_Set_3;
									else EstadoSiguiente <= Funcion_Set_2;
			Funcion_Set_3:		if (Contador >= N)
										EstadoSiguiente 	<= Funcion_Set_4;
									else EstadoSiguiente <= Funcion_Set_3;
			Funcion_Set_4:		if (Contador >= N)
										EstadoSiguiente 	<= Display_On ;
									else EstadoSiguiente <= Funcion_Set_4;
			Display_On :		if (Contador >= N)
										EstadoSiguiente 	<= Display_Clean;
									else EstadoSiguiente <= Display_On;
			Display_Clean:		if (Contador >= N) 
										EstadoSiguiente 	<= Entrar_M_Set;		
									else EstadoSiguiente <= Display_Clean;
			Entrar_M_Set:		if (Contador >= N) 
										EstadoSiguiente 	<= Fin_Iniciacion;
									else EstadoSiguiente <= Entrar_M_Set;
			Fin_Iniciacion:	if (Contador >= N) 
										EstadoSiguiente 	<= INICIO_HECHO;
									else EstadoSiguiente <= Fin_Iniciacion;
			INICIO_HECHO:		EstadoSiguiente 		<= INICIO_HECHO;
		endcase
	 end

// Cambio de Estado
	 always @ (posedge Reset or posedge CLK) begin
		if (Reset)
			EstadoActual 	<= Encender;
		else EstadoActual <= EstadoSiguiente;
	 end

// Asigna los Comandos de Salida del Modulo
	 assign 	Dato 	=	(EstadoActual == Funcion_Set_1) 	? 'h38:
							(EstadoActual == Funcion_Set_2) 	? 'h38: 
							(EstadoActual == Funcion_Set_3) 	? 'h38: 
							(EstadoActual == Funcion_Set_4) 	? 'h38:
							(EstadoActual == Display_On )   	? 'h06: 
							(EstadoActual == Display_Clean) 	? 'h0C: 
							(EstadoActual == Entrar_M_Set)  	? 'h01: 
							(EstadoActual == Fin_Iniciacion)	? 'h80: 'h00;
							
// Avisa que el encendido a terminado
	 assign 	Hecho	=	(EstadoActual == INICIO_HECHO) 	? 1'b1 : 1'b0;
	 
// Indica en que Parte se Encuentra el Contador
	 assign 	Cuenta	=	Contador; 

// El Contador se Reinicia con el Reset o Cuando se Habilita el Contador
	 assign 	Temp 	= 	Reset | Habilitar_Contador;
	 
	 always @ (posedge Temp or posedge CLK) begin
		if (Temp) 
			Contador <= 0;
		else 	
			if (Contador == N) 
				Contador <= 0;
			else 
				Contador <= Contador + 1;
	 end

endmodule
