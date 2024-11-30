    global main

    extern fclose
    extern fflush
    extern fopen
    extern fread
    extern fwrite
    extern printf
    extern remove
    extern scanf

    extern array_movimientos_posibles
    extern cargar_movimientos_oficial
    extern cargar_movimientos_soldado
    extern efectuar_movimiento_oficial
    extern efectuar_movimiento_soldado
    extern juego_terminado
    extern mostrar_estadisticas
    extern pos_oficial_1
    extern buffer_posicion_fortaleza
    extern seleccionar_celda
    extern seleccionar_proxima_celda
    extern tablero
    extern tablero_actualizar
    extern tablero_finalizar
    extern tablero_inicializar
    extern tablero_renderizar
    extern tablero_rotar_90

    %macro MENSAJE_RESALTADO 1
    db 10,0x1b,"[38;5;231;48;5;9m",%1,0x1b,"[0m",10,0
    %endmacro

    %macro MENSAJE_ERROR 1
    db 10,0x1b,"[38;5;231;48;5;31m",%1,0x1b,"[0m",10,0
    %endmacro

    %macro MENSAJE_PREGUNTA_INICIO 1
    db 10,0x1b,"[38;5;231;48;5;22m",%1,0x1b,"[0m",10,0
    %endmacro

    section .data

    msg_titulo db 10,0x1b,"[2J",0x1b,"[H"
    db "███████╗██╗        █████╗ ███████╗ █████╗ ██╗  ████████╗ ██████╗ ",10
    db "██╔════╝██║       ██╔══██╗██╔════╝██╔══██╗██║  ╚══██╔══╝██╔═══██╗",10
    db "█████╗  ██║       ███████║███████╗███████║██║     ██║   ██║   ██║",10
    db "██╔══╝  ██║       ██╔══██║╚════██║██╔══██║██║     ██║   ██║   ██║",10
    db "███████╗███████╗  ██║  ██║███████║██║  ██║███████╗██║   ╚██████╔╝",10
    db "╚══════╝╚══════╝  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝    ╚═════╝ ",10,0

    msg_continuar_partida_anterior db 10,"¿Continuar partida anterior? [Y/n]: ",0
    msg_personalizacion MENSAJE_RESALTADO " Personalizá tu partida "

    msg_elegir_primer_jugador db 10,0x1b,"[1m"," • ¿Quién mueve primero? [ 1 oficiales | 2 soldados ]: ",0x1b,"[0m",0
    msg_elegir_si_rotar_tablero db 10,0x1b,"[1m"," • ¿Desea rotar el tablero? [Y/n]: ",0x1b,"[0m",0
    msg_elegir_posicion_fortaleza db 10,0x1b,"[1m"," • ¿En qué posición querés ubicar la fortaleza? [ ^ arriba | > derecha | v abajo | < izquierda ]: ",0x1b,"[0m",0

    msg_seleccion_opcion db 10," - Seleccione una opción: ",0
    msg_err_seleccion MENSAJE_ERROR " Opción seleccionada no es válida "

    msg_turno_soldado MENSAJE_RESALTADO " Turno de los soldados "
    msg_turno_oficial MENSAJE_RESALTADO " Turno de los oficiales "
    msg_err_celda_invalida MENSAJE_ERROR " Celda ingresada es inválida - Vuelva a ingresar "
    msg_err_sin_movimientos MENSAJE_ERROR " Ficha seleccionada no tiene movimientos posibles - Elija otra ficha "
    msg_oficial_capturado MENSAJE_RESALTADO " ¡Oficial omitió su captura! "
    msg_continuar_partida_actual db 10,"¿Continuar en el juego? [Y/n]: ",0

    msg_ganador_soldados_fortaleza_llena MENSAJE_RESALTADO " ¡Soldados ganan! (Fortaleza capturada) "
    msg_ganador_soldados_oficiales_rodeados MENSAJE_RESALTADO " ¡Soldados ganan! (Oficiales inmobilizados) "
    msg_ganador_oficiales MENSAJE_RESALTADO " ¡Oficiales ganan! (Soldados diezmados) "
    msg_estadisticas MENSAJE_RESALTADO " Estadísticas del juego "

    ansi_limpiar_pantalla db 0x1b,"[2J",0x1b,"[H",0

    input_cargar_partida_guardada db " %c",0
    input_elegir_primer_jugador db " %c",0
    input_elegir_simbolo db " %c", 0
    input_elegir_rotar_tablero db " %c",0
    input_elegir_posicion_fortaleza db " %c",0
    input_continuar_partida_actual db " %c",0

    path_archivo_partida db "partida.dat",0
    modo_lectura_archivo_partida db "rb",0
    modo_escritura_archivo_partida db "wb+",0

    section .bss

    juego_activo resb 1                   ; bandera para saber si el juego está activo (1 = activo, 0 = terminado)
    es_turno_soldado resb 1               ; bandera para alternar turnos (1 = soldado, 0 = oficial)

    buffer_cargar_partida resb 1           ; guardar el valor de la respuesta de la carga de partida anterior
    buffer_elegir_primer_jugador resb 1    ; guarda el valor de la respuesta de que jugador empieza
    buffer_simbolo_oficiales resb 1        ; guarda el icono de los oficiales
    buffer_simbolo_soldados resb 1         ; guarda el icono de los soldados
    buffer_continuar_partida_actual resb 1 ; guarda el valor de la respuesta a si se desea continuar la partida actual o salir del juego
    buffer_celda_seleccionada resb 1       ; guarda la celda seleccionada en un turno
    buffer_prox_celda_seleccionada resb 1  ; guarda la celda a la que se va a mover el jugador del turno
    buffer_elegir_si_rotar resb 1          ; guarda el valor de la respuesta a si se desea rotar el tablero

    file_desc_archivo_partida resq 1      ; file descriptor archivo partida

    section .text

