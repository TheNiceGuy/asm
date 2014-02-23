#PURPOSE: This program illustrate how functions work.
#         This program will compute the value of:
#
#                       2^3+5^2
#

.section .data

.section .text

.globl _start
_start:
	pushl	$3
	pushl	$2
	call	power
	addl	$8, %esp

	pushl	%eax
	
	pushl	$2
	pushl	$5
	call	power
	addl 	$8, %esp

	popl	%ebx
	addl	%eax, %ebx

	movl	$1, %eax
	int	$0x80

#PURPOSE: This function is used to compute the value
#         of a number raised to a power.
#
#INPUT: ARG1 - the base number
#       ARG2 - the power number
#
#OUTPUT: The result of the number raised to the power
#
#VARIABLES: %eax - used for temporary usage
#           %ebx - holds the base number
#           %ecx - holds the power
#
#           -4(%ebp) - holds the current result
#

.type power, @function
power:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$4, %esp

	movl	8(%ebp), %ebx
	movl	12(%ebp), %ecx

power_loop:
	cmpl	$1, %ecx
	je	power_end
	movl	-4(%ebp), %eax
	imull	%ebx, %eax

	movl	%eax, -4(%ebp)

	decl	%ecx
	jmp	power_loop

power_end:
	movl	-4(%ebp), %eax
	movl	%ebp, %esp
	popl	%ebp
	ret
	
