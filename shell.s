BITS 64
DEFAULT REL

; must restore r8-r15 between pieces
; if we call something, make sure to save those registers and restore them after
; also, no jumps between pieces, obv
; pieces are divided with global labels as such XP#, with the last one being XPX

XP0:
	sub rsp, 0x10
	mov qword[rsp], 0
	mov qword[rsp + 0x8], 0
	; read 8 byte input
	xor rax, rax
	xor rdi, rdi
	mov rsi, rsp
	mov rdx, 0x8
	syscall	

	; compare checksum
	xor rax, rax
	xor al, byte[rsp]
	xor al, byte[rsp+1]
	xor al, byte[rsp+2]
	xor al, byte[rsp+3]
	xor al, byte[rsp+4]
	xor al, byte[rsp+5]
	xor al, byte[rsp+6]
	xor al, byte[rsp+7]
	
	cmp al, 0x3d
	jne short .skip
	mov rax, qword 0x726f787b67616c66
	mov qword[rsp], rax
	mov rax, qword 0x7d6d61667075656d
	mov qword[rsp + 0x8], rax
.skip:
	; write 8 byte output
	xor rax, rax
	inc rax
	xor rdi, rdi
	inc rdi
	mov rsi, rsp
	mov rdx, 0x10
	syscall

	add rsp, 0x10
XPX:
	hlt ; for testing	
