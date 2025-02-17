mov ax, 0xA000              ; set AX to start of screen buffer segment
mov ds, ax                  ; make DS point to screen buffer
mov es, ax                  ; same for ES
mov al, 0xF4                ; enable keyboard command
out 0x60, al                ; sends the command to the i8042 controller
mov dx, 0x3C0               ; port 0x3C0 writes to the attribute address registers
mov al, 0x7                 ; use 0x7 both to choose text color and the DAC corresponding to it
out dx, al                  ; choose 0x7 ("white on black") text color
out dx, al                  ; set it to DAC index 7, in this case, black (this inverts colors, but it's OK)
mov dl, 0xC9                ; port 0x3C9 writes to the DAC data register
mov al, 0x1F                ; store a 0x1F byte in the first DAC entry
times 3 out dx, al          ; set rgb value of background to grey (rgb #1f1f1f)
mov dl, 0xD4                ; port 0x3D4 writes to the CRT controller registers
mov ax, 0x2701              ; write 0x27 into register index 0x01 (end horizontal display register)
out dx, ax                  ; set horizontal character count to 0x27+1
xchg si, ax                 ; arbitrary pointer to memory location where the initial position of the snake head is stored
mov ax, 0x4807              ; write 0x48 into register index 0x07 (overflow register)
out dx, ax                  ; setting bit 6 (0x40) sets vertical display end register's bit 9 to 1 which allows us not to set it, setting bit 3 (0x8) sets bit 8 of register index 0x15 (which we also set)
mov al, 0x2                 ; write 0x48 into register index 0x02 (start horizontal blancking register)
out dx, ax                  ; disable blancking as 0x48 must be above the character clocks of a scan line as it's above the character clocks for the display
mov ax, 0xF09               ; write 0xF into register index 0x09 (maximum scan line register)
out dx, ax                  ; set character height to 0x0F+1
mov ax, 0x9015              ; write 0x190 into register index 0x15 (start vertical blanking register), the set 8 bit comes from the overflow register (index 0x07)
out dx, ax                  ; set display height to 0x10 (character height) times 25 lines
mov ch, 0x3B                ; override initial CX so that in initial screen clearing the entire buffer will be cleared
mov bp, 0x9FF               ; literally use a random value to initiate BP
start:                      ; reset game
    mov ax, 0x720           ; fill the screen with word 0x720 - white on black space (line 10 for clarification on why this doesn't work as expected)
    add ch, 0x5             ; add 0x500 to initial CX (0xFFFF) to write 0x4FF words (a little more then the screen)
    xor di, di              ; start writing at the start of the screen
    rep stosw               ; clear the screen
    dec cx                  ; set CX to 0xFFFF again
    mov di, [bx]            ; reset head position, BX always points to a valid screen position containing 0x720 after setting video mode
    lea sp, [bp+si]         ; set stack pointer (tail) to current head pointer
.food:                      ; create new food item
    push di                 ; save old DI before overwriting for randomization
.rand:                      ; lots of code to randomize food positions is better than initializing the PIT chip
    xchg di, bx             ; alternate BX between head position (not to iterate over the same food locations) and the end of the screen
    dec bh                  ; decreasing BH for randomization ensures BX is still divisble by 2 and if the snake isn't filling all the possible options, below 0x7D0
    xor [bx], cl            ; place food item and check if position was empty by applying XOR with CL (assumed to be 0xFF)
    jp .rand                ; if position was occupied by snake or wall in food generation => try again, if we came from main loop PF=0
    pop di                  ; restore actual head position
.input:                     ; handle keyboard input
    mov bx, 0x7D0           ; initialize BX to screen size (40x25x2 bytes)
.move:                      ; dummy label for jumping back to input evaluation
    in al, 0x60             ; read scancode from keyboard controller - bit 7 is set in case key was released
%ifdef NONUMPAD
    cmp al, 0xE0            ; if AL is the byte appended when using the keypad
    je .move                ; ignore it
%endif
    imul ax, BYTE 0xA       ; we want to map scancodes for arrow up (0x48/0xC8), left (0x4B/0xCB), right (0x4D/0xCD), down (0x50/0xD0) to movement offsets
    aam 0x14                ; IMUL (AH is irrelevant here), AAM and AAD with some magic constants maps up => -80, left => -2, right => 2, down => 80
    aad 0x44                ; using arithmetic instructions is more compact than checks and conditional jumps
    cbw                     ; but causes weird snake movements though with other keys
    add di, ax              ; add offset to head position
    cmp di, bx              ; check if head crossed vertical edge by comparing against screen size in BX
    lodsw                   ; load 0x2007 into AX from off-screen screen buffer and advance head pointer
    adc [di], ah            ; ADC head position with 0x20 to set snake character
    jnp start               ; if it already had snake or wall in it or if it crossed a vertical edge, PF=0 from ADC => game over
    mov [bp+si], di         ; store head position, use BP+SI to default to SS
    jz .food                ; if food was consumed, ZF=1 from ADC => generate new food
.wall:                      ; draw an invisible wall on the left side
    mov [bx], cl            ; store wall character
    sub bx, BYTE 0x50       ; go one line backwards
    jns .wall               ; jump to draw the next wall
    pop bx                  ; no food was consumed so pop tail position into BX
    mov [bx], ah            ; clear old tail position on screen
    jnp .input              ; loop to keyboard input, PF=0 from SUB
times ($$-$+0xFFFC) db 0x00 ; fill with zeros
nop
jmp $$
