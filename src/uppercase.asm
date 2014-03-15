#PURPOSE: This program converts an input file
#         to an output file with all letters
#         converted to uppercase.
#
#PROCESSING: 1) Open the input file
#            2) Open the output file
#            3) While we're not at the end of the input file
#                a) read part of the file into our memory buffer
#                b) go through each byte of memory
#                    - if the byte is a low-case letter,
#                      convert it to uppercase
#                c) write the memory bufer to the output file

.section .data
	.equ	SYS_EXIT,  1
	.equ	SYS_READ,  3
	.equ	SYS_WRITE, 4
	.equ	SYS_OPEN,  5
	.equ	SYS_CLOSE, 6

	.equ	O_RDONLY, 0
	.equ	O_WRONLY, 03101

	.equ	STDIN,  0
	.equ	STDOUT, 1
	.equ	STDERR, 2

	.equ	LINUX_SYSCALL, 0x80
	.equ	EOF, 0
	.equ	NUMBER_ARGUMENTS, 2

.section .bss
	.equ	BUFFER_SIZE, 512
	.lcomm	BUFFER_DATA, BUFFER_SIZE

.section .text
	.equ	ST_SIZE_RESERVE, 8
	.equ	ST_FD_IN,  -4
	.equ	ST_FD_OUT, -8
	.equ	ST_ARGC,    0
	.equ	ST_ARGV_0,  4
	.equ	ST_ARGV_1,  8
	.equ	ST_ARGV_2,  12

.globl _start
_start:
	movl	%esp, %ebp                             # save the stack pointer
	subl	$ST_SIZE_RESERVE, %esp                 # allocate space for our file descriptor
                                                       # on the stack
open_fd_in:
        ### OPEN INPUT FILE
	movl	$SYS_OPEN, %eax                        # 0. open syscall
	movl	ST_ARGV_1(%ebp), %ebx                  # 1. input filename
	movl	$O_RDONLY, %ecx                        # 2. read-only flag
	movl	$0666, %edx                            # 3. permissions
	int	$LINUX_SYSCALL                         # call Linux
store_fd_in:
	movl	%eax, ST_FD_IN(%ebp)                   # save the returned file descriptor

open_fd_out:
	### OPEN OUTPUT FILE
	movl	$SYS_OPEN, %eax                        # 0. open syscall
	movl	ST_ARGV_2(%ebp), %ebx                  # 1. output filename
	movl	$O_WRONLY, %ecx                  # 2. write-only flag
	movl	$0666, %edx                            # 3. permissions
	int	$LINUX_SYSCALL                         # call Linux
store_fd_out:
	movl	%eax, ST_FD_OUT(%ebp)                  # save the returned file descriptor

read_loop_begin:
	### READ IN A BLOCK FROM THE INPUT FILE
	movl	$SYS_READ, %eax                        # 0. read syscall
	movl	ST_FD_IN(%ebp), %ebx                   # 1. file descriptor
	movl	$BUFFER_DATA, %ecx                     # 2. buffer location
	movl	$BUFFER_SIZE, %edx                     # 3. buffer size
	int	$LINUX_SYSCALL                         # call Linux

	cmpl	$EOF, %eax                             # if read() hit the EOF
	jle	read_loop_end                          # goto end of loop

read_loop_continue:
	### CONVERT THE BLOCK TO UPPERCASE
	pushl	$BUFFER_DATA                           # 1. location of the buffer
	pushl	%eax                                   # 0. size of the buffer
	call	to_upper                               # call to_upper()
	popl 	%eax                                   # get the size back
	addl	$4, %esp                               # restore %esp

	### WRITE THE BLOCK OUT TO THE OUTPUT FILE
	movl	%eax, %edx                             # 3. size of the buffer
	movl	$SYS_WRITE, %eax                       # 0. write syscall
	movl	ST_FD_OUT(%ebp), %ebx                  # 1. file descriptor
	movl	$BUFFER_DATA, %ecx                     # 2. buffer location
	int 	$LINUX_SYSCALL                         # call Linux

	jmp	read_loop_begin                        # continue the loop

read_loop_end:
	### CLOSE THE FILES
	movl	$SYS_CLOSE, %eax                       # 0. close syscall
	movl	ST_FD_OUT(%ebp), %ebx                  # 1. file descriptor
	int	$LINUX_SYSCALL                         # call Linux

	movl	$SYS_CLOSE, %eax                       # 0. close syscall
	movl	ST_FD_IN(%ebp), %ebx                   # 1. file descriptor
	int	$LINUX_SYSCALL                         # call Linux

	### EXIT
	movl	$SYS_EXIT, %eax                        # 0. exit syscall
	movl	$0, %ebx                               # 1. return status
	int	$LINUX_SYSCALL                         # call Linux

#PURPOSE: This function does the conversion to
#         upper case for a block of data
#
#INPUT: ARG0 - length of the block of memory
#       ARG1 - starting address of the block of memory
#
#OUTPUT: This function overwrite the current buffer
#        with the upper-casified version.
#
#VARIABLES: %eax - holds the beginning of the buffer
#           %ebx - holds the length of the buffer
#           %cl  - holds the current byte being examined
#           %edi - holds the current buffer offset

.equ LOWERCASE_A, 'a'
.equ LOWERCASE_Z, 'z'
.equ UPPER_CONVERSION, 'A' - 'a'

.equ ST_BUFFER_LENGTH, 8
.equ ST_BUFFER, 12

to_upper:
	pushl	%ebp
	movl	%esp, %ebp

	### SET UP VARIABLE
	movl	ST_BUFFER(%ebp), %eax
	movl	ST_BUFFER_LENGTH(%ebp), %ebx
	movl	$0, %edi

	cmpl	$0, %ebx                               # if a buffer with zero length was given
	je	to_upper_end                           # to us, just leave

to_upper_loop:
	movb	(%eax,%edi,1), %cl                     # get the current byte

	cmpb	$LOWERCASE_A, %cl                      # if the byte isn't between 'a' and 'z'
	jl	to_upper_next_byte                     #
	cmpb	$LOWERCASE_Z, %cl                      #
	jg	to_upper_next_byte                     # go get the next byte

	addb	$UPPER_CONVERSION, %cl                 # otherwise, convert the byte to uppercase
	movb	%cl, (%eax,%edi,1)                     # store it back

to_upper_next_byte:
	incl	%edi                                   # next byte
	cmpl	%edi, %ebx                             # continue unless we've reach the end
	jne	to_upper_loop

to_upper_end:
	movl	%ebp, %esp
	popl	%ebp
	ret
