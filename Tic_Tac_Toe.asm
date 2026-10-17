.data 0x10010000

#0 means empty, 1 means used by player 1 and 2 means used by player 2
board: .word 0,0,0,0,0,0,0,0,0

user_input: .space 8

#Strings
opening_message: .asciiz, "Weclome to Tic Tac Toe.\n"

invalid_input: .asciiz, "You inputed an invalid index make sure it is between 1-9.and the spot isn't taken"

player1_wins: .asciiz, "Player one wins!"
tie: .asciiz, "Game has ended in a draw."
player2_wins: .asciiz, "Player two wins!"

horizontal_line: .asciiz, "+-----+"
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
	
	#Player one's turn ($s0 holds whose turn it is)
	li $s0, 0
	
	#$s2 holds the number of turn we are on
	li $s2, 0	
	#$s3 holds the max amount of turns
	li $s3, 9
	
	#The main game loop
	game_loop:
		#Show the current board
		jal print_board
		
		#Grab user input
		jal getInt
		
		#Increment the turn number
		addi $s2, $s2, 1
		
		#Check if we have played our last turn
		bne $s2, $s3, game_loop
	
	#Print the final board
	jal print_board
	
	#Since no win was detected this must end in a tie
	la $a0, tie
	jal print 
	
	j exit

print_board:
	#print seperator line
	la $a0, horizontal_line
	li $v0, 4
	syscall
		
	#Print starting line
	la $a0, new_line
	syscall
	
	#Stores the address
	la $t0, board
	
	#width and length of board
	li $t1, 3
	
	#$t2 is out i-value
	li $t2, 0
	print_row:
		#print intial vertical line
		la $a0, vertical
		syscall	
	
		#$t3 is out j-value
		li $t3, 0
		print_col:
			#print value
			j print_value
			end_print_value:
			
			#print line
			la $a0, vertical
			li $v0, 4
			syscall
			
			#Increment the col index
			addi $t3, $t3, 1
			
			#Check if we are on a valid column
			bne $t3, $t1, print_col
		
		#Print a new line
		la $a0, new_line
		syscall
		
		#Print the final seperator line
		la $a0, horizontal_line
		syscall
		
		#Print new line
		la $a0, new_line
		syscall
		
		#Increment the row index
		addi $t2, $t2, 1
		
		#Check if we are on a valid row
		bne $t2, $t1, print_row
		
	jr $ra



print_value:
	#Calculate the address
	lw $t4, 0($t0)
	
	#If the value is zero than it it empty
	beq $t4, $zero, not_taken
	
	#Check if are value is 2 which corresponds to O
	li $t5, 2
	beq $t4, $t5, print_O
	
	#Else the value is 1 and corresponds to X
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
	
	#Increment our address
	add $t0, $t0, 4
	
	j end_print_value
	
	
	
getInt:
	#Print a new line
	li $v0, 4
	la $a0, new_line
	syscall
	
	#Print the input field
	la $a0, input_field
	syscall
	
	#Get the user input integer
	li $v0, 5
	la $a0, user_input
	li $a1, 8
	syscall
	
	#Checks if the input is valid
	sanitize_input:			
		#Check if the input is within 1 - 9
		bltu $v0, 1, found_bad_input
		bgtu $v0, 9, found_bad_input
	
		#Turn the user input into and index
		subi $v0, $v0, 1
	
		#Use the index to see if the space is avalible, meaning the value is zero
		la $t0, board
		
		mul $t2, $v0, 4
		add $t4,$t2,$t0
		
		lw $t5, 0($t4)
		
		bne $t5, $zero, found_bad_input
		
		j found_good_input
		
	#Show an error message and re-get input
	found_bad_input:
		li $v0, 4
		la $a0, invalid_input
		syscall
		
		la $a0, new_line
		syscall
		
		j getInt
	
	#Store the valid chooen index at user_input
	found_good_input:
		#Store the chosen index at $t1
		move $t1, $v0
	
		la $a0, new_line
		li $v0, 4
		syscall
	
		#t1 is still the user choosen index
		j store_value


