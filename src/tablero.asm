	global tablero_inicializar
	global tablero_imprimir

	extern fopen
	extern fread
	extern printf


	section .data
iconos: times 49 db "X"

newline: db 10,0
archivo_pathname:  db "./build/tablero.dat",0
archivo_open_mode: db "rb",0


	section .bss
archivo_buffer: resb 29
archivo_fd: resq 1


	section .text
tablero_imprimir:
	mov rdi,archivo_pathname
	mov rsi,archivo_open_mode
	call fopen

	mov [archivo_fd],rax

	mov r12,0
loop_filas:
	mov r13,0

	loop_columnas:
		mov rdi,archivo_buffer
		mov rsi,29
		mov rdx,1
		mov rcx,[archivo_fd]
		call fread

		cmp rax,0
		je continue_loop

		mov r14,r12
		imul r14,7

		movzx rsi,byte [iconos + r13 + r14]
		mov rdi,archivo_buffer
		call printf

		inc r13
		cmp r13,7
		jl loop_columnas

	mov rdi,newline
	call printf

	inc r12
	cmp r12,7
	jl loop_filas

continue_loop:
	ret
