[org 0x7c00] ; tell the assembler that our offset is bootsector code

mov bx, welcome
call print
call print_nl

mov bp, 0x8000 ; set the stack safely away from us
mov sp, bp

mov bx, 0x9000 ; es:bx = 0x0000:0x9000 = 0x09000
mov dh, 2 ; read 2 sectors
; the bios sets 'dl' for our boot disk number
call disk_load

mov dx, [0x9000] ; retrieve the first loaded word, 0xdada
call print_hex

call print_nl

mov dx, [0x9000 + 512] ; first word from second loaded sector, 0xface
call print_hex

; Infinite loop (jumping to current address)
jmp $

; Include print functions
%include "print.asm"
%include "print_hex.asm"
%include "disk.asm"

welcome: ; Welcome string
    db 'Booting RailOS...', 0
lbl_debug:
	db '[DEBUG] ', 0

; Fill with 510 zeros minus the size of the previous code
times 510-($-$$) db 0
; Magic number
dw 0xaa55

times 256 dw 0xcafe ; sector 2 = 512 bytes
times 256 dw 0xface ; sector 3 = 512 bytes