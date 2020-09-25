
	;ld b, deh
	;ld c,b
	;ld c, 45h
	;ld b,c
	;jp hello2

;
;test add hl,bc/de/hl/sp
;
	ld hl,105h
	add hl,hl
	ld bc,106h
	add hl,bc
	ld de,107h
	add hl,de
	ld sp,108h
	add hl,sp
	ld a,h
	cp a,5
	jp nz,error
	ld a,l
	cp a,31
	jp nz,error

;
;test inc bc,de,hl,sp
;

	ld hl,101h
	inc hl
	add hl,hl
	ld bc,102h
	inc bc
	add hl,bc
	ld de,103h
	inc de
	add hl,de
	ld sp,104h
	inc sp
	add hl,sp
	ld a,h
	cp a,5
	jp nz,error
	ld a,l
	cp a,16
	jp nz,error

;test dec bc,de,hl,sp
;

	ld hl,101h
	dec hl
	add hl,hl
	ld bc,102h
	dec bc
	add hl,bc
	ld de,103h
	dec de
	add hl,de
	ld sp,104h
	dec sp
	add hl,sp
	ld a,h
	cp a,5
	jp nz,error
	ld a,l
	cp a,6
	jp nz,error	
	
	
;
;test inc (hl) and dec (hl)
;

	ld hl,scratch
	ld a,50
	ld (hl),a
	inc (hl)
	ld a,(hl)
	cp a,51
	jp nz,error
	dec (hl)
	ld a,(hl)
	cp a,50
	jp nz,error
	
;
;test inc r and dec r
;

	ld d,50
	inc d
	ld a,d
	cp a,51
	jp nz,error
	
	ld d,ffh
	inc d
	jp nz,error
	inc d
	jp z,error
	
	ld d,50
	dec d
	ld a,d
	cp a,49
	jp nz,error
	
	ld d,01h
	dec d
	jp nz,error	
	dec d
	jp z,error

;
;test di and ei
;

	di
	ei

;
; test ex de,hl
;
	ld hl, 3344h
	ld de, 7788h
	ex de,hl
	ld a,d
	cp a,33h
	jp nz,error
	ld a,e
	cp a,44h
	jp nz,error
	ld a,h
	cp a,77h
	jp nz,error
	ld a,l
	cp a,88h
	jp nz,error
	
;
; test ex (sp),hl
;

	ld sp,scratch
	ld hl,scratch
	ld a,9
	ld (hl), a
	ld hl,scratch+1 ; inc hl not available at the time
	ld a,7
	ld (hl), a
	ld hl,5566h
	ex (sp),hl
	ld a,h
	cp a,7
	jp nz,error
	ld a,l
	cp a,9
	jp nz,error
	ld hl,scratch
	ld a,(hl)
	cp a,66h
	jp nz,error
	ld hl,scratch+1
	ld a,(hl)
	cp a,55h
	jp nz,error


;
; test io
;

	ld a,17
	out (5), a
	ld a, 25
	in a, (5)
	cp a, 17
	jp nz, error

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