main:
    mov byte [juego_activo], 1 ; iniciamos el juego

    mov rdi, msg_titulo
    sub rsp, 8
    call printf
    add rsp, 8

    call partida_inicializar
    call tablero_inicializar

    .game_loop: ; <===== inicio de un turno
    ; limpiamos la pantalla en cada render
    mov rdi, ansi_limpiar_pantalla
    sub rsp, 8
    call printf
    add rsp, 8

    ; renderizamos el tablero sin selecciones
    mov rdi, 0
    call tablero_renderizar

    .inicio_ejecucion_turno: ; <====== acá se regresa en caso de input de celda inválida
    call mostrar_msg_turno
    call seleccionar_celda

    mov byte [buffer_celda_seleccionada], al ; guardamos la celda actual para `.efectuar_movimiento`

    mov rdi, rax
    call validar_celda_seleccionada ; valida = 1, invalida = 0
    cmp rax, 1
    je .celda_valida

    .celda_invalida:
    sub rsp, 8
    mov rdi, msg_err_celda_invalida
    call printf
    add rsp, 8

    jmp .inicio_ejecucion_turno

    .celda_valida:
    ; ya tengo rdi = rax = celda seleccionada
    cmp byte [es_turno_soldado], 1
    jne .cargar_movimientos_oficial

    .cargar_movimientos_soldado:
    call cargar_movimientos_soldado
    jmp .validar_ficha_tiene_movimientos

    .cargar_movimientos_oficial:
    call cargar_movimientos_oficial

    .validar_ficha_tiene_movimientos:
    ; si el primer byte del arreglo de movimientos posibles es 0, entonces la
    ; ficha no tiene movimientos posibles
    ;
    cmp byte [array_movimientos_posibles], 0
    jne .seleccionar_prox_celda

    .ficha_no_tiene_movimientos:
    mov rdi, msg_err_sin_movimientos
    sub rsp, 8
    call printf
    add rsp, 8

    jmp .inicio_ejecucion_turno ; volvemos por input inválida

    ; se selecciona a dónde se va a mover la ficha
    .seleccionar_prox_celda:
    mov rdi, 1
    call tablero_actualizar
    call seleccionar_proxima_celda

    mov byte [buffer_prox_celda_seleccionada], al ; guardamos la celda actual para `.efectuar_movimiento`

    mov rdi, rax
    call validar_prox_celda_seleccionada ; valida = 1, invalida = 0
    cmp rax, 1
    je .efectuar_movimiento

    .efectuar_movimiento:
    movzx rdi, byte [buffer_celda_seleccionada]
    movzx rsi, byte [buffer_prox_celda_seleccionada]

    cmp byte [es_turno_soldado], 1
    jne .mover_oficial

    .mover_soldado:
    call efectuar_movimiento_soldado
    jmp .verificar_estado_juego

    .mover_oficial:
    call efectuar_movimiento_oficial ; retorna rax = 1 si se removió al oficial del tablero (0 si no)
    cmp rax, 1
    jne .verificar_estado_juego

    mov rdi, msg_oficial_capturado
    sub rsp, 8
    call printf
    add rsp, 8

    ; ya cuando efectuamos el turno:
    .verificar_estado_juego:

    ; mostramos el tablero actualizado despues el movimiento
    mov rdi, 0
    call tablero_actualizar

    ; verificamos si el juego ha terminado
    call juego_terminado
    ;
    ; 0 si el juego sigue en curso
    ; 1 si ganaron los soldados llenando la fortaleza
    ; 2 si ganaron los soldados rodeando a los oficiales
    ; 3 si ganaron los oficiales
    ;
    cmp rax, 0 ; juego sigue en curso
    jne .finalizar_juego_ganado

    .continuar_juego:
    ; cambiar de turno y continuar el juego
    mov al, byte [es_turno_soldado]
    xor al, 1
    mov [es_turno_soldado], al

    call mostrar_msg_continuar_partida_actual

    cmp byte [buffer_continuar_partida_actual], "n"
    je .interrumpir_juego ; el usuario explícitamente quiere salir del juego

    jmp .game_loop ; avanzamos al siguiente turno (acá el juego sigue en curso)

    .finalizar_juego_ganado:
    cmp rax, 1 ; ganaron los soldados llenando la fortaleza
    jne .ganador_soldados_oficiales_rodeados
    mov rdi, msg_ganador_soldados_fortaleza_llena
    jmp .mostrar_ganador

    .ganador_soldados_oficiales_rodeados:
    cmp rax, 2 ; ganaron los soldados rodeando a los oficiales
    jne .mostrar_ganador_oficiales
    mov rdi, msg_ganador_soldados_oficiales_rodeados
    jmp .mostrar_ganador

    .mostrar_ganador_oficiales:
    mov rdi, msg_ganador_oficiales

    .mostrar_ganador:
    sub rsp, 8
    call printf
    add rsp, 8

    ; eliminamos el archivo de la partida en progreso si hay alguna, ya que la
    ; partida se terminó
    mov rdi, path_archivo_partida
    sub rsp, 8
    call remove
    add rsp, 8
    jmp .finalizar

    .interrumpir_juego:
    call guardar_partida

    .finalizar:
    call tablero_finalizar

    mov rdi, msg_estadisticas
    sub rsp, 8
    call printf
    add rsp, 8

    call mostrar_estadisticas

    ; exit syscall
    mov rax,60
    mov rdi,0
    syscall

    ; parámetros:
    ; - rdi: índice de la celda seleccionada
    ;
    ; retorna:
    ; - rax: 1 si la celda seleccionada es válida. (esta validación solo implica que
    ;   haya una ficha que pueda ser jugada por el turno actual en la celda
    ;   seleccionada, luego se deben hacer otras validaciones de ser necesarias, por
    ;   ejemplo, para ver si la ficha seleccionada tiene movimientos disponibles).
    ;
validar_celda_seleccionada:
    cmp byte [es_turno_soldado], 1
    jne .validar_celda_es_oficial

    .validar_celda_es_soldado:
    cmp byte [tablero + rdi], "X"
    jmp .validar

    .validar_celda_es_oficial:
    cmp byte [tablero + rdi], "O"

    .validar:
    jne .celda_invalida

    .celda_valida:
    mov rax, 1
    jmp .finalizar

    .celda_invalida:
    mov rax, 0

    .finalizar:
    ret

    ; descripción:
validar_prox_celda_seleccionada:
    ret

    ; descripción:
    ; muestra el mensaje de inicio de turno correspondiente a quien está
    ; ejecutando el turno actualmente
    ;
mostrar_msg_turno:
    cmp byte [es_turno_soldado], 1
    jne .msg_turno_oficiales
    mov rdi, msg_turno_soldado
    jmp .mostrar_msg_turno

    .msg_turno_oficiales:
    mov rdi, msg_turno_oficial

    .mostrar_msg_turno:
    call printf

    ret

    ; descripción:
    ; imprime el mensaje para salir del juego y pide la respuesta al usuario
    ; para almacenarla en `buffer_continuar_partida_actual`
    ;
mostrar_msg_continuar_partida_actual:
    mov rdi, msg_continuar_partida_actual
    call printf

    mov rdi, 0
    call fflush

    mov rdi, input_continuar_partida_actual
    mov rsi, buffer_continuar_partida_actual
    call scanf

    ret

