// arquivo contendo a descricao sitetizavel

`timescale 1ns / 1ps

// Interface do chip
module sigmoid_taylor (
	input 	logic [11:0] x,
	input 	logic clk,
	output 	logic [12:0] f_x
);
	
	// sinais auxiliares
	logic [3:0] n;	// igual a ni
	logic [7:0] phi;
	logic [10:0] phi_xi, xi, B, D, tmp_mult;
	logic [11:0] q, result_mult;
	logic [15:0] W, V, lambda, S, tmp_comp, tmp_shift;
	
	// caracteristica "por partes" da equacao
	always @ (posedge clk) begin
		if (x[11] == 0) begin
			f_x <= {1'b0, S[15:4]};
		end else begin
			f_x <= {1'b0, q};
		end
	end
	
	// Com Unit (complement Unit)
	always @ (*) begin
		// Atribuir parte mais significativa de S ao q.
		tmp_comp = ~S + 1;
		q <= tmp_comp[15:4];
	end

	// Gerar o valor de S
	always @ (*) begin
		S <= W + V + lambda;
	end

	// Gerar o valor de lambda, modulo SGU (Special number Generated Unit)
	// Essa parte esta funcional
	always @ (*) begin
		lambda[15]=1;
		lambda[14]=n[3] | n[2] | n[1];
		lambda[13]=n[3] | n[2] | n[0];
		lambda[12]=n[3] | n[2];
		lambda[11]=n[3] | (n[1] & (~n[0])) | ((~n[1]) & n[0]) | (n[2] & n[1] & n[0]);
		lambda[10]=n[3] | (n[2] & n[1]) | (n[1] & (~n[0]));
		lambda[9] =n[3] | (n[1] & n[0]) | ((~n[2]) & n[0]);
		lambda[8] =n[3] | ((~n[2]) & n[1] & n[0]);
		lambda[7] =((~n[2]) & (n[1] | n[0])) | (n[2] & (~n[1]) & (~n[0]));
		lambda[6] =(n[3] & n[1]) | ((~n[2]) & n[1] & (~n[0])) | (n[2] & (~n[1]) & (~n[0]));
		lambda[5] =(n[3] & n[1] & n[0]) | (n[2] & (~n[1])) | ((~n[3]) & (~n[1]) & n[0]);
		lambda[4] =n[2] & (~n[1]);
		lambda[3] =((~n[3]) & (~n[1]) & n[0]) | ((~n[3]) & n[1] & (~n[0])) | ((~n[3]) & (~n[2]) & n[1]);
		lambda[2] =(n[2] & (~n[1]) & n[0]) | ((~n[3]) & n[1] & (~n[0])) | ((~n[3]) & (~n[2]) & n[1]);
		lambda[1] =((~n[3]) & n[0]) | ((~n[3]) & n[2] & n[1]);
		lambda[0] =n[2] & n[1];
	end

	// Gerar o valor de W e V (M-SU)
	always @ (*) begin
		tmp_shift[15:5] <= phi_xi;
		tmp_shift[4:0] <= 0;
		// V e W tem 16 bits
		if (n == 0) begin
			//  Testar: colocar valor de phi_xi na parte mais significativa de W e V
			//Primeiro atribuir a w na parte mais significativa e depois faz o shift
			W <= tmp_shift >> 2;	// m1
			//V <= phi_xi;		// m2
			V <= 0;
		end else if (n == 1) begin
			W <= tmp_shift >> 3;
			V <= tmp_shift >> 7;
		end else if (n == 2) begin
			W <= tmp_shift >> 4;
			V <= tmp_shift >> 5;
		end else if (n == 3) begin
			W <= tmp_shift >> 5;
			V <= tmp_shift >> 6;
		end else if (n == 4) begin
			W <= tmp_shift >> 5;
			//V <= phi_xi;
			V <= 0;											// para n>3 testar fazendo V = 0
		end else if (n == 5) begin
			W <= tmp_shift >> 6;
			//V <= phi_xi;
			V <= 0;
		end else if (n == 6) begin
			W <= tmp_shift >> 7;
			//V <= phi_xi;
			V <= 0;
		end else if (n == 7) begin
			W <= tmp_shift >> 8;
			//V <= phi_xi;
			V <= 0;
		end else if (n == 8) begin
			W <= tmp_shift >> 9;
			//V <= phi_xi;
			V <= 0;
		end else if (n == 9) begin
			W <= tmp_shift >> 10;
			//V <= phi_xi;
			V <= 0;
		end else if (n == 10) begin
			W <= tmp_shift >> 11;
			//V <= phi_xi;
			V <= 0;
		end else if (n == 11) begin
			W <= tmp_shift >> 12;
			//V <= phi_xi;
			V <= 0;
		end else begin
			W <= 0;
			V <= 0;
		end
	end

	// Gerar valor de phi/xi
	always @ (*) begin
		if (n == 0) begin
			phi_xi = xi;
		end else begin
			phi_xi[10:3] = phi;
			phi_xi[2:0] = 0;
		end
	end

	// Gerar valor de phi e ni resultado de uma multiplicacao
	// Essa parte esta funcional
	always @ (*) begin
		// essa logica implementa xi*1.0111 sendo 1.0111 = log_2(e) = 1/log_e(2)
		B = xi>>1;
		D = xi>>4;
		result_mult = xi+B-D;
		// 1/ln(2) ~= 1.46
		n = result_mult[11:8];
		phi = result_mult[7:0];
		// n eh a parte inteira de x / ln(2)
		//phi eh a parte decimal de x / ln(2)
	end

	// Gerar valor de xi, ja contendo o sinal p
	// Essa parte esta funcional
	always @ (*) begin
		if (x[11] == 1) begin
			xi <= ~x[10:0] + 1;
		end else begin
			xi <= x[10:0];
		end
	end

endmodule