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



section .data
    mensaje_fin db "El juego ha terminado.", 0
    mensaje_turno_soldado db "Turno del soldado", 0
    mensaje_turno_oficial db "Turno del oficial", 0

section .bss
    juegoActivo resb 1        ; Bandera para saber si el juego está activo (1 = activo, 0 = terminado)
    esTurnoSoldado resb 1     ; Bandera para alternar turnos (1 = soldado, 0 = oficial)

section .text
    global _start
    extern inicializar_tablero, mostrar_tablero, jugar_turno, verificar_si_termino_juego, print_string

_start:
    ; Inicializar el tablero
    call inicializar_tablero
    
    ; Mostrar el tablero inicial
    call mostrar_tablero

    ; Configurar el juego como activo y el turno inicial
    mov byte [juegoActivo], 1
    mov byte [esTurnoSoldado], 1   ; Inicia con el turno del soldado

game_loop:
    ; Comprobar si el juego está activo
    cmp byte [juegoActivo], 1
    jne end_game                 ; Si juegoActivo es 0, salimos del juego

    ; Mostrar mensaje de turno según corresponda
    cmp byte [esTurnoSoldado], 1
    je turno_soldado
    jmp turno_oficial

turno_soldado:
    ; Imprimir mensaje de turno del soldado
    mov rdi, mensaje_turno_soldado
    call print_string
    jmp realizar_turno

turno_oficial:
    ; Imprimir mensaje de turno del oficial
    mov rdi, mensaje_turno_oficial
    call print_string

realizar_turno:
    ; Llamar a jugar_turno (maneja el turno del jugador actual)
    ; `jugar_turno` espera que [esTurnoSoldado] determine si es el turno del soldado
    call jugar_turno

    ; Mostrar el tablero actualizado
    call mostrar_tablero

    ; Verificar si el juego ha terminado
    call verificar_si_termino_juego
    ; Asumimos que `verificar_si_termino_juego` pone 0 en [juegoActivo] si terminó el juego

    ; Cambiar de turno
    cmp byte [esTurnoSoldado], 1
    je set_turno_oficial
    jmp set_turno_soldado

set_turno_oficial:
    mov byte [esTurnoSoldado], 0
    jmp game_loop

set_turno_soldado:
    mov byte [esTurnoSoldado], 1
    jmp game_loop

end_game:
    ; Imprimir mensaje de fin de juego
    mov rdi, mensaje_fin
    call print_string

    ; Salir del programa
    mov eax, 60        ; syscall: exit
    xor edi, edi       ; estado de salida = 0
    syscall
