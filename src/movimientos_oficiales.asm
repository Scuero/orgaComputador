section .data
    mensaje_captura_fallida: db "No se encuentra unsoldado para capturar", 10, 0
    mensaje_captura_exitosa: db "Soldado capturado exitosamente", 10, 0
    mensaje_movimiento_exitoso_oficial: db "Oficial movido exitosamente", 10, 0
    mensaje_movimiento_invalido_oficial: db "Movimiento invalido para oficial", 10, 0

section .text
global mover_oficial, capturar_soldado
extern printf


mover_oficial:

    ; Escenario I: Valido que el movimiento se encuentre dentro de los limites de nuestro tablero
    cmp rdx, 7         
    ja movimiento_invalido

    cmp rcx, 7
    ja movimiento_invalido

    ; Me faltaria la logica para ver si hay un oficial en la posicion destino
    ; Por ahora, asumo que el movimiento es valido
    mov rdi, mensaje_movimiento_exitoso_oficial
    call printf
    ret

movimiento_invalido:
    mov rdi, mensaje_movimiento_invalido_oficial
    call printf
    ret


capturar_soldado:


    ;Escenario I: Valido que la fila y columna destino estan dentro del tablero
    cmp rdx, 7          
    ja captura_invalida

    cmp rcx, 7          
    ja captura_invalida

    ; Claculo la posicion del soldado y verificar si hay uno para capturar
    mov rax, rdi        
    mov rbx, rsi        
    sub rax, 1           
    
    ; Verificar si hay un soldado en la pos del salto
    ; Como estamos con un tablero basado en iconos_fichas, propongo el uso de un arreglo o matriz que tenga las posiciones de los soldados
    movzx rcx, byte [iconos_fichas + rax*7 + rbx] ; 
    cmp rcx, 'X'        
    jne captura_invalida


    ; Verificar si la celda de destino se encuentra vacia
    mov rax, rdx
    mov rbx, rcx
    cmp byte [iconos_fichas + rdx*7 + rcx], ' ' 
    jne captura_invalida 

    ; Escenario II: Captura exitosa
    mov rdi, mensaje_captura_exitosa
    call printf

    ; Actualizar el estado del tablero: remover el soldado y mover el oficial
    mov byte [iconos_fichas + rax*7 + rbx], ' ' ; Remover soldado
    mov byte [iconos_fichas + rdx*7 + rcx], 'O' ; Mover oficial a la nueva pos
    ret

captura_invalida:
    mov rdi, mensaje_captura_fallida
    call printf
    ret