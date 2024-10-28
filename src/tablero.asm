	global tablero_inicializar
	global tablero_renderizar
	global __temp_tablero_llenar_fichas

	extern fopen
	extern fread
	extern printf


	%define LONGITUD_CELDA_ASCII 29
	%define CANTIDAD_FILAS 7
	%define CANTIDAD_COLUMNAS 7


	section .data
pos_castillo:  db "s"
iconos_fichas: times 49 db "X"

newline: db 10,0
archivo_tablero_path:      db "./static/tablero-abajo.dat",0
archivo_tablero_open_mode: db "rb",0

ansi_castillo: db 0x1b,"[38;5;000;48;5;244m %c ",0x1b,"[0m",0
ansi_indicador_celda: db 0x1b,"[38;5;046;00000049m %c ",0x1b,"[0m",0
ansi_celda_indicador_vacia: db "   ",0


	section .bss
archivo_buffer: resb 29
archivo_fd: resq 1


	section .text
tablero_inicializar:
	mov rdi,archivo_tablero_path
	mov rsi,archivo_tablero_open_mode
	call fopen

	mov [archivo_fd],rax

	mov al,[pos_castillo]

	cmp al,"w"

	ret


	; idealmente cada vez que se actualizen las fichas del juego, estas van a
	; llenar una matriz 7x7 cada una con su propio ícono. Luego el tablero solo
	; se va a encargar de dibujar estos íconos. esta matriz debería estar
	; inicializada en espacios en blanco en cada actualización, así solo se
	; cambian los íconos que las fichas populen.
	;
	; por ahora simulamos esta actualización pero al revés: inicializamos todos
	; los casilleros como si tuvieran fichas con ícono "X" para visualizarlas
	; fácilmente y quitamos los espacios que debería estar en blanco.
	;
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


tablero_renderizar:
	mov r12,0

	; fila de indicadores de columna
	mov rdi,ansi_celda_indicador_vacia
	call printf
loop_indicador_columna:
	mov r13,r12
	add r13,"A"
	mov rdi,ansi_indicador_celda
	mov rsi,r13
	call printf

	inc r12
	cmp r12,CANTIDAD_COLUMNAS
	jl loop_indicador_columna ; hay una columna extra para el indicador de filas

	; terminamos de renderizar la fila de indicadores de columnas
	;
	mov rdi,newline
	call printf
	mov r12,0
loop_filas:
	mov r13,0
loop_columnas:
	; leemos el archivo de celda en celda.
	;
	mov rdi,archivo_buffer
	mov rsi,LONGITUD_CELDA_ASCII
	mov rdx,1
	mov rcx,[archivo_fd]
	call fread

	cmp rax,0
	je continue_fin_archivo ; llegamos al fin del archivo

	; indicador de fila
	cmp r13,0
	jne continue_renderizar_celda ; ya está el indicador de la fila

	mov r14,r12
	add r14,"0"
	inc r14 ; las filas se numeran desde el 1

	mov rdi,ansi_indicador_celda
	mov rsi,r14
	call printf

continue_renderizar_celda:
	mov r14,r12
	imul r14,CANTIDAD_COLUMNAS ; offset de fila actual

	movzx rsi,byte [iconos_fichas + r13 + r14]
	mov rdi,archivo_buffer
	call printf

	inc r13
	cmp r13,CANTIDAD_COLUMNAS
	jl loop_columnas ; siguiente columnas

	mov rdi,newline
	call printf

	inc r12
	cmp r12,CANTIDAD_FILAS
	jl loop_filas ; siguiente fila
continue_fin_archivo:
	ret
