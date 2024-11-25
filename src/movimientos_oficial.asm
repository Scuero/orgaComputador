      global cargar_movimientos_oficial
    global efectuar_movimiento_oficial

    extern array_movimientos_posibles
    extern tablero

    %define CANTIDAD_COLUMNAS 7

    section .bss
        pos_oficial_1 resb 2      ; Reservar 2 bytes para el Oficial 1 (1 byte para fila, 1 byte para columna)
        pos_oficial_2 resb 2      ; Reservar 2 bytes para el Oficial 2 (1 byte para fila, 1 byte para columna)
        movimientos_oficial1 resb 1 ; Contador de movimientos para el Oficial 1
        movimientos_oficial2 resb 1 ; Contador de movimientos para el Oficial 2
        capturas_oficial1 resb 1  ; Contador de capturas para el Oficial 1
        capturas_oficial2 resb 1  ; Contador de capturas para el Oficial 2

    section .data
        mensaje_estadisticas db "Estadísticas del juego:", 0
        mensaje_oficial_1 db "Estadísticas del Oficial 1:", 0
        mensaje_oficial_2 db "Estadísticas del Oficial 2:", 0

    section .text
        global imprimir_cadena
        global efectuar_movimiento_oficial
        global mostrar_estadisticas




    ; actualiza el `array_movimientos_posibles` con los índices de las celdas a las
    ; que se puede mover el oficial dado
    ;
    ; parámetros:
    ; - rdi: índice celda actual oficial
    ;
