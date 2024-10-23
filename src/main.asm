	global main

	extern tablero_inicializar
	extern tablero_renderizar

	section .text
main:
	call tablero_inicializar
	call tablero_renderizar
exit:
	mov rax,60
	mov rdi,0
	syscall
