[org 0x9000]                ; Start address

; Entry point
_start:
  mov ah, 0x0e
  mov al, 'A'
  int 0x10
