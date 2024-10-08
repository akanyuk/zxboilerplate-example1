	; -- Стартовый блок -- 
	; Подгружается в каждом `main.asm` для совпадения адресов библиотечных функций во всех частях
	jp _start

ClearScreen	ld hl, #4000 : ld de, #4001 : ld bc, #17ff : ld (hl), l : ldir : ret
	
	; a - цвет атрибута
SetScreenAttr	ld hl, #5800 : ld de, #5801 : ld bc, #02ff : ld (hl), a : ldir : ret

SwapScreen	ld a, (CUR_SCREEN) : xor %00001000 : ld (CUR_SCREEN), a
	or a : jr z, $+4 : sub 2 : add 7
	; устанавливаем страницу, оставляя текущий экран
SetPage	ld (CUR_PAGE), a : ld b, a
	ld a, (CUR_SCREEN) : or b : or %00010000
	ld bc, #7ffd : out (c), a 
	ret
	; a=0 - normal screen
	; a=8 - alt screen
SetScreen	ld (CUR_SCREEN), a : ld b, a 
	ld a, (CUR_PAGE) : or b : or %00010000
	ld bc, #7ffd : out (c), a
	ret
CUR_PAGE	db #00
CUR_SCREEN	db #00

DownDE	inc d : ld a,d : and #07 : ret nz : ld a,e : sub #e0 : ld e,a : sbc a,a : and #f8 : add a,d : ld d,a : ret
UpDE	dec d : ld a, d : cpl : and #07 : ret nz : ld a, e : sub #20 : ld e, a : ret c : ld a, d : add a, #08 : ld d,a : ret
DownHL	inc h : ld a,h : and #07 : ret nz : ld a,l : sub #e0 : ld l,a : sbc a,a : and #f8 : add a,h : ld h,a : ret
UpHL	dec h : ld a, h : cpl : and #07 : ret nz : ld a, l : sub #20 : ld l, a : ret c : ld a, h : add a, #08 : ld h,a : ret


; Print zero ended string with font 8х8
; DE - Screen memory address
; HL - Text pointer
PrintStrZ_8x8 	ld a, (hl)
	or a : ret z
	call PrintChar_8x8
	jr PrintStrZ_8x8

; Print one char with ROM font
; DE - Screen memory address
; A  - char
PrintChar_8x8 	push hl, de, bc
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
	
; usage
; ld bc,tstates
; call DELAY;waits tstates

; Z80 delay routine
; by Jan Bobrowski, license GPL, LGPL
Delay	; wait bc T (including call; bc>=141)
	; destroys: af, bc, hl
	ld hl, -141
	add hl, bc
	ld bc, -23
_loop	add hl, bc
	jr c, _loop
	ld a, l
	add a, 15
	jr nc, _g0
	cp 8
	jr c, _g1
	or 0
_g0	inc hl
_g1	rra
	jr c, _b0
	nop
_b0	rra
	jr nc, _b1
	or 0
_b1	rra
	ret nc
	ret

Depack	include "dzx0_fast.asm"
_start