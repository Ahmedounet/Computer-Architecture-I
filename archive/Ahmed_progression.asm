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

addi t0, zero, INIT 
stw t0,CURR_STATE(zero)

;addi t1, zero, 12901	
;stw t1, CURR_STEP(zero)

main:

	call get_input
	add a0, v0, zero

	call change_steps

	call decrement_step

jmpi main

;BEGIN:decrement_step

decrement_step:

	addi v0,zero,0
	ldw t0,CURR_STATE(zero)

	addi t1,zero,RUN

	beq t0, t1, it_is_running  

	show_the_steps:

	ldw t2, CURR_STEP(zero)

	andi t4, t2, 0xF #extracting the units!
	andi t5, t2, 0xF0 	 #extracting the tens!
	srli t5,t5, 4
	andi t6, t2, 0xF00 	  #extracting the hundreds!
	srli t6,t6, 8

	slli t7, t4, 2
	ldw t7, font_data(t7) #get the unit's font
	addi t1,zero, 12
	stw t7, SEVEN_SEGS(t1) #display the units

	slli t7, t5, 2
	ldw t7, font_data(t7) #get the ten's font
	addi t1,zero, 8
	stw t7, SEVEN_SEGS(t1) #display the tens

	slli t7, t6, 2
	ldw t7, font_data(t7) #get the hundred's font
	addi t1,zero, 4
	stw t7, SEVEN_SEGS(t1) #display the hundreds


end_decrement_step:

	ret

	it_is_running:

		ldw t2, CURR_STEP(zero)

		beq t2, zero, current_step_null

		addi t3,zero,1
		sub t2,t2,t3

		andi t2, t2, 0xFFF

		stw t2,CURR_STEP(zero)

	jmpi show_the_steps

	current_step_null:

		addi v0, zero, 1

		jmpi show_the_steps
 
;END:decrement_step


;BEGIN:increment_seed
increment_seed:

addi s7, ra, 0
 
	ldw t0, CURR_STATE(zero)

	addi t3, zero , INIT 
	addi t4, zero, RAND

	beq t0, t3 , init_seed
	beq t0, t4 ,  rand_seed


	end_increment_seed:

addi ra, s7, 0

	ret

	init_seed:
	
		ldw t1, SEED(zero)
		addi t1, t1, 1
		stw t1, SEED(zero)

		slli t1, t1 ,2

		ldw t6, SEEDS(t1)

		addi t4,zero,0
		addi t2,zero,0
		addi t5,zero,8
		add t7, zero,t6
	loop_inc_seed_gsa:

		add t7, t6, t2
		ldw	t7, 0(t7)
		
		add a0, zero, t7
		add a1, zero, t4

		call set_gsa	

		#condition d'arret 8 fois, 8 lignes a mettre
		addi t4, t4, 1
	
#Deplacement a la ligne suivante dans le seed
		addi t2, t2, 4

		beq t4, t5, end_increment_seed

		jmpi loop_inc_seed_gsa

	jmpi end_increment_seed

	rand_seed:
	;	call random_gsa
		jmpi end_increment_seed
;END:increment_seed



; BEGIN:set_gsa
set_gsa:
	ldw t0, GSA_ID(zero)
	slli t0, t0, 5
	slli t1, a1, 2
	add t2, t0, t1
	stw a0, GSA0(t2)
	ret
; END:set_gsa




;BEGIN:change_speed
change_speed:
	# increasing 1
	# decreasing 2

	srli a0, a0, 2

	ldw t0, SPEED(zero)
	addi t1, zero,1

	beq a0, zero, increment
	beq a0, t1, decrement

	end_change_speed:

		stw t0, SPEED(zero)

	ret

	increment:
		addi t4, zero, MAX_SPEED
		bge t0, t4, end_change_speed
		addi t0, t0, 1
		jmpi end_change_speed

	decrement:
		addi t5, zero, MIN_SPEED
		bge t5, t0, end_change_speed
		sub t0, t0, t1
		jmpi end_change_speed

;END:change_speed




;BEGIN:update_state

update_state:

	addi s7, ra, 0

	ldw t0, CURR_STATE(zero)

	addi t1,zero, INIT
	addi t2, zero, RAND
	addi t3, zero, RUN

	addi t4, zero, 1
	addi t5, zero, 2
	addi t6,zero, 4
	addi t7,zero, 8

	beq t0, t1, initial_state 
	beq t0, t2, random_state
	beq t0, t3, run_state

	end_update_state:

		addi ra, s7, 0

	ret

	initial_state:

		beq a0, t5, goto_run

		beq a0, t4, goto_rand

		jmpi end_update_state

	goto_rand:

		ldw t0, SEED(zero)
		addi t1, zero, 4


		blt t0, t1, end_update_state

		stw t2, CURR_STATE(zero)

		jmpi end_update_state


	goto_run:
		stw t3, CURR_STATE(zero)

		jmpi end_update_state

	goto_init:
		
		stw t1, CURR_STATE(zero)

		add t7,s7,zero
		call reset_game
	
		add s7, t7 ,zero

		jmpi end_update_state


	random_state:
		beq a0, t5, goto_run # button1 going to run state
		beq a0, t6, end_update_state # button2
		beq a0, t7, end_update_state # button3
		beq a0, t4, end_update_state # button0
		addi t4, zero, 16
		beq a0, t4, end_update_state

		jmpi end_update_state

	run_state:
		beq a0, t5, end_update_state # button1

		beq a0, t7, goto_init # button3
		beq a0, t6, end_update_state # button2
	
		addi t7, zero, 16
		beq a0, t7, end_update_state # button4
		jmpi end_update_state

;END:update_state


;BEGIN:reset_game

reset_game:
	
	addi s7, ra, 0

	addi t1, zero, 1

	stw t1, CURR_STEP(zero)

	addi t3, zero, 3
	slli t3, t3, 2 # offset in 7 seg
	slli t2, t1, 2 # offset in font_data to get digit 1
	
	slli t4, t1, 2
	ldw t0, font_data(zero)
	stw t0, SEVEN_SEGS(t4) # seg1
	slli t4, t4, 1
	stw t0, SEVEN_SEGS(t4) # seg2
	
	ldw t1, font_data(t2)
	stw t1, SEVEN_SEGS(t3) # seg3

	call pause_game

	stw zero, SEED(zero)

	stw zero, GSA0(zero)

	stw zero, GSA_ID(zero)
	stw t1, SPEED(zero)

	addi ra, s7, 0

	ret
;END:reset_game



;BEGIN:pause_game
pause_game:

	ldw t0, PAUSE(zero) ; We get the current pause state

	addi t2, zero, PAUSED
	addi t3, zero, RUNNING

	xori t0, t0, 1
	stw t0, PAUSE(zero)

	ret
	
;END:pause_game



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
		
		andi t0, t0, 0xFFF
		stw t0, CURR_STEP(zero)

		ret

	add_unit:
		
		addi t0, t0,1 


		jmpi check_tens 


	add_tens:
		addi t0,t0, 0x10



		jmpi check_hundreds

	add_hundreds:
		addi t0,t0, 0x100

	
		jmpi end_change_steps
	
	
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

	beq t1, zero, end_zero_not_any_button_pressed

	addi t4, t1, 0 
	loop_bit_select:

		srli t4, t4, 1
		bge zero, t4, end_get_input
	
		jmpi bit_increment
	
	end_get_input:
	addi t1, zero, 1
	sll t1, t1, t2
	add v0, zero, t1 

	
	stw zero, BUTTONS(t0) # clears the edgecapture register

	ret

	end_zero_not_any_button_pressed:
	addi v0,zero,0
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
