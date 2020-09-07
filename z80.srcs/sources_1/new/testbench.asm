
	;ld b, deh
	;ld c,b
	;ld c, 45h
	;ld b,c
	ld de, hello
	ld c, 9
	rst #38
	halt
	
	
hello: db "hello world!\n", 0