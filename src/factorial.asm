#PURPOSE: This program will calculate the factorial
#         of a given number.
#
#         Example: 4! = 1*2*3*4 = 24
#

.section .data

.section .text

.globl _start
_start:
	pushl	$4              # push argument
	call	factorial       # call the function
	addl	$4, %esp        # move the stack pointer back
	movl	%eax, %ebx      # move the answer in %ebx
	
	movl	$1, %eax        # exit() syscall
	int	$0x80           # return answer

#PURPOSE: This function is used to compute the
#         factorial of a number.
#
#INPUT: ARG1 - the factorial number
#
#OUTPUT: The factorial of a number.
#
#VARIABLES: %eax - holds the argument and the return value
#           %ebx - holds the argument
#

.type factorial, @function
factorial:
	pushl	%ebp            # save the old pointer
	movl	%esp, %ebp      # make stack pointer the base pointer

	movl	8(%ebp), %eax   # move the argument in %eax
	cmpl	$1, %eax        # if the factorial is "1"
	je	factorial_end   # go to end

	decl	%eax            # otherwise, decrease the value
	pushl	%eax            # push argument
	call	factorial       # call the function recursively
	movl 	8(%ebp), %ebx   # reload the original argument

	imull	%ebx, %eax      # multiply the argument with the result
                                # given by the last function call

factorial_end:
	movl	%ebp, %esp      # restore the stack pointer
	popl	%ebp            # restore de base pointer
	ret
