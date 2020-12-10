	org	0

;
;test outi
;
	ld ix,scratch
	ld (ix),0x34
	ld (ix+1),0x12
	ld hl,scratch
	ld b,2
	ld c,10
	outi
	jp z,error
	in a,(c)
	cp a,0x34
	jp nz,error
	outi
	jp nz,error
	in a,(c)
	cp a,0x12
	jp nz,error
	
	halt
	
;
;test cpd
;
	ld ix,scratch
	ld (ix),0x34
	ld (ix+1),0x12
	ld (ix+2),0x34
	ld (ix+3),0x12
	ld hl,scratch+3
	ld bc,4
	ld a,0x12
	cpd
	jp nz,error
	jp po,error
	cpd
	jp z,error
	jp po,error
	
	ld bc,1
	cpd
	jp nz,error
	jp pe,error
	
	ld bc,1
	cpd
	jp z,error
	jp pe,error
	
;
;test cpdr
;
	ld ix,scratch
	ld (ix),0x34
	ld (ix+1),0x12
	ld hl,scratch+1
	ld bc,2
	ld a,0x12
	cpdr
	ld a,c
	cp a,1
	jp nz,error

	ld hl,scratch+1
	ld bc,2
	ld a,0x34
	cpdr
	ld a,c
	cp a,0
	jp nz,error
	
	ld hl,scratch+1
	ld bc,2
	ld a,0
	cpdr
	ld a,c
	cp a,0
	jp nz,error
	
;
;test cpi
;
	ld ix,scratch
	ld (ix),0x12
	ld (ix+1),0x34
	ld (ix+2),0x12
	ld (ix+3),0x34
	ld hl,scratch
	ld bc,4
	ld a,0x12
	cpi
	jp nz,error
	jp po,error
	cpi
	jp z,error
	jp po,error
	
	ld bc,1
	cpi
	jp nz,error
	jp pe,error
	
	ld bc,1
	cpi
	jp z,error
	jp pe,error
	
;
;test cpir
;
	ld ix,scratch
	ld (ix),0x12
	ld (ix+1),0x34
	ld hl,scratch
	ld bc,2
	ld a,0x12
	cpir
	ld a,c
	cp a,1
	jp nz,error

	ld hl,scratch
	ld bc,2
	ld a,0x34
	cpir
	ld a,c
	cp a,0
	jp nz,error
	
	ld hl,scratch
	ld bc,2
	ld a,0
	cpir
	ld a,c
	cp a,0
	jp nz,error
	
;
; test rld
;
	ld hl,scratch
	ld (hl),0x67
	ld a,0x89
	rld
	cp a,0x86
	jp nz,error
	ld a,(hl)
	cp a,0x79
	jp nz, error

;
; test rrd
;
	ld hl,scratch
	ld (hl),0x67
	ld a,0x89
	rrd
	cp a,0x87
	jp nz,error
	ld a,(hl)
	cp a,0x96
	jp nz, error

;
; test ld air,air
;
	ld a,33
	ld i,a
	ld a,45
	ld r,a
	ld a,0
	ld a,i
	cp a,33
	jp nz,error
	ld a,r
	cp a,45
	jp nz,error
	
;
; test call/retn
;

	ld sp,stack
	ld a, 45
	call retn_test
	cp a, 57
	jp nz, error
	jp retn_test2
retn_test:
	ld a, 57
	retn
	halt
retn_test2:

;
;test sbc and adc hl,qq
;
	ld hl,0x205
	ld sp,0x103
	scf
	sbc hl,sp
	ld a,h
	cp a,1
	jp nz,error
	ld a,l
	cp a,1
	jp nz,error
	
	ld hl,0x205
	ld sp,0x103
	scf
	adc hl,sp
	ld a,h
	cp a,3
	jp nz,error
	ld a,l
	cp a,9
	jp nz,error


;
;test neg
;
	ld a,0x02
	neg
	cp a,0xfe
	jp nz,error

;
;test lddr
;
	ld ix,scratch
	ld (ix),0x12
	ld (ix+1),0x54
	ld (ix+2),0x99
	ld (ix+5),0
	ld (ix+6),0
	ld (ix+7),0
	ld hl,scratch+1
	ld de,scratch+6
	ld bc,2
	lddr
	jp pe,error
	ld a,(ix+5)
	cp a,0x12
	jp nz,error
	ld a,(ix+6)
	cp a,0x54
	jp nz,error
	ld a,(ix+7)
	cp a,0
	jp nz,error
	
;
;test ldd
;
	ld ix,scratch
	ld (ix),0x12
	ld (ix+1),0x54
	ld (ix+5),0
	ld (ix+6),0
	ld hl,scratch+1
	ld de,scratch+6
	ld bc,2
	ldd
	jp po,error
	ldd
	jp pe,error
	ld a,(ix+5)
	cp a,0x12
	jp nz,error
	ld a,(ix+6)
	cp a,0x54
	jp nz,error
	
