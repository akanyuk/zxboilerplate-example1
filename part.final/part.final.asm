	define BG_COLOR %01000001

	xor a : out (#fe), a
	call ClearScreen
	ld a, BG_COLOR : call SetScreenAttr
	ld hl, TEXT : ld de, #486c : call PrintStrZ_8x8
	ret

TEXT	db "THE END", 0