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
	mainCharacter 		Sprite <>
	squareBrady 			Sprite <>
	camera 						Camera <>

	;STATE SPRITES
	pauseSprite 			Sprite <>
	winnerSprite 			Sprite <>
	deadSprite        Sprite <>
	welcomeSprite        Sprite <>

	;SOLO CUPS
	soloCup1        	Sprite <>
	soloCup2        	Sprite <>
	soloCup3        	Sprite <>
	soloCup4        	Sprite <>
	soloCup5        	Sprite <>

	;Platforms
	firstPlatform 		Platform <>
	secondPlatform 		Platform <>
	thirdPlatform 		Platform <>


	;Globals
  switch  					DWORD 0
	middle_line 			DWORD 01100000h
	worlds_end  			DWORD 0f9c0000h
	score 						DWORD 0
 	scoreToWin				DWORD 5
	winner 						DWORD 0


	paused 						 DWORD 0
	p_pressed 				 DWORD 0
	welcomeScreen 		 DWORD 1
	cameraSetForWelome DWORD 0

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
	INVOKE CheckCameraMovement, ADDR mainCharacter

	;localize all sprites
	INVOKE GlobalSpriteToCamera, ADDR mainCharacter
	INVOKE GlobalSpriteToCamera, ADDR soloCup1
	INVOKE GlobalSpriteToCamera, ADDR soloCup2
	INVOKE GlobalSpriteToCamera, ADDR soloCup3
	INVOKE GlobalSpriteToCamera, ADDR soloCup4
	INVOKE GlobalSpriteToCamera, ADDR soloCup5

	;localize all platoforms
 	INVOKE GlobalPlatformToCamera, ADDR firstPlatform
 	INVOKE GlobalPlatformToCamera, ADDR secondPlatform
 	INVOKE GlobalPlatformToCamera, ADDR thirdPlatform

	;DRAW BACKGROUND
	INVOKE DrawSprite, backgroundSprite

  ;DRAW PLATFORMS
  INVOKE DrawPlatform, ADDR firstPlatform
	INVOKE DrawPlatform, ADDR secondPlatform
	INVOKE DrawPlatform, ADDR thirdPlatform


	;DRAW CHARACTERS and items
	INVOKE DrawSprite, mainCharacter
	INVOKE DrawSprite, soloCup1
	INVOKE DrawSprite, soloCup2
	INVOKE DrawSprite, soloCup3
	INVOKE DrawSprite, soloCup4
	INVOKE DrawSprite, soloCup5

	cmp winner, 1
	jne done
	INVOKE DrawSprite, winnerSprite

 done:

	ret
Render ENDP

CheckPause PROC uses eax
		mov eax, KeyPress
		cmp eax, VK_P
		je  PPRESSED
		mov p_pressed, 0
		jmp done
	PPRESSED:
		cmp p_pressed, 0
		je toggle_pause
		jmp done
	toggle_pause:

		mov p_pressed, 1
		cmp paused, 0
		je pauseGame
		mov paused, 0
		jmp done
	pauseGame:
		mov paused, 1

	done:
		ret
CheckPause ENDP