;
;test ldir
;
	ld ix,scratch
	ld (ix),0x12
	ld (ix+1),0x54
	ld (ix+2),0x99
	ld (ix+5),0
	ld (ix+6),0
	ld (ix+7),0
	ld hl,scratch
	ld de,scratch+5
	ld bc,2
	ldir
	jp pe,error
	ld a,(ix+5)
	cp a,0x12
	jp nz,error
	ld a,(ix+6)
	cp a,0x54
	jp nz,error
	ld a,(ix+7)
	cp a,0
	jp nz,error
	
;
;test ldi
;
	ld ix,scratch
	ld (ix),0x12
	ld (ix+1),0x54
	ld (ix+5),0
	ld (ix+6),0
	ld hl,scratch
	ld de,scratch+5
	ld bc,2
	ldi
	jp po,error
	ldi
	jp pe,error
	ld a,(ix+5)
	cp a,0x12
	jp nz,error
	ld a,(ix+6)
	cp a,0x54
	jp nz,error
	
;
;test extended io
;
	ld c,0x55
	ld e,0x12
	out (c),e
	in a,(c)
	jp z,error
	cp a,0x12
	jp nz,error
	
	out (c),0
	in a,(c)
	jp nz,error
	cp a,0
	jp nz,error
	
	ld a,1
	out (c),a
	in (c)
	jp z,error
	xor a
	out (c),a
	in (c)
	jp nz,error
	

;
;test ld (**),qq and ld qq,(**)
;
	ld bc,0xaffe
	ld (scratch),bc
	ld de,(scratch)
	ld a,d
	cp a,0xaf
	jp nz,error
	ld a,e
	cp a,0xfe
	jp nz,error
	
	ld sp,0x1267
	ld (scratch),sp
	ld hl,(scratch)
	ld a,h
	cp a,0x12
	jp nz,error
	ld a,l
	cp a,0x67
	jp nz,error

;
;test bit instructions for (ixy+d)
;
	ld ix,scratch+10
	ld iy,scratch-10
	ld hl,scratch
	ld (hl),0x80
	rlc (ix-10),b
	jp nc,error
	ld a,(hl)
	cp a,0x01
	jp nz,error
	ld a,b
	cp a,0x01
	jp nz,error
	
	ld (hl),0x01
	rrc (iy+10)
	jp nc,error
	ld a,(hl)
	cp a,0x80
	jp nz,error
	
	ld (hl),0x3c
	bit 7,(ix-10)
	jp nz,error
	bit 5,(iy+10)
	jp z,error

	ld (hl),0x3c
	bit 7,(ix-10),e
	jp nz,error
	bit 5,(iy+10),c
	jp z,error
	
	ld (hl),0x0f
	res 0,(ix-10)
	res 3,(iy+10)
	set 7,(iy+10)
	set 4,(ix-10)
	ld a,(hl)
	cp a,0x96
	jp nz,error
	
;
;test ex (sp),ixy
;
	ld sp,scratch
	ld ix,0x1243
	ex (sp),ix
	ex (sp),iy
	push iy
	pop bc
	ld a,b
	cp a,0x12
	jp nz,error
	ld a,c
	cp a,0x43
	jp nz,error

;
;test jp (ix)
;
	ld ix,jpix
	jp (ix)
	jp error
jpix:

;
;test ld sp,ixy
;
	ld iy,0xaffe
	ld sp,iy
	ld ix,0
	add ix,sp
	ld a,ixh
	cp a,0xaf
	jp nz,error
	ld a,ixl
	cp a,0xfe
	jp nz,error

;
;test aloup ixyhl
;
	ld ix,0x0305
	ld iy,0x0407
	xor a
	add a,ixh
	sub a,iyh
	sub a,ixl
	add a,iyl
	cp a,1
	jp nz,error
	
;
;test aloup (ixy+d)
;
	ld ix,scratch+10
	ld iy,scratch-10
	ld hl,scratch
	ld (hl),5
	inc hl
	ld (hl),7
	inc hl
	ld (hl),9
	xor a
	add a, (ix-10)
	sub a, (iy+11)
	add a, (ix-8)
	cp a, 7
	jp nz, error
	

;
;test ld r,ixhl
;
	ld ix,0x5566
	ld iy,0x7788
	ld a,ixh
	ld d,iyl
	cp a,0x55
	jp nz,error
	ld a,d
	cp a,0x88
	jp nz,error


;
;test ld ixhl,r
;
	ld e,0x99
	ld ixh,e
	ld a,ixh
	cp a,0x99
	jp nz,error

	ld e,0x33
	ld iyl,e
	ld a,iyl
	cp a,0x33
	jp nz,error

;
;test ld (ixy+d),r and ld r,(ixy+d)
;

	ld ix,scratch+10
	ld iy,scratch-10
	ld d,0x12
	ld (ix-10),d
	ld a,(iy+10)
	cp a,0x12
	jp nz,error
	

;
;test ld (ixy+d),n
;
	ld ix,scratch+10
	ld iy,scratch-10
	ld hl,scratch
	ld (hl),0
	ld (ix-10),5
	ld a,(hl)
	cp a,5
	jp nz,error
	ld (iy+10),9
	ld a,(hl)
	cp a,9
	jp nz,error

;
;test inc (ixy+d) and dec (ixy+d)
;
	ld ix,scratch
	ld iy,scratch+10
	ld hl,scratch+1
	ld (hl),5
	inc hl
	ld (hl),11
	inc (ix+1)
	inc (iy-9)
	dec (ix+2)
	dec (iy-8)
	ld a,(hl)
	cp a,9
	jp nz,error
	dec hl
	ld a,(hl)
	cp a,7
	jp nz,error
	
;
;test inc ixyhl, dec ixyhl, ld ixyhl,nn
;
	ld sp,stack
	ld ixh,5
	inc ixh
	inc ixh
	dec ixh
	ld ixl,9
	dec ixl
	dec ixl
    inc ixl
	push ix
	pop bc
	ld a,b
	cp a,0x06
	jp nz,error
	ld a,c
	cp a,0x08
	jp nz,error
    
	ld iyh,3
	inc iyh
	inc iyh
	dec iyh
	ld iyl,7
	dec iyl
	dec iyl
    inc iyl
	push iy
	pop bc
	ld a,b
	cp a,0x04
	jp nz,error
	ld a,c
	cp a,0x06
	jp nz,error
	
;
;test inc ixy, dec ixy
;
	ld sp,stack
	ld ix,0xffff
	inc ix
	push ix
	pop bc
	ld a,b
	cp a,0x00
	jp nz,error
	ld a,c
	cp a,0x00
	jp nz,error
	
	ld iy,0x0001
	inc iy
	push iy
	pop bc
	ld a,b
	cp a,0x00
	jp nz,error
	ld a,c
	cp a,0x02
	jp nz,error
	
	ld ix,0xffff
	dec ix
	push ix
	pop bc
	ld a,b
	cp a,0xff
	jp nz,error
	ld a,c
	cp a,0xfe
	jp nz,error
	
	ld iy,0x0001
	dec iy
	push iy
	pop bc
	ld a,b
	cp a,0x00
	jp nz,error
	ld a,c
	cp a,0x00
	jp nz,error
	
		
;
;test ld (nnnn),ixy, ld ixy,(nnnn)
;
	ld sp,stack
	ld ix,0x1122
	ld (scratch),ix
	ld iy,0x3344
	ld (scratch+2),iy
	ld ix,(scratch+2)
	ld iy,(scratch)
	push ix
	pop bc
	ld a,b
	cp a,0x33
	jp nz,error
	ld a,c
	cp a,0x44
	jp nz,error

	push iy
	pop bc
	ld a,b
	cp a,0x11
	jp nz,error
	ld a,c
	cp a,0x22
	jp nz,error
	
;
;test add ixy,qq
;
	ld ix,0x0201
	ld bc,0x0303
	ld de,0x0404
	ld sp,0x0505
	add ix,ix
	add ix,bc
	add ix,de
	add ix,sp
	ld sp,stack
	push ix
	pop bc
	ld a,b
	cp a,0x10
	jp nz,error
	ld a,c
	cp a,0x0e
	jp nz,error

;
;test push/pop ixy
;
	ld sp,stack
	ld ix,0x0102
	ld iy,0x0304
	push ix
	push iy
	pop ix
	pop iy
	
	push ix
	pop bc
	ld a,b
	cp a,0x03
	jp nz,error
	ld a,c
	cp a,0x04
	jp nz,error

	push iy
	pop bc
	ld a,b
	cp a,0x01
	jp nz,error
	ld a,c
	cp a,0x02
	jp nz,error

;
;test ld ixy,nnnn and push ixy
;
	ld sp,stack
	ld hl,0x0102
	ld ix,0x0304
	ld iy,0x0506

	push hl
	pop bc
	ld a,b
	cp a,0x01
	jp nz,error
	ld a,c
	cp a,0x02
	jp nz,error

	push ix
	pop bc
	ld a,b
	cp a,0x03
	jp nz,error
	ld a,c
	cp a,0x04
	jp nz,error

	push iy
	pop bc
	ld a,b
	cp a,0x05
	jp nz,error
	ld a,c
	cp a,0x06
	jp nz,error
	
;
;test rlc (hl)
;
	ld hl,scratch
 	ld (hl),0x81
 	rlc (hl)
 	jp nc,error
 	ld a,(hl)
 	cp a,0x03
 	jp nz,error

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