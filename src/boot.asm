[org 0x7c00]            ; Start address
[bits 16]               ; Boot in 16-bit real mode

; Consts
%define SECTORS_IN      0x2f  ; Read 47 sectors, giving 24062 Bytes in total
                              ;0xf000 to 0x14e00

; Entry point
_start:
  mov bx, start_str
  call puts
  call read_disk
  jmp 0xf000:0x0000
  jmp $

; Subroutine puts - puts a null-terminated string to the screen
; - Params: bx points to string
; - Uses BIOS interrupts
puts:
  pusha
  mov ah, 0x0e          ; Teletype output
.loop:
  mov al, [bx]          ; Get char
  cmp al, 0             ; Check for end of string
  je .end
  int 0x10              ; Video services interrupt
  inc bx                ; Points to next char
  jmp .loop
.end:
  popa
  ret

; Subroutine read_disk - reads SECTORS_IN sectors from disk to 0xf000
; - Params: none
; - Uses BIOS interrupts
read_disk:
  pusha
  mov ah, 0x02          ; Read sectors from disk
  mov al, SECTORS_IN    ; Number of sectors to read
  mov ch, 0x00          ; From cylinder 0
  mov cl, 0x02          ; Second sector - indexed from 1, not 0
  mov dh, 0x00          ; From first head
  mov dl, 0x00          ; And first drive
  mov bx, 0xf000        ; Can't move immediate value directly into a segment
  mov es, bx            ; register, it is done through bx
  mov bx, 0x0000        ; Address is es:bx
  int 0x13              ; Disk operation interrupt
  jc .diskerr           ; Upon error, carry flag set
  cmp al, SECTORS_IN
  jne .diskerr
  popa
  ret
.diskerr:               ; Print error message
  mov bx, diskerr_str
  call puts

; Strings
start_str: db `INFO: Starting bootloader...\r\n\0`
diskerr_str: db `ERROR: Failed to load sectors from disk.\r\n\0`

times 510-($-$$) db 0x00; Cover full bootsector
dw 0x0aa55              ; Add magic number to make bootable
