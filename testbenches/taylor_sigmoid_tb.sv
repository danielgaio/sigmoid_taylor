// arquivo de testbench para a parte sitetizavel

`timescale 1ns/1ps

module taylor_sigmoid_tb();
	reg 	[11:0] 	fracionaria;
	logic [11:0] 	x_tb;
	logic [12:0] 	f_x_tb;
	logic [11:0]	input_dut;
	logic 				inteira;
	logic 				clk_tb;
	shortreal 		generated_results [4096];
	shortreal 		expected_results [4096];
	shortreal 		desvio [4096];
	shortreal 		passo, passo_abs, temp, temp2; // 32 bit
	shortreal 		erro_medio, max_error, converted, variancia, desvio_padrao;
	int 					i, j, k;
	int 					clk_counter, file_descriptor, expo;

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
		// ============ TESTES MANUAIS ============
		//fork
		    // x_tb = 12'b0010_10000000;	// sig(2.5)=0.924 | em bin: 000_11101101
		    // x_tb = 12'b0011_00000000; // +3
				// x_tb = 12'b1101_00000000; // -3 -> 0.0474
				// x_tb = 12'b0001_00000000; // +1
				//#40
		    //$display("f_x = %b", f_x_tb);
		//join
		//$stop;

		// ============= ENTRADAS PARA A ARQUITETURA ==========
		fork
			// Cria controlador do arquivo txt
			file_descriptor = $fopen(
				"./../../../testbenches/log_obtained_values.txt", "w"
			);

			if (file_descriptor)
				$display("Arquivo aberto com sucesso: %0d", file_descriptor);
			else
				$display("Erro na abertura do arquivo: %0d", file_descriptor);

			// gerando todos os valores de teste para o DUT
			input_dut = 12'b0000_00000000;
			for (i=0; i<4095; i=i+1) begin

				// pular o primeiro valor negativo, porque é calculado como zero
				if (input_dut == 12'b1000_00000000) begin
					input_dut = input_dut+12'b0000_00000001;
					$fwrite(file_descriptor, "Pulou primeiro valor negativo.\n");
				end

				// injetar sinal no DUT
				x_tb = input_dut;

				$display("x_tb: %b", x_tb);
				$fwrite(file_descriptor, "x_tb: %b\n", x_tb);

				#20

				// exibir saida do DUT
				$display("y_tb: %b", f_x_tb);
				$fwrite(file_descriptor, "y_tb: %b\n", f_x_tb);
				
				// converter resultado de saida do DUT para decimal e salva em um vetor
				temp = 0;
				expo = 1;

				// converter parte inteira extraindo parte correspondente
				inteira = f_x_tb[12];

				// converter parte fracionaria
				fracionaria = f_x_tb[11:0];
				//$display("fracionaria: %b", fracionaria);

				// da esquerda para a direita, ver se o bit eh 1, se sim, calcular
				// 2^(posição do bit) e armazenar se proximo bit eh 1, calcular
				// novamente e somar ao resultado ja armazenado
				for (j = 11; j >= 0; j--) begin
					if (fracionaria[j] == 1)
						temp += shortreal'(1)/(2**(expo));

					expo ++;
					//$display("temp: %f", temp);
				end

				// somar parte inteira e fracionaria
				converted = inteira + temp;

				// guarda valor convertido em um vetor
				generated_results[input_dut] = converted;
				$display("generated_results[%d]: %f", input_dut,
					generated_results[input_dut]);
				$fwrite(file_descriptor, "generated_results[%d]: %f\n", input_dut,
					generated_results[input_dut]);
				$fwrite(file_descriptor, "-----------------------------\n");
				input_dut = input_dut+12'b0000_00000001;
			end

		join
		$stop;

		// ============== CALCULO DE VALORES EXATOS ================

		// calculando valor preciso e guardando em expected_results
		// O bloco abaixo esta pronto
		fork
			// Cria controlador do arquivo txt
			file_descriptor = $fopen(
				"./../../../testbenches/log_exact_values.txt", "w"
			);
			if (file_descriptor)
				$display("Arquivo aberto com sucesso: %0d", file_descriptor);
			else
				$display("Erro na abertura do arquivo: %0d", file_descriptor);

			passo = -7.999;
			for (k=0; k<=4095; k++) begin
				expected_results[k] = 1.0/(1.0+(2.718281828**(-passo)));
				$display("passo: %f", passo);
				$fwrite(file_descriptor, "passo: %f\n", passo);
				$display("expected_results[%d]: %f", k, expected_results[k]);
				$fwrite(file_descriptor, "expected_results[%d]: %f\n", k,
					expected_results[k]);
				passo += 0.00390;
			end
			//Encerra controlador do arquivo
			$fwrite(file_descriptor, "\n\n");
			$fclose(file_descriptor);
		join
		$stop;

		// ============== CALCULO DOS ERROS ===============
		// calculando para o primeiro intervalo 0 -> 0.5
		// j é o indice exact value (0->0.5). k é o obtained value(0.5->1).
		fork

			j = 0;
			for (k = 2048; k >= 4095; k++) begin
				temp = expected_results[k];
				temp2 = generated_results[j];

				// calculando o erro medio
				if ((temp2 - temp) < 0)
					erro_medio += -(temp2 - temp);
				else begin
					erro_medio += (temp2 - temp);
				end
				
				// calculando o erro maximo
				if ((temp2 - temp) > max_error)
					max_error = (temp2 - temp);
				
				j++;
			end

			// calculando para o segundo intervalo
			// j(0.5->1), k(0->0.5)
			max_error = 0;

			// j é o indice exact value. k é o obtained value.
			j = 2046;
			for (k = 0; k <= 2048; k++) begin
				// valor exato
				temp = expected_results[j];
				// valor obtido
				temp2 = generated_results[k];

				// calculando o erro medio
				if ((temp2 - temp) < 0)
					erro_medio += -(temp2 - temp);
				else begin
					erro_medio += (temp2 - temp);
				end
				
				// calculando o erro maximo
				if ((temp2 - temp) > max_error)
					max_error = (temp2 - temp);

				j++;
			end

			// exibindo o erro médio
			//erro_medio = erro_medio/1000;
			erro_medio /= 4096;
			$display("Erro medio: %f", erro_medio);
				
			// exibindo o erro maximo
			$display("Max_error: %f", max_error);

		join
		$stop;

		// calculando variância e desvio padrão
		fork
			k = 2048;
			for (j = 0; j <= 4095; j++) begin
				if (j == 2048)
		 			k = 0;
				$display("k: %d", k);
				// valor exato
				temp = expected_results[j];
				// valor obtido
				temp2 = generated_results[k];

				if ((temp2-temp) < 0) begin
					//$display((-(temp2-temp)));
					if ((-(temp2-temp)) - erro_medio < 0)
						desvio[j] = -((-(temp2-temp)) - erro_medio);
					else
						desvio[j] = (-(temp2-temp)) - erro_medio;
				end else begin
					if (((temp2-temp)) - erro_medio < 0)
						desvio[j] = -((temp2-temp) - erro_medio);
					else
						desvio[j] = (temp2-temp) - erro_medio;
				end
				$display("desvio[%d]: %f", j, desvio[j]);
				k++;
				
			end

			// calcular variancia
			for (k = 0; k <= 4095; k++) begin
				variancia += desvio[k]**2;
			end
			variancia /= 4096;
			$display("Variancia: %f", variancia);

			// calculo do desvio padrao
			desvio_padrao = variancia**(1.0/2.0);
			$display("Desvio padrao: %f", desvio_padrao);

		join
		$stop;

	end

endmodule