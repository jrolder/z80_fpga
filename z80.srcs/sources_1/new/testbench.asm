
	;ld b, deh
	;ld c,b
	;ld c, 45h
	;ld b,c
	;jp hello2
	
;
; test ld r,(hl) and ld (hl), r
;
	ld hl, scratch
	ld b, 77
	ld (hl), b
	ld a, 77
	cp (hl)
	jp nz, error
	ld a,(hl)
	cp 77
	jp nz, error

;
; test op a, r
;
	jp cphl_test
cphl_data: 
	db 6
cphl_test:
	ld a, 6
	ld hl, cphl_data
	cp a, (hl)
	jp nz, error

	ld a, 3
	scf
	add a, a
	cp a, 6
	jp nz, error
	
	ld a, 3
	ld b, 5
	scf
	adc a, b
	cp a, 9
	jp nz, error
	
	ld a, 3
	ld c, 2
	scf
	sub a, c
	cp a, 1
	jp nz, error
	
	ld a, 3
	ld d, 2
	scf
	sbc a, d
	cp a, 0
	jp nz, error	
	
	ld a, 3
	ld e, 5
	and e
	cp a, 1
	jp nz, error	
	
	ld a, 3
	ld h, 6
	xor 5
	cp a, h
	jp nz, error
	
	ld a, 3
	ld l, 5
	or l
	cp a, 7
	jp nz, error

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
	
scratch:
	db 0, 0