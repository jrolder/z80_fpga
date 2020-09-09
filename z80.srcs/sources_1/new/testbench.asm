
	;ld b, deh
	;ld c,b
	;ld c, 45h
	;ld b,c
	jp hello2
	ld a, 3
	cp a, 5
	cp a, 3
hello2:
	ld de, hello
	ld c, 9
	rst #38
	halt
	
	
hello: 
	db "hello world!\n", 0