cargar_movimientos_oficial:
    ; Calculamos fila y columna
    mov rax, rdi
    mov rcx, 7
    xor rdx, rdx

    div rcx ; rax = fila, rdx = columna
    mov r8, rax ; r8 = fila
    mov r9, rdx ; r9 = columna

    xor rcx, rcx ; rcx = índice del array

    ; ========== ARRIBA ==========
    ;
    .check_limites_arriba:
    ; si estamos en una columa entre la 2 y la 4 (inclusive) significa que no
    ; estamos en las aspas, por lo tanto, el único límite que nos importa es el
    ; límite superior de todo el tablero.
    ;
    cmp r9, 2
    jl .check_normal_arriba_aspa_horizontal
    cmp r9, 4
    jg .check_normal_arriba_aspa_horizontal
    jmp .check_captura_arriba

    ; en el caso de estar en las aspas, el límite superior que nos importa es el
    ; de las aspas.
    ;
    .check_normal_arriba_aspa_horizontal:
    ; Si estamos en las aspas laterales, no permitimos ningun movimiento hacia
    ; arriba en la primera fila.
    ;
    cmp rax, 2
    je .check_limites_abajo

    ; a su vez, si estamos en la segunda fila de las aspas no permitimos
    ; movimientos de captura hacia arriba.
    ;
    cmp rax, 3
    je .check_normal_arriba

    .check_captura_arriba:
    ; verificar si hay un soldado directamente arriba
    mov r11, rdi
    sub r11, 7

    cmp byte [tablero + r11], 'X'
    jne .check_normal_arriba

    ; para captura, verificar la siguiente posición
    sub r11, 7 ; r11 ahora tiene la posición después del salto sobre el oficial

    ; verificar que no nos salimos del tablero
    cmp r11, 0
    jl .check_limites_abajo

    ; verificar que la posición de salto esta vacía
    cmp byte [tablero + r11], ' '
    jne .check_limites_abajo

    mov byte [array_movimientos_posibles + rcx], r11b
    inc rcx

    ; si puedo hacer un movimiento de captura hacia arriba, automáticamente no
    ; puedo hacer un movimiento normal hacia arriba, porque significa que la
    ; celda de arriba está ocupada por un soldado.

    .check_normal_arriba:
    ; verificar si la casilla de arriba está vacía
    mov r11, rdi
    sub r11, 7

    cmp byte [tablero + r11], ' '
    jne .check_limites_abajo
    mov byte [array_movimientos_posibles + rcx], r11b
    inc rcx

    ; ========== ABAJO ==========
    ;
    .check_limites_abajo:
    ; de nuevo, primero verificamos si estamos en una posicion donde tenemos
    ; condiciones especiales para el movimiento en cuestión (en las aspas
    ; horizontales para el caso de movimientos hacia abajo).
    ;
    cmp r9, 2
    jl .check_normal_abajo_aspa_horizontal
    cmp r9, 4
    jg .check_normal_abajo_aspa_horizontal
    jmp .check_captura_abajo

    ; en el caso de estar en las aspas, el límite inferior que nos importa es el
    ; de las aspas.
    ;
    .check_normal_abajo_aspa_horizontal:
    ; Si estamos en las aspas laterales, no permitimos ningun movimiento hacia
    ; abajo en la última fila.
    ;
    cmp rax, 4
    je .check_limites_izquierda

    ; si estamos en la penúltima fila de las aspas no permitimos
    ; movimientos de captura hacia abajo.
    ;
    cmp rax, 3
    je .check_normal_abajo

    .check_captura_abajo:
    ; verificar si hay un soldado directamente abajo
    mov r11, rdi
    add r11, 7

    cmp byte [tablero + r11], 'X'
    jne .check_normal_abajo

    ; para captura, verificar la siguiente posición
    add r11, 7 ; r11 ahora tiene la posición después del salto sobre el soldado

    ; verificar que no nos salimos del tablero (por abajo)
    cmp r11, 49
    jge .check_limites_izquierda

    ; verificar que la posición de salto está vacía
    cmp byte [tablero + r11], ' '
    jne .check_limites_izquierda

    mov byte [array_movimientos_posibles + rcx], r11b
    inc rcx

    ; si puedo hacer un movimiento de captura hacia abajo, automáticamente no
    ; puedo hacer un movimiento normal hacia abajo, porque significa que la
    ; celda de abajo está ocupada por un soldado.
    jmp .check_limites_izquierda

    .check_normal_abajo:
    ; verificar si la casilla de abajo está vacía
    mov r11, rdi
    add r11, 7

    cmp byte [tablero + r11], ' '
    jne .check_limites_izquierda
    mov byte [array_movimientos_posibles + rcx], r11b
    inc rcx

    ; ========== IZQUIERDA ==========
    ;
    .check_limites_izquierda:
    ; verificamos si estamos en una fila donde tenemos condiciones especiales
    ; (en las aspas verticales para movimientos laterales)
    ;
    cmp r8, 2 ; r8 tiene la fila actual
    jl .check_normal_izquierda_aspa_vertical
    cmp r8, 4
    jg .check_normal_izquierda_aspa_vertical
    jmp .check_captura_izquierda

    .check_normal_izquierda_aspa_vertical:
    ; Si estamos en las aspas verticales, no permitimos movimiento hacia
    ; la izquierda en la columna más a la izquierda
    ;
    cmp r9, 2
    je .check_limites_derecha

    ; si estamos en la segunda columna desde la izquierda no permitimos
    ; movimientos de captura hacia la izquierda
    ;
    cmp r9, 3
    je .check_normal_izquierda

    .check_captura_izquierda:
    ; verificar si hay un soldado directamente a la izquierda
    mov r11, rdi
    dec r11 ; la casilla de la izquierda a la actual

    cmp byte [tablero + r11], 'X'
    jne .check_normal_izquierda

    ; para captura, verificar la siguiente posición
    dec r11 ; r11 ahora tiene la posición después del salto sobre el soldado

    ; verificar que seguimos en la misma fila después del salto
    push rcx
    mov rax, r11
    mov rcx, 7
    xor rdx, rdx
    div rcx
    pop rcx

    cmp rax, r8 ; comparamos la fila nueva con la fila actual
    jne .check_normal_izquierda ; si no es la misma fila, el movimiento no es válido

    ; verificar que la posición de salto está vacía
    cmp byte [tablero + r11], ' '
    jne .check_limites_derecha

    mov byte [array_movimientos_posibles + rcx], r11b
    inc rcx
    jmp .check_limites_derecha

    .check_normal_izquierda:
    ; verificar si la casilla a la izquierda está vacía
    mov r11, rdi
    dec r11

    ; verificar que seguimos en la misma fila
    push rcx
    mov rax, r11
    mov rcx, 7
    xor rdx, rdx
    div rcx
    pop rcx

    cmp rax, r8 ; comparamos la fila nueva con la fila actual
    jne .check_limites_derecha ; si no es la misma fila, el movimiento no es válido

    cmp byte [tablero + r11], ' '
    jne .check_limites_derecha
    mov byte [array_movimientos_posibles + rcx], r11b
    inc rcx

    ; ========== DERECHA ==========
    ;
    .check_limites_derecha:
    ; verificamos si estamos en una fila donde tenemos condiciones especiales
    ; (en las aspas verticales para movimientos laterales)
    ;
    cmp r8, 2 ; r8 tiene la fila actual
    jl .check_normal_derecha_aspa_vertical
    cmp r8, 4
    jg .check_normal_derecha_aspa_vertical
    jmp .check_captura_derecha

    .check_normal_derecha_aspa_vertical:
    ; Si estamos en las aspas verticales, no permitimos movimiento hacia
    ; la derecha en la columna más a la derecha
    ;
    cmp r9, 4
    je .check_limites_diagonal_arriba_izquierda

    ; si estamos en la penúltima columna desde la derecha no permitimos
    ; movimientos de captura hacia la derecha
    ;
    cmp r9, 3
    je .check_normal_derecha

    .check_captura_derecha:
    ; verificar si hay un soldado directamente a la derecha
    mov r11, rdi
    inc r11 ; la casilla de la derecha a la actual

    cmp byte [tablero + r11], 'X'
    jne .check_normal_derecha

    ; para captura, verificar la siguiente posición
    inc r11 ; r11 ahora tiene la posición después del salto sobre el soldado

    ; verificar que seguimos en la misma fila después del salto
    push rcx
    mov rax, r11
    mov rcx, 7
    xor rdx, rdx
    div rcx
    pop rcx

    cmp rax, r8 ; comparamos la fila nueva con la fila actual
    jne .check_normal_derecha ; si no es la misma fila, el movimiento no es válido

    ; verificar que la posición de salto está vacía
    cmp byte [tablero + r11], ' '
    jne .check_limites_diagonal_arriba_izquierda

    mov byte [array_movimientos_posibles + rcx], r11b
    inc rcx
    jmp .check_limites_diagonal_arriba_izquierda

    .check_normal_derecha:
    ; verificar si la casilla a la derecha está vacía
    mov r11, rdi
    inc r11

    ; verificar que seguimos en la misma fila
    push rcx
    mov rax, r11
    mov rcx, 7
    xor rdx, rdx
    div rcx ; rax = nueva fila
    pop rcx

    cmp rax, r8 ; comparamos la fila nueva con la fila actual
    jne .check_limites_diagonal_arriba_izquierda ; si no es la misma fila, el movimiento no es válido

    cmp byte [tablero + r11], ' '
    jne .check_limites_diagonal_arriba_izquierda
    mov byte [array_movimientos_posibles + rcx], r11b
    inc rcx

    ; ========== DIAGONAL ARRIBA IZQUIERDA ==========
    ;
    .check_limites_diagonal_arriba_izquierda:
    mov r11, rdi
    sub r11, 8

    push rcx
    mov rax, r11
    mov rcx, 7
    xor rdx, rdx
    div rcx ; rax = nueva fila; rdx = nueva columna
    pop rcx

    ; Si nos salimos del tablero por arriba el movimiento es invalido.
    cmp rax, 0
    jl .check_limites_diagonal_arriba_derecha

    ; Si nos salimos del tablero por la izquierda el movimiento es invalido
    ; (esto lo checkeamos como antes, comparando con la columna actual, si es
    ; mayor, tenemos wrap-around)
    ;
    cmp rdx, r9 ; comparamos la nueva columna con la anterior
    jge .check_limites_diagonal_arriba_derecha

    ; Si caemos en el cuadrado 2x2 de la esquina superior o inferieor izquierda es un
    ; movimiento invalido. (este sería el checkeo de las aspas tanto verticales
    ; como horizontales).
    ;
    ; matriz 2x2 esquina superior izquierda
    cmp rax, 2 ; fila
    jge .check_mov_arriba_matriz_inferior_izquierda
    cmp rdx, 2 ; col
    jge .check_mov_arriba_matriz_inferior_izquierda
    jmp .check_limites_diagonal_arriba_derecha ; acá fila <= 1 && col <= 1

    ; matriz 2x2 esquina inferior izquierda
    .check_mov_arriba_matriz_inferior_izquierda:
    cmp rax, 5 ; fila
    jl .check_normal_arriba_izquierda
    cmp rdx, 2 ; col
    jge .check_normal_arriba_izquierda
    jmp .check_limites_diagonal_arriba_derecha ; acá fila >= 5 && col <= 1

    .check_normal_arriba_izquierda:
    cmp byte [tablero + r11], ' '
    jne .check_limites_diagonal_arriba_derecha
    mov byte [array_movimientos_posibles + rcx], r11b
    inc rcx

    ; ========== DIAGONAL ARRIBA DERECHA ==========
    ;
    .check_limites_diagonal_arriba_derecha:
    mov r11, rdi
    sub r11, 6

    push rcx
    mov rax, r11
    mov rcx, 7
    xor rdx, rdx
    div rcx ; rax = nueva fila; rdx = nueva columna
    pop rcx

    ; Si nos salimos del tablero por arriba el movimiento es invalido.
    cmp rax, 0
    jl .check_limites_diagonal_abajo_derecha

    ; Si nos salimos del tablero por la derecha el movimiento es invalido
    cmp rdx, r9 ; comparamos la nueva columna con la anterior
    jle .check_limites_diagonal_abajo_derecha

    ; Checkeo de las matrices 2x2 en las esquinas
    ; matriz 2x2 esquina superior derecha
    cmp rax, 2 ; fila
    jge .check_mov_arriba_matriz_inferior_derecha
    cmp rdx, 4 ; col
    jle .check_mov_arriba_matriz_inferior_derecha
    jmp .check_limites_diagonal_abajo_derecha ; acá fila <= 1 && col >= 5

    .check_mov_arriba_matriz_inferior_derecha:
    cmp rax, 5 ; fila
    jl .check_normal_arriba_derecha
    cmp rdx, 4 ; col
    jle .check_normal_arriba_derecha
    jmp .check_limites_diagonal_abajo_derecha ; acá fila >= 5 && col >= 5

    .check_normal_arriba_derecha:
    cmp byte [tablero + r11], ' '
    jne .check_limites_diagonal_abajo_derecha
    mov byte [array_movimientos_posibles + rcx], r11b
    inc rcx

    ; ========== DIAGONAL ABAJO DERECHA ==========
    .check_limites_diagonal_abajo_derecha:
    mov r11, rdi
    add r11, 8

    push rcx
    mov rax, r11
    mov rcx, 7
    xor rdx, rdx
    div rcx ; rax = nueva fila; rdx = nueva columna
    pop rcx

    ; Si nos salimos del tablero por abajo el movimiento es invalido.
    cmp rax, 6
    jg .check_limites_diagonal_abajo_izquierda

    ; Si nos salimos del tablero por la derecha el movimiento es invalido
    cmp rdx, r9 ; comparamos la nueva columna con la anterior
    jle .check_limites_diagonal_abajo_izquierda

    ; Checkeo de las matrices 2x2 en las esquinas
    ; matriz 2x2 esquina superior derecha
    cmp rax, 2 ; fila
    jge .check_mov_abajo_matriz_inferior_derecha
    cmp rdx, 4 ; col
    jle .check_mov_abajo_matriz_inferior_derecha
    jmp .check_limites_diagonal_abajo_izquierda ; acá fila <= 1 && col >= 5

    .check_mov_abajo_matriz_inferior_derecha:
    cmp rax, 5 ; fila
    jl .check_normal_abajo_derecha
    cmp rdx, 4 ; col
    jle .check_normal_abajo_derecha
    jmp .check_limites_diagonal_abajo_izquierda ; acá fila >= 5 && col >= 5

    .check_normal_abajo_derecha:
    cmp byte [tablero + r11], ' '
    jne .check_limites_diagonal_abajo_izquierda
    mov byte [array_movimientos_posibles + rcx], r11b
    inc rcx

    ; ========== DIAGONAL ABAJO IZQUIERDA ==========
    .check_limites_diagonal_abajo_izquierda:
    mov r11, rdi
    add r11, 6

    push rcx
    mov rax, r11
    mov rcx, 7
    xor rdx, rdx
    div rcx ; rax = nueva fila; rdx = nueva columna
    pop rcx

    ; Si nos salimos del tablero por abajo el movimiento es invalido.
    cmp rax, 6
    jg .finalizar

    ; Si nos salimos del tablero por la izquierda el movimiento es invalido
    cmp rdx, r9 ; comparamos la nueva columna con la anterior
    jge .finalizar

    ; Si caemos en el cuadrado 2x2 de la esquina superior o inferior izquierda es un
    ; movimiento invalido.
    ; matriz 2x2 esquina superior izquierda
    cmp rax, 2 ; fila
    jge .check_mov_abajo_matriz_inferior_izquierda
    cmp rdx, 2 ; col
    jge .check_mov_abajo_matriz_inferior_izquierda
    jmp .finalizar ; acá fila <= 1 && col <= 1

    .check_mov_abajo_matriz_inferior_izquierda:
    cmp rax, 5 ; fila
    jl .check_normal_abajo_izquierda
    cmp rdx, 2 ; col
    jge .check_normal_abajo_izquierda
    jmp .finalizar ; acá fila >= 5 && col <= 1

    .check_normal_abajo_izquierda:
    cmp byte [tablero + r11], ' '
    jne .finalizar
    mov byte [array_movimientos_posibles + rcx], r11b
    inc rcx

    .finalizar:
    mov r8, 12 ; tamaño máximo del arreglo
    sub r8, rcx ; calculamos cuántas posiciones nos faltan llenar

    mov r9, rcx ; guardamos la posición inicial en r9
    mov rcx, r8 ; movemos a rcx la cantidad de iteraciones para loop

    .loop_rellenar:
    mov byte [array_movimientos_posibles + r9], 0
    inc r9
    loop .loop_rellenar

    ret


