BITS 64
DEFAULT REL

; must restore r8-r15 between pieces
; if we call something, make sure to save those registers and restore them after
; also, no jumps between pieces, obv
; also flags wond last between pieces
; pieces are divided with labels as such XP#, with the last one being XPX
; there must be global labels XP_LIST_LEN and XP_LIST
; XP_LIST having the address of all the XP# labels
; no section can have a length greater than moving_window's maplen - piece_end len
; no section can have a length greater than 0xff

GLOBAL XP_LIST_LENGTH, XP_LIST
SECTION .text

XP0:
	sub rsp, 0x10
	mov qword[rsp], 0
XP1:
	mov qword[rsp + 0x8], 0
	; read 8 byte input
	xor rax, rax
XP2:
	xor rdi, rdi
	mov rsi, rsp
	mov rdx, 0x8
XP3:
	syscall	

	; compare checksum
	xor rax, rax
	xor al, byte[rsp]
XP4:
	xor al, byte[rsp+1]
	xor al, byte[rsp+2]
	xor al, byte[rsp+3]
	xor al, byte[rsp+4]
	xor al, byte[rsp+5]
	xor al, byte[rsp+6]
XP5:
	xor al, byte[rsp+7]
XP6:
	cmp al, 0x37
	jne short .skip
	mov rax, qword 0x726f787b67616c66
	mov qword[rsp], rax
	mov rax, qword 0x7d6d61667075656d
	mov qword[rsp + 0x8], rax
.skip:
XP7:
	; write 8 byte output
	xor rax, rax
	inc rax
	xor rdi, rdi
XP8:
	inc rdi
	mov rsi, rsp
	mov rdx, 0x10
	syscall

XP9:
	add rsp, 0x10
XPX:
	; anything past the XPX wont go in the formatted one
	; exit for clean testing
	mov rax, 0x3c
	xor rdi, rdi
	syscall

; format info
SECTION .data
XP_LIST_LENGTH:
	dq 11
XP_LIST:
	dq XP0
	dq XP1
	dq XP2
	dq XP3
	dq XP4
	dq XP5
	dq XP6
	dq XP7
	dq XP8
	dq XP9
	dq XPX
