; Gherman Maria Irina @ 324 CB

%include "include/io.inc"

extern atoi
extern printf
extern exit

; Functions to read/free/print the image.
; The image is passed in argv[1].
extern read_image
extern free_image
; void print_image(int* image, int width, int height);
extern print_image

; Get image's width and height.
; Store them in img_[width, height] variables.
extern get_image_width
extern get_image_height

section .data
        use_str db "Use with ./tema2 <task_num> [opt_arg1] [opt_arg2]", 10, 0
        revient db "revient", 0
        message db "C'est un proverbe francais.", 0
        a_morse db ".-", 0
        b_morse db "-...", 0
        c_morse db "-.-.", 0
        d_morse db "-..", 0
        e_morse db ".", 0
        f_morse db "..-.", 0
        g_morse db "--.", 0
        h_morse db "....", 0
        i_morse db "..", 0
        j_morse db ".---", 0
        k_morse db "-.-", 0
        l_morse db ".-..", 0
        m_morse db "--", 0
        n_morse db "-.", 0
        o_morse db "---", 0
        p_morse db ".--.", 0
        q_morse db "--.-", 0
        r_morse db ".-.", 0
        s_morse db "...", 0
        t_morse db "-", 0
        u_morse db "..-", 0
        v_morse db "...-", 0
        w_morse db ".--", 0
        x_morse db "-..-", 0
        y_morse db "-.--", 0
        z_morse db "--..", 0
        comma_morse db "--..--", 0   
            
section .bss
    task:       resd 1
    img:        resd 1
    img_width:  resd 1
    img_height: resd 1

section .text
global main

bruteforce_singlebyte_xor:
    push ebp
    mov ebp, esp
    
    xor esi, esi ; iterator pt 'revient'
    xor ecx, ecx ; key-ul
    xor edx, edx ; variabila pt parcurgerea unei linii
    xor ebx, ebx ; variabila pt pargurgerea coloanelor
    mov ax, 4              ; avem nevoie de limita 
    mul word[img_width]    ; liniei (width * 4)
    mov edi, eax ; edi = width * 4
    mov eax, dword[img] ; adresa imaginii

    jmp check

new_key:
    xor ebx, ebx
    xor edx, edx
    inc cl
    cmp cl, 0
    je end_task1 ; nu mai avem chei de incercat

check:
    mov eax, dword[img]
    add eax, edx ; 4 * current_width
    add eax, ebx ; 4 * current_height
    mov eax, [eax]
    
    xor al, cl
    cmp al, byte[revient + esi]
    jnz reset ; nu am gasit ce trebuie, cautam de la r
    
    add esi, 1 ; trecem la urm litera de cautat
    cmp esi, 7
    jne next ; nu am gasit tot cuvantul

    mov eax, edi
    mov esi, dword[img_height]
    mul esi ; width * 4 * height
    mov esi, eax
    xor edx, edx ; parcurgem linia cu asta
        
    mov eax, dword[img]
    ; edi -> width * 4
    ; esi -> height * width * 4

xor_whole_matrix:
    xor byte[eax + edx], cl
    add edx, 4
    cmp edx, esi ; daca am ajuns la final
    je finish
    jne xor_whole_matrix

finish:
    xor eax, eax
    mov eax, ebx
    xor edx, edx
    div edi
    jmp end_task1
reset:
    xor esi, esi

next:
    add edx, 4 ; urmatorul caracter de comparat
    cmp edx, edi ; am ajuns la sfarsitul liniei
    jne check ; daca nu am ajuns la sf liniei
    
    xor edx, edx
    add ebx, edi
    
    push eax
    mov eax, dword[img_height]
    mul edi
    
    cmp ebx, eax
    pop eax

    jne check ; nu am ajuns la sf imaginii
    jmp new_key
       
end_task1:
    leave
    ret
    

