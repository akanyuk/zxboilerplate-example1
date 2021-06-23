	define BG_COLOR %01000011

	jp init     ; $+0   
	jp main     ; $+3  
init	ld a, BG_COLOR : call SetScreenAttr
	ld hl, TEXT : ld de, #4021 : call PrintStrZ_8x8
	ret

TEXT	db "Part two", 0

main	ld a, #00 : inc a : cp #04 : jr c, $+4 : ld a, #00 : ld (main + 1), a
	out (#fe), a
	ret