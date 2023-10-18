; Este programa es un juego simple en lenguaje ensamblador que representa un juego del gato.
; Instituto Tecnologico de Costa Rica
; Estudiantes: Alice Arias y Gilberth Aguilar
; Curso: Fundamentos de organizacion de computadoras
; Fecha: Octubre del 2023   

; ---------------------------------
; Encabezados y definiciones
; ---------------------------------

extra segment                 ; Segmento extra (vacio)
ends   

data segment
    nueva_linea db 13, 10, "$"       ; Nueva linea en formato DOS

    dibujo_juego db "_|_|_", 13, 10  ; Dibujo del juego (tablero)
                 db "_|_|_", 13, 10
                 db "_|_|_", 13, 10, "$"

    puntero_juego db 9 DUP(?)        ; Puntero al juego

    bandera_victoria db 0            ; Bandera de victoria (0 si no ha ganado)
    jugador db "0$"                  ; Jugador actual

    mensaje_fin_juego db "           Fin del juego   ", 13, 10, "$"                            ; Mensaje de fin de juego
    mensaje_inicio_juego db "                          Bienvenidos al juego del bingo", 13, 10, "$"  ; Mensaje de inicio de juego
    mensaje_jugador db 13, 10,"          Jugador $", 13, 10                                          ; Mensaje de jugador actual
    mensaje_victoria db 13, 10,"   Felicidades has ganado!$", 13, 10                                 ; Mensaje de victoria
    mensaje_posicion db "Escribe una posicion en la que deseas jugar: $"                             ; Mensaje para pedir una posicion
    movimientos db 0                                                                                 ; Contador de movimientos
    mensaje_empate db "  Empate. Nadie ha ganado el juego.", 13, 10, "$"                             ; Mensaje de empate  
    mensaje_posicion_ocupada db 13, 10,13, 10,"Posicion ocupada. Intentalo nuevamente.", 13, 10, "$"
ends

code segment  
      
inicio:                       ; Establecer registros de segmento
    mov ax, data              ; Cargar el registro de datos en AX
    mov ds, ax                ; Asignar el valor de AX al registro de segmento de datos
    mov ax, extra             ; Cargar el registro extra en AX
    mov es, ax                ; Asignar el valor de AX al registro de segmento extra 
    ;--------------------
    ; Iniciar el juego 
    ;--------------------
    call establecer_puntero_juego ; Llamar a la funcion para establecer el puntero del juego

bucle_principal:
    call limpiar_pantalla             ; Llama a la funcion para limpiar la pantalla
    lea dx, mensaje_inicio_juego      ; Carga el mensaje de inicio del juego en DX
    call imprimir                     ; Llama a la funcion para imprimir el mensaje
    lea dx, nueva_linea               ; Carga una nueva linea en DX
    call imprimir                     ; Llama a la funcion para imprimir una nueva linea
    lea dx, mensaje_jugador           ; Carga el mensaje del jugador actual en DX
    call imprimir                     ; Llama a la funcion para imprimir el mensaje
    lea dx, jugador                   ; Carga el numero de jugador en DX
    call imprimir                     ; Llama a la funcion para imprimir el numero de jugador
    lea dx, nueva_linea               ; Carga una nueva linea en DX
    call imprimir                     ; Llama a la funcion para imprimir una nueva linea
    lea dx, dibujo_juego              ; Carga el dibujo del juego (tablero) en DX
    call imprimir                     ; Llama a la funcion para imprimir el dibujo
    lea dx, nueva_linea               ; Carga una nueva linea en DX
    call imprimir                     ; Llama a la funcion para imprimir una nueva linea
    lea dx, mensaje_posicion          ; Carga el mensaje para pedir una posicion en DX
    call imprimir                     ; Llama a la funcion para imprimir el mensaje
    ;------------------------------
    ; Lee la posicion de dibujo 
    ;------------------------------
    call leer_teclado                 ; Llama a la funcion para leer la posicion desde el teclado
    ;-------------------------------
    ; Calcula la posicion de dibujo 
    ;-------------------------------
    sub al, 49                        ; Resta 49 al valor ASCII para obtener el indice numérico
    mov bh, 0                         ; Borra BH
    mov bl, al                        ; Mueve el indice a BL
    call actualizar_dibujo            ; Llama a la funcion para actualizar el dibujo en la posición
    ;-----------------------------
    ; Verifica si hay un ganador 
    ;-----------------------------
    call verificar                    ; Llama a la funcion para verificar si hay un ganador
    ;------------------------------------
    ; Comprueba si el juego ha terminado                           
    ;------------------------------------
    cmp bandera_victoria, 1           ; Compara la bandera de victoria con 1
    je fin_del_juego                  ; Salta al final del juego si hay un ganador
    ;------------------------------------
    ; Aumenta el contador de movimientos 
    ;-------------------------------------
    inc movimientos                   ; Incrementa el contador de movimientos
    ;--------------------------------------------------------------------------------
    ; Si se alcanzan los 9 movimientos (tablero lleno), muestra un mensaje de empate 
    ;--------------------------------------------------------------------------------
    cmp movimientos, 9                ; Compara el contador de movimientos con 9
    je empate                         ; Salta a la etiqueta "empate" si son iguales
    ;--------------------
    ; Cambiar de jugador  
    ;--------------------
    call cambiar_jugador              ; Llama a la funcion para cambiar al siguiente jugador
    jmp bucle_principal               ; Salta de nuevo al bucle principal

