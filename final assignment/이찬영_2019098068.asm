# switch to the Data segment
	.data
	# global data is defined here
	# Don't forget the backslash-n (newline character)
Homework:
	.asciiz	"ENE 1004 23978 Assignment 2\n"
Name:
	.asciiz "My name is CHANYOUNG LEE:\n"

# switch to the Text segment
	.text
	# the program is defined here
	.globl	main
main:
	# Whose program is this?
	la	$a0, Homework	# $s0 = Homework
	jal	Print_string	# Print_string으로 jump and link
	la	$a0, Name
	jal	Print_string
	
	la	$a0, cr
	jal	Print_string
	la	$a0, header
	jal	Print_string
	
	# int i, n;
	# for (i = 0; i < 18; i++)
	#   {
	#      ... calculate n from i
	#      ... print i and n
	#   }
	
	# register assignments
	#	$s0	i
	#	$s1	n
	#	$s2	address of testcase[0]
	#	$s3	testcase[i]
	#	$t0	temporary values
	#	$a0	argument to Print_integer, Print_string, etc.
	#	add to this list if you use any other registers
	
	la	$s2, testcase		# $s2 = testcase (word 단위로 된 16진수 testcase)
	
	# for (i = 0; i < 18; i++)
	li	$s0, 0			# i = 0
	bge	$s0, 18, bottom		# $s0>=18 이면 go to PC+4+bottom
top:
	# calculate n from shuffle32(testcase[i])
	sll	$t0, $s0, 2	# 4*i
	add	$t0, $s2, $t0	# address of testcase[i]
	lw	$s3, 0($t0)	# testcase[i]
	
	move	$a0, $s3	# $a0 = $s3 (testcase[i])
	jal	shuffle32	# jump and link shuffle32
	move	$s1, $v0	# n = shuffle32(testcase[i])
	
	# print i and n
	# if (i < 10) print an extra space for alignment
	bge	$s0, 10, L1	# if($s0>=10) go to PC+4+L1 
	la	$a0, sp		# space
	jal	Print_string	
L1:
	move	$a0, $s0	# i
	jal	Print_integer
	la	$a0, sp		# space
	jal	Print_string
	move	$a0, $s3	# testcase[i]
	jal	Print_hex
	la	$a0, sp		# space
	jal	Print_string
	move	$a0, $s3	# testcase[i]
	jal	Print_binary
	la	$a0, sp		# space
	jal	Print_string
	move	$a0, $s1	# n
	jal	Print_binary
	la	$a0, sp		# space
	jal	Print_string
	move	$a0, $s1	# n
	jal	Print_hex
	la	$a0, cr		# newline
	jal	Print_string
	
	# for (i = 0; i < 18; i++)
	add	$s0, $s0, 1	# i++
	blt	$s0, 18, top	# i < 18
bottom:
	
	la	$a0, done	# mark the end of the program
	jal	Print_string
	
	jal	Exit	# end the program, no explicit return status

	
# switch to the Data segment
	.data
	# global data is defined here
sp:
	.asciiz	" "
cr:
	.asciiz	"\n"
done:
	.asciiz	"All done!\n"
header:
	.asciiz	" i testcase[i]           testcase[i] in binary        shuffled result in binary     result\n"

testcase:			# array
	.word	0xffffffff,	#  0	
		0xffff0000,	#  1
		0x0000ffff,	#  2
		0xff00ff00,	#  3
		0x00ff00ff,	#  4
		0xf0f0f0f0,	#  5
		0x0f0f0f0f,	#  6
		0xcccccccc,	#  7
		0x33333333,	#  8
		0xaaaaaaaa,	#  9
		0x55555555,	# 10
		0x00000000,	# 11
		0xffff0000,	# 12
		0xaaaaaaaa,	# 13
		0xcccccccc,	# 14
		0xf0f0f0f0,	# 15
		0xff00ff00,	# 16
		0x12345678	# 17
	
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	.text
# Your part starts here
shuffle32:
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	
	andi $t0, $a0, 16711680			
	andi $t1, $a0, 65280			
	andi $t2, $a0, 4278190335		
	
	srl $t0, $t0, 8			
	sll $t1, $t1, 8			
	
	or $s0, $t0, $t1		
	or $s0, $s0, $t2		

	andi $t3, $s0, 4294901760		
	srl $t3, $t3, 16			
	move $a0, $t3				
	jal shuffle16

	sll $s1, $v0, 16			
	
	andi $t3, $s0, 65535 		
	move $a0, $t3			
	jal shuffle16
	
	or $s1, $s1, $v0		
	move $v0, $s1			
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	
	jr $ra

