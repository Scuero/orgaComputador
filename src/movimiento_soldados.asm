section .text
global mover_soldado
extern printf

mover_soldado:

    ;Escenario I: Aca verifico que el movimiento sea hacia las primeras filas 1 o 2
    cmp rdx, 2      
    jg movimiento_invalido ; Fila > 2 --> Movimiento invalido

    ; Escenario II:Verifico si el movimiento es lateral (en la misma fila) o diagonal
    mov rax, rdx
    sub rax, rdi     
    mov rbx, rcx
    sub rbx, rsi    

    ; Escenario III:Verifico si es un movimiento diagonal (distancia en filas igual a distancia en columnas)
    cmp rax, rbx
    je movimiento_valido
    cmp rax, -rbx
    je movimiento_valido

    ; Escenario IV: Verifico si el movimiento es vertical (mismo columna)
    cmp rbx, 0
    je movimiento_valido

movimiento_invalido:
    mov rdi, mensaje_movimiento_invalido
    call printf
    ret

movimiento_valido:
    ; Actualizar el estado del tablero (
    mov rdi, mensaje_movimiento_exitoso
    call printf
    ; En esta parte faltaria la logica para actualizar los iconos_fichas(tablero)
    ret