;---------------------
;   Filas(lineas)
;---------------------
primera_linea:                       ; Etiqueta para comprobar la primera linea
    mov si, 0                        ; Establece el indice para la primera linea
    jmp comprobar_linea              ; Salta a la comprobacion de linea

segunda_linea:                       ; Etiqueta para comprobar la segunda linea
    mov si, 3                        ; Establece el indice para la segunda linea
    jmp comprobar_linea              ; Salta a la comprobacion de linea

tercera_linea:                       ; Etiqueta para comprobar la tercera linea
    mov si, 6                        ; Establece el indice para la tercera linea
    jmp comprobar_linea              ; Salta a la comprobacion de linea 
    
;---------------------
;  Columnas(columna)
;---------------------
primera_columna:
    mov si, 0                     ; Establece el indice para la primera columna
    jmp comprobar_columna         ; Salta a la comprobacion de columna

segunda_columna:
    mov si, 1                     ; Establece el indice para la segunda columna
    jmp comprobar_columna         ; Salta a la comprobacion de columna

tercera_columna:
    mov si, 2                     ; Establece el indice para la tercera columna
    jmp comprobar_columna         ; Salta a la comprobacion de columna 
    
; ---------------------------------
; Funciones auxiliares
; ---------------------------------
    
cambiar_jugador:
    lea si, jugador                   ; Carga la direccion de la variable jugador
    xor ds:[si], 1                    ; Realiza una operacion XOR para cambiar el jugador entre 0 y 1
    ret                               ; Retorna de la funcion

;------------------------------
;        Actualizaciones
;------------------------------    
actualizar_dibujo:
    mov bl, puntero_juego[bx]         ; Obtiene la posicion del juego
    mov bh, 0                         ; Borra el registro BH
    mov al, ds:[bx]                   ; Obtiene el valor en la posicion
    cmp al, "_"                       ; Comprueba si la posicion esta vacia
    jne posicion_ocupada              ; Salta a la etiqueta "posicion_ocupada" si la posicion esta ocupada
    lea si, jugador                   ; Carga la direccion de la variable "jugador"
    cmp ds:[si], "1"                  ; Comprueba si el jugador actual es 0
    je dibujar_x                      ; Salta a "dibujar_x" para dibujar una "x"
    cmp ds:[si], "0"                  ; Comprueba si el jugador actual es 1
    je dibujar_o                      ; Salta a "dibujar_o" para dibujar una "o" 
    
actualizar:                          ; Actualizar la posicion con "x" u "o"
    mov ds:[bx], cl                  ; Actualiza la posicion con el valor en el registro CL (que es "x" u "o")
    ret                              ; Retorna al punto de llamada  

;---------------------
;  Dibujar x y o
;---------------------
dibujar_x:                          
    mov cl, "x"                     ; Carga el valor "x" en el registro CL (caracter para dibujar "x")
    jmp actualizar                  ; Salta a la etiqueta "actualizar"

dibujar_o:                          
    mov cl, "o"                     ; Carga el valor "o" en el registro CL (caracter para dibujar "o")
    jmp actualizar                  ; Salta a la etiqueta "actualizar" 

;-----------------------------------
; Diagonal desendence y ascendente   
;-----------------------------------

primera_diagonal_descendente:
    mov si, 0                         ; Establece el indice
    mov dx, 4                         ; Tamano del salto
    jmp comprobar_diagonal_descendente; Salta a la comprobacion de diagonal descendente

