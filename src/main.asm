	global main

	extern tablero_inicializar
	extern tablero_imprimir

	section .text
main:
	call tablero_inicializar
	call tablero_imprimir
exit:
	mov rax,60
	mov rdi,0
	syscall
