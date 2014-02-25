#PURPOSE: This program illustrate how functions work.
#         This program will compute the value of:
#
#                     2^0 + 2^1 + 2^2
#

.section .data

.section .text

.globl _start
_start:
	pushl	$0              # push second argument
	pushl	$2              # push first argument
	call	power           # call the function
	addl	$8, %esp        # move the stack pointer back
	pushl	%eax            # save the first answer
	
	pushl	$1              # push second argument
	pushl	$2              # push first argument
	call	power           # call the function
	addl 	$8, %esp        # move the stack pointer back
	pushl	%eax            # save the second answer

	pushl	$2              # push second argument
	pushl	$2              # push first argument
	call	power           # call the function
	addl	$8, %esp        # move the stack pointer back
	
	popl	%ebx            # pop the second answer in %ebx
                                # the third answer is in %eax
	addl	%eax, %ebx      # add them together
                                # the result is in %ebx
	movl	%ebx, %eax      # move the result in %eax
	popl	%ebx            # pop the first answer in %ebx
	addl	%eax, %ebx      # add them togeter
                                # the result is in %ebx

	movl	$1, %eax        # exit() syscall
	int	$0x80           # return answer

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
	pushl	%ebp            # save the old pointer
	movl	%esp, %ebp      # make stack pointer the base pointer
	subl	$4, %esp        # get room for our local storage

	movl	8(%ebp), %ebx   # move the first argument in %ebx
	movl	12(%ebp), %ecx  # move the second argument in %exc

	movl	%ebx, -4(%ebp)  # store the current value
	cmpl	$0, %ecx        # if the power is "0", the result is one
	je	power_one

power_loop:
	cmpl	$1, %ecx        # if the power is "1", we are done
	je	power_end
	movl	-4(%ebp), %eax  # move the current result into %eax
	imull	%ebx, %eax      # multiply the current result by the base

	movl	%eax, -4(%ebp)  # store current result

	decl	%ecx            # decrease the power
	jmp	power_loop      # run for the next power

power_one:
	movl	$1, -4(%ebp)    # the power is "0", the result is one

power_end:
	movl	-4(%ebp), %eax  # return value goes in %eax
	movl	%ebp, %esp      # restore the stack pointer
	popl	%ebp            # restore the base pointer
	ret
	
