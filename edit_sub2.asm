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

; BEGIN:main
main:

	# algorithm of the game
	addi t0, zero, 0
	addi t1, zero, 0
	addi t2, zero, 0
	addi t3, zero, 0
	addi t4, zero, 0
	addi t5, zero, 0
	addi t6, zero, 0
	addi t7, zero, 0
	addi s0, zero, 0
	addi s1, zero, 0
	addi s2, zero, 0
	addi s3, zero, 0
	addi s4, zero, 0
	addi s5, zero, 0
	addi s6, zero, 0
	addi s7, zero, 0
	addi a0, zero, 0
	addi a1, zero, 0
	addi a2, zero, 0
	addi a3, zero, 0
	call reset_game
	call get_input
	add a0, zero, v0
	addi s4, zero, 0 # done
	addi s6, zero, 1
	while:
		beq s4, s6, end_while # if done==1 then end
		addi a3, a0, 0
		call select_action # a0 gets overwritten big time
		 #retrieve the og edgecapture 
		addi a0, a3, 0
		call update_state
		#add s7, zero, a0 #saving a0 from the callees needed?
		call update_gsa
		call mask
		call draw_gsa
		call wait
		call decrement_step	
		add s4, v0, zero
		call get_input
		add a0, zero, v0
		jmpi while
	end_while:

	jmpi main

; END:main

; BEGIN:clear_leds
clear_leds:

addi t1, zero ,4

addi t2, zero, 8
stw zero ,LEDS(zero)

stw zero ,LEDS(t1)

stw zero,LEDS (t2)


end_clear_leds:

ret

; END:clear_leds

; BEGIN:set_pixel
set_pixel:


add t2,zero,a0
;    add t2,t2,a0
    addi t3,zero,0
    addi t4,zero,1
    addi t5, zero, 8
    addi t6, zero, 4

    loop_position_LED_ARRAY:

        beq t2,zero, get_out_of_the_loop
        beq t2,t5,position_LED_ARRAY_incrementation

        beq t2,t6,position_LED_ARRAY_incrementation

    decrement_loop_position_LED_ARRAY:
        sub t2,t2 ,t4  ; t3 is used to know in which led to display!

        bne t2,zero, loop_position_LED_ARRAY

get_out_of_the_loop:
    slli t0,a0,3
    add t0,t0, a1

    addi t1, zero,1 
    sll t1,t1,t0

    ldw t7,LEDS(t3)

    or t1,t1,t7

    stw  t1,LEDS(t3)

    ret 

    position_LED_ARRAY_incrementation:
        addi t3,t3,4
        jmpi decrement_loop_position_LED_ARRAY

; END:set_pixel

; BEGIN:wait
wait:

    addi t0, zero, 1

    ldw t2, SPEED(zero)

    addi t2, t2, -1

    addi t3, zero, 22

    sub t4, t3,t2

    sll t0, t0, t4

    addi t1, zero, 1

    loop_wait:
        sub t0, t0, t1
        bne t0, zero, loop_wait

    ret
; END:wait

; BEGIN:get_gsa
get_gsa:
	ldw t0, GSA_ID(zero)
	slli t0, t0, 5
	slli t1, a0, 2
	add t2, t0, t1
	ldw v0, GSA0(t2)
	ret
; END:get_gsa

; BEGIN:set_gsa
set_gsa:
	ldw t0, GSA_ID(zero)
	slli t0, t0, 5
	slli t1, a1, 2
	add t2, t0, t1
	stw a0, GSA0(t2)
	ret
; END:set_gsa

; BEGIN:draw_gsa
draw_gsa:
	ldw t0, GSA_ID(zero)
	slli t0, t0, 5

	addi t1, zero, 3
	addi t2, zero, 0 # loopa increment

