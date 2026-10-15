.data

user_input: .space 8


#Strings
opening_message: .asciiz, "Weclome to Tic Tac Toe.\n"

#0 means empty, 1 means used by player 1 and 2 means used by player 2
board: .word 0,0,0,0,0,0,0,0,0

horizontal_line: .asciiz, "_____"
vertical: .asciiz, "|"

player_one: .asciiz, "X" 
player_two: .asciiz, "O" 
space: .asciiz, " "

new_line: .asciiz, "\n"
input_field: .asciiz, "> "

.text

main:
	la $a0, opening_message
	jal print
	
	#Player one's turn ($s1 holds whose turn it is)
	li $s1, 0
	
	game_loop:
		jal print_board
		jal getInt
		
	j exit

print_board:
	#width and length of board
	li $t1, 3
	
	#i value
	li $t2, 0
	print_row:
		#j value
		li $t3, 0
		print_col:
			#print value
			j print_value
			end_print_value:
			
			#print line
			la $a0, vertical
			li $v0, 4
			syscall
			
			addi $t3, $t3, 1
			
			bne $t3, $t1, print_col
		
		#Print new line
		la $a0, new_line
		li $v0, 4
		syscall
		
		#print seperator line
		la $a0, horizontal_line
		li $v0, 4
		syscall
		
		#Print new line
		la $a0, new_line
		li $v0, 4
		syscall
		
		addi $t2, $t2, 1
		
		bne $t2, $t1, print_row
		
	jr $ra


print_value:
	li $t6, 1
	li $t7, 2

	
	
	print_X:
		la $a0, player_one
		j end_select_value
	print_O:
		la $a0, player_two
		j end_select_value
	not_taken:
		la $a0, space
		
	end_select_value:
		
	li $v0, 4
	syscall
	
	j end_print_value
	
	
	
getInt:
	la $a0, input_field
	li $v0, 4
	syscall
	
	li $v0, 5
	la $a0, user_input
	li $a1, 8
	syscall
	
	la $a0, new_line
	li $v0, 4
	syscall
	
	j store_value



store_value:
	la $t0, board
	lw $t2, user_input
	
	mul $t3, $t2, 4
	
	add $t4, $t0, $t3
	
	#If
	beq $s0, $zero, store_x
	#Else
	j store_y
	
	store_x:
		li $t5, 1
		j finish_store
	
	store_y:
		li $t5, 2
		
	finish_store:
		sw $t5, 0($t4)
		j end_turn
		
		
		
end_turn:
	#IF
	beq $s0, $zero, p_one_turn
	#Else
	j p_two_turn
	
	p_one_turn:
		li $s0, 0
		j finish_end_turn
	p_two_turn:
		li $s0, 1
		
	finish_end_turn: 
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