xor_encode:
    push ebp
    mov ebp, esp
    
    call bruteforce_singlebyte_xor
    ; eax -> line
    ; ebx -> eax * width * 4
    ; ecx -> key
    add ecx, ecx ; ecx = ecx * 2
    add ecx, 3 ; 2 * ecx + 3
    ; facem impartirea
    mov eax, ecx
    mov esi, 5
    div esi
    mov ecx, eax ; (2 * ecx + 3) div 5
    sub ecx, 4 ; ecx = floor((2 * ecx + 3) / 5) - 4
    ; adaugam mesajul nostru
    mov eax, 4
    mul dword[img_width]
    add ebx, eax ; ebx = ebx + 4 * width
    mov eax, dword[img]
    add eax, ebx ; mergem la linia unde trb adaugat mesajul

    xor edi, edi ; iterator prin img
    xor edx, edx ; placeholder pt a evita mov [mem], [mem]
    xor ebx, ebx ; iterator prin mesaj
    
copy_msg:
    ; dubiosenia asta cu 2 iteratori e pt ca am incercat
    ; sa declar string-ul cu dd si sa dau mov dword, n-a mers
    ; si imi baga valori dubioase
    
    ; am incercat aceeasi schema si cu word, tot gibberish
    
    ; am incercat si sa resetez valoarea din memorie
    ; cu mov dword[img + w/e], 0, tot n-a mers
    ; asta e singura solutie care a mers, nu ma intrebati de ce
    
    mov dl, byte[message + ebx]
    mov byte[eax + edi], dl
    add edi, 4
    add ebx, 1
    cmp ebx, 27
    jbe copy_msg
    
    ; incepem xorarea matricii
    mov eax, dword[img_width]
    mov edx, 4
    mul edx ; width * 4
    mov edi, eax

    mov esi, dword[img_height]
    mul esi ; width * 4 * height
    mov esi, eax
    
    xor edx, edx ; parcurgem linia cu asta
        
    mov eax, dword[img]
    ; edi -> width * 4
    ; esi -> height * width * 4
    ; ecx -> cheia

xor_encode_matrix:
    
    xor byte[eax + edx], cl
    add edx, 4
    cmp edx, esi ; daca am ajuns la final
    je end_task2
    jne xor_encode_matrix
   
end_task2:
    leave
    ret


morse:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8] ; indice
    mov ebx, [ebp + 12] ; pointer la string
    
    mov ecx, 4
    mul ecx ; indice * 4
    
    mov edi, dword[img]
    add edi, eax ; mergem la al eax-ulea octet
    
    xor ecx, ecx
    xor esi, esi
    
    ; edi -> pointer la img
    ; ebx -> pointer la msj
    ; eax -> pointer la litere
    
loop_morse:
    ; scuze pt codul copy paste

    ; daca stiti voi vreo metoda cu mai putin copy paste, sunt chiar
    ; curioasa sa o aud
    mov dl, byte[ebx]
    
    cmp byte[ebx], 'A'
    je is_A

    cmp byte[ebx], 'B'
    je is_B

    cmp byte[ebx], 'C'
    je is_C

    cmp byte[ebx], 'D'
    je is_D

    cmp byte[ebx], 'E'
    je is_E

    cmp byte[ebx], 'F'
    je is_F

    cmp byte[ebx], 'G'
    je is_G

    cmp byte[ebx], 'H'
    je is_H

    cmp byte[ebx], 'I'
    je is_I

    cmp byte[ebx], 'J'
    je is_J

    cmp byte[ebx], 'K'
    je is_K

    cmp byte[ebx], 'L'
    je is_L

    cmp byte[ebx], 'M'
    je is_M

    cmp byte[ebx], 'N'
    je is_N

    cmp byte[ebx], 'O'
    je is_O

    cmp byte[ebx], 'P'
    je is_P

    cmp byte[ebx], 'Q'
    je is_Q

    cmp byte[ebx], 'R'
    je is_R

    cmp byte[ebx], 'S'
    je is_S

    cmp byte[ebx], 'T'
    je is_T

    cmp byte[ebx], 'U'
    je is_U

    cmp byte[ebx], 'V'
    je is_V

    cmp byte[ebx], 'W'
    je is_W

    cmp byte[ebx], 'X'
    je is_X

    cmp byte[ebx], 'Y'
    je is_Y

    cmp byte[ebx], 'Z'
    je is_Z

    cmp byte[ebx], ','
    je is_Comma

    cmp byte[ebx], ' '
    je is_space
    
    jmp end_morse
    
