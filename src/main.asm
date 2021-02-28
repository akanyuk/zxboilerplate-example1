	device zxspectrum128

	; адресa частей
	define A_PART_ONE #7000
	define A_PART_TWO #7000
	define A_PART_FINAL #7000

	; страницы частей
	define P_PART_ONE 1
	define P_PART_TWO 3
	define P_PART_FINAL 4

	; счетчики
	define C_PART_ONE_END 200
	define C_PART_TWO_END 500

	org #6000
page0s	include "lib/shared.asm"	
	di : ld sp, page0s
	xor a : out (#fe), a 

	call clearScreen

	ld a,#be, i,a, hl,interr, (#beff),hl : im 2 : ei

	; part.one: depack and initialization
	ld a, P_PART_ONE : call setPage
	ld hl, PART_ONE_PACKED
	ld de, A_PART_ONE
	call zx7_depack
	call A_PART_ONE

	; part.one: main
1	call A_PART_ONE + 3
	halt
	ld de, C_PART_ONE_END
	ld hl, (INTS_COUNTER) : sbc hl, de : jr c, 1b

	xor a : out (#fe), a : call setScreenAttr
	ld b, 50 : halt : djnz $ -1

	; part.two: depack and initialization
	ld a, P_PART_TWO : call setPage
	ld hl, PART_TWO_PACKED
	ld de, A_PART_TWO
	call zx7_depack
	call A_PART_TWO

	; part.two: main
1	call A_PART_TWO + 3
	halt
	ld de, C_PART_TWO_END
	ld hl, (INTS_COUNTER) : sbc hl, de : jr c, 1b

	xor a : out (#fe), a : call setScreenAttr
	ld b, 50 : halt : djnz $ -1

	; part.final: depack and start
	ld a, P_PART_FINAL : call setPage
	ld hl, PART_FINAL_PACKED
	ld de, A_PART_FINAL
	call zx7_depack
	call A_PART_FINAL
	jr $

interr	di
	push af,bc,de,hl,ix,iy
	exx : ex af, af'
	push af,bc,de,hl,ix,iy
	ifdef _DEBUG_BORDER : ld a, #01 : out (#fe), a : endif ; debug

	; счетчик интов
INTS_COUNTER	equ $+1
	ld hl, #0000 : inc hl : ld ($-3), hl

	ifdef _DEBUG_BORDER : xor a : out (#fe), a : endif ; debug
	pop iy,ix,hl,de,bc,af
	exx : ex af, af'
	pop iy,ix,hl,de,bc,af
	ei
	ret

setPage	or %00010000
	ld bc, #7ffd : out (c), a 
	ret

zx7_depack	include "lib/zx7_packer.asm"
page0e	display /d, '[page 0] free: ', #ffff - $, ' (', $, ')'	

	define _page1 : page 1 : org #c000
page1s	
PART_ONE_PACKED	incbin "build/part.one.bin.zx7"
page1e	display /d, '[page 1] free: ', 65536 - $, ' (', $, ')'

	define _page3 : page 3 : org #c000
page3s
PART_TWO_PACKED	incbin "build/part.two.bin.zx7"
page3e	display /d, '[page 3] free: ', 65536 - $, ' (', $, ')'

	define _page4 : page 4 : org #c000
page4s
PART_FINAL_PACKED	incbin "build/part.final.bin.zx7"
page4e	display /d, '[page 4] free: ', 65536 - $, ' (', $, ')'

	include "src/builder.asm"