#Stores the players choice on the board
store_value:
	#Store the boards address at $t0
	la $t0, board
	
	#Calculate the address to store the players value at
	mul $t2, $t1, 4
	add $t4,$t2,$t0
	
	#If it's players one turn meaning $s0 == 0
	beq $s0, $zero, store_X
	#Else
	j store_O
	
	store_X:
		li $t5, 1
		j finish_store
	
	store_O:
		li $t5, 2
		
	#Store the value of the player at the stated address
	finish_store:
		sw $t5, 0($t4)
		j check_for_winner



#Checks whether the player current player has won
check_for_winner:
	#$s5 holds the boards value
	la $s5, board
		
	#$t0 holds the length needed for a connection to be long enough to win
	li $t0, 3
	
	#Get the current player index
	bne $s0, $zero, set_index_player2
	
	set_index_player1:
		li $t7, 1
		j end_set_player_index
		
	set_index_player2:
		li $t7, 2

	end_set_player_index:
	
	#I-value
	li $t1, 0
	check_horizontal:
		#j-value
		li $t2, 0 
		check_horizontal_indvidual:
			#Calculate the address to check
			mul $t3, $t2, 4
			add $t4,$s5,$t3
		
			#Load in the value
			lw $t5, 0($t4)
			
			#Check if it is the players value
			bne $t5, $t7, failed_horizontal_check
			
			#Increment j
			addi $t2, $t2, 1
			
			#Keep checking values in till we have found 3 in a row
			bne $t2, $t0, check_horizontal_indvidual
		
			j found_winner
		
		failed_horizontal_check:
			#Increment i
			addi $t1, $t1, 1
			
			#offset by a row
			addi $s5, $s5, 12
			
			#Check the next row until we have checked all three
			bne $t0, $t1, check_horizontal
	
	
	#Refresh board address
	la $s5, board
	
	#I-value
	li $t1, 0
	check_vertical:
		#j-value
		li $t2, 0 
		
		move $t4, $s5
		check_vertical_indvidual:
			#grab the value at address $t4
			lw $t5, 0($t4)
		
			#Check if the value held matches the player
			bne $t5, $t7, failed_vertical_check
			
			#Increment j
			addi $t2, $t2, 1
			
			#Increment Index
			add $t4,$t4,12
			
			#Check loop condition
			bne $t2, $t0, check_vertical_indvidual
		
			j found_winner
		
		failed_vertical_check:
			#increment i
			addi $t1, $t1, 1
			#offset by a row
			addi $s5, $s5, 4
			#Keep checking columns until we have checked all 3
			bne $t0, $t1, check_vertical
			
	
	#Refresh the board address	
	la $s5, board
	
	#I-value
	li $t1, 0
	
	# We jump address by $t6 every iteration
	li $t6, 16
	check_diagonal:
		#grab the value at address $s5
		lw $t5, 0($s5)
		
		#Check if the value held matches the player
		bne $t5, $t7, diagonal_failed
	
		#increment j
		addi $t1, $t1, 1
		
		#offset address
		add $s5, $s5, $t6
			
		#If j < 3 keep checking
		bne $t0, $t1, check_diagonal
		
		#Else
		j found_winner
		
		#Changes the setting to check for the oppposite diagonal or end the find_winner process
		diagonal_failed:
			#If $t6 == 8 then we must have just finished checking the second diagonal
			li $t9, 8
			beq $t9, $t6, all_checks_failed
			
			#Else we haven't checked the second diagonal

			#Refresh the starting index with a start offset of 8
			la $s5, board
			addi $s5, $s5, 8
			
			#Change the incrementation of the address to be by 8 instead of 16
			move $t6, $t9
			
			#Reset i
			li $t1, 0
			
			#Check the second diagonal
			j check_diagonal
	
	all_checks_failed:	
		j end_turn
	
	
end_turn:
	#If $s0 != 0 then it is player ones turn
	bne $s0, $zero, p_one_turn
	#Else it is player two's turn
	j p_two_turn
	
	p_one_turn:
		li $s0, 0
		j finish_end_turn
	p_two_turn:
		li $s0, 1
		
	finish_end_turn: 
		jr $ra
	
#Handles Fidning a winner
found_winner:
	#print the winning board
	jal print_board

	#If it is player one's turn then player one has won
	beq $s0, $zero, player_one_wins
	#Else player two has one
	j player_two_wins
	
	player_one_wins:
		la $a0, player1_wins
		j print_winner
	
	player_two_wins:
		la $a0, player2_wins
	
	print_winner:
		jal print
	
		j exit



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
