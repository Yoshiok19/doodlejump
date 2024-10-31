#####################################################################
#
# Winter 2021 Assembly Programming Project
# University of Toronto
#
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# - Gradual increase in difficulty. Platforms shrink and change colour as you progress. 
# 
#
#####################################################################
.data
	displayAddress:	.word 0x10008000
	doodler: .word 0	# Doodler address
	platform1: .word 0	# Platform1 address
	platform2: .word 0	# Platform2 address
	platform3: .word 0	# Platform3 address
	jump_count: .word 0	# Status of jump
	hold_count: .word 0	# Status of hold
	out_of_bounds: .word 0x10009000 	
	height_limit: .word 0x10008400
	difficulty: .word 0

.text
	li $t9 0 # Main loop counter
	
	lw $t0 displayAddress	# $t0 stores the base address for display
	addi $t1 $t0 3776
	sw $t1 doodler	# Storing the top left address of the doodler
	
	# Storing initial platform locations
	addi $t2 $t0 2980
	sw $t2 platform1
	addi $t3 $t0 2000 
	sw $t3 platform2
	addi $t4 $t0 648
	sw $t4 platform3 
	
main_loop:
	li $t6 0 # Background loop counter
	li $t5 0
	lw $t0 displayAddress
	lw $t1 doodler
	addi $t5 $t1 128
	lw $t2 platform1
	lw $t3 platform2
	lw $t4 platform3
	li $t7 0xffffff	# Load the colour white into $t7
	
draw_background:
	bge $t6 4096 next2 # while $t6 < 4096
	beq $t0 $t1 draw_half # Draw top half of doodler
	beq $t0 $t5 draw_half # Draw bottom half of doodler
	beq $t0 $t2 draw_platform1 # Draw platform1
	beq $t0 $t3 draw_platform2 # Draw platform2
	beq $t0 $t4 draw_platform3 # Draw platform3
	# Draw empty units
	sw $t7 0($t0)
	addi $t0 $t0 4 # Update bitmap address
	addi $t6 $t6 4 # Update loop counter
	j draw_background

draw_half:
	li $t8 0x9ACD32	# Load the colour blue into $t8
	sw $t8 0($t0)
	sw $t8 4($t0)
	addi $t0 $t0 8 # Update bitmap address
	addi $t6 $t6 8 # Update loop counter
	j draw_background
	
draw_platform1:	
	li $t8 0x87CEFA	# Load the colour green into $t8
	# Check difficulty
	lw $s0 difficulty
	li $s1 8
	li $s2 0
	ble $s0 10 draw1
	li $s1 7
	li $t8 0x4169E1
	ble $s0 20 draw1
	li $s1 6
	li $t8 0x0000FF
	ble $s0 30 draw1
	li $s1 5
	li $t8 0x000080
draw1:
	bgt $s2 $s1 draw_background
	sw $t8 0($t0)
	addi $t0 $t0 4 # Update bitmap address
	addi $t6 $t6 4 # Update main loop counter
	addi $s2 $s2 1 # Update platform loop counter
	j draw1
	
draw_platform2:	
	li $t8 0x87CEFA	# Load the colour green into $t8
	# Check difficulty
	lw $s0 difficulty
	li $s1 8
	li $s2 0
	ble $s0 10 draw2
	li $s1 7
	li $t8 0x4169E1
	ble $s0 20 draw2
	li $s1 6
	li $t8 0x0000FF
	ble $s0 30 draw2
	li $s1 5
	li $t8 0x000080
draw2:
	bgt $s2 $s1 draw_background
	sw $t8 0($t0)
	addi $t0 $t0 4 # Update bitmap address
	addi $t6 $t6 4 # Update main loop counter
	addi $s2 $s2 1 # Update platform loop counter
	j draw2
	
draw_platform3:	
	li $t8 0x87CEFA
	# Check difficulty
	lw $s0 difficulty
	li $s1 8
	li $s2 0
	ble $s0 10 draw3
	li $s1 7
	li $t8 0x4169E1
	ble $s0 20 draw3
	li $s1 6
	li $t8 0x0000FF
	ble $s0 30 draw3
	li $s1 5
	li $t8 0x000080
draw3:
	bgt $s2 $s1 draw_background
	sw $t8 0($t0)
	addi $t0 $t0 4 # Update bitmap address
	addi $t6 $t6 4 # Update main loop counter
	addi $s2 $s2 1 # Update platform loop counter
	j draw3
	
next2:
	li $t1 0
	addi $sp $sp -4
	sw $t1 0($sp)
	jal draw_doodler
	j check_landing
	
