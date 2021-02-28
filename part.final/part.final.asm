	define BG_COLOR %01000001

	xor a : out (#fe), a
	call clearScreen
	ld a, BG_COLOR : call setScreenAttr
	ld hl, TEXT : ld de, #486c : call printStrZ_8x8
	ret

TEXT	db "THE END", 0