is_A:
    mov eax, a_morse
    jmp move_letter
    
is_B:
    mov eax, b_morse
    jmp move_letter
    
is_C:
    mov eax, c_morse
    jmp move_letter
    
is_D:
    mov eax, d_morse
    jmp move_letter
    
is_E:
    mov eax, e_morse
    jmp move_letter
    
is_F:
    mov eax, f_morse
    jmp move_letter
    
is_G:
    mov eax, g_morse
    jmp move_letter
    
is_H:
    mov eax, h_morse
    jmp move_letter
    
is_I:
    mov eax, i_morse
    jmp move_letter
    
is_J:
    mov eax, j_morse
    jmp move_letter
    
is_K:
    mov eax, k_morse
    jmp move_letter
    
is_L:
    mov eax, l_morse
    jmp move_letter
    
is_M:
    mov eax, m_morse
    jmp move_letter
    
is_N:
    mov eax, n_morse
    jmp move_letter
    
is_O:
    mov eax, o_morse
    jmp move_letter
    
is_P:
    mov eax, p_morse
    jmp move_letter
    
is_Q:
    mov eax, q_morse
    jmp move_letter
    
is_R:
    mov eax, r_morse
    jmp move_letter
    
is_S:
    mov eax, s_morse
    jmp move_letter
    
is_T:
    mov eax, t_morse
    jmp move_letter
    
is_U:
    mov eax, u_morse
    jmp move_letter
    
is_V:
    mov eax, v_morse
    jmp move_letter
    
is_W:
    mov eax, w_morse
    jmp move_letter
    
is_X:
    mov eax, x_morse
    jmp move_letter
    
is_Y:
    mov eax, y_morse
    jmp move_letter
    
is_Z:
    mov eax, z_morse
    jmp move_letter
    
is_Comma:
    mov eax, comma_morse
    jmp move_letter
    
move_letter: ; loop-ul pt parcurgerea codificarii literei
    mov dl, byte[eax]
    mov byte[edi], dl
    add edi, 4 ; iterator pt imagine
    add eax, 1 ; iterator pt codificare
    cmp byte[eax], 0
    je end_morse_loop
    jmp move_letter
    
is_space:
    sub edi, 4 ; daca e spatiu, ne mutam cu o pozitie in urma, pt ca oricum
    ; dupa label-ul asta scriem spatiu
    
end_morse_loop:
    cmp byte[ebx], 0
    je end_morse
    add ebx, 1
    mov byte[edi], ' '
    add edi, 4
    xor eax, eax
    jmp loop_morse
    
end_morse:
    mov byte[edi - 4], 0 ; punem null in locul spatiului
    leave
    ret
    
    
LSB_encode:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp + 8] ; indice
    mov esi, [ebp + 12] ; pointer la string
    
    mov ecx, 4
    mul ecx ; indice * 4
    
    mov edi, dword[img]
    add edi, eax ; mergem la al eax-ulea octet
    sub edi, 4 ; minus unu
    
    xor ecx, ecx
    xor ebx, ebx
    xor eax, eax
    
    ; edi -> imaginea
    ; esi -> mesaj
    ; edx -> temp
    ; eax -> bitul
    ; ebx -> masca
    ; ecx -> counter
    
    mov bl, 128

lup_mesaj:
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    mov ecx, 8
    mov bl, 128
    mov al, byte[esi]
   
lup_cuvant:
    xor eax, eax
    mov al, byte[esi]
    test al, bl
    jz zero
    jnz one
    
zero:
    xor eax, eax
    jmp continue_LSB
    
one:
    xor eax, eax
    mov eax, 1

