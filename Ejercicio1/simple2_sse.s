	.file	"simple2.c"
	.text
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB39:
	.cfi_startproc
	endbr64
	leaq	b(%rip), %rcx
	movdqa	.LC0(%rip), %xmm2
	leaq	a(%rip), %rdx
	movdqa	.LC1(%rip), %xmm4
	movq	%rcx, %rax
	movdqa	.LC2(%rip), %xmm3
	movq	%rdx, %rsi
	leaq	16384(%rcx), %rdi
.L2:
	movdqa	%xmm2, %xmm0
	addq	$32, %rax
	addq	$32, %rsi
	cvtdq2pd	%xmm0, %xmm1
	movaps	%xmm1, -32(%rax)
	pshufd	$238, %xmm0, %xmm1
	paddd	%xmm3, %xmm0
	cvtdq2pd	%xmm1, %xmm1
	movaps	%xmm1, -16(%rax)
	cvtdq2pd	%xmm0, %xmm1
	paddd	%xmm4, %xmm2
	movaps	%xmm1, -32(%rsi)
	pshufd	$238, %xmm0, %xmm0
	cvtdq2pd	%xmm0, %xmm0
	movaps	%xmm0, -16(%rsi)
	cmpq	%rdi, %rax
	jne	.L2
	movsd	c(%rip), %xmm1
	movl	$1000000, %esi
	movapd	.LC3(%rip), %xmm3
.L3:
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L4:
	movapd	(%rdx,%rax), %xmm0
	mulpd	%xmm3, %xmm0
	addpd	(%rcx,%rax), %xmm0
	addq	$16, %rax
	cmpq	$16384, %rax
	movapd	%xmm0, %xmm2
	unpckhpd	%xmm0, %xmm0
	addsd	%xmm1, %xmm2
	movapd	%xmm0, %xmm1
	addsd	%xmm2, %xmm1
	jne	.L4
	subl	$1, %esi
	jne	.L3
	movsd	%xmm1, c(%rip)
	xorl	%eax, %eax
	ret
	.cfi_endproc
.LFE39:
	.size	main, .-main
	.local	c
	.comm	c,8,8
	.local	b
	.comm	b,16384,32
	.local	a
	.comm	a,16384,32
	.section	.rodata.cst16,"aM",@progbits,16
	.align 16
.LC0:
	.long	0
	.long	1
	.long	2
	.long	3
	.align 16
.LC1:
	.long	4
	.long	4
	.long	4
	.long	4
	.align 16
.LC2:
	.long	1
	.long	1
	.long	1
	.long	1
	.align 16
.LC3:
	.long	3683363953
	.long	1072693352
	.long	3683363953
	.long	1072693352
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.2) 9.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
