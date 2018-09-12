.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
# TBD: Complete it
StoreFrame:
	addi	$sp, $sp, -52
	sw	$fp, 52($sp)
	sw	$ra, 48($sp)
	sw	$a0, 44($sp)
	sw	$a1, 40($sp)
	sw	$s0, 36($sp)
	sw	$s1, 32($sp)
	sw	$s2, 28($sp)
	sw	$s3, 24($sp)
	sw	$s4, 20($sp)
	sw	$s5, 16($sp)
	sw 	$s6, 12($sp)
	sw	$s7, 8($sp)
	addi	$fp, $sp, 52
determine_operation:
	li $t0, '+'						
	beq $a2, $t0, add_sub_logical
	li $t0, '-'
	beq $a2, $t0, add_sub_logical
	li $t0, '*'						
	beq $a2, $t0, mult_logical
	li $t0, '/'						
	beq $a2, $t0, div_logical
add_sub_logical:
	# set i = 0
	li $s0, 0
	# set s = 0
	li $s1, 0
	# set c = $a2[0]
	li $s2, 0
	li $t0, '-'
	beq $a2, $t0, subtraction
	j addition
subtraction:
	# if subtraction invert
	not $a1, $a1
	#set carry to 1
	li $s2, 1
addition:
	#set future registers to 0
	li $t3, 0 #ith bit of a0
	li $t1, 0 #ith bit of a1
	#extract ith bits
	extract_nth_bit($a0,$s0, $t3)
	extract_nth_bit($a1,$s0, $t1)
	# y = $a0[i]+ $a1[i]+ c
	# $t5 = y
	xor $s3, $t3, $t1
	xor $s3, $s3, $s2 
	#calculate new carry value = carry in(AxorB)+AB
	xor $t0, $t3, $t1		
	and $s2, $s2, $t0			
	and $t0, $t3, $t1		
	or  $s2, $s2, $t0	
	#set sum bit with found value
	set_n_with($s1, $s0, $s3, $v0)
	#move sum to answer register
	move $s1, $v0
	# i++
	add $s0, $s0, 1		
	li $t0, 32 
	# if i == 32 end
	beq $s0, $t0, restore	
	# else i != 32 jump back up to addition
	j addition		
mult_logical:
	#I
	move $s0, $zero
	#H
	move $s1, $zero
	#L
	move $s2, $a0
	#M
	move $s3, $a1
	#temp duplicate of data
	move $s4, $a0
	move $s5, $a1
	move $s6, $a2
	j mult_signed
mult_signed:	
	#get sign and store in s7
	li $t1, 31
	extract_nth_bit($s4, $t1, $t0)
	extract_nth_bit($s5, $t1, $t2)
	xor $s7, $t0, $t2
	
	#complement if negative
	move $t0, $s4
	move $v0, $t0
	twos_complement($t0)
	move $s2, $v0
	move $t1, $s5
	move $v0, $t1
	twos_complement($t1)
	move $s3, $v0
	#do unsigned multiplication
	jal mult_unsigned
	li $t1, 1
	beq $s7, $t1, twos_complement_64bit
	j restore
	#if negative complement the result
	twos_complement_64bit:
	twos_complement_64bit($v0, $v1)
	j restore
mult_unsigned:
	mul_loop:
	#R extract LSB and replicate
	extract_nth_bit($s2, $zero, $v0)
	bit_replicator($v0)
	move $v0, $t0
	#Calculate X = (mask AND M) + H
	and $t0, $v0, $s3
	move $t8, $ra
	li $a2, '+'
	move $a0, $s1
	move $a1, $t0
	jal au_logical
	move $s1, $v0
	move $ra, $t8
	#slide L one right
	srl $s2, $s2, 1
	#extract LSB of H
	extract_nth_bit($s1, $zero, $v0)
	li $t4, 31
	#set MSB of L with that bit
	set_n_with($s2,$t4,$v0, $t9)
	move $s2, $t9
	#slide H one right
	srl $s1, $s1, 1
	#i++
	addi $s0, $s0, 1
	#continue loop if < 32
	li $t0, 32
	beq $s0, $t0, mult_finished
	j mul_loop
	mult_finished:
	move $v1, $s1
	move $v0, $s2
	jr $ra
div_logical:
	move $v0, $zero
	move $v1, $zero
	#i
	li $s0, 0
	#q
	move $s1, $a0
	#d
	move $s2, $a1
	#r
	li $s3, 0
	#temp duplicate of data
	move $s4, $a0
	move $s5, $a1
	move $s6, $a2
	j div_signed	
div_unsigned:
	li $s0, 0
	li $s3, 0
	div_loop:
	#slide  R
	sll $s3, $s3, 1
	li $t1, 31 
	#extract MSB of Q
	extract_nth_bit($s1, $t1, $t2)
	#set R LSB with MSB of Q
	set_n_with($s3, $zero, $t2, $t9)
	move $s3, $t9
	#slide Q
	sll $s1, $s1, 1
	#calculate S = R-D
	move $t8, $ra
	li $a2, '-'
	move $a0, $s3
	move $a1, $s2
	jal au_logical
	move $t9, $v0
	move $ra, $t8
	blt $t9, $zero, skip
	#if >= 0 store
	move $s3, $t9
	li $t1, 1
	set_n_with($s1, $zero, $t1, $t8)
	move $s1, $t8
	skip:
	#else redo loop
	addi $s0, $s0, 1
	li $t0, 32
	beq $s0, $t0, end
	j div_loop
	end:
	move $v0, $s1
	move $v1, $s3
	jr $ra
div_signed:
	
	move $t1, $a1
	#complement if negative
	move $t0, $s4
	move $v0, $t0
	twos_complement($t0)
	move $s1, $v0
	move $t1, $s5
	move $v0, $t1
	twos_complement($t1)
	move $s2, $v0
	#do unsigned division
	jal div_unsigned
	#extract the MSB of original inputs to get sign
	li $t2, 31
	extract_nth_bit($s4, $t2, $t0)
	extract_nth_bit($s5, $t2, $t1)
	xor $s7, $t0, $t1
	beqz $s7, check_2
	#if it is negative complement the quotient
	twos_complement_ungaurded($v0)
	check_2:
	li $t2, 31
	extract_nth_bit($s4, $t2, $t0)
	extract_nth_bit($zero, $t2, $t1)
	xor $s7, $t0, $t1
	beqz  $s7, end_signed_div
	#complement the remainder if necessary
	move $t9, $v0
	twos_complement_ungaurded($v1)
	move $v1, $v0
	move $v0, $t9
	end_signed_div:
	j restore
restore: 
	lw	$fp, 52($sp)
	lw	$ra, 48($sp)
	lw	$a0, 44($sp)
	lw	$a1, 40($sp)
	lw	$s0, 36($sp)
	lw	$s1, 32($sp)
	lw	$s2, 28($sp)
	lw	$s3, 24($sp)
	lw	$s4, 20($sp)
	lw 	$s5, 16($sp)
	lw 	$s6, 12($sp)
	lw 	$s7, 8($sp)
	addi	$sp, $sp 52
	jr	$ra
