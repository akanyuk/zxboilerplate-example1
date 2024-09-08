	device zxspectrum128

	define PART_MODULE   #7000

	org #6000
start	
	module common
	include "src/common/common.asm"	
	endmodule

	di : ld sp, start

	xor a : out #fe, a
	ld a,#5c, i,a, hl,interr, (#5cff),hl : im 2 : ei

	call PART_MODULE

	jr $	

interr	di
	push af,bc,de,hl,ix,iy
	exx : ex af, af'
	push af,bc,de,hl,ix,iy
	
	pop iy,ix,hl,de,bc,af
	exx : ex af, af'
	pop iy,ix,hl,de,bc,af
	ei
	ret

	org PART_MODULE
	include "part.final.asm"

	display /d, 'Part length: ', $ - PART_MODULE
	display 'Part ended at: ', $

	; build
	if (_ERRORS == 0 && _WARNINGS == 0)
	;  LABELSLIST "user.l"
	  savesna SNA_FILENAME, start	   ; SNA_FILENAME defined in Makefile
	  savebin BIN_FILENAME, PART_MODULE, $-PART_MODULE ; BIN_FILENAME defined in Makefile
	endif
