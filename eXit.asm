.data 0x10010000

bitmap: .space 1024

user_input: .space 30

#Colors
white: .word 0x00FFFFFF
green: .word 0x0000FF00
yellow: .word 0x00FFFF00
red: .word 0x00FF0000

new_line: .asciiz, "\n"

#Hazzard Symbol
hazard:
.byte 0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0
.byte 0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0
.byte 0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0
.byte 0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0
.byte 0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0
.byte 0,0,0,0,1,1,0,1,1,0,1,1,0,0,0,0
.byte 0,0,0,1,1,0,0,1,1,0,0,1,1,0,0,0
.byte 0,0,0,1,1,0,0,1,1,0,0,1,1,0,0,0
.byte 0,0,1,1,0,0,0,1,1,0,0,0,1,1,0,0
.byte 0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
.byte 0,1,1,0,0,0,0,1,1,0,0,0,0,1,1,0
.byte 0,1,1,0,0,0,0,1,1,0,0,0,0,1,1,0
.byte 1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1
.byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1


#NuclearTexts
nuclear_start: .asciiz, "The power plant is using too much power it must be disengaged to stop it from destroying the world.\nYou find a Computer and boot it.\n\neXit"

nuclear_warning: .asciiz, "\nWarning! The plant is at 110% capacity the overflow capacity will explode at 120%\n\n"

nuclear_exploded: .asciiz, "Failed to disegngage, the nuclear power plant has destroyed the world."
nuclear_disengaged: .asciiz, "Plant Disengaged"

#Opening Route
opening: .asciiz, "\nYou\'re trapped in a dungeon with your friend.\nYou see a barrel. What do you do? (Move the barrel/Sit down next to your friend)\n"

move_barrel: .asciiz, "Move the barrel\n"
sitdown: .asciiz, "Sit down next to your friend\n"

input_field: .asciiz, "> "

#Losing Route
losing_01: .asciiz, "The barrel rolls aside and you find a secret tunnel.\nWhat do you do? (Enter the tunnel)\n"

enter_tunnel: .asciiz, "Enter the tunnel\n"

losing_02: .asciiz, "You start to escape but your friend is too weak to go with you. \nThey hand you a note. What do you do? (Read note/Keep going)\n"

read_note: .asciiz, "Read note\n"
keep_going: .asciiz, "Keep going\n"

losing_03: .asciiz, "It is too dark to read the note.\nWhat do you do? (Keep going)\n"

losing_04: .asciiz, "You crawl through the tunnel and the tunnel leads you to the beach.\nWhat do you do? (Look/Give up)\n"

look: .asciiz, "Look\n"

losing_05: .asciiz, "In the water you see a boat.\nWhat do you do? (Get on the boat)\n"

board_boat: .asciiz, "Get on the boat\n"

losing_06 : "Congratulations, you're heading to a new world!\n"

#Winning texts
winning_01: .asciiz, "Your friend hands you a note.\nWhat do you do? (Leave them/Light a match)\n"

light_match: .asciiz, "Light a match\n"

winning_02: .asciiz,  "The note says, \"Don\'t leave me here.\"\nDo you leave your friend or stay? (Leave/Stay)\n"

stay: .asciiz, "Stay\n"

.text

main:
	lw $t9, green
	jal start_draw

	la $a0, nuclear_start
	jal print
	
	la $a0, opening
	jal print
	
	jal getString
	
	#comapare opening
	la $a0, move_barrel
	la $a1, user_input
	jal compare_strings
	
	beq $t5, $t6, losing_path
	
	#comapare opening
	la $a0, sitdown
	la $a1, user_input
	jal compare_strings
	
	beq $t5, $t6, winning_path
	
	j meltdown


start_draw:
	la $t0, bitmap
	la $t1, hazard
	li $t5, 256
	j draw_loop


draw_loop:
	lbu $t3, 0($t1)
	beqz $t3, draw_white
	j draw_status
	
draw_status:	
	move $t7, $t9
	j draw_pixel

draw_white:
	lw $t7, white
	j draw_pixel


draw_pixel:
	sw $t7, 0($t0)
	addiu $t0, $t0, 4
	addiu $t1, $t1, 1
	addiu $t5, $t5, -1
	
	bnez $t5, draw_loop
	jr $ra
	

losing_path:
	Enter_Tunnel:
		la $a0, losing_01
		jal print
	
		jal getString
	
		la $a0, enter_tunnel
		la $a1, user_input
		jal compare_strings
	
		beq $t5, $zero, meltdown
	#End Enter Tunnel

	Hurt_Friend:
		la $a0, losing_02
		jal print
	
		jal getString
	
		la $a0, keep_going
		la $a1, user_input
		jal compare_strings
	
		beq $t5, $t6, Left_Tunnel

		la $a0, read_note
		la $a1, user_input
		jal compare_strings
		
		bne $t5, $t6, meltdown
	#End Hurt Friend
	
	Dark_Note:	
		la $a0, losing_03
		jal print
	
		jal getString
	
		la $a0, keep_going
		la $a1, user_input
		jal compare_strings
	
		bne $t5, $t6, meltdown
	#End Dark Note
	
	lw $t9, yellow
	jal start_draw
	
	jal warning_message
		
	Left_Tunnel:
		la $a0, losing_04
		jal print
	
		jal getString

		la $a0, look
		la $a1, user_input
		jal compare_strings
		
		bne $t5, $t6, meltdown
	#End Left Tunnel
	
	Found_Ship:
		la $a0, losing_05
		jal print
	
		jal getString
		
		la $a0, board_boat
		la $a1, user_input
		jal compare_strings
	
		bne $t5, $t6, meltdown
	#End Found Ship

	Completed_Lost:
		la $a0, losing_06
		jal print
	
		j meltdown
	#End Losing Route



winning_path:
	Sitdown:
		la $a0, winning_01
		jal print
	
		jal getString
		
		la $a0, light_match
		la $a1, user_input
		jal compare_strings
		
		bne $t5, $t6, meltdown
	#end sitdown
	
	
	lw $t9, yellow
	jal start_draw
	
	jal warning_message
		
		
	Read_Note:
		la $a0, winning_02
		jal print
	
		jal getString
		
		la $a0, stay
		la $a1, user_input
		jal compare_strings
		
		bne $t5, $t6, meltdown


	Dissengage:
		la $a0, nuclear_disengaged
		jal print
	
		lw $t9, green
		jal start_draw
	
		j exit
	#End disengage

	

compare_strings:
	# Register t5 holds return value and t6 holds one so we can compare the two to branch if we succeed
	li $t6, 1
	
	loop:
		lb $t0, 0($a0)
		lb $t1, 0($a1)
	
		#return false
		bne $t0, $t1, not_equal
		#return true
		beq $t1, $zero, equal
		
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		j loop
	
	equal:
		li $t5, 1
		jr $ra
		
	not_equal:
		li $t5, 0
		jr $ra



warning_message:
	la $a0, nuclear_warning
	li $v0, 4
	syscall

	jr $ra
	
	

meltdown:
	lw $t9, red
	jal start_draw

	la $a0, nuclear_exploded
	jal print
	
	j exit


	
getString:
	la $a0, input_field
	li $v0, 4
	syscall
	
	li $v0, 8
	la $a0, user_input
	li $a1, 30
	syscall
	
	la $a0, new_line
	li $v0, 4
	syscall
	
	jr $ra



#Prints the string in $a0 and a new line
print:
	li $v0, 4
	syscall
	
	la $a0, new_line
	li $v0, 4
	syscall
	jr $ra



#Exits the program
exit:
	li $v0, 10
	syscall