GameInit PROC USES eax

	;; LOAD POINTERS FOR BITMAPS INTO GLOBAL VARS FOR EASY ACCESS

		mov camera.left_x, 0
		mov camera.right_x, 027f0000h

		mov score, 0
		mov winner, 0

    lea eax, mountainsBMP
    mov backgroundSprite.pointer, eax
    mov backgroundSprite.x_pos, 0fec00000h 	;x=319
    mov backgroundSprite.y_pos, 0dc0000h	;y=220

		lea eax, deadBMP
    mov deadSprite.pointer, eax
    mov deadSprite.x_pos, 01400000h 	;x=319
    mov deadSprite.y_pos, 0820000h	;y=220

		lea eax, better_pause
		mov pauseSprite.pointer, eax
		mov pauseSprite.x_pos, 01400000h
		mov pauseSprite.y_pos, 0820000h

		lea eax, Winner
		mov winnerSprite.pointer, eax
		mov winnerSprite.x_pos, 01400000h
		mov winnerSprite.y_pos, 0820000h

		lea eax, Welcome
		mov welcomeSprite.pointer, eax
		mov welcomeSprite.x_pos, 01400000h
		mov welcomeSprite.y_pos, 0da0000h

		lea eax, PenguinStraight
		mov mainCharacter.pointer, eax
		mov mainCharacter.straightBMP, eax
		lea eax, PenguinLeft
		mov mainCharacter.leftBMP, eax
		lea eax, PenguinRight
		mov mainCharacter.rightBMP, eax
		mov mainCharacter.global_x, 0c80000h	;x=200
		mov mainCharacter.y_pos, 0c80000h	;y=200
		mov mainCharacter.previous_y, 0c80000h	;y=200
		mov mainCharacter.jumping, 1	;y=200
		mov mainCharacter.dead, 0	;y=200
		mov mainCharacter.vertical_velocity, 0	;y=200
		mov mainCharacter.angle, 0	;y=200
		mov mainCharacter.flipping, 0	;y=200

		lea eax, soloCup
		mov soloCup1.pointer, eax
		mov soloCup1.global_x, 02080000h	;x=479
		mov soloCup1.y_pos, 00ca0000h	;y=200
		mov soloCup1.dead, 0

		mov soloCup2.pointer, eax
		mov soloCup2.global_x, 03500000h	;x=479
		mov soloCup2.y_pos, 014a0000h	;y=200
		mov soloCup2.dead, 0

		mov soloCup3.pointer, eax
		mov soloCup3.global_x, 04500000h	;x=479
		mov soloCup3.y_pos, 014a0000h	;y=200
		mov soloCup3.dead, 0

		mov soloCup4.pointer, eax
		mov soloCup4.global_x, 05000000h	;x=479
		mov soloCup4.y_pos, 00ca0000h	;y=200
		mov soloCup4.dead, 0

		mov soloCup5.pointer, eax
		mov soloCup5.global_x, 01500000h	;x=479
		mov soloCup5.y_pos, 010a0000h	;y=200
		mov soloCup5.dead, 0


    mov firstPlatform.global_x, 0c80000h  ; x=200
    mov firstPlatform.y_pos, 01900000h ;y=318
    mov firstPlatform.color, 0ddh
    mov firstPlatform.p_height, 021h ; height = 100
    mov firstPlatform.p_width, 0c8h ; width = 200

		mov secondPlatform.global_x, 02080000h  ; x=200
		mov secondPlatform.y_pos, 01100000h ;y=318
		mov secondPlatform.color, 0edh
		mov secondPlatform.p_height, 021h ; height = 100
		mov secondPlatform.p_width, 0c8h ; width = 200

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

	checkWelcome:
		mov eax, welcomeScreen
		cmp eax, 1
		jne checkWinner
		mov eax, KeyPress
		cmp eax, VK_RETURN
		jne scroll
		mov welcomeScreen, 0
		INVOKE GameInit

	checkWinner:
		mov eax, score
		cmp eax, scoreToWin
		jl checkDead
		mov winner, 1
		mov eax, KeyPress
		cmp eax, VK_RETURN
		jne  checkPhysics
		INVOKE GameInit


	checkDead:
		mov eax, mainCharacter.dead
		cmp eax, 1
		jne checkPause
		INVOKE DrawSprite, deadSprite
		mov eax, KeyPress
		cmp eax, VK_R
		jne  done
		INVOKE GameInit

	checkPause:
		INVOKE CheckPause
		cmp paused, 1
		je gamePaused



  checkKeyboard:
    INVOKE Keyboard_Check, ADDR mainCharacter

  checkCollisions:

		INVOKE CheckSpritePlatformInteraction, ADDR mainCharacter, ADDR firstPlatform
		INVOKE CheckSpritePlatformInteraction, ADDR mainCharacter, ADDR secondPlatform
		INVOKE CheckSpritePlatformInteraction, ADDR mainCharacter, ADDR thirdPlatform

	checkCups:
		INVOKE CheckCharacterCupInteraction, ADDR mainCharacter, ADDR soloCup1
		add score, eax
		INVOKE CheckCharacterCupInteraction, ADDR mainCharacter, ADDR soloCup2
		add score, eax
		INVOKE CheckCharacterCupInteraction, ADDR mainCharacter, ADDR soloCup3
		add score, eax
		INVOKE CheckCharacterCupInteraction, ADDR mainCharacter, ADDR soloCup4
		add score, eax
		INVOKE CheckCharacterCupInteraction, ADDR mainCharacter, ADDR soloCup5
		add score, eax

	checkPhysics:
		;update positions
		INVOKE CheckCharacterFlipping, ADDR mainCharacter
		INVOKE UpdateSpritePositions, ADDR mainCharacter
		INVOKE UpdateSpriteVelocities, ADDR mainCharacter
		INVOKE AnimateMainCharacter, ADDR mainCharacter

  	INVOKE Render
		jmp done

	gamePaused:
		INVOKE DrawSprite, pauseSprite
		jmp done

	scroll:
		INVOKE DrawSprite, backgroundSprite
		INVOKE DrawSprite, welcomeSprite

		sub backgroundSprite.x_pos, 040000h

	checkBackground:
		mov eax, backgroundSprite.x_pos				;move xposition of backgroundinto eax
		cmp eax, 0fec00000h
		jg done								;if if background is still in frame keep going
		mov backgroundSprite.x_pos, 03bf0000h




	done:
	  ret         ;; Do not delete this line!!!
GamePlay ENDP






END
