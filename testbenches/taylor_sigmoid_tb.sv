// arquivo de testbench para a parte sitetizavel

`timescale 1ns/1ps

module psoa_sigmoid_tb();
	logic [11:0] x_tb;
	logic [11:0] f_x_tb;
	logic clk_tb;

	shortreal 	generated_results [4096];
	shortreal 	expected_results [4096];
	logic 			j;
	shortreal 	passo, passo_abs, temp, temp2; // 32 bit
	int 				k, i;
	shortreal 	erro_medio, max_error;
	int 				clk_counter, file_descriptor;

	// modulo teste
	sigmoid_taylor sigmoid_taylor_DUT(
		.x(x_tb),
		.clk(clk_tb),
		.f_x(f_x_tb)
	);

	// inicializar clock
	initial begin
		clk_tb = 0;
		clk_counter = 0;
	end

	// oscilar clock
	always begin
		#10
		clk_tb = ~clk_tb;
		clk_counter++;
	end

	// bloco do reset: em reset no primeiro ciclo
	//initial begin reset_tb = 1; #9.9 reset_tb = 0; end

	// estimulos
	initial begin
		//fork
		    // x_tb = 12'b0010_10000000;	// sig(2.5)=0.924 | em bin: 000_11101101
		    // x_tb = 12'b0011_00000000; // +3
				// x_tb = 12'b1101_00000000; // -3 -> 0.0474
				// x_tb = 12'b0001_00000000; // +1
				//#40
		    //$display("f_x = %b", f_x_tb);
		//join
		//$stop;

		// secao para geracao de valores de entrada
		// fork
		// 	passo = -8;
		// 	// intervalo de [-8,+8]
		// 	for (i=0; i<=1000; i++) begin
		// 		// se input for negativo injetar valor absoluto e guardar (1 - result)
		// 		if (passo < 0) begin
		// 			passo_abs = -passo;
		// 			x_tb = passo_abs*1024;
		// 		// se input for positivo
		// 		end else begin
		// 			x_tb = passo*1024;
		// 		end

		// 		$display("x= %d", x_tb);
		// 		#40

		// 		if (passo < 0) begin

		// 			//if (clk_counter > 1) begin
		// 				generated_results [i] = 1 - (shortreal'(f_x_tb)/shortreal'(1024));
		// 				$display("generated result [%d]: %f", i, generated_results[i]);
		// 			//end

		// 		end else begin

		// 			generated_results [i] = (shortreal'(f_x_tb)/shortreal'(1024));
		// 			$display("generated result [%d]: %f", i, generated_results[i]);

		// 		end
		// 		passo += 0.016;
		// 	end
		// join
		// $stop;

		// calculando valor preciso e guardando em expected_results
		fork
			// Cria controlador do arquivo txt
			file_descriptor = $fopen("./../../../testbenches/log_exact_values.txt", "a");
			if (file_descriptor)
				$display("Arquivo aberto com sucesso: %0d", file_descriptor);
			else
				$display("Erro na abertura do arquivo: %0d", file_descriptor);

			passo = -7.999;
			for (k=0; k<4096; k++) begin
				expected_results[k] = 1.0/(1.0+(2.718281828**(-passo)));
				$display("passo: %f", passo);
				$fwrite(file_descriptor, "passo: %f\n", passo);
				$display("expected_results[%d]: %f", k, expected_results[k]);
				$fwrite(file_descriptor, "expected_results[%d]: %f\n", k, expected_results[k]);
				passo += 0.00390;
			end
			//Encerra controlador do arquivo
			$fwrite(file_descriptor, "\n\n");
			$fclose(file_descriptor);
		join
		$stop;

		// calcular as diferencas entre valor gerado e valor esperado
		fork
			
			max_error = 0;
			for (k = 0; k < 1000; k++) begin
				temp = expected_results[k];
				temp2 = generated_results[k];
				
				// calculando o erro maximo
				if ((temp2 - temp) > max_error)
					max_error = (temp2 - temp);

				// calculando o erro medio
				if ((temp2-temp) < 0)
					erro_medio += -(temp2-temp);
				else begin
					erro_medio += (temp2-temp);
				end
			end

			//erro_medio = erro_medio/1000;
			erro_medio /= 1000;
			$display("Erro medio: %f", erro_medio);
			
			// exibindo o erro maximo
			$display("Max_error: %f", max_error);
		join
		$stop;

	end

endmodule