; Función para efectuar el movimiento de un oficial
; Argumentos: [rdi] = tablero (puntero al tablero), [rsi] = fila_inicial, [rdx] = col_inicial,
; [rcx] = fila_final, [r8] = col_final
efectuar_movimiento_oficial:

    ; Comparar posición inicial con pos_oficial_1
    mov rax, [pos_oficial_1]              ; Cargar la fila del oficial 1
    cmp rsi, rax                           ; Comparar fila inicial con fila oficial 1
    jne .check_oficial_2                   ; Si no es igual, comprobar el oficial 2
    mov rax, [pos_oficial_1+1]             ; Cargar la columna del oficial 1
    cmp rdx, rax                           ; Comparar columna inicial con columna oficial 1
    jne .check_oficial_2                   ; Si no es igual, comprobar el oficial 2

    ; Comprobar si la nueva posición está dentro de los límites del tablero (1-7)
    cmp rcx, 1
    jl .finalizar                           ; Si fila final < 1, finalizar
    cmp rcx, 7
    jg .finalizar                           ; Si fila final > 7, finalizar
    cmp r8, 1
    jl .finalizar                           ; Si columna final < 1, finalizar
    cmp r8, 7
    jg .finalizar                           ; Si columna final > 7, finalizar

    ; Actualizar posición del Oficial 1
    mov [pos_oficial_1], rcx               ; Establecer nueva fila
    mov [pos_oficial_1+1], r8              ; Establecer nueva columna

    ; Lógica para registrar el movimiento del oficial 1
    inc byte [movimientos_oficial1]        ; Incrementar el contador de movimientos del oficial 1

    ; Comprobar si hubo captura
    mov rax, rcx
    imul rax, rax, 7                       ; Multiplicar por el número de columnas (7)
    add rax, r8
    mov rbx, [rdi + rax]                   ; Cargar el valor de la celda destino
    cmp rbx, 'X'
    jne .no_captura                        ; Si no hay captura

    inc byte [capturas_oficial1]           ; Incrementar contador de capturas del oficial 1
    jmp .finalizar

