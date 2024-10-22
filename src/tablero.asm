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

newline: db 10,0
simbolo_string: db " %c ",0


	section .text
tablero_inicializar:
	mov byte [celdas + 46 + celda.simbolo_unicode],88
	mov byte [celdas + 48 + celda.simbolo_unicode],88
	mov byte [celdas + 50 + celda.simbolo_unicode],88

	mov byte [celdas + 60 + celda.simbolo_unicode],88
	mov byte [celdas + 62 + celda.simbolo_unicode],88
	mov byte [celdas + 64 + celda.simbolo_unicode],88
	
	mov byte [celdas + 74 + celda.simbolo_unicode],88
	mov byte [celdas + 76 + celda.simbolo_unicode],88
	mov byte [celdas + 78 + celda.simbolo_unicode],88

	ret


tablero_imprimir:
	mov r13,0

	loop_filas:
		mov r12,0

		loop_columnas:
			; offset fila
			mov rax,r13
			imul rax,7*BYTES_CELDA

			; offset columna
			mov rcx,r12
			imul rcx,BYTES_CELDA

			mov rdi,simbolo_string
			movzx rsi,byte [celdas + rax + rcx + celda.simbolo_unicode]
			call printf

			inc r12
			cmp r12,LONG_TABLERO
			jl loop_columnas

		mov rdi,newline
		call printf

		inc r13
		cmp r13,LONG_TABLERO
		jl loop_filas

	ret