shuffle16:
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	
	# $a0 = 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16(input)
	andi $t0, $a0, 3840		# $t0 = 0 0 0 0 5 6 7 8 0 0 0 0 0 0 0 0
	andi $t1, $a0, 240		# $t1 = 0 0 0 0 0 0 0 0 9 10 11 12 0 0 0 0
	andi $t2, $a0, 61455		# $t2 = 1 2 3 4 0 0 0 0 0 0 0 0 13 14 15 16
	
	srl $t0, $t0, 4			# $t0 = 0 0 0 0 0 0 0 0 5 6 7 8 0 0 0 0
	sll $t1, $t1, 4			# $t1 = 0 0 0 0 9 10 11 12 0 0 0 0 0 0 0 0
	
	or $s0, $t0, $t1		
	or $s0, $s0, $t2		# $s0 = 1 2 3 4 9 10 11 12 5 6 7 8 13 14 15 16

	andi $t3, $s0, 65280		# $t3 = 1 2 3 4 9 10 11 12 0 0 0 0 0 0 0 0
	srl $t3, $t3, 8			# $t3 = 0 0 0 0 0 0 0 0 1 2 3 4 9 10 11 12
	move $a0, $t3			# $a0 = 1 2 3 4 9 10 11 12
	jal shuffle8

	sll $s1, $v0, 8			# $s1 = 1 9 2 10 3 11 4 12 0 0 0 0 0 0 0 0
	
	andi $t3, $s0, 255 		# $t3 = 0 0 0 0 0 0 0 0 5 6 7 8 13 14 15 16
	move $a0, $t3			# $a0 = 5 6 7 8 13 14 15 16
	jal shuffle8
	
	or $s1, $s1, $v0		# $s1 = 1 9 2 10 3 11 4 12 5 13 6 14 7 15 8 16
	move $v0, $s1			# $v0 = 1 9 2 10 3 11 4 12 5 13 6 14 7 15 8 16 (output)
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	
	jr $ra
	
shuffle8:
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	
	# $a0 = 1 2 3 4 5 6 7 8 (input)
	andi $t0, $a0, 48		# $t0 = 00340000
	andi $t1, $a0, 12		# $t1 = 00005600
	andi $t2, $a0, 195		# $t2 = 12000078
	
	srl $t0, $t0, 2			# $t0 = 00003400
	sll $t1, $t1, 2			# $t1 = 00560000
	
	or $s0, $t0, $t1		# $s0 = 00563400
	or $s0, $s0, $t2		# $s0 = 12563478

	andi $t3, $s0, 240		# $t3 = 12560000
	srl $t3, $t3, 4			# $t3 = 00001256
	move $a0, $t3			# $a0 = 1256
	jal shuffle4

	sll $s1, $v0, 4			# $s1 = 15260000
	
	andi $t3, $s0, 15 		# $t3 = 00003478
	move $a0, $t3			# $a0 = 3478
	jal shuffle4
	
	or $s1, $s1, $v0		# $s1 = 15263748
	move $v0, $s1			# $v0 = 15263478 (output)
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	
	jr $ra

# function shuffle32 to be defined here
shuffle4:
	# $a0 = (00000000 00000000 00000000 0000)b3 b2 b1 b0 (input) - decimal, hexdecial, binary
	# $v0 = (00000000 00000000 00000000 0000)b3 b1 b2 b0 (output)
	andi $t0, $a0, 9   # 9 = (0x28bits)1001 & b3 b2 b1 b0 = b3 0 0 b0; $t0 = b3 0 0 b0
	andi $t1, $a0, 2   # 2 = (0x28bits)0010 & b3 b2 b1 b0 = 0 0 b1 0; $t1 = 0 0 b1 0
	andi $t2, $a0, 4   # 4 = (0x28bits)0100 & b3 b2 b1 b0 = 0 b2 0 0; $t2 = 0 b2 0 0

	sll  $t1, $t1, 1   # $t1= 0 b1 0 0
	srl  $t2, $t2, 1   # $t2 = 0 0 b2 0

	# combine $t0 + $t1 + $t2: b3 b1 b2 b0
	or   $v0, $t1, $t2   # $v0 = (0x28bits) 0 b1 b2 0
	or   $v0, $v0, $t0   # $v0 = (0x28bits) b3 b1 b2 b0
	
	jr   $ra
# Your part ends here

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Wrapper functions around some of the system calls
# See P&H COD, Fig. B.9.1, for the complete list.  More are available with MARS.

# switch to the Text segment
	.text

	.globl	Print_integer
Print_integer:	# print the integer in register a0, decimal
	li	$v0, 1
	syscall
	jr	$ra

	.globl	Print_hex
Print_hex:	# print the integer in register a0, hexadecimal
	li	$v0, 34
	syscall
	jr	$ra

	.globl	Print_binary
Print_binary:	# print the integer in register a0, binary
	li	$v0, 35
	syscall
	jr	$ra

	.globl	Print_string
Print_string:	# print the string whose starting address is in register a0
	li	$v0, 4		# $v0 = 4
	syscall
	jr	$ra		

	.globl	Exit
Exit:		# end the program, no explicit return status
	li	$v0, 10
	syscall
	jr	$ra

	.globl	Exit2
Exit2:		# end the program, with return status from register a0
	li	$v0, 17
	syscall
	jr	$ra
