	global tablero_inicializar
	global tablero_imprimir

	extern printf

struc celda
	.es_castillo 	 resb 1
	.simbolo_unicode resb 1
endstruc


	section .data
celdas:
%rep 49
	istruc celda
		at celda.es_castillo, db 0
		at celda.simbolo_unicode, db 95
	iend
%endrep
%define BYTES_CELDA 2
%define LONG_TABLERO 7
%define FILA r13
%define COLUMNA r12
%macro macro_rax_offset_celda 0
	mov rax,FILA
	imul rax,LONG_TABLERO*BYTES_CELDA
	mov rcx,COLUMNA
	imul rcx,BYTES_CELDA
	add rax,rcx
%endmacro

newline: db 10,0
simbolo_string: db " %c ",0
ansi_castillo: db 27,"[38;5;0;48;5;245m",0
ansi_resetear: db 27,"[0m",0


	section .text
tablero_inicializar:
	mov byte [celdas + 46 + celda.es_castillo],1
	mov byte [celdas + 46 + celda.simbolo_unicode],88
	mov byte [celdas + 48 + celda.es_castillo],1
	mov byte [celdas + 48 + celda.simbolo_unicode],88
	mov byte [celdas + 50 + celda.es_castillo],1
	mov byte [celdas + 50 + celda.simbolo_unicode],88

	mov byte [celdas + 60 + celda.es_castillo],1
	mov byte [celdas + 60 + celda.simbolo_unicode],88
	mov byte [celdas + 62 + celda.es_castillo],1
	mov byte [celdas + 62 + celda.simbolo_unicode],88
	mov byte [celdas + 64 + celda.es_castillo],1
	mov byte [celdas + 64 + celda.simbolo_unicode],88
	
	mov byte [celdas + 74 + celda.es_castillo],1
	mov byte [celdas + 74 + celda.simbolo_unicode],88
	mov byte [celdas + 76 + celda.es_castillo],1
	mov byte [celdas + 76 + celda.simbolo_unicode],88
	mov byte [celdas + 78 + celda.es_castillo],1
	mov byte [celdas + 78 + celda.simbolo_unicode],88

	ret


tablero_imprimir:
	mov FILA,0

	loop_filas:
		mov COLUMNA,0

		loop_columnas:
			macro_rax_offset_celda		

			mov r14b,[celdas + rax + celda.es_castillo]
			cmp r14b,1
			jne continue_no_iniciar_ansi

			mov rdi,ansi_castillo
			call printf

			continue_no_iniciar_ansi:
			mov rdi,simbolo_string
			movzx rsi,byte [celdas + rax + celda.simbolo_unicode]
			call printf

			cmp r14b,1
			jne continue_no_resetear_ansi

			mov rdi,ansi_resetear
			call printf

			continue_no_resetear_ansi:
			inc COLUMNA
			cmp COLUMNA,LONG_TABLERO
			jl loop_columnas

		mov rdi,newline
		call printf

		inc FILA
		cmp FILA,LONG_TABLERO
		jl loop_filas

	ret
