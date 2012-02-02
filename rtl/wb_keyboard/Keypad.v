//**************************************************************************
//  Módulo de Teclado Matricial
//  
//  Este módulo envía cada 5 ms una señal a través de una de las columnas del teclado
//  en cada momento para permitir detectar la tecla. En el momento que una tecla es presionada
//  el switch se cierra conectando la fila con la columna y enviando un 1 a través de esa fila
//  cada vez que se activa dicha columna.
//
//**************************************************************************

module Keypad #(
	 parameter				freq_hz = 50000000
   )(
	 // Entradas
	 input					clk,
	 input			[3:0] filas,
	 // Salidas
	 output reg				dato_valido,
	 output			[3:0] dato,
	 output					presionar_db,
	 output reg		[3:0] columnas
    );
// Parametro y Señales de Secuencia	 
//	 parameter 		DELAY = 250000;			//Retraso de 5 ms para la secuencia
 	 parameter		DELAY = 2500;
	 integer 		cont 	= 0;
	 
// Señales Internas
	 reg				presionar_temp;
	 reg		[3:0]	dato_temp = 4'h0;
	 
//**************************************************************************
//  Declaración de los Estados (Secuencia):

	 parameter	column0 = 4'b1000,		//Activar la columna 0
					column1 = 4'b0100,		//Activar la columna 1
					column2 = 4'b0010,		//Activar la columna 2
					column3 = 4'b0001;		//Activar la columna 3
    reg	[3:0] Estado = column0;			//Estado Actual

//**************************************************************************
//  					Máquina de Estado (Secuencia):

	 always @ (posedge clk) begin
		case (Estado)
			column0:	begin columnas <= column0;
						if (cont < DELAY) begin		//Comparación del contador con el retraso 
							Estado <= column0;			//Mantenerse durante 5 ms en la Columna X
							cont <= cont + 1;
						end else begin
							Estado <= column1;			//Pasar a la siguiente columna
							cont <= 0;						//Reiniciar el contador
						end end

			column1:	begin columnas <= column1;
						if (cont < DELAY) begin 
							Estado <= column1;
							cont <= cont + 1;
						end else begin
							Estado <= column2;
							cont <= 0;
						end end
		
			column2:	begin columnas <= column2;
						if (cont < DELAY) begin 
							Estado <= column2;
							cont <= cont + 1;
						end else begin
							Estado <= column3;
							cont <= 0;
						end end
			
			column3:	begin columnas <= column3;
						if (cont < DELAY) begin 
							Estado <= column3;
							cont <= cont + 1;
						end else begin
							Estado <= column0;
							cont <= 0;
						end end
		
			default: Estado <= column0;
			
		endcase
	 end
	 
//**************************************************************************
//  									Anti-rebote:
	 always @ (posedge clk)
		presionar_temp	<= |filas;
	 
	 Keypad_debounce Debounce (
		.CLK_DB 				(clk),
		.Presion_Boton		(presionar_temp),
		.PB_D					(presionar_db)
	 );
	 
//**************************************************************************
//  					Maquina de Estado (Tabla de Conversión)
//  Decodificador que asigna el dato dependiendo de la fila y columna que se
//  mantengan activas.

	 always @ (posedge presionar_temp) begin
		case({columnas, filas})				//Evalua la concatenación de columnas con filas y dependiendo de la tecla presionada asigna un valor.
			8'h11:	begin
						dato_temp <= 4'hD;
						end
						
			8'h12:	begin
						dato_temp <= 4'hC;
						end
						
			8'h14:	begin
						dato_temp <= 4'hB;
						end
						
			8'h18:	begin
						dato_temp <= 4'hA;
						end

			8'h21:	begin
						dato_temp <= 4'hF;
						end

			8'h22:	begin
						dato_temp <= 4'h9;
						end

			8'h24:	begin
						dato_temp <= 4'h6;
						end

			8'h28:	begin
						dato_temp <= 4'h3;
						end

			8'h41:	begin
						dato_temp <= 4'h0;
						end

			8'h42:	begin
						dato_temp <= 4'h8;
						end

			8'h44:	begin
						dato_temp <= 4'h5;
						end

			8'h48:	begin
						dato_temp <= 4'h2;
						end

			8'h81:	begin
						dato_temp <= 4'hE;
						end

			8'h82:	begin
						dato_temp <= 4'h7;
						end

			8'h84:	begin
						dato_temp <= 4'h4;
						end

			8'h88:	begin
						dato_temp <= 4'h1;
						end

			default:	begin
						dato_temp <= dato_temp;
						end

		endcase
	 end
	 
	 assign	dato = dato_temp;
	 
	 reg [7:0]	cont_intr = 0;
	
	always @ (posedge clk or posedge presionar_db) begin
		if (presionar_db) begin
			cont_intr	<=	cont_intr + 1;
			dato_valido 	<= 1'b1;
			if(cont_intr <  250)
				dato_valido 	<= 1'b1;
			else begin
				cont_intr		<= 251;
				dato_valido 	<= 1'b0;
			end
		end else begin
			cont_intr		<= 0;
			dato_valido 	<= 1'b0;
		end
	 end


endmodule
