	.section .text
	.globl main
conclusion:
	movq	%rax, %rbx
	movq	$1, %rax
	int	$128
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$48, %rsp
	movq	$13, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, -16(%rbp)
	negq	-16(%rbp)
	movq	-16(%rbp), %rax
	movq	%rax, -24(%rbp)
	movq	-16(%rbp), %rax
	addq	%rax, -24(%rbp)
	movq	$42, -32(%rbp)
	addq	$8, -32(%rbp)
	movq	-24(%rbp), %rax
	movq	%rax, -40(%rbp)
	movq	-32(%rbp), %rax
	addq	%rax, -40(%rbp)
	callq	read_int
	movq	%rax, -48(%rbp)
	movq	-40(%rbp), %rax
	addq	-48(%rbp), %rax
	popq	%rbp
	jmp	conclusion