loopa:
	beq t2, t1, enda # if t2 == 3 we are done
	andi t3, t3, 0 # loopb increment
	addi t4, zero, 8
	
	addi t5, zero, 0 
	slli s1, t2, 2
	
	loopb:
		beq t3, t4, endb # if t3 == 8 we are done 
		
		slli t6, t3, 2 # start computing the line address
		add t6, t6, t0 # line address
		ldw t7, GSA0(t6) # get line
		srl t7, t7, s1
		andi t6, t7, 0x0001 # get bit 0
		sll t6, t6, t3 # shifting in terms of the line we're in
		or t5, t5, t6 # store in t5 temporary LED word

		srli t7, t7, 1 # get bit 1
		andi t6, t7, 0x0001
		sll t6, t6, t3
		slli t6, t6, 8
		or t5, t5, t6

		srli t7, t7, 1 # get bit 2
		andi t6, t7, 0x0001
		sll t6, t6, t3
		slli t6, t6, 16
		or t5, t5, t6

		srli t7, t7, 1 # get bit 3
		andi t6, t7, 0x0001
		sll t6, t6, t3
		slli t6, t6, 24
		or t5, t5, t6

		slli t6, t2, 2 # pointer of the LED array
		stw t5, LEDS(t6) # store the word in the current LED array
		
		
		addi t3, t3, 1
		jmpi loopb
	endb:
	addi t2, t2, 1 # add 1 to t2
	jmpi loopa # jump back to the top
enda:

	ret
; END:draw_gsa

; BEGIN:random_gsa
random_gsa:
	ldw t0, GSA_ID(zero) # loading GSA_ID
	slli t0, t0, 5

	andi t1, t1, 0
	
	addi t2, zero, N_GSA_LINES

	loop:
		beq t1, t2, end # if t1==N_GSA_LINES we are done

		ldw t3, RANDOM_NUM(zero)
		andi t3, t3, 0x0FFF # keeping only the last 12 bits of the rand nb
		slli t4, t1, 2 # line y *4
		add t5, t0, t4 # address where to store the random nb
		stw t3, GSA0(t5) # storing the random nb in the current line of the GSA
		
		addi t1, t1, 1
		jmpi loop
	end:

	ret
; END:random_gsa

; BEGIN:change_speed
change_speed:
	# increasing 1
	# decreasing 2

;	srli a0, a0, 2

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

; END:change_speed


; BEGIN:pause_game
pause_game:

	ldw t0, PAUSE(zero) ; We get the current pause state

	addi t2, zero, PAUSED
	addi t3, zero, RUNNING

	xori t0, t0, 1
	stw t0, PAUSE(zero)

	ret


; END:pause_game

; BEGIN:change_steps
change_steps:

	ldw t0, CURR_STEP(zero)

	add t0,t0,a0
	slli a1,a1,4

	add t0, t0,a1
	
	slli a2, a2, 8 
	
	add t0,t0,a2

	stw t0, CURR_STEP(zero)
ret


	
; END:change_steps

; BEGIN:increment_seed
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

		ldw t1, SEED(zero)
		addi t7, zero, N_SEEDS
		bge t1, t7, rand_seed
		addi t1, t1, 1
		stw t1, SEED(zero)

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
	call random_gsa
		jmpi end_increment_seed
; END:increment_seed

; BEGIN:update_state

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

		addi t0,zero, RUNNING
		stw t0,PAUSE(zero)

		jmpi end_update_state

	goto_init:
		
		;stw t1, CURR_STATE(zero)

		add s4, s7, zero
		call reset_game
		add s7, s4 ,zero
		addi s4, zero, 1

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

; END:update_state

; BEGIN:select_action

select_action:

	ldw t0, CURR_STATE(zero)
	addi t1, zero, 1
	addi t2, zero, 2
	addi t3, zero, 4
	addi t4, zero, 8

	addi t5, zero, INIT
	addi t6, zero, RAND
	addi t7, zero, RUN

	addi s1, ra,0

	beq t0, t5, select_state_init
	beq t0, t6, select_state_rand
	beq t0, t7, select_state_run

end_select_action:

