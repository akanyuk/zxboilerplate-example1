	define BG_COLOR %01000001

	xor a : out (#fe), a
	call common.ClearScreen
	ld a, BG_COLOR : call common.SetScreenAttr
	ld hl, TEXT : ld de, #486c : call common.PrintStrZ_8x8
	ret

TEXT	db "THE END", 0