segunda_diagonal_descendente:
    mov si, 2                         ; Establece el indice
    mov dx, 2                         ; Tamaño del salto
    jmp comprobar_diagonal_descendente; Salta a la comprobacion de diagonal descendente  
    
primera_diagonal_ascendente:           ; La primera diagonal ascendente
    mov si, 0                          ; Establece el indice para la primera diagonal ascendente
    mov dx, 4                          ; Tamaño del salto
    jmp comprobar_diagonal_ascendente  ; Salta a la comprobacion de diagonal ascendente

segunda_diagonal_ascendente:           ; La segunda diagonal ascendente
    mov si, 2                          ; Establece el indice para la segunda diagonal ascendente
    mov dx, 2                          ; Tamaño del salto
    jmp comprobar_diagonal_ascendente  ; Salta a la comprobacion de diagonal ascendente

;-------------------------------
;      Verificar Linea
;-------------------------------  

verificar:                           
    call verificar_linea             ; Llama a la subrutina para verificar si hay una linea completa
    ret                              ; Retorna al punto de llamada 
    
verificar_linea:                     ; Etiqueta para verificar una linea
    mov cx, 0                        ; Inicializa el contador

bucle_verificar_linea:               
    cmp cx, 0                        ; Comprueba si el contador es igual a 0
    je primera_linea                 ; Salta a comprobar la primera linea si es igual a 0
    cmp cx, 1                        ; Comprueba si el contador es igual a 1
    je segunda_linea                 ; Salta a comprobar la segunda linea si es igual a 1
    cmp cx, 2                        ; Comprueba si el contador es igual a 2
    je tercera_linea                 ; Salta a comprobar la tercera linea si es igual a 2
    call verificar_columna           ; Llama a la subrutina para comprobar si hay una columna completa
    ret                              ; Retorna al punto de llamada

comprobar_linea:                  
    inc cx                          ; Incrementa el contador de lineas
    mov bh, 0                       ; Borra el registro BH
    mov bl, puntero_juego[si]       ; Obtiene la posicion de la linea
    mov al, ds:[bx]                 ; Obtiene el valor en la posicion
    cmp al, "_"                     ; Comprueba si la posicion está vacia
    je bucle_verificar_linea        ; Salta si la posicion está vacia
    inc si                          ; Avanza al siguiente indice
    mov bl, puntero_juego[si]       ; Obtiene la siguiente posicion
    cmp al, ds:[bx]                 ; Compara el valor con el siguiente
    jne bucle_verificar_linea       ; Salta si no son iguales
    inc si                          ; Avanza al siguiente indice
    mov bl, puntero_juego[si]       ; Obtiene la siguiente posicion
    cmp al, ds:[bx]                 ; Compara el valor con el siguiente
    jne bucle_verificar_linea       ; Salta si no son iguales
    mov bandera_victoria, 1         ; Establece la bandera de victoria
    ret                             ; Retorna al punto de llamada    
    
;------------------------------
;    Verificar Columna
;------------------------------
verificar_columna:                ; Verificar si hay una columna completa
    mov cx, 0                     ; Inicializa el contador

bucle_verificar_columna:
    cmp cx, 0
    je primera_columna            ; Salta a comprobar la primera columna
    cmp cx, 1
    je segunda_columna            ; Salta a comprobar la segunda columna
    cmp cx, 2
    je tercera_columna            ; Salta a comprobar la tercera columna
    call verificar_diagonal       ; Comprueba si hay una diagonal completa
    ret

comprobar_columna:                ; Comprobar si hay una columna completa
    inc cx                        ; Incrementa el contador de columnas
    mov bh, 0                     ; Borra el registro BH
    mov bl, puntero_juego[si]     ; Obtiene la posicion de la columna
    mov al, ds:[bx]               ; Obtiene el valor en la posicion
    cmp al, "_"                   ; Comprueba si la posicion está vacia
    je bucle_verificar_columna    ; Salta si la posicion esta vacia
    add si, 3                     ; Avanza al siguiente indice en la misma columna
    mov bl, puntero_juego[si]     ; Obtiene la siguiente posicion
    cmp al, ds:[bx]               ; Compara el valor con el siguiente
    jne bucle_verificar_columna   ; Salta si no son iguales
    add si, 3                     ; Avanza al siguiente indice en la misma columna
    mov bl, puntero_juego[si]     ; Obtiene la siguiente posicion
    cmp al, ds:[bx]               ; Compara el valor con el siguiente
    jne bucle_verificar_columna   ; Salta si no son iguales
    mov bandera_victoria, 1       ; Establece la bandera de victoria
    ret