draw_doodler:
	lw $t1 doodler	# Loading the address of the doodler
	li $t2 0xffffff # Load white into $t2
	lw $t3 0($sp)
	addi $sp $sp 4
	# Remove previous squares of the doodler
	sw $t2 0($t1)
	sw $t2 4($t1)
	sw $t2 128($t1)
	sw $t2 132($t1)
	li $t2 0x9ACD32 # Load doodler colour into $t2
	# Update doodler location
	add $t1 $t1 $t3
	sw $t1 doodler
	# Draw all squares of the doodler
	sw $t2 0($t1)
	sw $t2 4($t1)
	sw $t2 128($t1)
	sw $t2 132($t1)
	
	jr $ra
	
check_landing:
	lw $t1 jump_count
	lw $t8 hold_count
	# Only land if falling:
	blt $t1 21 check_input
	bne $t8 0 check_input
	# Loading platforms
	lw $t2 platform1
	lw $t3 platform2
	lw $t4 platform3
	
	# 1 unit above the platforms
	addi $t2 $t2 -128
	addi $t3 $t3 -128
	addi $t4 $t4 -128
	
	# Platform 1 collision check
	addi $sp $sp -4
	sw $t2 0($sp)
	jal check_collisions
	lw $t7 0($sp)
	addi $sp $sp 4
	beq $t7 0 check_input
	# Platform 2 collision check
	addi $sp $sp -4
	sw $t3 0($sp)
	jal check_collisions
	lw $t7 0($sp)
	addi $sp $sp 4
	beq $t7 0 check_input
	# Platform 3 collision check
	addi $sp $sp -4
	sw $t4 0($sp)
	jal check_collisions
	lw $t7 0($sp)
	addi $sp $sp 4
	beq $t7 0 check_input
	
	j check_input

check_collisions:
	# Loading doodler
	lw $t1 doodler
	addi $t1 $t1 128 # $t1 = bottom left of doodler
	addi $t5 $t1 4 # $t5 = bottom right of doodler
	# Popping stack for platform address
	lw $t2 0($sp)
	addi $sp $sp 4
	# Collision check
	beq $t2 $t1 collide
	beq $t2 $t5 collide
	addi $t2 $t2 4
	beq $t2 $t1 collide
	beq $t2 $t5 collide
	addi $t2 $t2 4
	beq $t2 $t1 collide
	beq $t2 $t5 collide
	addi $t2 $t2 4
	beq $t2 $t1 collide
	beq $t2 $t5 collide
	addi $t2 $t2 4
	beq $t2 $t1 collide
	beq $t2 $t5 collide
	# Check difficulty
	lw $s0 difficulty
	ble $s0 10 difficulty_10
	ble $s0 20 difficulty_20
	ble $s0 30 difficulty_30
	j no_collisions
	
difficulty_10:
	addi $t2 $t2 4
	beq $t2 $t1 collide
	beq $t2 $t5 collide
	addi $t2 $t2 4
	beq $t2 $t1 collide
	beq $t2 $t5 collide
	addi $t2 $t2 4
	beq $t2 $t1 collide
	beq $t2 $t5 collide
	j no_collisions
difficulty_20:
	addi $t2 $t2 4
	beq $t2 $t1 collide
	beq $t2 $t5 collide
	addi $t2 $t2 4
	beq $t2 $t1 collide
	beq $t2 $t5 collide
	j no_collisions	
difficulty_30:
	addi $t2 $t2 4
	beq $t2 $t1 collide
	beq $t2 $t5 collide
	j no_collisions	
	
no_collisions:
	# No collision. Return 1
	li $t6 1
	addi $sp $sp -4
	sw $t6 0($sp)
	jr $ra
	
collide:
	# Collision. Reset jump_count and return 0
	sw $zero jump_count
	addi $sp $sp -4
	sw $zero 0($sp)
	jr $ra
	
check_input:
	lw $t1 0xffff0000
	beq $t1 0 next3 # If no keyboard press continue
	j user_input_true
	
user_input_true:
	lw $t1 0xffff0004
	beq $t1 0x6a move_left
	j move_right

move_left:
	li $t1 -4
	# Push the shift amount and call draw_doodler
	addi $sp $sp -4
	sw $t1 0($sp)
	jal draw_doodler
	
move_right:	
	lw $t1 0xffff0004
	bne $t1, 0x6b, next3
	
	li $t1 4
	# Push the shift amount and call draw_doodler
	addi $sp $sp -4
	sw $t1 0($sp)
	jal draw_doodler
	
next3:	

check_height:
	lw $t1 doodler
	lw $t2 height_limit
	lw $t3 jump_count
	lw $t4 hold_count
	ble $t1 $t2 hold_doodler # If Doodler above height limit
	bgt $t4 0 hold_doodler
	j check_game_over

