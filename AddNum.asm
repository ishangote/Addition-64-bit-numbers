;Addition of 64-bit numbers stored in array

;************************************************************************
Section .data

msg1: db "Enter number of numbers to be addded: "
len1: equ $-msg1
msg2: db "Enter 64 bit numbers: "
len2: equ $-msg2
msgnl: db 0x0A
lennl: equ 1
msg3: db "Sum: ",0x0A
len3: equ $-msg3
msgc: db "Carry is present.",0x0A
lenc: equ $-msgc

;************************************************************************

Section .bss

temp: resb 0x11				;Temporary storage for input
num: resq 0x0F				;Array of numbers
cnta: resb 0x01				;Counter for numbers(addition)
cntc: resb 0x01				;Counter for conversion
count_c: resb 0x01			;Count of carry
count_disp: resb 0x01			;Count for display function
result: resq 0x01
res: resb 0x01				;Temporary storage

;************************************************************************

%macro print 2				;Macro for printing
	mov rax,0x01
	mov rdi,0x01
	mov rsi,%1
	mov rdx,%2
	syscall
%endmacro

;************************************************************************

%macro read 2				;Macro for reading
	mov rax,0x00
	mov rdi,0x00
	mov rsi,%1
	mov rdx,%2
	syscall
%endmacro

;************************************************************************

Section .text

Global _start
_start: 
	print msg1,len1
	read cnta,2			;Accept n	

	cmp byte[cnta],0x39
	jbe digit
	sub byte[cnta],0x07

digit:					;Convert to HEX
	sub byte[cnta],0x30
	
	mov cl,byte[cnta]
	push rcx
	
	print msg2,len2
	print msgnl,lennl
	
	mov rdi,num

accept:					;Accept numbers
	push rdi
	read temp,0x11	
	pop rdi
	xor rax,rax
	mov byte[cntc],0x10
	mov rsi,temp			;For conversion

convert:				;ASCII to HEX
	mov bl,byte[rsi]
	cmp bl,0x39
	jbe digit1
	sub bl,0x07

digit1:
	sub bl,0x30

	rol rax,0x04
	add al,bl

	inc rsi
	dec byte[cntc]
	jnz convert

store:	
	mov qword[rdi],rax		;Stored in num(memory)
	add rdi,0x8
	dec byte[cnta]
	jnz accept

	pop rcx
	mov byte[cnta],cl
	
	mov rsi,num
	xor rax,rax
	mov byte[count_c],0x00

;************************************************************************
	
sum:	
	add rax,[rsi]
	jnc no_c			;Get the 17th digit
	inc byte[count_c]
	
no_c:
	add rsi,0x8
	dec byte[cnta]
	jnz sum
	mov r8,rax

	cmp byte[count_c],0x00
	jbe no_c_msg
	print msgc,lenc

no_c_msg:
	print msg3,len3
	mov cl,byte[count_c]
	mov byte[result+7],cl
	mov byte[count_disp],0x02	;Print MSB
	call disp		
	mov [result],r8
	mov byte[count_disp],0x10
	call disp			;Print remaining result
	print msgnl,lennl

;************************************************************************

exit:
	mov rax,0x3C
	mov rbx,0x00
	syscall
;************************************************************************

disp:					;HEX to ASCII display routine
back:
	rol qword[result],4
	mov bl,byte[result]
	and bl,0FH
	cmp bl,09H
	jbe next
	add bl,07H

next:	
	add bl,30H
	mov byte[res],bl
	print res,1
	dec byte[count_disp]
	jnz back
	ret
