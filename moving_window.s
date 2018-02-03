BITS 64
DEFAULT REL
GLOBAL DoItToIt

%define maplen 0x300
%define stacksz 0x10

_start:
	hlt

; Get the pancakes out
; buf is specially xor'd shellcode
; buf shellcode has to not use r8 - r15
; except for r11, because syscalls

; void DoItToIt(char* buf, int len)
DoItToIt:
	; save buf and buf_end
	mov r12, rdi
	mov r14, rsi
	add r14, r12
	mov r15, 0x42
	; mmap a rwe segment
	;void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset);
	xor rax, rax
	mov ax, 9
	xor rdi, rdi
	mov rsi, maplen
	mov rdx, 0x3 ; RWX
	mov r10, 0x21 ; MAP_PRIVATE | MAP_ANONYMOUS
	mov r8, -1
	mov r9, 0
	syscall
	
	xor r8, r8
	test rax, rax
	js .done

	mov r10, r12
	mov r8, rax ; save buf in r8

.bigloop:
	; clean our buf
	xor r12, r12
.cleanloop:
	lea r13, [r12 + r8]
	mov byte[r13], 0x90
	inc r12
	cmp r12, maplen
	jnz .cleanloop

	; mov in the return to our spot
	mov r12, .piece_end_end
	mov r13, r8
	add r13, maplen
.pieceloop:
	dec r13
	dec r12
	mov r11b, byte[r12]
	mov byte[r13], r11b
	cmp r12, .piece_end_start
	jnz .pieceloop

	; loop through decoding the pieces and running them
	; r8 is our map
	; r10 is buf
	; r14 is buf + len
	; r15b is last_xor, starts at 0x42

	movzx r12, byte[r10] ; length of section
	xor r12b, r15b ; xor to get real length
	inc r10
	xor byte[r10], r15b ; xor to get real next key
	mov r15b, byte[r10] ; next xor key
	inc r10
	
	xor r11, r11 ; counter
.cpyloop:
	; copy and xor to map
	lea r13, [r11 + r8] ; ptr
	mov r9b, byte[r10]
	mov byte[r13], r9b
	xor byte[r13], r15b
	inc r11
	inc r10
	cmp r11, r12
	jnz .cpyloop

	; set r9 as the return from piece
	mov r9, .back

	; go to piece
	jmp r8
	
.back:
	; see if we are done
	cmp r10, r14
	jb .bigloop
.done:
	; munmap
	test r8, r8
	jnz .donedone
	mov rax, 11
	mov rdi, r8
	mov rsi, maplen
	syscall
.donedone:
	ret

.piece_end_start:
	jmp r9
.piece_end_end:

