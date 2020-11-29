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


addi a0,zero,4
addi a1, zero, 1

call set_pixel

addi a0,zero,5
addi a1, zero, 2

call set_pixel

addi a0,zero,3
addi a1, zero, 3

call set_pixel
addi a0,zero,4
addi a1, zero, 3
call set_pixel

addi a0,zero,5
addi a1, zero, 3
call set_pixel

addi t0,zero,2

stw t0,SEED(zero)


stw zero, GSA_ID(zero) # GSA_ID is set to 0
addi t5, zero, N_GSA_LINES
addi t6, zero, 0
stw zero, GSA_ID(zero) # GSA_ID is set to 0
loop_set_gsa0:
	beq t6, t5, end_set_gsa0
	slli t7, t6, 2

	ldw a0, seed2(t7)
	addi a1, t6, 0
	call set_gsa
	addi t6, t6, 1
	jmpi loop_set_gsa0
end_set_gsa0:

addi t2,zero,1

stw t2,PAUSE(zero)


call update_gsa

call draw_gsa


break






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

        add a1, s1, zero # y coordinate
        update_column_loop:
            beq s2, s3, end_update_column_loop

            slli s5, s5, 1 
            andi a0, a0, 0
            add a0, s3, zero # x coordinate
            call find_neighbours

		  ;addi v0,zero,

            add a0, v0, zero
            add a1, v1, zero
            call cell_fate 

			;addi v0,zero,

            add s5, v0, s5 # building the line to pass as argument to set_gsa
			
			;addi s5,s5,1
		
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


; BEGIN:cell_fate
cell_fate:
	
	cmpeqi t3, a0, 3 # 1 if a0 == 3
	xori t1, a1, 1
	and t0, t1, t3 # 1 if DEAD && a0 == 3

	cmpeqi t5, a0, 3 # 1 if a0 == 3
	cmpeqi t2, a0, 2 # 1 if a0 == 2
	or t1, t2, t5 # a0 == 3 || a0 == 2
	and t4, a1, t1 # 1 if ALIVE && (a0 == 2 || a0 == 3)

	cmplti t6, a0, 2 # 1 if a0 < 2
	cmpgei t7, a0, 4 # 1 if a0 > 3
	or t1, t7, t6 # 1 if a0 < 2 || a0 > 3
	and t1, t1, a1 # 1 if ALIVE && (above line)
	xori t1, t1, 1
	
	or t1, t1, t4
	or v0, t1, t0 # outputs if the cell is alive or dead

	ret

; END:cell_fate


; BEGIN:draw_gsa
draw_gsa:
	ldw t0, GSA_ID(zero)
	slli t0, t0, 5

	addi t1, zero, 3
	addi t2, zero, 0 # loopa increment

loopa:
	beq t2, t1, enda # if t2 == 3 we are done
	andi t3, t3, 0 # loopb increment
	addi t4, t4, 8
	
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




















;BEGIN:clear_leds
clear_leds:

	addi t1, zero, 0
	addi t2, zero, 12 ;Upper limit size of leds array! 

	addi t3, zero, 0x00

	slli t4,t3,8
	slli t5,t3,16
	slli t6,t3,24


	or t3,t3,t4
	or t3,t3,t5
	or t3,t3,t6


	loop_clear:
		;stw zero,LEDS(t1)

		stw  t3,LEDS(t1)
	;	slli LEDS(t1),LEDS(t1) , 1
		
		addi t1,t1,4
		bne t1,t2,loop_clear
	ret

;END:clear_leds


;BEGIN:set_pixel
set_pixel:


add t2,zero,a0
;	add t2,t2,a0
	addi t3,zero,0
	addi t4,zero,1
	addi t5, zero, 8
	addi t6, zero, 4

	loop_position_LED_ARRAY:
	
		beq t2,t5,position_LED_ARRAY_incrementation
		
		beq t2,t6,position_LED_ARRAY_incrementation

	decrement_loop_position_LED_ARRAY:
		sub t2,t2 ,t4  ; t3 is used to know in which led to display!
		
		bne t2,zero, loop_position_LED_ARRAY

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

;END:set_pixel


; BEGIN:set_gsa
set_gsa:
	ldw t0, GSA_ID(zero)
	slli t0, t0, 5
	slli t1, a1, 2
	add t2, t0, t1
	stw a0, GSA0(t2)
	ret
; END:set_gsa








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











