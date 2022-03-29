#####################################################################
#
# CSCB58 Winter 2022 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Denis Dekhtyarenko, 1006316675, dekhtyar, d.dekhtyarenko@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed)
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 512 (update this as needed)
# - Display height in pixels: 1024 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... Features TODO: double jump, fail condition: no health, win condition: timer, health bar and timer (score), moving platforms, enemies shoot back
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes and please share this project github link as well https://github.com/Umenemo/CSCB58_Final (Private and can't be accessed until end of semester as per the handout)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.eqv BASE_ADDRESS 0x10008000
.eqv blue 0x0056c9ef
.eqv spike_inside 0x00dfdfdf
.eqv spike_outline 0x002f2f2f	
.eqv board_back 0x004a4a4a

.data

.text
main:
	# paint the sky, scoreboard and spikes
	li $t0, blue
	li $t1, BASE_ADDRESS	# $t1 is the counter
	addi $t2, $t1, 27648	# $t2 = target address (64px * 108px * 4 bytes per unit = 27648)
start_loop_paint_sky:
	bge $t1, $t2, end_loop_paint_sky	# run while $t1 < $t2
	sw $t0, 0($t1)		# set the unit to blue
	addi $t1, $t1, 4	# increment counter
	j start_loop_paint_sky	
end_loop_paint_sky:	
	
	addi $t1, $t1, 256	# skip a line
	addi $t2, $t2, 5120 	# $t2 = target address (64px * 20px * 4 bytes per unit - 256 (last line) = 5120 )
	li $t3, 61	# units per row
	li $t4, 0	# counter for inner start_loop
	li $t0, board_back
start_loop_paint_board2:
	bge $t1, $t2, end_loop_paint_board2	# run while $t1 < $t2
	addi $t1, $t1, 4	# skip first pixel
start_loop_paint_board1:
	bgt $t4, $t3, end_loop_paint_board1	# run while $t4 < 62
	sw $t0, 0($t1)		# set the unit to board_back (dark grey)
	addi $t1, $t1, 4	# increment counters
	addi $t4, $t4, 1	
	j start_loop_paint_board1	
end_loop_paint_board1:
	li $t4, 0	# $t4 = 0, reset counter for inner start_loop 
	addi $t1, $t1, 4	# skip last pixel 
	j start_loop_paint_board2
end_loop_paint_board2:
	# left and right spikes 
	li $t0, spike_outline
	li $s7, spike_inside
	li $t9, BASE_ADDRESS
	# pointer for each side of the wall. $t1 is left, $t2 is right
	addi $t1, $t9, 2560	# row 10 unit 0
	addi $t2, $t9, 2812	# row 10 unit 63
	li $t3, 0	# $t3 = counter for 12 spikes
	li $t4, 12	# $t4 = target for $t3
	li $t5, 0	# $t5 = counter for first 3 pixels
	li $t6, 3	# $t6 = target for $t5
	li $t7, 0	# $t7 = counter for last 4 pixels
	li $t8, 3	# $t8 = target for $t7
start_loop_paint_spike1: # outline of the spike
	bge $t3, $t4, end_loop_paint_spike1	# run while $t3 < 12
	addi $s3, $t6, 2	# $s3 = heigth of next fill, starts at 5
start_loop_paint_spike2: # top 4 pixels + filling
	bge $t5, $t6, end_loop_paint_spike2	# run while $t5 < 4
	sw $t0, 0($t1)		# set the units to spike_outline (dark grey)
	sw $t0, 0($t2)
	
	move $s0, $s3		# get height of next fill
	move $s1, $t1		# copy current pointers
	move $s2, $t2
start_loop_paint_spike4:	# filling
	blez $s0, end_loop_paint_spike4	# run while $s0 > 0	
	addi $s1, $s1, 256	# move down one row
	addi $s2, $s2, 256
	sw $s7, 0($s1)		# set the units to spike_inside (grey)
	sw $s7, 0($s2)
	addi $s0, $s0, -1	# decrement
	j start_loop_paint_spike4
end_loop_paint_spike4:
	addi $s3, $s3, -2	# match the next column of filling to the height of the spike
	
	addi $t1, $t1, 260	# go down 1 right 1
	addi $t2, $t2, 252	# go down 1 left 1
	addi $t5, $t5, 1	# increment counter
	j start_loop_paint_spike2
end_loop_paint_spike2:

start_loop_paint_spike3:	#bottom 3 pixels
	bge $t7, $t8, end_loop_paint_spike3	# run while $t7 < 3
	sw $t0, 0($t1)		# set the units to spike_outline (dark grey)
	sw $t0, 0($t2)
	addi $t1, $t1, 252	# go down 1 left 1
	addi $t2, $t2, 260	# go down 1 right 1
	addi $t7, $t7, 1	# increment counter
	j start_loop_paint_spike3
end_loop_paint_spike3:

	sw $t0, 0($t1)		# last pixel before next spike
	sw $t0, 0($t2)
	li $t5, 0	# $t5 = counter for first 4 pixels
	li $t7, 0	# $t7 = counter for last 3 pixels
	addi $t1, $t1, 512	# go down 2 rows each side
	addi $t2, $t2, 512	
	addi $t3, $t3, 1	# increment counter
	j start_loop_paint_spike1
end_loop_paint_spike1:

	# bottom spikes 
	addi $t1, $t9, 27392	# $t1 = row 107 unit 0
	li $t3, 0
	li $t4, 8		# draw 7 spikes
start_loop_paint_spike5: # outline of the spike
	bge $t3, $t4, end_loop_paint_spike5	# run while $t3 < 8
	addi $s3, $t6, 2	# $s3 = width of next fill, starts at 5
start_loop_paint_spike6: # left 4 pixels + filling
	bge $t5, $t6, end_loop_paint_spike6	# run while $t5 < 4
	sw $t0, 0($t1)		# set the units to spike_outline (dark grey)
	
	move $s0, $s3		# get width of next fill
	move $s1, $t1		# copy current pointer
start_loop_paint_spike8:	# filling
	blez $s0, end_loop_paint_spike8	# run while $s0 > 0	
	addi $s1, $s1, 4	# move right one pixel
	sw $s7, 0($s1)		# set the units to spike_inside (grey)
	addi $s0, $s0, -1	# decrement
	j start_loop_paint_spike8
end_loop_paint_spike8:
	addi $s3, $s3, -2	# match the next column of filling to the height of the spike
	
	addi $t1, $t1, -252	# go up 1 right 1
	addi $t5, $t5, 1	# increment counter
	j start_loop_paint_spike6
end_loop_paint_spike6:

start_loop_paint_spike7:	# bottom 3 pixels
	bge $t7, $t8, end_loop_paint_spike7	# run while $t7 < 3
	sw $t0, 0($t1)		# set the units to spike_outline (dark grey)
	addi $t1, $t1, 260	# go down 1 right 1
	addi $t7, $t7, 1	# increment counter
	j start_loop_paint_spike7
end_loop_paint_spike7:

	sw $t0, 0($t1)		# last pixel before next spike
	li $t5, 0	# $t5 = counter for first 4 pixels
	li $t7, 0	# $t7 = counter for last 3 pixels
	addi $t1, $t1, 8	# go right 2 pixels
	addi $t3, $t3, 1	# increment counter
	j start_loop_paint_spike5
end_loop_paint_spike5:

	li $v0, 10 # terminate the program gracefully
	syscall