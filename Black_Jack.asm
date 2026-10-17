.data 0x10010000

#Hands (max cards a player can have in blackjack is  11)
player_hand: .space, 48
dealer_hand: .space, 48

user_input: .space 30

#Labels
player_hand_label: .asciiz, "\nPlayers Hand:"
dealer_hand_label: .asciiz, "Dealers Hand:"

#Suits
heart: .asciiz, " of Hearts"
diamond: .asciiz, " of Diamonds"
club: .asciiz, " of Clubs"
spade: .asciiz, " of Spades"

#Special card names
ace: .asciiz, "Ace"
king: .asciiz, "King"
queen: .asciiz, "Queen"
jack: .asciiz, "Jack"

opening: .asciiz "Welcome to the Black Jack table. \n"

choice: .asciiz, "Would you like to hit or would you like to stand? (Hit/Stand)\n\n"
input_error: .asciiz "\nI'm sorry I didn't understand your input please,\n"

new_player_card: .asciiz, "The player got a new card: "
new_dealer_card: .asciiz, "The dealer got a new card: "

#Result messages
win: .asciiz "\nYou have won!"
push: .asciiz "\nThe game has ended in a draw, chips have been given back"
lost: .asciiz "\nYou ran out of luck better come back later"

new_line: .asciiz, "\n"
input_field: .asciiz "> "

stand: .asciiz, "Stand\n"
hit: .asciiz, "Hit\n"

.text

main:
	#prints the opening message
	la $a0, opening
	jal print
	
	#Get the Dealers Hand
	la $a0, dealer_hand_label
	jal print
		
	la $a2, dealer_hand
	
	jal getCard
	jal getCard
	
	#Get the Players Hand
	la $a0, player_hand_label
	jal print
	
	la $a2, player_hand
	
	jal getCard
	jal getCard
	
	#The interactive loop of the game
	game_loop:
		#Calcualte the dealers score and store it in $s1
		la $a2, dealer_hand
		jal calculate_score
		move $s1, $t1
	
		#Calcualte the players score and store it in $s2
		la $a2, player_hand
		jal calculate_score
		move $s2, $t1
		
		#Check if either the player ot the dealer are over 21
		bgtu $s1, 21, player_won
		bgtu $s2, 21, dealer_won
		
		players_turn:
			#Get if the player will hit or stand
			jal get_string
			
			#Check for Stand
			la $a0, stand
			la $a1, user_input
			jal compare_strings
			
			#Make it the dealers turn if we stand
			bne $t5, $zero, dealers_turn
			
			#Check for hit
			la $a0, hit
			la $a1, user_input
			jal compare_strings
			
			#If it wasn't hit or stand put up an error message and re get the input
			beq $t5, $zero, bad_input
			
			#Handles a hit by getting the player a new card
			la $a0, new_player_card
			jal print
				
			la $a2, player_hand
			jal getCard
			
			#re-run the game loop to check the new scores
			j game_loop

		#Handles all of the dealer logic
		dealers_turn:
			#Check whether the dealer has busted
			bgtu $s1, 22, player_won
			#End the dealer loop if their value is above 16
			bgtu $s1, 16, find_winner
			
			#Handles the dealer drawing a new card
			la $a0, new_dealer_card
			jal print
				
			la $a2, dealer_hand
			jal getCard
			
			#Recalculate the dealers score
			la $a2, dealer_hand
			jal calculate_score
			move $s1, $t1
			
			#Run the dealers turn again
			j dealers_turn
		
		#Handles finding the winner
		find_winner:
			#Check if the players hand is higher than the dealers
			bgt $s2, $s1, player_won
			#Check if the dealers hand is higher than the players
			blt $s2, $s1, dealer_won
			#If neither must be a tie
			j tie
			
			player_won:
				la $a0, win
				jal print
				
				j exit
			dealer_won:
				la $a0, lost
				jal print
				
				j exit
			tie:
				la $a0, push
				jal print
				
				j exit



