#PURPOSE: This program will calculate the square
#         of a given number.
#
#         Example: 4^2 = 4*4 = 16
#

.section .data

.section .text

.globl _start
_start:
	pushl	$4              # push argument
	call	square          # call the function
	addl	$4, %esp        # move the stack pointer back
	movl	%eax, %ebx      # move the answer in %ebx
	
	movl	$1, %eax        # exit() syscall
	int	$0x80           # return answer

#PURPOSE: This function is used to compute the
#         square of a number.
#
#INPUT: ARG1 - the number to square
#
#OUTPUT: The square of the number.
#
#VARIABLES: %eax - holds the argument
#

.type square, @function
square:
	pushl	%ebp            # save the old pointer
	movl	%esp, %ebp      # make stack pointer the base pointer

	movl	8(%ebp), %eax   # move the argument in %eax
	imull	8(%ebp), %eax   # square the number, the result will
                                # be in %eax

	movl	%ebp, %esp
	popl	%ebp
	ret