;----------------------
;  Verificacion
;----------------------
verificar_diagonal:
    call verificar_diagonal_ascendente    ; Comprueba la diagonal ascendente
    call verificar_diagonal_descendente   ; Comprueba la diagonal descendente
    ret
;------------------------------
;     Diagonal Ascendente
;----------------------------
verificar_diagonal_ascendente:
    mov cx, 0                             ; Inicializa el contador

bucle_verificar_diagonal_ascendente:   ; Verificar la diagonal ascendente
    cmp cx, 0                          ; Comprueba el contador de diagonal
    je primera_diagonal_ascendente     ; Salta a comprobar la primera diagonal ascendente
    cmp cx, 1                          ; Comprueba el contador de diagonal
    je segunda_diagonal_ascendente     ; Salta a comprobar la segunda diagonal ascendente
    ret

comprobar_diagonal_ascendente:                ; Comprobar la diagonal ascendente
    inc cx                                    ; Incrementa el contador de diagonales
    mov bh, 0                                 ; Borra el registro BH
    mov bl, puntero_juego[si]                 ; Obtiene la posicion de la diagonal ascendente
    mov al, ds:[bx]                           ; Obtiene el valor en la posicion
    cmp al, "_"                               ; Comprueba si la posicion esta vacia
    je bucle_verificar_diagonal_ascendente    ; Salta si la posicion esta vacia
    add si, dx                                ; Avanza al siguiente indice en la misma diagonal ascendente
    mov bl, puntero_juego[si]                 ; Obtiene la siguiente posicion
    cmp al, ds:[bx]                           ; Compara el valor con el siguiente
    jne bucle_verificar_diagonal_ascendente   ; Salta si no son iguales
    add si, dx                                ; Avanza al siguiente indice en la misma diagonal ascendente
    mov bl, puntero_juego[si]                 ; Obtiene la siguiente posicion
    cmp al, ds:[bx]                           ; Compara el valor con el siguiente
    jne bucle_verificar_diagonal_ascendente   ; Salta si no son iguales
    mov bandera_victoria, 1                   ; Establece la bandera de victoria
    ret

;----------------------------------------
;        Diagonal Descendente 
;----------------------------------------
verificar_diagonal_descendente:
    mov cx, 0                         ; Inicializa el contador de diagonales

bucle_verificar_diagonal_descendente:
    cmp cx, 0                         ; Comprueba el contador de diagonales
    je primera_diagonal_descendente   ; Salta a comprobar la primera diagonal descendente
    cmp cx, 1                         ; Comprueba el contador de diagonales
    je segunda_diagonal_descendente   ; Salta a comprobar la segunda diagonal descendente
    ret

comprobar_diagonal_descendente:
    inc cx                                    ; Incrementa el contador de diagonales
    mov bh, 0                                 ; Borra el registro BH
    mov bl, puntero_juego[si]                 ; Obtiene la posicion de la diagonal descendente
    mov al, ds:[bx]                           ; Obtiene el valor en la posicion
    cmp al, "_"                               ; Comprueba si la posicion esta vacia
    je bucle_verificar_diagonal_descendente   ; Salta si la posicion esta vacia
    add si, dx                                ; Avanza al siguiente indice en la misma diagonal descendente
    mov bl, puntero_juego[si]                 ; Obtiene la siguiente posicion
    cmp al, ds:[bx]                           ; Compara el valor con el siguiente
    jne bucle_verificar_diagonal_descendente  ; Salta si no son iguales
    add si, dx                                ; Avanza al siguiente indice en la misma diagonal descendente
    mov bl, puntero_juego[si]                 ; Obtiene la siguiente posicion
    cmp al, ds:[bx]                           ; Compara el valor con el siguiente
    jne bucle_verificar_diagonal_descendente  ; Salta si no son iguales
    mov bandera_victoria, 1                   ; Establece la bandera de victoria
    ret

; ---------------------------------
; Manejo de la finalizacion
; ---------------------------------