.check_oficial_2:
    ; Comparar posición inicial con pos_oficial_2
    mov rax, [pos_oficial_2]              ; Cargar la fila del oficial 2
    cmp rsi, rax                           ; Comparar fila inicial con fila oficial 2
    jne .finalizar                         ; Si no es oficial 2, terminar
    mov rax, [pos_oficial_2+1]             ; Cargar la columna del oficial 2
    cmp rdx, rax                           ; Comparar columna inicial con columna oficial 2
    jne .finalizar                         ; Si no es oficial 2, terminar

    ; Actualizar posición del Oficial 2
    mov [pos_oficial_2], rcx               ; Establecer nueva fila
    mov [pos_oficial_2+1], r8              ; Establecer nueva columna

    ; Lógica para registrar el movimiento del oficial 2
    inc byte [movimientos_oficial2]        ; Incrementar el contador de movimientos del oficial 2

    ; Comprobar si hubo captura
    mov rax, rcx
    imul rax, rax, 7                       ; Multiplicar por el número de columnas (7)
    add rax, r8
    mov rbx, [rdi + rax]                   ; Cargar el valor de la celda destino
    cmp rbx, 'X'
    jne .no_captura_2                      ; Si no hay captura

    inc byte [capturas_oficial2]           ; Incrementar contador de capturas del oficial 2

