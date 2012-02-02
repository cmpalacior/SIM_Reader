//**************************************************************************
//  				Módulo de Anti-rebote para Teclado Matricial
//  
//
//**************************************************************************
module Keypad_debounce #(
	 parameter		freq_hz = 50000000
   )(
	 // Entradas
	 input 			CLK_DB,
    input 			Presion_Boton,
	 // Salida
    output reg		PB_D
	 );
// Parametro y Señales de Division de Frecuencia
//	 parameter		N = 250000;											// N = freq_hz*0.005
	 parameter		N = 2500;
	 integer			contador_div = 0;
	 reg				CLK_5ms;

// Señales Anti-rebote
	 reg		[3:0]	SHIFT_PB;
	 
// Divisor de Frecuencia a 200 Hz
	 always @ (posedge CLK_DB) begin
		if (contador_div < N/2) begin
			contador_div	<=	contador_div + 1;
			CLK_5ms 			<= 1'b1;
		end
		else
			if (contador_div < N) begin
				contador_div 	<= contador_div + 1;
				CLK_5ms <= 0;
			end
		if (contador_div == N)
			contador_div 		<= 1'b0;
	 end
	 
// Anti-Rebote	 
	 always @ (posedge CLK_5ms) begin
		SHIFT_PB [2:0]	<= SHIFT_PB [3:1];
		SHIFT_PB [3]	<=	Presion_Boton;
		if (SHIFT_PB [3:0] != 4'h0)
			PB_D			<= 1'b1;
		else
			PB_D			<= 1'b0;
	 end

endmodule
