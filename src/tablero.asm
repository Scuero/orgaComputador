	global __temp_tablero_llenar_fichas
	global tablero_finalizar
	global tablero_inicializar
	global tablero_renderizar
	global tablero_seleccionar_celda

	extern fclose
	extern fopen
	extern fread
	extern printf
	extern rewind
	extern scanf
	extern fflush

	%define LONGITUD_CELDA_ASCII 29
	%define CANTIDAD_FILAS 7
	%define CANTIDAD_COLUMNAS 7

; =============== DATA ===============

	section .data
pos_castillo:  db "s"
iconos_fichas: times 49 db "X"
icono_celda_indicador_vacia: db "   ",0

newline: db 10,0
archivo_tablero_path:      db "./static/tablero-abajo.dat",0
archivo_tablero_open_mode: db "rb",0

ansi_indicador_celda: db 0x1b,"[38;5;033;00000049m %c ",0x1b,"[0m",0
ansi_celda_seleccionada: db 0x1b,"[38;5;000;48;5;033m %c ",0x1b,"[0m",0

prompt_seleccion_fila: db "seleccionar fila: ",0
prompt_seleccion_columna: db "seleccionar columna: ",0
scanf_int: db "%i",0
scanf_char: db " %c\n",0

fila_seleccionada: db -1
columna_seleccionada: db -1

; =============== BSS ===============

	section .bss
buffer_ansi_celda: resb LONGITUD_CELDA_ASCII
archivo_tablero_fd: resq 1

scanf_buffer_int: resd 1
scanf_buffer_char: resb 1

; =============== TABLERO_INICIALIZAR ===============

	section .text
tablero_inicializar:
	mov rdi,archivo_tablero_path
	mov rsi,archivo_tablero_open_mode
	call fopen

	mov [archivo_tablero_fd],rax

	mov al,[pos_castillo]

	cmp al,"w"

	ret

; =============== __TEMP_TABLERO_LLENAR_FICHAS ===============

__temp_tablero_llenar_fichas:
	mov byte [iconos_fichas]," "
	mov byte [iconos_fichas + 1]," "
	mov byte [iconos_fichas + 5]," "
	mov byte [iconos_fichas + 6]," "
	mov byte [iconos_fichas + 7]," "
	mov byte [iconos_fichas + 8]," "
	mov byte [iconos_fichas + 12]," "
	mov byte [iconos_fichas + 13]," "

	mov byte [iconos_fichas + 35]," "
	mov byte [iconos_fichas + 36]," "
	mov byte [iconos_fichas + 40]," "
	mov byte [iconos_fichas + 41]," "
	mov byte [iconos_fichas + 42]," "
	mov byte [iconos_fichas + 43]," "
	mov byte [iconos_fichas + 47]," "
	mov byte [iconos_fichas + 48]," "

	ret

; =============== TABLERO_RENDERIZAR ===============

tablero_renderizar:
	mov r12,0

	mov rdi,icono_celda_indicador_vacia
	call printf

loop_indicador_columna:
	mov r13,r12
	add r13,"A"
	mov rdi,ansi_indicador_celda
	mov rsi,r13
	call printf

	inc r12
	cmp r12,CANTIDAD_COLUMNAS
	jl loop_indicador_columna

	mov rdi,newline
	call printf

	mov r12,0
loop_filas:
	mov r13,0

loop_columnas:
	mov rdi,buffer_ansi_celda
	mov rsi,LONGITUD_CELDA_ASCII
	mov rdx,1
	mov rcx,[archivo_tablero_fd]
	call fread

	cmp rax,0
	je continue_fin_archivo

	cmp r13,0
	jne continue_renderizar_celda

	mov r14,r12
	add r14,"0"
	inc r14

	mov rdi,ansi_indicador_celda
	mov rsi,r14
	call printf

continue_renderizar_celda:
	mov r14,r12
	imul r14,CANTIDAD_COLUMNAS

	movzx rsi,byte [iconos_fichas + r13 + r14]

	cmp r12b,byte [fila_seleccionada]
	jne celda_no_seleccionada
	cmp r13b,byte [columna_seleccionada]
	jne celda_no_seleccionada

	mov rdi,ansi_celda_seleccionada
	jmp renderizar_celda
celda_no_seleccionada:
	mov rdi,buffer_ansi_celda
renderizar_celda:
	call printf

	inc r13
	cmp r13,CANTIDAD_COLUMNAS
	jl loop_columnas ; siguiente columna

	mov rdi,newline
	call printf

	inc r12
	cmp r12,CANTIDAD_FILAS
	jl loop_filas ; siguiente fila
continue_fin_archivo:
	mov rdi,[archivo_tablero_fd]
	call rewind

	ret

; =============== TABLERO_SELECCIONAR_CELDA ===============

tablero_seleccionar_celda:
	mov rdi,prompt_seleccion_fila
	call printf

	mov rdi,scanf_int
	mov rsi,scanf_buffer_int
	call scanf

	mov r12d,[scanf_buffer_int]

	mov rdi,prompt_seleccion_columna
	call printf

	mov rdi,scanf_char
	mov rsi,scanf_buffer_char
	call scanf

	mov r13b,[scanf_buffer_char]

	sub r12d,1
	sub r13b,"A"

	mov [fila_seleccionada],r12d
	mov [columna_seleccionada],r13b

	ret

; =============== TABLERO_FINALIZAR ===============

tablero_finalizar:
	mov rdi,[archivo_tablero_fd]
	call fclose
	ret
