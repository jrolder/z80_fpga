
	;ld b, deh
	;ld c,b
	;ld c, 45h
	;ld b,c
	;jp hello2
	
;
; test op a, n
;
	ld a, 3
	scf
	add a, 5
	cp a, 8
	jp nz, error
	
	ld a, 3
	scf
	adc a, 5
	cp a, 9
	jp nz, error
	
	ld a, 3
	scf
	sub a, 2
	cp a, 1
	jp nz, error
	
	ld a, 3
	scf
	sbc a, 2
	cp a, 0
	jp nz, error	
	
	ld a, 3
	and 5
	cp a, 1
	jp nz, error	
	
	ld a, 3
	xor 5
	cp a, 6
	jp nz, error
	
	ld a, 3
	or 5
	cp a, 7
	jp nz, error
;
; test cp a, nn and jp cc
;
	ld a, 3
	cp a, 5
	jp nz, l1
	halt
	nop
l1:
    jp z, error
    
	cp a, 3
	jp nz, error
	jp z, l2
	jp error
l2:


hello2:
	ld de, hello
	ld c, 9
	rst #38
	halt

error:
	halt
	
hello: 
	db "hello world!\n", 0