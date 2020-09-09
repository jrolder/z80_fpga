
	;ld b, deh
	;ld c,b
	;ld c, 45h
	;ld b,c
	;jp hello2
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