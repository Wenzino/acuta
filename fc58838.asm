; =========================================================
; Projeto ACUtA – UTF8 → ASCII Converter
; fc58838.asm
; =========================================================

global _start

extern readTextFile
extern writeTextFile
extern utoa3

section .bss
    input_buf  resb 2000
    ascii_buf  resb 2000
    count_buf  resb 32

    total_bytes resq 1
    ascii_cnt   resq 1
    utf2_cnt    resq 1
    utf3_cnt    resq 1
    utf4_cnt    resq 1
    
    ; Ponteiros para nomes dos ficheiros
    input_name  resq 1
    count_name  resq 1
    ascii_name  resq 1

section .text

_start:
    ; ----------------------------
    ; Obter argumentos da linha de comando
    ; Stack: [argc][argv[0]][argv[1]][argv[2]][argv[3]][NULL]
    ; ----------------------------
    
    ; Verificar número de argumentos
    mov rax, [rsp]          ; argc
    cmp rax, 4
    jl exit_error
    
    ; Guardar ponteiros para os nomes dos ficheiros
    mov rax, [rsp + 16]     ; argv[1] - input
    mov [input_name], rax
    
    mov rax, [rsp + 24]     ; argv[2] - contagens
    mov [count_name], rax
    
    mov rax, [rsp + 32]     ; argv[3] - ASCII
    mov [ascii_name], rax

    ; ----------------------------
    ; Ler ficheiro de entrada
    ; ----------------------------
    mov rdi, [input_name]
    mov rsi, input_buf
    call readTextFile
    
    ; Verificar se leu bytes
    test rax, rax
    jz exit_error
    
    mov [total_bytes], rax

    ; ============================
    ; FASE 1 – CONTAGENS
    ; ============================
    xor r8, r8              ; índice no buffer

fase1_loop:
    cmp r8, [total_bytes]
    jae fase1_done

    movzx rax, byte [input_buf+r8]

    ; Verificar se é ASCII (bit 7 = 0)
    test al, 0x80
    jz ascii_char

    ; Verificar UTF-2 (110xxxxx)
    mov bl, al
    and bl, 0xE0
    cmp bl, 0xC0
    je utf2_char

    ; Verificar UTF-3 (1110xxxx)
    mov bl, al
    and bl, 0xF0
    cmp bl, 0xE0
    je utf3_char

    ; Verificar UTF-4 (11110xxx)
    mov bl, al
    and bl, 0xF8
    cmp bl, 0xF0
    je utf4_char

    ; Se não corresponde a nenhum, tratar como ASCII
    jmp ascii_char

ascii_char:
    inc qword [ascii_cnt]
    inc r8
    jmp fase1_loop

utf2_char:
    inc qword [utf2_cnt]
    add r8, 2
    jmp fase1_loop

utf3_char:
    inc qword [utf3_cnt]
    add r8, 3
    jmp fase1_loop

utf4_char:
    inc qword [utf4_cnt]
    add r8, 4
    jmp fase1_loop

fase1_done:

    ; ============================
    ; ESCREVER FICHEIRO DE CONTADORES
    ; ============================
    lea rsi, [count_buf]    ; ponteiro inicial

    ; Total de bytes
    mov rdi, [total_bytes]
    call utoa3
    
    ; Contagem ASCII
    lea rsi, [count_buf + 4]
    mov rdi, [ascii_cnt]
    call utoa3

    ; Contagem UTF-2
    lea rsi, [count_buf + 8]
    mov rdi, [utf2_cnt]
    call utoa3

    ; Contagem UTF-3
    lea rsi, [count_buf + 12]
    mov rdi, [utf3_cnt]
    call utoa3

    ; Contagem UTF-4
    lea rsi, [count_buf + 16]
    mov rdi, [utf4_cnt]
    call utoa3

    ; Escrever ficheiro
    mov rdi, [count_name]
    mov rsi, count_buf
    mov rdx, 20
    call writeTextFile

    ; ============================
    ; FASE 2 e 3 – CONVERSÃO ASCII
    ; ============================
    xor r8, r8              ; índice no input_buf
    xor r9, r9              ; índice no ascii_buf

