; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 4/5
;
;
; #########################################################################

.586
.MODEL FLAT,STDCALL
.STACK 4096
option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc
include spritecontrol.inc
include game.inc

;; Has keycodes
include keys.inc


.DATA
	;; If you need to, you can place global variables here

	backgroundSprite  	Sprite <>
	bradySprite 		Sprite <>
	otherBradySprite 		Sprite <>
	firstPlatform 		Platform <>
  switch DWORD 0

.CODE

absVal PROC val:SDWORD ;RETURNS TO EAX
    mov eax, val
    and eax, 080000000h   ;see if sign bit is tripped
    jz pos
    mov eax, val
    xor eax, 0ffffffffh   ;flip bits
    add eax, 1             ;add 1
    jmp done
  pos:
    mov eax, val
  done:
    ret
absVal ENDP



;; Note: You will need to implement CheckIntersect!!!

CheckIntersect PROC uses ebx oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP
    local dist_vert:DWORD, dist_horz:DWORD, sum_horz:DWORD, sum_vert:DWORD

    mov esi, oneBitmap
    mov eax, (EECS205BITMAP PTR[esi]).dwHeight
    mov esi, twoBitmap
    add eax, (EECS205BITMAP PTR[esi]).dwHeight
    shl eax, 15       ;convert to FIXED,but divide by 2
    mov sum_vert, eax

    mov esi, oneBitmap
    mov eax, (EECS205BITMAP PTR[esi]).dwWidth
    mov esi, twoBitmap
    add eax, (EECS205BITMAP PTR[esi]).dwWidth
    shl eax, 15       ;convert to FIXED, but divide by 2
    mov sum_horz, eax

    mov eax, oneX
    sub eax, twoX
    INVOKE absVal, eax    ;dist_horz = abs(oneX - twoX)
    mov dist_horz, eax

    mov eax, oneY
    sub eax, twoY
    INVOKE absVal, eax    ;dist_vert = abs(oneY - twoY)
    mov dist_vert, eax

    mov eax, dist_vert
    cmp eax, sum_vert     ;if dist vert > sumVert - nocollision possible
    jg  noCollision

    mov eax, dist_horz
    cmp eax, sum_horz     ;if dist_horz > sum_horz, no collision bossible
    jg  noCollision

    mov eax, 01h        ;return 1 if collision
    jmp done

  noCollision:
    mov eax, 0        ;return 0 if no collision

  done:



  ret
CheckIntersect ENDP


Render  PROC
	;DRAW BACKGROUND

	mov eax,backgroundSprite.x_pos				;move xposition of backgroundinto eax
	cmp eax, 0fec00000h
	jg backgroundOK								;if if background is still in frame keep going
	mov backgroundSprite.x_pos, 03bf0000h

  backgroundOK:
	INVOKE DrawSprite, backgroundSprite

  ;DRAW PLATFORMS
  INVOKE DrawPlatform, ADDR firstPlatform

	;DRAW CHARACTERS

  INVOKE DrawSprite, otherBradySprite
	INVOKE DrawSprite, bradySprite

	;DRAW PLATFORMS..EVENTUALLY

	ret
Render ENDP


GameInit PROC

	;; LOAD POINTERS FOR BITMAPS INTO GLOBAL VARS FOR EASY ACCESS

    lea eax, otherBradyBMP
    mov bradySprite.pointer, eax
    mov bradySprite.x_pos, 0c80000h	;x=200
    mov bradySprite.y_pos, 0c80000h	;y=200


    lea eax, mountainsBMP
    mov backgroundSprite.pointer, eax
    mov backgroundSprite.x_pos, 0fec00000h 	;x=319
    mov backgroundSprite.y_pos, 0dc0000h	;y=220

    lea eax, bradyBMP
    mov otherBradySprite.pointer, eax
    mov otherBradySprite.x_pos, 02080000h	;x=479
    mov otherBradySprite.y_pos, 0c80000h	;y=200

    lea eax, firstPlatform
    mov firstPlatform.x_pos, 0c80000h  ; x=200
    mov firstPlatform.y_pos, 01380000h ;y=318
    mov firstPlatform.color, 0ddh
    mov firstPlatform.p_height, 028h ; height = 100
    mov firstPlatform.p_width, 0c8h ; width = 200


    ;DRAW BACKGROUND
	INVOKE DrawSprite, backgroundSprite

  ;DRAW PLATfORMS
  INVOKE DrawPlatform, ADDR firstPlatform

	;DRAW CHARACTER
	INVOKE DrawSprite, bradySprite
  INVOKE DrawSprite, otherBradySprite



	ret         ;; Do not delete this line!!!
GameInit ENDP


GamePlay PROC uses eax

  checkKeyboard:
	  cmp KeyPress, 0    ;;FOR NOW IF NO KEYS ARE PRESSED, DO NOTHING
	  jz checkMouse     ;if nothing, jump away and scroll

    INVOKE ChangeSpritePosition_Keyboard, ADDR bradySprite
  checkMouse:
    mov eax, MouseStatus.buttons
    cmp eax, 0
    jz checkCollisions

    INVOKE ChangeSpritePosition_MOUSE, ADDR otherBradySprite


  checkCollisions:

    INVOKE CheckIntersect, bradySprite.x_pos, bradySprite.y_pos, bradySprite.pointer, otherBradySprite.x_pos, otherBradySprite.y_pos, otherBradySprite.pointer
    cmp eax, 0
    je scroll

    cmp switch, 0
    je pos_1
    mov switch, 0
    mov otherBradySprite.x_pos, 0c80000h
    mov otherBradySprite.y_pos, 0c80000h
    jmp scroll

  pos_1:
    mov switch, 1
    mov otherBradySprite.x_pos, 02080000h
    mov otherBradySprite.y_pos, 0c80000h

  scroll:
    mov eax, backgroundSprite.x_pos
  	sub eax, 04ffffh						; subtract 4 pixels from position of the backgorund
  	mov backgroundSprite.x_pos, eax

  	INVOKE Render

	  ret         ;; Do not delete this line!!!
GamePlay ENDP






END
