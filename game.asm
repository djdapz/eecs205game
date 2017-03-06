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
include platform.inc
include spritecontrol.inc
include game.inc

;; Has keycodes
include keys.inc


.DATA
	;; If you need to, you can place global variables here




	backgroundSprite  Sprite <>
	bradySprite 			Sprite <>
	otherBradySprite 	Sprite <>
	firstPlatform 		Platform <>
	secondPlatform 		Platform <>
	thirdPlatform 		Platform <>
	camera 						Camera <>
  switch  					DWORD 0
	middle_line 			DWORD 01100000h
	worlds_end  			DWORD 0f9c0000h

.CODE


CheckIntersect PROC oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP
;ignore this
	ret
CheckIntersect ENDP

;; Note: You will need to implement CheckIntersect!!!

GlobalSpriteToCamera PROC uses ebx sprite:PTR Sprite
	mov esi, sprite
	mov eax, (Sprite PTR[esi]).global_x
	sub eax, camera.left_x

	mov (Sprite PTR[esi]).x_pos, eax

	ret
GlobalSpriteToCamera ENDP

GlobalPlatformToCamera PROC uses ebx platform:PTR Platform
	mov esi, platform
	mov eax,  (Platform PTR[esi]).global_x
	sub eax, camera.left_x

	mov  (Platform PTR[esi]).x_pos, eax

	ret
GlobalPlatformToCamera ENDP

CheckCameraMovement PROC uses esi eax character:PTR Sprite
	;; PASS MAIN CHARACTER
	;;returns in eax the amount it moves

		mov eax, camera.right_x
		cmp eax, worlds_end
		jge done        		;if the camera is at or past the world's end then camear cant move

		mov esi, character
		mov eax, (Sprite PTR[esi]).global_x
		sub eax, camera.left_x
		sub eax, middle_line     	;find distance between char and middle line
		cmp eax, 0 								;if the character is past the middle line, move camera instead of character
		jle done
		add camera.left_x, eax
		add camera.right_x, eax
		shr eax, 1
		sub backgroundSprite.x_pos, eax

	checkBackground:
		mov eax, backgroundSprite.x_pos				;move xposition of backgroundinto eax
		cmp eax, 0fec00000h
		jg done								;if if background is still in frame keep going
		mov backgroundSprite.x_pos, 03bf0000h


	done:

		ret
CheckCameraMovement ENDP


Render  PROC USES eax
	;DRAW BACKGROUND



	INVOKE CheckCameraMovement, ADDR bradySprite

	;localize all sprites
	INVOKE GlobalSpriteToCamera, ADDR bradySprite
	INVOKE GlobalSpriteToCamera, ADDR otherBradySprite
 	INVOKE GlobalPlatformToCamera, ADDR firstPlatform
 	INVOKE GlobalPlatformToCamera, ADDR secondPlatform
 	INVOKE GlobalPlatformToCamera, ADDR thirdPlatform



	;DRAW BACKGROUND
	INVOKE DrawSprite, backgroundSprite

  ;DRAW PLATFORMS
  INVOKE DrawPlatform, ADDR firstPlatform
	INVOKE DrawPlatform, ADDR secondPlatform
	INVOKE DrawPlatform, ADDR thirdPlatform


	;DRAW CHARACTERS
  INVOKE DrawSprite, otherBradySprite
	INVOKE DrawSprite, bradySprite


	ret
Render ENDP




GameInit PROC USES eax

	;; LOAD POINTERS FOR BITMAPS INTO GLOBAL VARS FOR EASY ACCESS



    lea eax, mountainsBMP
    mov backgroundSprite.pointer, eax
    mov backgroundSprite.x_pos, 0fec00000h 	;x=319
    mov backgroundSprite.y_pos, 0dc0000h	;y=220

    lea eax, bradyBMP
    mov otherBradySprite.pointer, eax
    mov otherBradySprite.global_x, 02080000h	;x=479
    mov otherBradySprite.y_pos, 0c80000h	;y=200

		lea eax, otherBradyBMP
		mov bradySprite.pointer, eax
		mov bradySprite.global_x, 0c80000h	;x=200
		mov bradySprite.y_pos, 0c80000h	;y=200


    lea eax, firstPlatform
    mov firstPlatform.global_x, 0c80000h  ; x=200
    mov firstPlatform.y_pos, 01900000h ;y=318
    mov firstPlatform.color, 0ddh
    mov firstPlatform.p_height, 021h ; height = 100
    mov firstPlatform.p_width, 0c8h ; width = 200

		lea eax, secondPlatform
		mov secondPlatform.global_x, 02080000h  ; x=200
		mov secondPlatform.y_pos, 01000000h ;y=318
		mov secondPlatform.color, 0edh
		mov secondPlatform.p_height, 021h ; height = 100
		mov secondPlatform.p_width, 0c8h ; width = 200

		lea eax, thirdPlatform
		mov thirdPlatform.global_x,  03500000h   ; x=200
		mov thirdPlatform.y_pos, 01900000h ;y=318
		mov thirdPlatform.color, 0f0h
		mov thirdPlatform.p_height, 021h ; height = 100
		mov thirdPlatform.p_width, 0208h ; width = 200




    ;DRAW BACKGROUND
	INVOKE Render



	ret         ;; Do not delete this line!!!
GameInit ENDP


GamePlay PROC uses eax ebx

  checkKeyboard:
    INVOKE Keyboard_Check, ADDR bradySprite

  checkMouse:
    mov eax, MouseStatus.buttons
    cmp eax, 0
    jz checkCollisions

    INVOKE ChangeSpritePosition_MOUSE, ADDR otherBradySprite

  checkCollisions:

		INVOKE CheckSpritePlatformInteraction, ADDR bradySprite, ADDR firstPlatform
		INVOKE CheckSpritePlatformInteraction, ADDR bradySprite, ADDR secondPlatform
		INVOKE CheckSpritePlatformInteraction, ADDR bradySprite, ADDR thirdPlatform

  scroll:

    ;update velocites


		;update positions
		INVOKE UpdateSpritePositions, ADDR bradySprite
		INVOKE UpdateSpriteVelocities, ADDR bradySprite



  	INVOKE Render

	  ret         ;; Do not delete this line!!!
GamePlay ENDP






END
