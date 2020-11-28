  ;;    game state memory location
    .equ CURR_STATE, 0x1000              ; current game state
    .equ GSA_ID, 0x1004                     ; gsa currently in use for drawing
    .equ PAUSE, 0x1008                     ; is the game paused or running
    .equ SPEED, 0x100C                      ; game speed
    .equ CURR_STEP,  0x1010              ; game current step
    .equ SEED, 0x1014              ; game seed
    .equ GSA0, 0x1018              ; GSA0 starting address
    .equ GSA1, 0x1038              ; GSA1 starting address
    .equ SEVEN_SEGS, 0x1198             ; 7-segment display addresses
    .equ CUSTOM_VAR_START, 0x1200 ; Free range of addresses for custom variable definition
    .equ CUSTOM_VAR_END, 0x1300
    .equ LEDS, 0x2000                       ; LED address
    .equ RANDOM_NUM, 0x2010          ; Random number generator address
    .equ BUTTONS, 0x2030                 ; Buttons addresses

    ;; states
    .equ INIT, 0
    .equ RAND, 1
    .equ RUN, 2

    ;; constants
    .equ N_SEEDS, 4
    .equ N_GSA_LINES, 8
    .equ N_GSA_COLUMNS, 12
    .equ MAX_SPEED, 10
    .equ MIN_SPEED, 1
    .equ PAUSED, 0x00
    .equ RUNNING, 0x01





main:

	call get_input
	add a0, v0, zero

	call change_steps 

jmpi main




;BEGIN:change_steps
change_steps:

	srli a0, a0, 2
	andi a2, a0, 1

	srli a0, a0, 1
	andi a1, a0, 1

	srli a0, a0, 1
	andi a0, a0, 1

	addi t1, zero, 0
	addi t2, zero, 0
	addi t3, zero, 0

	ldw t0, CURR_STEP(zero)


	bne a0, zero, add_unit
	check_tens:

		bne a1, zero, add_tens


	check_hundreds:
		bne a2, zero, add_hundreds
	

	end_change_steps:
		
		stw t0, CURR_STEP(zero)

		ret

	add_unit:
		
		addi t0, t0,1 

		display_unit:

		andi t3, t0, 0xF
		slli t4,t3,2		

		ldw t4, font_data(t4)

		addi t5, zero, 12

		stw t4, SEVEN_SEGS(t5) # units

		jmpi check_tens 


	add_tens:
		
		addi t0,t0, 0x10

		display_tens:

		;add t6, t0, zero
	;	add t7, t3, zero
		
		andi t3, t0, 0xF0
		srli t3, t3, 4

		#Chiffre r�cup�r� dans t3

		slli t4, t3, 2
		ldw t4, font_data(t4)
		addi t5,zero, 8
		

		stw t4, SEVEN_SEGS(t5) # hundreds


		jmpi check_hundreds



	add_hundreds:
		addi t0,t0, 0x100

		display_hundreds:

		add t6, t0, zero
		
		andi t3, t6, 0xF00
		srli t3, t3, 8

		#Chiffre r�cup�r� dans t3

		slli t4, t3, 2
		ldw t4, font_data(t4)
		addi t5,zero, 4 
		

		stw t4, SEVEN_SEGS(t5) # hundreds
	
		jmpi end_change_steps
	
	
		jmpi display_hundreds
	
;END:change_steps





;BEGIN:get_input
get_input:


	#RESET ALL REGISTERS!

	addi t0, zero, 0
	addi t1, zero, 0
	addi t2, zero, 0
	addi t3, zero, 0
	addi t4, zero, 0
	addi t5, zero, 0
	addi t6, zero, 0
	addi t7, zero, 0


	addi t0, zero, 4
	addi t3, zero, 2 ; step
 
	addi t2, zero, 0 ;increment to see what bit do we have
	ldw t1, BUTTONS(t0)
	addi t4, t1, 0 
	loop_bit_select:

		srli t4, t4, 1
		bge zero, t4, end_get_input
	
		jmpi bit_increment
	
	end_get_input:
	addi t1, zero, 1
	sll t1, t1, t2
	add v0, zero, t1 

	#addi t1, zero, 0
	
	
	stw zero, BUTTONS(t0) # clears the edgecapture register

	ret

	bit_increment:

		addi t2, t2, 1

		jmpi loop_bit_select

;END:get_input


font_data:
    .word 0xFC ; 0
    .word 0x60 ; 1
    .word 0xDA ; 2
    .word 0xF2 ; 3
    .word 0x66 ; 4
    .word 0xB6 ; 5
    .word 0xBE ; 6
    .word 0xE0 ; 7
    .word 0xFE ; 8
    .word 0xF6 ; 9
    .word 0xEE ; A
    .word 0x3E ; B
    .word 0x9C ; C
    .word 0x7A ; D
    .word 0x9E ; E
    .word 0x8E ; F

seed0:
    .word 0xC00
    .word 0xC00
    .word 0x000
    .word 0x060
    .word 0x0A0
    .word 0x0C6
    .word 0x006
    .word 0x000

seed1:
    .word 0x000
    .word 0x000
    .word 0x05C
    .word 0x040
    .word 0x240
    .word 0x200
    .word 0x20E
    .word 0x000

seed2:
    .word 0x000
    .word 0x010
    .word 0x020
    .word 0x038
    .word 0x000
    .word 0x000
    .word 0x000
    .word 0x000

seed3:
    .word 0x000
    .word 0x000
    .word 0x090
    .word 0x008
    .word 0x088
    .word 0x078
    .word 0x000
    .word 0x000

    ;; Predefined seeds
SEEDS:
    .word seed0
    .word seed1
    .word seed2
    .word seed3

mask0:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF

mask1:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x1FF
	.word 0x1FF
	.word 0x1FF

mask2:
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF

mask3:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

mask4:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

MASKS:
    .word mask0
    .word mask1
    .word mask2
    .word mask3
    .word mask4

