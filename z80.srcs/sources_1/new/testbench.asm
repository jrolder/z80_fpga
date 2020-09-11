
	;ld b, deh
	;ld c,b
	;ld c, 45h
	;ld b,c
	;jp hello2

;
; test call cc
;
	ld sp,stack
	scf
	call nc, error
	call c, call_cc1
	halt
call_cc1:

;
; test ret cc
;

	ld sp,stack
	scf
	call ret_cc1
	jp ret_cc2
ret_cc1:
	ret c
	halt
ret_cc2:
	call ret_cc3
	halt
ret_cc3:
	ret nc	

;
; test call/ret
;

	ld sp,stack
	ld a, 45
	call call_test
	cp a, 57
	jp nz, error
	jp call_test2
call_test:
	ld a, 57
	ret
	halt
call_test2:
	
;
; test push/pop
;

	ld sp,stack
	ld bc,affeh
	push bc
	pop de
	
	ld de, bffah
	push de
	pop hl
	
	ld hl, cff1h
	push hl
	pop af

    push af
    pop bc
    
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
	ld de, result_good
	ld c, 9
	rst #38
	halt

error:
	halt
	
result_good: 
	db "*** test completed, no errors\n", 0
	
scratch:
	db 0, 0
	
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
stack: