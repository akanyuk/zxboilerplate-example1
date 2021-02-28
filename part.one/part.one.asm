	define BG_COLOR %01000110

	jp init     ; $+0   
	jp main     ; $+3  
init	ld a, BG_COLOR : call setScreenAttr
	ld hl, TEXT : ld de, #4021 : call printStrZ_8x8
	ret
TEXT	db "Part one", 0

main	ld a, #01 : inc a : inc a : cp #06 : jr c, $+4 : ld a, #01 : ld (main + 1), a
	out (#fe), a
	ret