;	addi ra, s7, 0

	addi ra,s1,0

	ret

	select_state_init:

		andi t2,a0, 16 ;MSB=16
		addi t4, zero, 16

		addi a2,zero,0
		addi a1,zero,0
		add t7, zero, a0
		srli a0,t2,4
		beq t2, t4, change_steps
		add a0, zero, t7


		andi t2,a0, 8	;MSB= 8
		addi t4, zero, 8
		addi a2,zero,0
		srli a1,t2,3
		add t7, zero, a0
		addi a0,zero,0
		beq t2, t4, change_steps
		add a0, zero, t7


		andi t2,a0, 4  ;MSB=4
		srli a2,t2,2
		addi a1,zero,0
		add t7,zero,a0
		addi a0,zero,0
		beq t2, t3, change_steps
		add a0, zero, t7


		andi t2,a0, 1  ;MSB=1
		beq t2, t1, increment_seed

		jmpi end_select_action

	select_state_rand:

		andi t2,a0, 16 ;MSB=16
		addi t4, zero, 16
		addi a2,zero,0
		addi a1,zero,0
		add t7, zero, a0
		srli a0,t2,4
		beq t2, t4, change_steps
		add a0, zero, t7


		andi t2,a0, 8	;MSB= 8
		addi t4, zero, 8
		addi a2,zero,0
		srli a1,t2,3
		add t7, zero, a0
		addi a0,zero,0
		beq t2, t4, change_steps
		add a0, zero, t7


		andi t2,a0, 4  ;MSB=4
		srli a2,t2,2
		addi a1,zero,0
		add t7,zero,a0
		addi a0,zero,0
		beq t2, t3, change_steps
		add a0, zero, t7

		andi t2,a0, 1
		beq t2, t1, increment_seed

		jmpi end_select_action

	select_state_run:

		andi t5,a0, 16
		addi t4, zero, 16
		beq t5, t4, random_gsa 

	;	andi t5,a0, 8
		;addi t4, zero, 8
		;beq t5, t4, reset_game
		
		andi t5,a0, 4
		add t7, a0,zero
		srli a0, a0, 2
		beq t5, t3, change_speed
		add a0,t7, zero		

		andi t5,a0, 2
		add t7, a0,zero
		srli a0, a0, 2
		beq t5, t2, change_speed
		add a0,t7, zero		


		andi t5,a0, 1
		beq t5, t1, pause_game

		jmpi end_select_action

; END:select_action

; BEGIN:cell_fate
cell_fate:
	
	cmpeqi t3, a0, 3 # 1 if a0 == 3
	xori t1, a1, 1
	and t0, t1, t3 # 1 if DEAD && a0 == 3

	cmpeqi t5, a0, 3 # 1 if a0 == 3
	cmpeqi t2, a0, 2 # 1 if a0 == 2
	or t1, t2, t5 # a0 == 3 || a0 == 2
	and t4, a1, t1 # 1 if ALIVE && (a0 == 2 || a0 == 3)

	or v0, t4, t0 # outputs if the cell is alive or dead

	ret

; END:cell_fate

; BEGIN:find_neighbours
find_neighbours:

	# finding the state of the examined cell
	ldw t0, GSA_ID(zero)
	slli t0, t0, 5
	slli t1, a1, 2
	add t1, t1, t0 # address in the GSA
	ldw t2, GSA0(t1)
	srl t2, t2, a0 # get the cell at coord x in the line 
	andi v1, t2, 1 # outputs the state of the examined cell

	# computing the nb of live neighbours
	andi v0, v0, 0
	andi t1, t1, 0
	addi t1, t1, -1
	andi t7, t7, 0
	addi t7, t7, 2
	loop_neighbours:
		beq t1, t7, end_loop_neighbours # done looping through the 3 neighbour lines if t1==2 

		add t2, a1, t1 # current y	
		andi t2, t2, N_GSA_LINES - 1 # current y mod 8
		
		euclidian_mod_8:
			cmplti t6, t2, N_GSA_LINES # x+1 < 8 ?
			cmpgei t5, t2, 0 # x+1 >= 0 ?
			beq t6, t5, end_mod_8
			beq t5, zero, neg_8
			beq t6, zero, pos_8
			pos_8:
				addi t2, t2, -N_GSA_LINES
				jmpi euclidian_mod_8
			neg_8:
				addi t2, t2, N_GSA_LINES
				jmpi euclidian_mod_8
		end_mod_8:
		slli t2, t2, 2
		add t2, t2, t0 # address to access current GSA line

		
		addi t4, zero, -1
		loop_x:
			beq t4, t7, end_loop_x 

			add t3, a0, t4 # current x

			euclidian_mod_12:
				cmplti t6, t3, N_GSA_COLUMNS # x+1 < 12 ?
				cmpgei t5, t3, 0 # x+1 >= 0 ?
				beq t6, t5, end_mod_12
				beq t5, zero, neg_12
				beq t6, zero, pos_12
				pos_12:
					addi t3, t3, -N_GSA_COLUMNS
					jmpi euclidian_mod_12
				neg_12:
					addi t3, t3, N_GSA_COLUMNS
					jmpi euclidian_mod_12
			end_mod_12:

			ldw t5, GSA0(t2) # line at current y mod 8
			srl t5, t5, t3 # cell at current x mod 12
			andi t5, t5, 1
			add v0, v0, t5 # updating the sum of living neighbours



			addi t4, t4, 1
			jmpi loop_x
		end_loop_x:

		addi t1, t1, 1
		jmpi loop_neighbours
	end_loop_neighbours:

	sub v0, v0, v1 # we subtract the examined cell as it was counted in the loops
	ret

