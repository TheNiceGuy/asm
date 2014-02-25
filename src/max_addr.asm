#PURPOSE: This program finds the maximum number of a
#         set of data items.
#
#
#VARIABLES: %edi - holds the index of the data item being examined
#           %eax - current data item
#           %ebx - largest data item found
#
#           data_items - contains the item data
#           end        - contains the number of item
#           end_addr   - contains the end address
#

.section .data
data_items:
	.long 3,67,34,222,45,75,54,43,44,33,22,11,66
end:
	.long 12
end_addr:
	.long 0

.section .text

.globl _start
_start:
	movl end, %ecx
	leal data_items(,%ecx,4), %ecx   # compute end address
	movl %ecx, end_addr              # move end address to end_addr
	movl $0, %edi                    # move 0 into the index register
	movl data_items(,%edi,4), %eax   # load the first byte of data
	movl %eax, %ebx                  # since this is the first item, %eax
                                         # is the biggest

start_loop:
	leal data_items(,%edi,4), %ecx   # compute current address
	cmpl %ecx, end_addr              # compare end and current address
	je loop_exit                     # jump to loop_exit
	incl %edi                        # increment %edi
	movl data_items(,%edi,4), %eax   # load next value in %eax
	cmpl %ebx, %eax                  # compare values
	jle start_loop                   # jump to loop beginning if the new
                                         # one isn't bigger
	movl %eax, %ebx                  # move the value as the largest
	jmp start_loop                   # jump to loop beginning
	
loop_exit:
	movl $1, %eax                    # 1 is the exit() syscall
                                         # %ebx is loaded with the max value
	int $0x80                        # linux kernel syscall