.no_captura:
.no_captura_2:
.finalizar:
    ret


; Función para mostrar estadísticas
mostrar_estadisticas:
    ; Mostrar mensaje "Estadísticas del juego:"
    mov rdi, mensaje_estadisticas
    call imprimir_cadena

    ; Mostrar estadísticas del Oficial 1
    mov rdi, mensaje_oficial_1
    call imprimir_cadena
    ; Aquí imprimiríamos el número de movimientos y capturas para Oficial 1
    ; Imprimir "Movimientos: X, Capturas: Y" para Oficial 1
    mov rdi, movimientos_oficial1
    call imprimir_cadena

    ; Mostrar estadísticas del Oficial 2
    mov rdi, mensaje_oficial_2
    call imprimir_cadena
    ; Aquí imprimiríamos el número de movimientos y capturas para Oficial 2
    ; Imprimir "Movimientos: X, Capturas: Y" para Oficial 2
    mov rdi, movimientos_oficial2
    call imprimir_cadena

    ret

; Función para imprimir una cadena
imprimir_cadena:
    ; rdi = puntero a la cadena (argumento de la función)
    ; Usamos la syscall para escribir en la salida estándar (stdout)
    mov rax, 0x1         
    mov rdi, 0x1         
    mov rsi, rdi          ; rsi = puntero a la cadena
    mov rdx, 100          ; longitud de la cadena 
    syscall
    ret



    ; parámetros:
    ; - rdi: número de fila anterior
    ; - rsi: número de columna anterior
    ; - rdx: número de fila nueva
    ; - rcx: número de columna nueva
    ;
    ; retorna:
    ; - rax: la distancia entre la fila anterior y la nueva
    ; - rbx: la distancia entre la columna anterior y la nueva
    ;
    ; * ambas distancias son valores absolutos
    ;
calcular_distancia_entre_celdas:
    ; distancia entre filas
    mov rax, rdx
    sub rax, rdi
    test rax, rax
    jge .columna_absoluta
    neg rax

    ; distancia entre columnas
    .columna_absoluta:
    mov rbx, rcx
    sub rbx, rsi
    test rbx, rbx
    jge .finalizar
    neg rbx

    .finalizar:
    ret