fin_del_juego:
    call limpiar_pantalla       ; Limpia la pantalla
    lea dx, mensaje_inicio_juego; Muestra el mensaje de inicio
    call imprimir
    lea dx, nueva_linea         ; Nueva linea
    call imprimir
    lea dx, dibujo_juego        ; Muestra el dibujo del juego (tablero)
    call imprimir
    lea dx, nueva_linea         ; Nueva linea
    call imprimir
    lea dx, mensaje_fin_juego   ; Muestra el mensaje de fin de juego
    call imprimir
    lea dx, mensaje_jugador     ; Muestra el mensaje del jugador actual
    call imprimir
    lea dx, jugador             ; Muestra el número de jugador
    call imprimir
    lea dx, mensaje_victoria    ; Muestra el mensaje de victoria
    call imprimir
    jmp fin                 
    
;-----------------------------------------
;  En caso de empate o posicion ocupada   
;-----------------------------------------
empate:
    call limpiar_pantalla             ; Llama a la funcion para limpiar la pantalla
    lea dx, mensaje_inicio_juego      ; Carga el mensaje de inicio del juego en DX
    call imprimir                     ; Llama a la funcion para imprimir el mensaje
    lea dx, nueva_linea               ; Carga una nueva linea en DX
    call imprimir                     ; Llama a la funcion para imprimir una nueva linea
    lea dx, mensaje_empate            ; Carga el mensaje de empate en DX
    call imprimir                     ; Llama a la funcion para imprimir el mensaje
    jmp fin                           ; Salta al final del programa

posicion_ocupada:                     

    lea dx, nueva_linea                 ; Carga la cadena de nueva lInea en DX
    call imprimir                       ; Llama a la funcion para imprimir la nueva linea

    lea dx, mensaje_posicion_ocupada    ; Carga el mensaje de posicion ocupada en DX
    call imprimir                       ; Imprime el mensaje

    lea dx, nueva_linea                 ; Carga la cadena de nueva linea en DX
    call imprimir                       ; Imprime la nueva linea
    ;-------------------------------------------------------
    ; Muestra el mensaje para pedir una posicion nuevamente 
    ;-------------------------------------------------------
    lea dx, mensaje_posicion            ; Carga el mensaje para pedir una posicion en DX
    call imprimir                       ; Imprime el mensaje
    ;-----------------------------------------
    ; Lee la posicion de dibujo nuevamente   
    ;-----------------------------------------
    call leer_teclado                    ; Llama a la funcion para leer la posicion desde el teclado
    sub al, 49                           ; Convierte el valor ASCII en un indice numerico
    mov bh, 0                            ; Borra BH
    mov bl, al                           ; Mueve el indice a BL
    call actualizar_dibujo               ; Llama a la funcion para actualizar el dibujo en la posición
    ret                                  ; Retorna de la funcion "posicion_ocupada" 
    
establecer_puntero_juego:
    lea si, dibujo_juego    ; Carga la direccion del dibujo del juego
    lea bx, puntero_juego   ; Carga la direccion del puntero al juego
    mov cx, 9               ; Inicializa el contador

bucle_1:
    cmp cx, 6            ; Comprueba si el contador llego a 6
    je anadir_1          ; Salta a la etiqueta anadir_1 si es igual a 6
    cmp cx, 3            ; Comprueba si el contador llego a 3
    je anadir_1          ; Salta a la etiqueta anadir_1 si es igual a 3
    jmp anadir_2         ; Salta a la etiqueta anadir_2    

anadir_1:
    add si, 1            ; Avanza en la direccion del dibujo
    jmp anadir_2         ; Salta a la etiqueta anadir_2

anadir_2:
    mov ds:[bx], si      ; Guarda la direccion en el puntero al juego
    add si, 2            ; Avanza en la direccion del dibujo
    inc bx               ; Incrementa el puntero
    loop bucle_1         ; Repite el bucle 1
    ret

imprimir:
    mov ah, 9   ; Funcion para imprimir cadena
    int 21h     ; Interrupcion del DOS para imprimir
    ret

limpiar_pantalla:
    mov ah, 0fh   ; Funcion para obtener el modo de video
    int 10h       ; Interrupcion del BIOS para el video
    mov ah, 0     ; Establece el modo de video en modo texto
    int 10h       ; Interrupcion del BIOS para el video
    ret

leer_teclado:
                                     ; Lee el teclado y devuelve el contenido en ah
    mov ah, 1                        ; Funcion para leer una tecla
    int 21h                          ; Interrupcion del DOS para la entrada
    ret

fin:
    jmp fin                          ; Bucle infinito para mantener el programa en ejecucion

code ends                                  

end inicio