hold_doodler:
 	lw $t1 doodler
 	lw $t2 jump_count 
 	lw $t3 hold_count
 	bne $t3 0 move_platforms_down # If holding
 	li $t4 21
 	sub $t3 $t4 $t2 # How much of the jump is left
 	sw $t3 hold_count
 	li $t5 21
 	sw $t5 jump_count
 
move_platforms_down:
	lw $t3 hold_count
	beq $t3 0 check_game_over
	lw $t4 platform1
	lw $t5 platform2
	lw $t6 platform3
	addi $t4 $t4 128
	addi $t5 $t5 128
	addi $t6 $t6 128
	addi $t3 $t3 -1
	sw $t4 platform1
	sw $t5 platform2
	sw $t6 platform3
	sw $t3 hold_count
	bgt $t3 0 reset_platforms
	li $t7 21
	sw $t7 jump_count

reset_platforms:
	
	lw $t7 out_of_bounds
	bgt $t4 $t7 reset_platform1
	bgt $t5 $t7 reset_platform2
	bgt $t6 $t7 reset_platform3
	
	j check_game_over
 	
reset_platform1:
 	li $v0 42
 	li $a1 24
 	syscall
 	lw $t0 displayAddress
 	li $t2 4
 	mult $a0 $t2
 	mflo $t2
 	add $t1 $t0 $t2
 	sw $t1 platform1
	# Difficulty increment(everytime platform is reset)
 	lw $t3 difficulty
 	addi $t3 $t3 1
 	sw $t3 difficulty
 	j check_game_over
 	
reset_platform2:
 	li $v0 42
 	li $a1 24
 	syscall
 	lw $t0 displayAddress
 	li $t2 4
 	mult $a0 $t2
 	mflo $t2
 	add $t1 $t0 $t2
 	sw $t1 platform2
 	# Difficulty increment(everytime platform is reset)
 	lw $t3 difficulty
 	addi $t3 $t3 1
 	sw $t3 difficulty
 	j check_game_over
 
reset_platform3:
  	li $v0 42
 	li $a1 24
 	syscall
 	lw $t0 displayAddress
 	li $t2 4
 	mult $a0 $t2
 	mflo $t2
 	add $t1 $t0 $t2
 	sw $t1 platform3
 	# Difficulty increment(everytime platform is reset)
 	lw $t3 difficulty
 	addi $t3 $t3 1
 	sw $t3 difficulty
 	j check_game_over
 	
check_game_over:
	lw $t1 doodler
	lw $t2 out_of_bounds
	bgt $t1 $t2 game_over
		
doodle_jump:
	lw $t3 jump_count
	bgt $t3 20 doodle_fall # Check if doodler should fall
	addi $t3 $t3 1
	sw $t3 jump_count
	
	li $t1 -128
	# Push the shift amount and call draw_doodler
	addi $sp $sp -4
	sw $t1 0($sp)
	jal draw_doodler
	j finish
	
doodle_fall:
	lw $t2 hold_count
	bne $t2 0 finish
	li $t1 128
	# Push the shift amount and call draw_doodler
	addi $sp $sp -4
	sw $t1 0($sp)
	jal draw_doodler
	j finish

finish:
	li $v0 32
	li $a0 40
	syscall
	j main_loop
	
game_over:
	# Drawing game over screen
	lw $t0 displayAddress
	addi $t0 $t0 1060
	addi $sp $sp -4
	sw $t0 0 ($sp)
	jal draw_G
	
	lw $t0 displayAddress
	addi $t0 $t0 1084
	addi $sp $sp -4
	sw $t0 0($sp)
	jal draw_G
	
draw_EP:
	lw $t0 displayAddress
	li $t1 0xFF6347
	addi $t0 $t0 1108
	sw $t1 0($t0)
	sw $t1 128($t0)
	sw $t1 256($t0)
	sw $t1 384($t0)
	sw $t1 512($t0)
	sw $t1 768($t0)
	
	j Exit
draw_G:
	lw $t0 0($sp) # Pop address of top left of G
	addi $sp $sp 4
	li $t1 0xFF6347
	sw $t1 4($t0)
	sw $t1 8($t0)
	sw $t1 12($t0)
	sw $t1 128($t0)
	sw $t1 144($t0)
	sw $t1 256($t0)
	sw $t1 384($t0)
	sw $t1 392($t0)
	sw $t1 396($t0)
	sw $t1 400($t0)
	sw $t1 512($t0)
	sw $t1 520($t0)
	sw $t1 528($t0)
	sw $t1 640($t0)
	sw $t1 656($t0)
	sw $t1 772($t0)
	sw $t1 776($t0)
	sw $t1 780($t0)
	
	jr $ra
	
Exit:
	# Sleeping for a second then exiting
	li $v0 32
	li $a0 1000
	syscall
	li $v0, 10
	syscall
