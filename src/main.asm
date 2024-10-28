	global main

	extern __temp_tablero_llenar_fichas
	extern tablero_finalizar
	extern tablero_inicializar
	extern tablero_renderizar
	extern tablero_seleccionar_celda

	section .text
main:
	call tablero_inicializar

	call __temp_tablero_llenar_fichas

	call tablero_renderizar
	call tablero_seleccionar_celda
	call tablero_renderizar

	call tablero_finalizar
exit:
	mov rax,60
	mov rdi,0
	syscall