partida_inicializar:
    mov rdi, path_archivo_partida
    mov rsi, modo_lectura_archivo_partida
    call fopen

    cmp rax, 0 ; en este caso no se abrió el archivo
    je .nueva_partida

    ; si encontre un archivo, me guardo el file descriptor, aunque puede ser
    ; que el usuario decida no cargar la partida anterior
    ;
    mov [file_desc_archivo_partida], rax

    mov rdi, msg_continuar_partida_anterior
    call printf

    mov rdi, 0
    call fflush

    mov rdi, input_cargar_partida_guardada
    mov rsi, buffer_cargar_partida
    call scanf

    cmp byte [buffer_cargar_partida], "n"
    je .nueva_partida

    .cargar_partida_anterior:
    ; leemos quien tiene el proximo turno
    mov rdi, es_turno_soldado
    mov rsi, 1
    mov rdx, 1
    mov rcx, [file_desc_archivo_partida]
    call fread

    ; leemos las fichas del tablero
    mov rdi, tablero
    mov rsi, 1
    mov rdx, 49
    mov rcx, [file_desc_archivo_partida]
    call fread

    ; leemos las estadisticas de los oficiales
    mov rdi, pos_oficial_1
    mov rsi, 1
    mov rdx, 38
    mov rcx, [file_desc_archivo_partida]
    call fread

    ret

    .nueva_partida:
    ; eliminamos el archivo de partida anterior
    ; TODO: en este caso deberiamos iniciar con los valores por defecto? Si,
    ; pero no hay necesidad de generarlos dinamicamente aca o si? Probablemente
    ; si, en funcion de la customizacion que se elija
    mov rdi, path_archivo_partida
    call remove

    ; iniciamos la personalizacion de la nueva partida
    mov rdi, msg_personalizacion
    call printf

    sub rsp, 8
    call elegir_primer_jugador
    call elegir_simbolos
    call elegir_orientacion_tablero
    add rsp, 8

    ret

elegir_primer_jugador:
    mov rdi, msg_elegir_primer_jugador
    call printf

    mov rdi, input_elegir_primer_jugador
    mov rsi, buffer_elegir_primer_jugador
    call scanf

    cmp byte [buffer_elegir_primer_jugador], "1"
    je .empiezan_los_oficiales
    cmp byte [buffer_elegir_primer_jugador], "2"
    je .empiezan_los_soldados

    mov rdi, msg_err_seleccion
    call printf
    jmp elegir_primer_jugador

    .empiezan_los_soldados:
    mov byte [es_turno_soldado], 1
    ret

    .empiezan_los_oficiales:
    mov byte [es_turno_soldado], 0
    ret

