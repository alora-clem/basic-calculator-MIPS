# Add your macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#

#  Extracts a bit from a position
#	$source has the register which you want to extract from
#	$position has the position from which you want to extract a bit
#	$endSource is where the bit is placed, will have a 0 or 1
 .macro extract_nth_bit($source, $position, $endSource)
 	#slide to right by given position amount and store in $endSource
 	srlv $endSource, $source, $position
    	and $endSource, 1
 .end_macro 

# Sets a bit to a certain value
#	$source has the value that will get a bit inserted in
#	$position has the value of the position in the reigster from which you want to set a bit
#	$value has a 0 or 1 that you want to insert
#	$end has the ending value
.macro set_n_with($source, $position, $value, $end)
 	li $t0, 1
  	#slide 1 leftwards to needed position
	sllv $end, $t0, $position
 	#if value != 0 set the source value at the posiiton to 1
	bne $value, $zero, set_one
	set_zero:
	or $end, $end, $value
	#invert the value so you get a 0 and all 1's elsewhere			
	not $end, $end		
	and $end, $end, $source	
	j end_macro
	set_one:
	or $end, $end, $source	
	end_macro:
	#end
.end_macro

# Takes the value and complements it if it is negative
#	$input the value to complement, and place back into
.macro twos_complement($input)
	bgt $input, $zero, twos_complement_end
	#takes in input, complements it
	not $a0, $input
	li $a1, 1
	li $a2, '+'
	jal au_logical
	twos_complement_end:
.end_macro 

# Takes the value and complements 
# It is ungaurded meaning a positive number can be passed into it
#	$input the value to complement, and place back into
.macro twos_complement_ungaurded($input)
	#takes in input, complements it
	not $a0, $input
	li $a1, 1
	li $a2, '+'
	jal au_logical
.end_macro 

# Takes a 64 bit number and complements it
#	$inputhi the hi value to be complemented
#	$inputlo the lo value to be complemented
.macro twos_complement_64bit($inputhi, $inputlo)
	move $s5, $inputhi
	twos_complement($inputlo)
	bne $v0, $zero, complementHi
	li $inputlo, -1
	complementHi:
	not $a0, $s5
	beq $a0, $zero, end_64
	li $a1, 1
	li $a2, '+'
	jal au_logical
	end_64:	
.end_macro 

# Replicates one bit based on input
#	$input the value to replicate, 0 or 1
.macro bit_replicator($input)
	bnez  $input, replicate_one
	replicate_zero:
	move $t0, $zero
	j end
	replicate_one:
	li $t0, -1
	end:
.end_macro 

	