#Return sum of the hand in $t1
calculate_score:
	#$t0 holds the address of the element we are on in the list
	move $t0, $a2
	
	#$t1 holds the value of the sum
	li $t1, 0
	
	#sums the cards and 
	add_cards:
		lw $t2, 0($t0)
		
		addi $t0, $t0, 4
		
		add $t1, $t1, $t2
		
		#If the value we are in is 0 then we have reached the end of the list
		bne $t2, $zero, add_cards
	
	#If the score is less than 22 then don't check for aces
	bltu $t1, 22, return_score
	
	#$t0 holds the address of the element we are on in the list
	move $t0, $a2
	#$t8 holds the value an ace
	li $t8, 11
	check_for_aces:
		lw $t2, 0($t0)
		
		beq $t8, $t2, found_ace
		
		addi $t0, $t0, 4	
		
		#If the value we are in is 0 then we have reached the end of the list
		bne $t2, $zero, check_for_aces
		
		j return_score
	
		#If we have found an ace set it's value from 11 to 1 and recalculate the score
		found_ace:
			li $t2, 1
			sw $t2, 0($t0)
			j calculate_score
		
	return_score:
		jr $ra
		


getCard:
	#Get the address we want to store our card value at and put it in $t1
	move $t0, $a2
	find_avalible_address:
		lw $t1, 0($t0)
		
		beqz $t1, found_address
		
		addi $t0, $t0, 4
		
		j find_avalible_address
		
	found_address:
	
	#Get random integer and store at $t2 ranging from 0 - 12
	li $a0, 1
	li $a1, 13

	li $v0, 42	
	syscall
	
	#Add 1 to make the range 1 - 13
	addi $a0, $a0, 1
	
	#t2 holds the card index, which is used to print the name of the card
	move $t2, $a0
	#t3 stores the numerical value of the card
	move $t3, $a0
	
	#Store the card value
	
	#If the card is a one store it as an ace
	li $t4, 1
	beq $t3, $t4, ace_value
	
	#If the card is a face card make it's value 10
	bgtu $t3, 10, face_card_value
	
	#Else just store the generated value
	j store_value
	
	ace_value:
		li $t3, 11
		j store_value
	face_card_value:
		li $t3, 10
		j store_value
	#Stores the value at the address we specified was open earlier
	store_value:
		sw $t3, 0($t0)
		
		
	#print the card value
	li $v0, 4
	
	print_card_value: 
		#Check if the card is an ace
		li $t0, 1
		beq $t2, $t0, print_ace
		
		#Check if the card is an jack
		li $t0, 11
		beq $t2, $t0, print_jack
		
		#Check if the card is an queen
		li $t0, 12
		beq $t2, $t0, print_queen
		
		#Check if the card is an king
		li $t0, 13
		beq $t2, $t0, print_king
		
		#Else print normally
		j print_integer
		
		print_ace:
			la $a0, ace
			j end_print_card_value
		
		print_king:
			la $a0, king
			j end_print_card_value
		
		print_queen:
			la $a0, queen
			j end_print_card_value
		
		print_jack:
			la $a0, jack
			j end_print_card_value
		
		print_integer:
			li $v0, 1
			move $a0, $t2
			
		end_print_card_value: 
			syscall
	
	
	#Get random suit and store at $t3
	li $a0, 1
	li $a1, 4

	li $v0, 42	
	syscall
	
	move $t3, $a0
	
	#Compare the int and print the corresponding suit
	print_card_suit: 
		li $t0, 0
		beq $t3, $t0, print_heart
		
		li $t0, 1
		beq $t3, $t0, print_diamond
		
		li $t0, 2
		beq $t3, $t0, print_club
		
		j print_spade
		
		print_heart:
			la $a0, heart
			j end_print_suit
		
		print_diamond:
			la $a0, diamond
			j end_print_suit
		
		print_club:
			la $a0, club
			j end_print_suit
		
		print_spade:
			la $a0, spade

		end_print_suit: 
			li $v0, 4
			syscall
	
	la $a0, new_line
	syscall
	
	jr $ra



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



#Prints an error message and returns back to the players turn to reget input
bad_input:
	li $v0, 4
	la $a0, input_error
	syscall 
	
	j players_turn



#Used to get player input
get_string:
	li $v0, 4
	
	la $a0, choice
	syscall
	
	la $a0, input_field
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
