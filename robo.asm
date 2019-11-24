.data
	#Cores
	black:	  .word 0x000000
	white:	  .word 0xFFFFFF
	robo:   .word 0xFF0000
	rastro: .word 0x202020
	end: .word 0x9C9C9C

.text
	j main # Pula direto para main
	
	go_to_main: # Retorna para a funcao principal
		jr $ra

	set_tela: # Inicia todos os valores para a tela
		addi $t0, $zero, 65536 # 65536 = (512*512)/4 pixels
		add $t1, $t0, $zero # Adicionar a distribuição de pixels ao endereco $t1
		lui $t1, 0x1004 # Endereco base da tela
		j go_to_main
	
	set_cores: # salva as cores nos registradores
		lw $s4, white
		lw $s5, robo
		lw $s6, rastro
		lw $s3, end
		jr $ra
	
	set_linha: # gera um caminho aleatorio para a linha
		add $t0, $zero, $t1 # salva o endereco base em $t1
		addi $t2, $zero, 0 # zera o contador (a ser utilizado posteriormente)
		
		# Gera um numero aleatório entre 0 e 999
		li $v0, 42 # gera um numero aleatorio
		li $a1, 1000 # limite superior
		syscall # numero gerado sera armazenado em $a0
		move $s2, $a0 # move o numero gerado para o registrador $s0
		
		add $t0, $t0, 15500 # seta o ponto de partida da linha
		
		loop_1:
			li $v0, 42
			li $a1, 2
			syscall
			move $s0, $a0 # move o numero gerado para o registrador $s0
			
			# faz a comparação
			beq $s0, 1, move_direita # se $s0=1 a linha segue para direita
			beq $s0, 0, move_baixo # se $s0=0 a linha segue para baixo
			
			move_direita:
				addi $t0, $t0, 4 # anda um pixel para a direita
				sw $s4, ($t0) # o pixel armazenado em $t0 eh pintado de $s4 (branco)
				addi $t2, $t2, 1 # contador + 1
				beq $t2, 150, go_to_main # se o contador = 150 entao sai do loop e encerra a criacao da linha
				j loop_1 # se o contador < 150 volta para o loop_1
			
			move_baixo:
				addi $t0, $t0, 512 # anda para baixo
				sw $s4, ($t0) # o pixel armazenado em $t0 eh pintado de $s4 (branco)
				addi $t2, $t2, 1 # contador + 1
				beq $t2, 150, go_to_main # se o contador = 150 entao sai do loop e encerra a criacao da linha
				j loop_1 # se o contador < 150 volta para o loop_1
	
	gera_posicao_inicial: # gera um pixel aleatorio para o robo iniciar o percurso
		li $v0, 42
		li $a1, 10000
		syscall
		move $t8, $a0 # move o numero gerado para o registrador $s0
		
		addi $t6, $zero, 4

		mul $t8, $t8,$t6
		jr $ra
	
	
	
	set_robo: # movimenta o robo ate achar a linha a ser seguida
		add $t0, $zero, $t1 # armazena em $t0 a posicao inicial da tela (primeiro pixel esquerdo superior)
		
		add $t0, $t0, $t8 # $t0 vai receber uma posicao aleatoria para o robo comecar a percorrer
		
		addi $t2, $zero, 0 # zera o contador (a ser utilizado posteriormente)
		
		sw $s5, ($t0)
		
		# delay de 100 milissegundos
		li $v0, 32
		add $a0, $a0, 100
		syscall
		add $a0, $zero, 0
		
		loop_direita: # loop que movimenta o robo para frente
		
			# condicional para o robo continuar percorrendo
			lw $t7, ($t0) # carrega a cor do pixel atual que estava na memoria para o registrador $s7
			beq $t7, $s4, go_to_main # se a cor for igual a branco (chegou na linha) -> sai do laço
			
			# se nao encontrou um pixel branco entao pode continuar percorrendo
			
			# delay de 1 milissegundo
			li $v0, 32
			add $a0, $a0, 100
			syscall
			add $a0, $zero, 0
			
			sub $t5, $t0, 4 # $t5 armazena o pixel anterior (para formar o rastro)
			
			sw $s5, ($t0) # Pixel atual recebe a cor do robo
			addi $t0, $t0, 4 # Pulo para o proximo pixel
			sw $s6, ($t5) # Pixel anterior eh pintado pela cor do rastro do robo
			addi $t2, $t2, 1 #Contador +1
			j loop_direita
	
	segue_linha:
		sub $t5, $t0, 4
		sw $s6, ($t5) # Pinta o rastro
		sw $s5, ($t0)
		
		segue_linha2: # funcao eh iniciada quando o robo encontrou a linha em algum dos pixels ao redor
		
			addi $t0, $t0, 4 # $t0 recebe o pixel a direita
			lw $t5, ($t0) # $t5 recebe a cor do pixel 
			beq $t5, $s4, direita # se a cor do pixel for branca entao entra no laço 'direita'
			
			sub $t0, $t0, 4 # volta $t0 anterior
			
			addi $t0, $t0, 512 # $t0 recebe o pixel abaixo
			lw $t5, ($t0) # $t5 recebe a cor do pixel 
			beq $t5, $s4, baixo # se a cor do pixel for branca entao entra no laço 'baixo'
			
			j go_to_main # se nao encontrou pixel branco nem a sua direita nem abaixo, entao volta para o main

			
			direita:
				# delay de 100 milissegundos
				li $v0, 32
				add $a0, $a0, 100
				syscall
				add $a0, $zero, 0
				
				sw $s5, ($t0) # robo entra no pixel
				
				sub $t5, $t0, 4 # $t5 recebe o pixel anterior (a esquerda)
				sw $s4, ($t5) # 're-pinta' o caminho percorrido
				
				j segue_linha2 # volta para o loop_2 (que controla a direcao a ser percorrida)
			
			baixo:
				# delay de 100 milissegundos
				li $v0, 32
				add $a0, $a0, 100
				syscall
				add $a0, $zero, 0
				
				sw $s5, ($t0) # robo entra no pixel
				
				sub $t5, $t0, 512 # $t5 recebe o pixel anterior (acima)
				sw $s4, ($t5) # 're-pinta' o caminho percorrido
				
				j segue_linha2 # volta para o loop_2 (que controla a direcao a ser percorrida)
	
	the_end: # funcao que eh chamada quando o robo chega ao final da linha
		add $t0, $zero, $t1
		addi $t0, $t0, 65536		
		the_end2:
			sw $s3, ($t0)
			sub $t0, $t0, 4
			addi $t2, $t2, 1 # Contador +1
			beq $t2, 65536, go_to_main
			j the_end2
	
	main:
		jal set_tela
		jal set_cores
		jal set_linha
		jal gera_posicao_inicial
		jal set_robo
		jal segue_linha
		jal the_end