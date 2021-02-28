	; -- Стартовый блок -- 
	; Подгружается в каждом `main.asm` для совпадения адресов библиотечных функций во всех частях
	jp _start

clearScreen	ld hl, #4000 : ld de, #4001 : ld bc, #17ff : ld (hl), l : ldir
	ret
	
	; a - цвет атрибута
setScreenAttr	ld hl, #5800 : ld de, #5801 : ld bc, #02ff : ld (hl), a : ldir
	ret

; Print zero ended string with font 8х8
; DE - Screen memory address
; HL - Text pointer
printStrZ_8x8 	ld a, (hl)
	or a : ret z
	call printChar_8x8
	jr printStrZ_8x8

; Print one char with ROM font
; DE - Screen memory address
; A  - char
printChar_8x8 	push hl, de, bc
	sub #1f
	ld hl, #3d00 - #08
	ld bc, #08
1	add hl, bc
	dec a
	jr nz, 1b

	dup 8 
	;ld a,(hl) : ld (de),a		; normal
	ld a,(hl) : ld b, a : rla : or b : ld (de), a   ; bold
	inc d : inc l
	edup 

	pop bc, de, hl
	inc hl : inc de
	ret 

_start