; END:find_neighbours

; BEGIN:update_gsa
update_gsa:

    addi s7, ra, 0

	addi t7,zero, PAUSED

	ldw t6, PAUSE(zero)

	beq t6,t7,end_update_gsa

    addi s0, zero, N_GSA_LINES
    andi s1, s1, 0
    andi s5, s5, 0

    update_line_loop:
        beq s1, s0, end_update_line_loop # if s1==8 we're done looping over the lines
        addi s2, zero, -1
        addi s3, zero, N_GSA_COLUMNS - 1
        addi s5, zero, 0

       ; add a1, s1, zero # y coordinate
        update_column_loop:
            beq s2, s3, end_update_column_loop

            slli s5, s5, 1 
            andi a0, a0, 0
            add a0, s3, zero # x coordinate
		 	add a1, s1, zero # y coordinate

            call find_neighbours

            add a0, v0, zero
            add a1, v1, zero
            call cell_fate 

            add s5, v0, s5 # building the line to pass as argument to set_gsa
		
            addi s3, s3, -1
            jmpi update_column_loop
        end_update_column_loop:
        add a0, s5, zero
        add a1, s1, zero
        ldw t7, GSA_ID(zero)
        xori t7, t7, 1 # inverting the GSA_ID
        stw t7, GSA_ID(zero)
        call set_gsa
        ldw t7, GSA_ID(zero)
        xori t7, t7, 1 # inverting the GSA_ID
        stw t7, GSA_ID(zero)

        addi s1, s1, 1
        jmpi update_line_loop
    end_update_line_loop:

    ldw t7, GSA_ID(zero)
    xori t7, t7, 1 # inverting the GSA_ID
    stw t7, GSA_ID(zero)

	end_update_gsa:
    addi ra, s7, 0
    ret
; END:update_gsa

; BEGIN:mask
mask:
	
;	addi sp, sp, -4 # decrement stack pointer
	;stw ra, 0(sp) # push the ra that goes back to main in the stack

	addi s7, ra, 0

	ldw t7, SEED(zero) # nb of the seed
	slli t7, t7, 2
	ldw s3, MASKS(t7) # address of the corresponding mask

	addi s0, zero, N_GSA_LINES
	addi s1, zero, 0

	loop_mask:
		beq s1, s0, end_loop_mask

		add a0, zero, s1 # line y coordinate
		call get_gsa
			
		add a1, zero, a0 # line y coordinate
		slli s2, s1, 2
		add s2, s2, s3
		ldw s2, 0(s2) # current mask line
		and a0, v0, s2 # applying the mask
		call set_gsa


		addi s1, s1, 1
		jmpi loop_mask
	end_loop_mask:

	addi ra, s7, 0

	ret
; END:mask

; BEGIN:get_input
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

; END:get_input

; BEGIN:decrement_step

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
		ldw t2, PAUSE(zero)
        beq t2,zero, show_the_steps

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
 
; END:decrement_step

; BEGIN:reset_game

reset_game:
	
	addi s7, ra, 0
	call clear_leds
	addi t1, zero, INIT
	stw t1, CURR_STATE(zero)

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

	stw zero, PAUSE(zero) # puts the game in pause mode
	stw zero, SEED(zero) # seed 0 is selected

	call decrement_step
		
	addi t5, zero, N_GSA_LINES
	addi t6, zero, 0
	stw zero, GSA_ID(zero) # GSA_ID is set to 0
	loop_set_gsa0:
		beq t6, t5, end_set_gsa0
		slli t7, t6, 2

		ldw a0, seed0(t7)
		addi a1, t6, 0
		call set_gsa


		addi t6, t6, 1
		jmpi loop_set_gsa0
	end_set_gsa0:


	addi t1, zero, MIN_SPEED
	stw t1, SPEED(zero) # speed is set to 1

	call draw_gsa

	addi ra, s7, 0

	ret
; END:reset_game

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

