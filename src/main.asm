	global main

	extern tablero_inicializar
	extern tablero_renderizar
	extern __temp_tablero_llenar_fichas

	section .text
main:
	call tablero_inicializar

	; función temporal mientras no tenemos implementada la lógica de
	; actualización de las posiciones del juego en cada turno. sirve para
	; mostrar algo en pantalla.
	;
	call __temp_tablero_llenar_fichas

	call tablero_renderizar
exit:
	mov rax,60
	mov rdi,0
	syscall