continue_LSB:
    shr bl, 1
    ; trb sa iau bitii progresiv
    ; setam LSB la 0 (and cu 1111 1110 / FE)
    ; facem or cu 0000 000x, unde x e bitul care trebuie
    ; codificat
    mov dl, byte[edi]
    and dl, 0xFE
    or dl, al
    
    mov byte[edi], dl
    add edi, 4

    dec ecx
    cmp ecx, 0
    jnz lup_cuvant
    cmp byte[esi], 0
    jz end_LSB
    add esi, 1
    
    jmp lup_mesaj
    
end_LSB:
    leave
    ret
    
    
LSB_decode:
    push ebp
    mov ebp, esp
        
    mov eax, [ebp + 8]
    
    dec eax
        
    mov ecx, 4
    mul ecx
    
    mov esi, dword[img]
    add esi, eax

    ; esi -> img
    ; eax -> octetul decodat
    ; ebx -> temp
    ; ecx -> counter

    mov ecx, 8
    jmp loop_word

print:
    PRINT_CHAR eax
    mov ecx, 8

loop_word:
    mov bl, byte[esi]
    and bl, 1
    shl al, 1
    add al, bl
    add esi, 4
    
    dec ecx
    cmp ecx, 0
    jnz loop_word
        
    cmp eax, 0
    jnz print
    
end_decode:
    NEWLINE
    leave
    ret
    
    
    
blur:
    push ebp
    mov ebp, esp
    
    mov edi, dword[img_width] ; o pastram constanta
    mov eax, 4
    mul edi
    mov edi, eax ; edi = width * 4
    
    mov esi, dword[img]
    mov eax, 4
    
    mov ecx, 0 ; printam prima linie

first_line:
    mov eax, dword[esi + ecx]
    PRINT_UDEC 4, eax
    PRINT_STRING " "
    add ecx, 4
    cmp ecx, edi
    jnz first_line
    NEWLINE
    
    mov eax, dword[esi + ecx]
    PRINT_UDEC 4, eax
    add ecx, 4
       
    mov ebx, dword[img_width]
    mov eax, dword[img_height]
    dec eax
    mul ebx ; eax = (width) * (height - 1)
    mov ebx, 4
    mul ebx ; eax = (width) * (height - 1) * 4
    mov ebx, eax ; ebx = (width) * (height - 1) * 4
    sub ebx, 4
    
    mov ecx, dword[img_width]
    mov eax, dword[img_height]
    mul ecx ; ecx = width * height
    mov ecx, 4
    mul ecx
    mov ecx, eax ; ecx = width * height * 4 
    
    ; edi -> width * 4
    
    
    mov edx, edi
    add edi, edx ; edi = 2w * 4
    sub edi, 4 ; edi = (2w - 1) * 4
    xor ecx, ecx
    mov ecx, edx
    add ecx, 4 ; w + 1 * 4
     
    ; ebx = (width) * (height - 1) * 4
    ; ecx = counter (initial e (2w - 1) * 4)
    ; edx -> (width - 1) * 4
    ; edi = counter pt width
    ; esi -> img
    
blur_loop:
    cmp ecx, ebx
    jz last_line

    cmp ecx, edi
    jz next_two_pixels
    
    jmp compute_blur
    
next_two_pixels:
    mov eax, dword[esi + ecx]
    PRINT_STRING " "
    PRINT_UDEC 4, eax
    PRINT_STRING " "
    NEWLINE
    add ecx, 4
    mov eax, dword[esi + ecx]
    PRINT_UDEC 4, eax
    add ecx, 4
    add edi, edx
    jmp compute_blur
     
last_line:
    
    mov eax, dword[esi + ecx]
    PRINT_STRING " "
    PRINT_UDEC 4, eax
    PRINT_STRING " "
    NEWLINE
    add ecx, 4
    mov eax, dword[esi + ecx]
    PRINT_UDEC 4, eax
    add ecx, 4
    add edi, edx
    
    mov edi, ebx ; (w) * (h - 1) * 4
    add ebx, dword[img_width]
    add ebx, dword[img_width]
    add ebx, dword[img_width]
    add ebx, dword[img_width]
    add ebx, 4
    
