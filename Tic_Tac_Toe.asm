.data



new_line: .asciiz, "\n"

.text

main:
	la $a0, 
	jal print



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