// arquivo contendo a descricao sitetizavel

`timescale 1ns / 1ps

module sigmoid_taylor (
	input 	logic [11:0] x,		// 12 bits
	input 	logic clk,
	output 	logic [11:0] f_x
);
	
	// sinais auxiliares
	logic [11:0] q, S, result_mult;
	logic [15:0] W, V, lambda, n_temp;
	logic [10:0] phi_xi, xi, p; // tamanhos originais
	//logic [11:0] phi_xi, xi, p; // tam. meus testes
	logic [7:0] phi;
	logic [3:0] n;	// igual a ni
	
	// caracteristica "por partes" da equacao
	always @ (posedge clk) begin
		if (x[11] == 0) begin
			f_x <= q;
		end else begin
			f_x <= S;
		end
	end
	
	// Com Unit (complement Unit)
	always @ (*) begin
		q <= ~S + 1;
	end

	// Gerar o valor de S
	always @ (*) begin
		S <= W + V + lambda;
	end

	// Gerar o valor de lambda, modulo SGU (Special number Generated Unit)
	always @ (*) begin
		lambda[15] 	<= 1;
		lambda[14] 	<= n[3]|n[2]|n[1];
		lambda[13] 	<= n[3]|n[2]|n[0];
		lambda[12] 	<= n[3]|n[2];
		lambda[11] 	<= n[3]|(n[1]&(~n[0]))|((~n[1])&n[0])|(n[2]&n[1]&n[0]);
		lambda[10] 	<= n[3]|(n[2]&n[1])|(n[1]&(~n[0]));
		lambda[9] 	<= n[3]|(n[1]&n[0])|((~n[2])&n[0]);
		lambda[8] 	<= n[3]|((~n[2])&n[1]&n[0]);
		lambda[7] 	<= ((~n[2])&(n[1]|n[0]))|(n[2]&(~n[1])&(~n[0]));
		lambda[6] 	<= (n[3]&n[1])|((~n[2])&n[1]&(~n[0]))|(n[2]&(~n[1])&(~n[0]));
		lambda[5] 	<= (n[3]&n[1]&n[0])|(n[2]&(~n[1]))|((~n[3])&(~n[1])&n[0]);
		lambda[4] 	<= n[2]&(~n[1]);
		lambda[3] 	<= ((~n[3])&(~n[1])&n[0])|((~n[3])&n[1]&(~n[0]))|((~n[3])&(~n[2])&n[1]);
		lambda[2] 	<= (n[2]&(~n[1])&n[0])|((~n[3])&n[1]&(~n[0]))|((~n[3])&(~n[2])&n[1]);
		lambda[1] 	<= ((~n[3])&n[0])|((~n[3])&n[2]&n[1]);
		lambda[0] 	<= n[2]&n[1];
	end

	// Gerar o valor de W e V
	always @ (*) begin

		// Artigo fala lambda mas desconfio que esta errado e que seja n.
		//No modulo, M-SU tem n como entrada, nao lambda
		//if (lambda == 0) begin	// DISCUTIR
		if (n == 0) begin
			W <= phi>>2;
			V <= phi;		// revisando, esses eram os com shift por 0
		end else if (n == 1) begin
			W <= phi>>3;
			V <= phi>>7;
		end else if (n == 2) begin
			W <= phi>>4;
			V <= phi>>5;
		end else if (n == 3) begin
			W <= phi>>5;
			V <= phi>>6;
		end else if (n == 4) begin
			W <= phi>>5;
			V <= phi;		 // revisando
		end else if (n == 5) begin
			W <= phi>>6;
			V <= phi;		// revisando
		end else if (n == 6) begin
			W <= phi>>7;
			V <= phi;		// revisando
		end else if (n == 7) begin
			W <= phi>>8;
			V <= phi;		// revisando
		end else if (n == 8) begin
			W <= phi>>9;
			V <= phi;		// revisando
		end else if (n == 9) begin
			W <= phi>>10;
			V <= phi;		// revisando
		end else if (n == 10) begin
			W <= phi>>11;
			V <= phi;		// revisando
		end else if (n == 11) begin
			W <= phi>>12;
			V <= phi;		// revisando
		end
	end

	// Gerar valor de phi/xi
	always @ (*) begin
		if (n == 0) begin
			phi_xi <= phi;
		end else begin
			phi_xi <= xi;
		end
	end

	// Gerar valor de phi e ni resultado de uma multiplicacao
	always @ (*) begin
		result_mult <= xi * 4'b1_011;
		// n eh a parte inteira de x / ln(2)
		// 1/ln(2) ~= 1.46
		//phi eh a parte decimal de x / ln(2)
		phi <= result_mult[7:0];
		n <= result_mult[11:8];
	end

	// Gerar valor de xi, já contendo o sinal p
	always @ (*) begin
		if (x[11] == 1) begin
			xi <= ~x[10:0] + 1;
		end else begin
			xi <= x[10:0];
		end
	end

endmodule