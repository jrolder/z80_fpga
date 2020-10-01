	org	0

	;ld b, deh
	;ld c,b
	;ld c, 45h
	;ld b,c
	;jp hello2

;
;test rlc, rrc, rl, rr, sla, sra, sll, srl
;
 	ld h,0x81
 	rlc h
 	jp nc,error
 	ld a,h
 	cp a,0x03
 	jp nz,error

 	ld h,0x81
 	rrc h
 	jp nc,error
 	ld a,h
 	cp a,0xc0
 	jp nz,error
 	
 	ld h,0x01
 	scf
 	rl h
 	jp c,error
 	ld a,h
 	cp a,0x03
 	jp nz,error

 	ld h,0x80
 	scf
 	rr h
 	jp c,error
 	ld a,h
 	cp a,0xc0
 	jp nz,error

 	ld h,0x81
 	sla h
 	jp nc,error
 	ld a,h
 	cp a,0x02
 	jp nz,error

 	ld h,0x81
 	sra h
 	jp nc,error
 	ld a,h
 	cp a,0xc0
 	jp nz,error
 	
 	ld h,0x81
 	sll h
 	jp nc,error
 	ld a,h
 	cp a,0x03
 	jp nz,error

 	ld h,0x81
 	srl h
 	jp nc,error
 	ld a,h
 	cp a,0x40
 	jp nz,error
 	 	
;
;test res/set n,(hl)
;
	ld hl,scratch
	ld (hl),0xff
	res 3,(hl)
	ld a,(hl)
	cp a,0xf7
	jp nz,error
	set 3,(hl)
	ld a,(hl)
	cp a,0xff
	jp nz,error
	
;
;test res/set n,r
;
	ld h,0xff
	res 3,h
	ld a,h
	cp a,0xf7
	jp nz,error
	set 3,h
	ld a,h
	cp a,0xff
	jp nz,error
	
;
;test ld (hl),nn
;
	ld hl,scratch
	ld (hl),0x98
	ld a,(hl)
	cp a,0x98
	jp nz,error

;
;test bit n,(hl)
;
	ld hl,scratch
	ld (hl),8
	bit 3,(hl)
	jp z,error
	ld (hl),0
	bit 3,(hl)
	jp nz,error
	
;
;test bit n,r
;
	ld h,8
	bit 3,h
	jp z,error
	ld h,0
	bit 3,h
	jp nz,error
	
;
;test cpl
;
	ld a,0x13
	cpl
	cp a,0xec
	jp nz,error
	

;
;test daa
;
	ld a,0x12
	add 0x23
	daa
	cp a,0x35
	jp nz,error
	
	ld a,0x19
	add 0x11
	daa
	cp a,0x30
	jp nz,error
	
	ld a,0x91
	add 0x11
	daa
	cp a,0x02
	jp nz,error

	ld a,0x99
	add 0x22
	daa
	cp a,0x21
	jp nz,error


	ld a,0x99
	sub 0x23
	daa
	cp a,0x76
	jp nz,error
	
	ld a,0x09
	sub 0x11
	daa
	cp a,0x98
	jp nz,error
	
	ld a,0x90
	sub 0x11
	daa
	cp a,0x79
	jp nz,error

	ld a,0x00
	sub 0x22
	daa
	cp a,0x78
	jp nz,error
	
;
;test rlca, rrca, rla, rra
;
	ld a,0x81
	rlca
	jp nc,error
	cp a,0x03
	jp nz,error

	ld a,0x81
	rrca
	jp nc,error
	cp a,0xc0
	jp nz,error

	ld a,0x81
	scf
	ccf
	rla
	jp nc,error
	cp a,0x02
	jp nz,error

	ld a,0x81
	scf
	ccf
	rra
	jp nc,error
	cp a,0x40
	jp nz,error

;
;test ld (nnnn),a/hl and ld a/hl,(nnnn)
;
	ld hl,0x1234
	ld (scratch),hl
	ld a,(scratch)
	cp a,0x34
	jp nz,error
	ld a,(scratch+1)
	cp a,0x12
	jp nz,error
	
	ld a,0x56
	ld (scratch),a
	ld a,0x78
	ld (scratch+1),a
	ld hl,(scratch)
	ld a,l
	cp a,0x56
	jp nz,error
	ld a,h
	cp a,0x78
	jp nz,error

;
;test ld a,(bc/de)
;
	ld bc,scratch
	ld hl,scratch
	ld a,0x23
	ld (hl),a
	xor a
	ld a,(bc)
	cp a,0x23
	jp nz,error
	
	ld de,scratch
	ld a,0x24
	ld (hl),a
	xor a
	ld a,(de)
	cp a,0x24
	jp nz,error

;
;test ld (bc/de),a
;
	ld bc,scratch
	ld hl,scratch
	ld a,0x21
	ld (bc),a
	xor a
	ld a,(hl)
	cp a,0x21
	jp nz,error
	
	ld de,scratch
	ld a,0x22
	ld (de),a
	xor a
	ld a,(hl)
	cp a,0x22
	jp nz,error

;
;test djnz
;
	ld b,3
	ld c,0
djnz1:
	inc c
	djnz djnz1
	ld a,c
	cp a,3
	jp nz,error

;
;test jp (hl)
;
	ld hl,jphl
	jp (hl)
	jp error
jphl:

;
;test ld sp,hl
;
	ld hl,0xaffe
	ld sp,hl
	ld hl,0
	add hl,sp
	ld a,h
	cp a,0xaf
	jp nz,error
	ld a,l
	cp a,0xfe
	jp nz,error

;
;test jr 
;
	xor a
	jr nz,jrerror
	jr z,jrgood1
	jp error
jrgood1:
	xor a
	inc a
	jr c,jrerror
	jr nc,jrgood2
	jp error
jrgood2:
	jr jrgood3
	
jrerror:
	jp error
	
jrgood3:

;
;test add hl,bc/de/hl/sp
;
	ld hl,0x105
	add hl,hl
	ld bc,0x106
	add hl,bc
	ld de,0x107
	add hl,de
	ld sp,0x108
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

	ld hl,0x101
	inc hl
	add hl,hl
	ld bc,0x102
	inc bc
	add hl,bc
	ld de,0x103
	inc de
	add hl,de
	ld sp,0x104
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

	ld hl,0x101
	dec hl
	add hl,hl
	ld bc,0x102
	dec bc
	add hl,bc
	ld de,0x103
	dec de
	add hl,de
	ld sp,0x104
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
	
	ld d,0xff
	inc d
	jp nz,error
	inc d
	jp z,error
	
	ld d,50
	dec d
	ld a,d
	cp a,49
	jp nz,error
	
	ld d,0x01
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
	ld hl, 0x3344
	ld de, 0x7788
	ex de,hl
	ld a,d
	cp a,0x33
	jp nz,error
	ld a,e
	cp a,0x44
	jp nz,error
	ld a,h
	cp a,0x77
	jp nz,error
	ld a,l
	cp a,0x88
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
	ld hl,0x5566
	ex (sp),hl
	ld a,h
	cp a,7
	jp nz,error
	ld a,l
	cp a,9
	jp nz,error
	ld hl,scratch
	ld a,(hl)
	cp a,0x66
	jp nz,error
	ld hl,scratch+1
	ld a,(hl)
	cp a,0x55
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
	ld bc,0xaffe
	push bc
	pop de
	
	ld de, 0xbffa
	push de
	pop hl
	
	ld hl, 0xcff1
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
	rst 0x38
	halt

error:
	halt
	
result_good: 
	db "*** test completed, no errors\n", 0
	
scratch:
	db 0, 0
	
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
stack: