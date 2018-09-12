.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
# TBD: Complete it

#Store
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$a2,  8($sp)
	addi	$fp, $sp, 24

#Body
	
	beq $a2, '+', addition
	beq $a2, '-', subtraction
	beq $a2, '*', multiplication
	beq $a2, '/', division
	#add
	#if a2 = +
addition:
	add $v0, $a0, $a1
	j Restore
subtraction:
	#sub
	#if a2 = -
	sub $v0, $a0, $a1
	j Restore
multiplication:
	#mul
	#if a2 = *
	mul $v0, $a0, $a1
	mfhi $v1
	j Restore
division:
	#div
	#if a2 = /
	div $v0, $a0, $a1
	mfhi $v1
	j Restore
Restore:
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$a2,  8($sp)
	addi	$sp, $sp, 24
	jr	$ra