last_line_loop:
    mov eax, dword[esi + ecx]
    PRINT_STRING " "
    PRINT_UDEC 4, eax
    add ecx, 4
    cmp ecx, ebx
    jnz last_line_loop
    jmp end_blur
      
compute_blur: 
    xor eax, eax
    mov eax, dword[esi + ecx]
    
    add ecx, edx ; edx -> width * 4
    add eax, dword[esi + ecx]
    sub ecx, edx
    
    sub ecx, edx
    add eax, dword[esi + ecx]
    add ecx, edx
    
    sub ecx, 4
    add eax, dword[esi + ecx]
    add ecx, 4
    
    add ecx, 4
    add eax, dword[esi + ecx]
    sub ecx, 4
    
    push ecx
    push edx
    xor edx, edx
    mov ecx, 5
    div ecx
    pop edx
    pop ecx
    
    PRINT_STRING " "
    PRINT_UDEC 4, eax
    add ecx, 4
    jmp blur_loop
    
end_blur:
    PRINT_STRING " " ; pentru ca aparent testele au trailing whitespace
    NEWLINE          ; si newline la final
    leave
    ret
    

main:
    mov ebp, esp; for correct debugging
    ; Prologue
    ; Do not modify!
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    cmp eax, 1
    jne not_zero_param

    push use_str
    call printf
    add esp, 4

    push -1
    call exit

not_zero_param:
    ; We read the image. You can thank us later! :)
    ; You have it stored at img variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 4]
    call read_image
    add esp, 4
    mov [img], eax

    ; We saved the image's dimensions in the variables below.
    call get_image_width
    mov [img_width], eax

    call get_image_height
    mov [img_height], eax

    ; Let's get the task number. It will be stored at task variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 8]
    call atoi
    add esp, 4
    mov [task], eax

    ; There you go! Have fun! :D
    mov eax, [task]
    cmp eax, 1
    je solve_task1
    cmp eax, 2
    je solve_task2
    cmp eax, 3
    je solve_task3
    cmp eax, 4
    je solve_task4
    cmp eax, 5
    je solve_task5
    cmp eax, 6
    je solve_task6
    jmp done

solve_task1:
    call bruteforce_singlebyte_xor
    ; eax -> line
    ; ebx -> eax * width * 4
    ; ecx -> key
    
    mov esi, dword[img]
    add esi, ebx
    xor edx, edx ; iterator
    
print_task1:
    cmp dword[esi + edx], 0
    je finish_print1
    PRINT_STRING [esi + edx]
    add edx, 4
    jmp print_task1
    
finish_print1:
    NEWLINE
    PRINT_UDEC 4, ecx
    NEWLINE
    PRINT_UDEC 4, eax
    jmp done
    
solve_task2:
    call xor_encode
    ; void print_image(int* image, int width, int height);
    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
    add esp, 12    
    
    jmp done
    
solve_task3:
    mov ebx, [ebp + 12]
    push dword[ebx + 16]
    call atoi
    add esp, 4
    push dword[ebx + 12]
    push eax
    call morse
    add esp, 8
    
    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
    add esp, 12 
    
    jmp done
    
solve_task4:
    mov ebx, [ebp + 12]
    push dword[ebx + 16]
    call atoi
    add esp, 4
    push dword[ebx + 12]
    push eax
    call LSB_encode
    add esp, 8
    
    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
    add esp, 12
    
    jmp done
solve_task5:
    mov ebx, [ebp + 12]
    push dword[ebx + 12]
    call atoi
    add esp, 4
    push eax
    
    call LSB_decode
    
    add esp, 4
    
    jmp done
solve_task6:
    push 0
    push 0
    push 0
    call print_image
    add esp, 12
    
    call blur
    
    jmp done

    ; Free the memory allocated for the image.
done:
    push DWORD[img]
    call free_image
    add esp, 4

    ; Epilogue
    ; Do not modify!
    xor eax, eax
    leave
    ret
    
