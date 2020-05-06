	.section .text
	.globl _start
after:
	movq	$1, %rax
	int	$0x80
_start:
	movq	$42, %rbx
	jmp	after