fase3_loop:
    cmp r8, [total_bytes]
    jae fase3_done

    movzx rax, byte [input_buf+r8]

    ; Se for ASCII, copiar diretamente
    test al, 0x80
    jz copy_ascii

    ; Verificar se é caractere português UTF-2 (0xC3)
    cmp al, 0xC3
    je check_c3

    ; Verificar UTF-3
    mov bl, al
    and bl, 0xF0
    cmp bl, 0xE0
    je skip_utf3

    ; Verificar UTF-4
    mov bl, al
    and bl, 0xF8
    cmp bl, 0xF0
    je skip_utf4

    ; UTF-2 não português: saltar
    add r8, 2
    jmp fase3_loop

skip_utf3:
    add r8, 3
    jmp fase3_loop

skip_utf4:
    add r8, 4
    jmp fase3_loop

check_c3:
    ; Verificar se há próximo byte
    mov rax, r8
    inc rax
    cmp rax, [total_bytes]
    jae fase3_done
    
    movzx rbx, byte [input_buf+r8+1]

    ; ===== MAIÚSCULAS =====
    ; À, Á, Â, Ã → A
    cmp bl, 0x80
    je put_A
    cmp bl, 0x81
    je put_A
    cmp bl, 0x82
    je put_A
    cmp bl, 0x83
    je put_A
    
    ; Ç → C
    cmp bl, 0x87
    je put_C
    
    ; É, Ê → E
    cmp bl, 0x89
    je put_E
    cmp bl, 0x8A
    je put_E
    
    ; Í → I
    cmp bl, 0x8D
    je put_I
    
    ; Ó, Ô, Õ, Ö → O
    cmp bl, 0x93
    je put_O
    cmp bl, 0x94
    je put_O
    cmp bl, 0x95
    je put_O
    cmp bl, 0x96
    je put_O
    
    ; Ú, Ü → U
    cmp bl, 0x9A
    je put_U
    cmp bl, 0x9C
    je put_U

    ; ===== MINÚSCULAS =====
    ; à, á, â, ã → a
    cmp bl, 0xA0
    je put_a
    cmp bl, 0xA1
    je put_a
    cmp bl, 0xA2
    je put_a
    cmp bl, 0xA3
    je put_a
    
    ; ç → c
    cmp bl, 0xA7
    je put_c
    
    ; é, ê → e
    cmp bl, 0xA9
    je put_e
    cmp bl, 0xAA
    je put_e
    
    ; í → i
    cmp bl, 0xAD
    je put_i
    
    ; ó, ô, õ, ö → o
    cmp bl, 0xB3
    je put_o
    cmp bl, 0xB4
    je put_o
    cmp bl, 0xB5
    je put_o
    cmp bl, 0xB6
    je put_o
    
    ; ú, ü → u
    cmp bl, 0xBA
    je put_u
    cmp bl, 0xBC
    je put_u

    ; Não é caractere português: saltar
    add r8, 2
    jmp fase3_loop

copy_ascii:
    mov [ascii_buf+r9], al
    inc r9
    inc r8
    jmp fase3_loop

; ===== CONVERSÕES MAIÚSCULAS =====
put_A:
    mov byte [ascii_buf+r9], 'A'
    jmp put_done

put_C:
    mov byte [ascii_buf+r9], 'C'
    jmp put_done

put_E:
    mov byte [ascii_buf+r9], 'E'
    jmp put_done

put_I:
    mov byte [ascii_buf+r9], 'I'
    jmp put_done

put_O:
    mov byte [ascii_buf+r9], 'O'
    jmp put_done

put_U:
    mov byte [ascii_buf+r9], 'U'
    jmp put_done

; ===== CONVERSÕES MINÚSCULAS =====
put_a:
    mov byte [ascii_buf+r9], 'a'
    jmp put_done

put_c:
    mov byte [ascii_buf+r9], 'c'
    jmp put_done

put_e:
    mov byte [ascii_buf+r9], 'e'
    jmp put_done

put_i:
    mov byte [ascii_buf+r9], 'i'
    jmp put_done

put_o:
    mov byte [ascii_buf+r9], 'o'
    jmp put_done

put_u:
    mov byte [ascii_buf+r9], 'u'
    jmp put_done

put_done:
    inc r9
    add r8, 2
    jmp fase3_loop

fase3_done:
    ; Escrever ficheiro ASCII
    mov rdi, [ascii_name]
    mov rsi, ascii_buf
    mov rdx, r9
    call writeTextFile

    ; ============================
    ; TERMINAR PROGRAMA (sucesso)
    ; ============================
    mov rax, 60
    xor rdi, rdi
    syscall

exit_error:
    ; ============================
    ; TERMINAR PROGRAMA (erro)
    ; ============================
    mov rax, 60
    mov rdi, 1
    syscall 