elegir_simbolos:
    ; mov rdi, msg_elegir_simbolos_oficiales
    ; call printf

    ; mov rdi, input_elegir_simbolo
    ; mov rsi, buffer_simbolo_oficiales
    ; call scanf

    ; mov rdi, msg_elegir_simbolos_soldados
    ; call printf

    ; mov rdi, input_elegir_simbolo
    ; mov rsi, buffer_simbolo_soldados
    ; call scanf

    ret

; elegir_posicion_fortaleza:
;     mov rdi, msg_elegir_posicion_fortaleza
;     call printf
; 
;     mov rdi, input_elegir_posicion_fortaleza
;     mov rsi, posicion_fortaleza
;     call scanf
; 
;     cmp byte [buffer_posicion_fortaleza], "^"
;     je .finalizar
;     cmp byte [buffer_posicion_fortaleza], "v"
;     je .finalizar
; 
;     mov rdi, msg_err_seleccion
;     call printf
;     jmp elegir_posicion_fortaleza
; 
;     .finalizar:
;     ret

elegir_orientacion_tablero:
    mov rdi, msg_elegir_si_rotar_tablero
    call printf

    ;call flush

    mov rdi, input_elegir_primer_jugador
    mov rsi, buffer_elegir_si_rotar
    call scanf

    cmp byte[buffer_elegir_si_rotar], "n"
    je .finalizar

    .preguntar_posicion:
    mov rdi, msg_elegir_posicion_fortaleza
    call printf

    lea rdi, input_elegir_posicion_fortaleza
    lea rsi, buffer_posicion_fortaleza
    call scanf

    cmp byte [buffer_posicion_fortaleza], "^"
    je .posicionar_arriba
    cmp byte [buffer_posicion_fortaleza], ">"
    je .posicionar_derecha
    cmp byte [buffer_posicion_fortaleza], "v"
    je .posicionar_abajo
    cmp byte [buffer_posicion_fortaleza], "<"
    je .posicionar_izquierda

    ; si llegue aqui es porque ninguna de las opciones es valida
    mov rdi, msg_err_seleccion
    call printf
    jmp .preguntar_posicion

    .posicionar_arriba:
    ; call tablero_rotar_90
    ; mov rdi, 0
    jmp .finalizar

    .posicionar_derecha:
    ; call tablero_rotar_90
    ; call tablero_rotar_90
    ; call tablero_rotar_90
    ; mov rdi, 0
    jmp .finalizar

    .posicionar_abajo:
    ; call tablero_rotar_90
    ; call tablero_rotar_90
    ; mov rdi, 0
    jmp .finalizar

    .posicionar_izquierda:
    jmp .finalizar

    .finalizar:
    ; no hay necesidad de llamar a tablero_actualizar, porque igual esto se
    ; configura antes de que el tablero se inicialice, entonces el tablero
    ; siempre va a arrancar con las posicion elegida

    ret

guardar_partida:
    mov rdi, path_archivo_partida
    mov rsi, modo_escritura_archivo_partida
    call fopen
    mov [file_desc_archivo_partida], rax

    ; guardado de quien tiene el proximo turno
    mov rdi, es_turno_soldado ; ya en este momento se cambió al siguiente
    mov rsi, 1
    mov rdx, 1
    mov rcx, [file_desc_archivo_partida]
    call fwrite

    ; guardado de la ubicacion de la fortaleza
    mov rdi, buffer_posicion_fortaleza
    mov rsi, 1
    mov rdx, 1
    mov rcx, [file_desc_archivo_partida]
    call fwrite

    ; guardado de las fichas del tablero
    mov rdi, tablero
    mov rsi, 1
    mov rdx, 49
    mov rcx, [file_desc_archivo_partida]
    call fwrite

    ; guardado de las estadisticas de los oficiales
    mov rdi, pos_oficial_1
    mov rsi, 1
    mov rdx, 38
    mov rcx, [file_desc_archivo_partida]
    call fwrite

    mov rdi, [file_desc_archivo_partida]
    call fclose

    ret
