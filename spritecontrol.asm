
.586
.MODEL FLAT,STDCALL
.STACK 4096
option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc
include platform.inc
include game.inc
include spritecontrol.inc

;; Has keycodes
include keys.inc


.DATA
	;; If you need to, you can place global variables here

.CODE

DrawSprite PROC uses ebx sprite:Sprite
	LOCAL x_pos:DWORD, y_pos:DWORD

	mov ebx, sprite.x_pos		;shift the fixed x position to decimal x position
	sar ebx, 16					;use arithmetic shift to preserve sign
	mov x_pos, ebx

	mov ebx, sprite.y_pos		;shift the fixed Y position to decimal Y position
	sar ebx, 16					;use arithmetic shift to preserve sign
	mov y_pos, ebx



	mov ebx, sprite.angle			;check angle, if none, then jraw basic, if so, invoke rotate
	cmp ebx, 0
	jz noRotation
	INVOKE RotateBlit, sprite.pointer, x_pos, y_pos, sprite.angle
	jmp done

  noRotation:
  	INVOKE BasicBlit, sprite.pointer, x_pos, y_pos

  done:
	ret
DrawSprite ENDP


MoveSpriteHoriz PROC uses eax spriteAddress:PTR Sprite, amount:DWORD
    mov esi, spriteAddress

    mov eax, (Sprite PTR [esi]).x_pos  		;ebx = x
    add eax, amount

    cmp eax, 027f0000h  ;past right edge
    jg  makeZero
    cmp eax, 00h        ;negative
    jl  makeRightEdge
    jmp nowSafe

  makeZero:
    mov eax, 000h
    jmp nowSafe
  makeRightEdge:
    mov eax, 027f0000h
    jmp nowSafe

  nowSafe:
    mov (Sprite PTR [esi]).x_pos, eax

    ret
MoveSpriteHoriz ENDP

MoveSpriteVert PROC uses eax spriteAddress:PTR Sprite, amount:DWORD
    mov esi, spriteAddress

    mov eax, (Sprite PTR [esi]).y_pos  		;ebx = x
    add eax, amount                   ;ebx = position + ammounttomove

    cmp eax, 01df0000h  ;past bottom
    jg  makeZero
    cmp eax, 00h        ;negative
    jl  makeRightEdge
    jmp nowSafe

  makeZero:
    mov eax, 000h
    jmp nowSafe
  makeRightEdge:
    mov eax, 01df0000h
    jmp nowSafe

  nowSafe:
    mov (Sprite PTR [esi]).y_pos, eax
    ret
MoveSpriteVert ENDP

ChangeSpritePosition_Keyboard PROC uses eax ebx edx esi spriteAddress:PTR Sprite
  LOCAL horizontal_velocity:DWORD, vertical_velocity:DWORD
  mov esi, spriteAddress

  mov eax, (Sprite PTR [esi]).horizontal_velocity 		  ;put velocity in local  var
  mov horizontal_velocity, eax

	mov eax, (Sprite PTR [esi]).vertical_velocity 		  ;put velocity in local  var
	mov vertical_velocity, eax

	mov eax, KeyPress
	mov ebx, (Sprite PTR [esi]).x_pos  		;ebx = x
	mov edx, (Sprite PTR [esi]).y_pos 		  ;edx = y

  ;figure out if it was an arrow key and route to correct move
	cmp eax, VK_RIGHT
	jz 	moveRight

	cmp eax, VK_LEFT
	jz 	moveLeft

	cmp eax, VK_UP
	jz 	moveUp

	cmp eax, VK_DOWN
	jz 	moveDown
  jmp done

  moveLeft:
    xor horizontal_velocity, 0ffffffffh    ;we want to move it negative in the velocity if we're going left
    inc horizontal_velocity
	moveRight:
	  INVOKE MoveSpriteHoriz, spriteAddress, horizontal_velocity
    jmp done

  moveUp:
    xor vertical_velocity, 0ffffffffh    ; we want to edincrment the y_position if moving up
    inc vertical_velocity
	moveDown:
	  INVOKE MoveSpriteVert, spriteAddress, vertical_velocity
    jmp done

	done:
	  ret
ChangeSpritePosition_Keyboard ENDP


Keyboard_Check PROC uses eax ebx esi spriteAddress:PTR Sprite
	  LOCAL max_speed:DWORD
	  mov esi, spriteAddress


	  mov ebx, (Sprite PTR [esi]).max_speed 		  ;put velocity in local  var
	  mov max_speed, ebx



	  ;figure out if it was an arrow key and route to correct move

	checkJumping:
		mov eax, MouseStatus.buttons
		cmp eax, 0
		je checkLeftRight 					;fall through if not equal

	jumping:		;check jump first so that if the user is already moving then jumping won't fuck it up
		mov ebx, (Sprite PTR [esi]).jumping
		cmp ebx, 0
		jne done 				; if the character is jumping, don't modify

		mov ebx, (Sprite PTR [esi]).jump_velocity
		mov (Sprite PTR [esi]).vertical_velocity, ebx
		mov (Sprite PTR [esi]).jumping, 1
		jmp done


	checkLeftRight:
		mov eax, KeyPress
		cmp eax, VK_RIGHT
		jz 	moveRight

		cmp eax, VK_LEFT
		jz 	moveLeft

		jmp neitherPressed

  moveLeft:
    xor max_speed, 0ffffffffh    ;we want to move it negative in the velocity if we're going left
    inc max_speed
	moveRight:
		mov ebx, max_speed
	  mov (Sprite PTR [esi]).horizontal_velocity, ebx
    jmp done

  neitherPressed:
		mov (Sprite PTR [esi]).horizontal_velocity, 0





	done:
	  ret
Keyboard_Check ENDP


ChangeSpritePosition_MOUSE PROC uses eax ebx edx esi spriteAddress:PTR Sprite
		LOCAL horizontal_velocity:DWORD, vertical_velocity:DWORD
		mov esi, spriteAddress

		mov eax, (Sprite PTR [esi]).horizontal_velocity 		  ;put velocity in local  var
		mov horizontal_velocity, eax

		mov eax, (Sprite PTR [esi]).vertical_velocity 		  ;put velocity in local  var
		mov vertical_velocity, eax

    mov eax, MouseStatus.buttons
    cmp eax, MK_LBUTTON
    je  horizontalMovement        ;right click makes sprite move up and down, left makes it move left and right
    cmp eax, MK_RBUTTON
    je  verticalMovement



  verticalMovement:
    ;setup necessary variables
    mov eax, MouseStatus.vert          ;eax = mouse
    shl eax, 16                          ;convert mouse to fixed
  	mov ebx, (Sprite PTR [esi]).y_pos    ; ebx = sprite


    cmp eax, ebx
    jg  moveDown
  moveUp:
    xor vertical_velocity, 0ffffffffh    ; we want to edincrment the y_position if moving up
    inc vertical_velocity
  moveDown:
    INVOKE MoveSpriteVert, spriteAddress, vertical_velocity
    jmp done



  horizontalMovement:
    ;setup necessary variables
    mov eax,  MouseStatus.horiz         ;eax = mouse
    shl eax, 16                          ;convert mouse to fixed
    mov ebx,  (Sprite PTR [esi]).x_pos   ;ebx = sprite


    cmp eax, ebx
    jg  moveRight
  moveLeft:
    xor horizontal_velocity, 0ffffffffh    ;we want to move it negative in the velocity if we're going left
    inc horizontal_velocity
  moveRight:
    INVOKE MoveSpriteHoriz, spriteAddress, horizontal_velocity
    jmp done

  	done:
  	  ret
ChangeSpritePosition_MOUSE ENDP

CheckSpritePlatformVerticalInteraction PROC USES edi esi ebx ecx spriteAddress:PTR Sprite, platformAddress:PTR Platform
		LOCAL platform_y:DWORD, sprite_y:DWORD, bottom_sprite:DWORD, top_platform:DWORD, top_sprite:DWORD, bottom_platform:DWORD
 		;Checks where sprite is releative to this platform - Return values:
		; Returns 2 if not touching
		; Returns 1 if intersecting
		; Returns 0 if on-top-of

		mov edi, platformAddress
		mov esi, spriteAddress

    mov eax, (Sprite PTR [esi]).y_pos
		sar eax, 16 											;convert to fixed
		mov sprite_y, eax

		mov eax, (Platform PTR [edi]).y_pos
		sar eax, 16
		mov platform_y, eax

		mov ebx, (Sprite PTR [esi]).pointer
		mov eax, (EECS205BITMAP PTR [ebx]).dwHeight	;since the height is in a bitmap which is in the strtuct we need two steps
		sar eax, 1    	;Convert and divide by 2
		add eax, sprite_y
		mov bottom_sprite, eax

		mov eax, (Platform PTR [edi]).p_height
		sar eax, 1 		;Convert and divide by 2
		mov ebx, platform_y
		sub ebx, eax    		; top_platform = platform_y - .5*height_platform
		mov top_platform, ebx
		add ebx, eax
		add ebx, eax    		; bottom_platform = top_platform + height_platform
		mov bottom_platform, ebx

		mov eax, top_platform
		sub eax, bottom_sprite      	;bottom of sprite - top_platform = distance

		cmp eax, 0
		jg positive
		jl negative
		jmp done

	positive:
		mov eax, 2
		jmp done

	negative:
		mov ecx, sprite_y
		mov top_sprite, ecx

		mov ebx, (Sprite PTR [esi]).pointer
		mov eax, (EECS205BITMAP PTR [ebx]).dwHeight	;since the height is in a bitmap which is in the strtuct we need two steps
		sar eax, 1    	;Convert and divide height by 2
		sub top_sprite, eax

		mov eax, top_sprite
		cmp bottom_platform, eax
		jge overlap   	;if bottom_platform less that top_sprite then they must intersect
		mov eax, 2
		jmp done
	overlap:
		mov eax, 1
	done:
		ret
CheckSpritePlatformVerticalInteraction ENDP



UpdateSpritePositions PROC USES esi eax ebx spriteAddress:PTR Sprite
		mov esi, spriteAddress

	checkHorizontal:
		mov eax, (Sprite PTR [esi]).horizontal_velocity
		cmp eax, 0 					; if no horizontal_velocity, do nothing
		je checkVertical

		mov ebx, (Sprite PTR [esi]).global_x		;incremenet the global x position by the velocity... should work for negative numbers
		add ebx, eax
		mov (Sprite PTR [esi]).global_x,  ebx

	checkVertical:
		mov eax, (Sprite PTR [esi]).vertical_velocity
		cmp eax, 0 					; if no vertical_velocity, do nothing
		je done

		mov ebx, (Sprite PTR [esi]).y_pos ; subtract to allow accelleration to be analagous to real world
		sub ebx, eax
		mov (Sprite PTR [esi]).y_pos, ebx

	done:
		ret
UpdateSpritePositions ENDP

UpdateSpriteVelocities PROC USES esi spriteAddress:PTR Sprite
		mov esi, spriteAddress

		mov eax, (Sprite PTR [esi]).horizontal_accel
		cmp eax, 0 					; if no accelleration, do nothing
		je checkVertical

		mov ebx,  (Sprite PTR [esi]).horizontal_velocity
		add ebx, eax
		mov (Sprite PTR [esi]).horizontal_velocity, ebx

	checkVertical:
	 	mov eax, (Sprite PTR [esi]).vertical_accel
		cmp eax, 0
		je done

		mov ebx,  (Sprite PTR [esi]).vertical_velocity
		add ebx, eax
		mov (Sprite PTR [esi]).vertical_velocity, ebx


  done:


		ret
UpdateSpriteVelocities ENDP


CheckIntersectBetter PROC uses esi spriteOne:PTR Sprite, spriteTwo:PTR Sprite
    local dist_vert:DWORD, dist_horz:DWORD, sum_horz:DWORD, sum_vert:DWORD, oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP

		mov esi, spriteOne
		mov eax, (Sprite PTR[esi]).x_pos
    mov oneX, eax
		mov eax, (Sprite PTR[esi]).y_pos
    mov oneY, eax
		mov eax, (Sprite PTR[esi]).pointer
    mov oneBitmap, eax


		mov esi, spriteTwo
		mov eax, (Sprite PTR[esi]).x_pos
    mov twoX, eax
		mov eax, (Sprite PTR[esi]).y_pos
    mov twoY, eax
		mov eax, (Sprite PTR[esi]).pointer
    mov twoBitmap, eax

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
CheckIntersectBetter ENDP

CheckIntersectSpriteAndPlatform PROC uses esi spriteOne:PTR Sprite, platform:PTR Platform
    local platformBMP:EECS205BITMAP, platformSprite:Sprite

		mov esi, platform
		mov eax, (Platform PTR[esi]).p_width
		mov platformBMP.dwWidth, eax
		mov eax, (Platform PTR[esi]).p_height
		mov platformBMP.dwHeight, eax
		lea eax, platformBMP
		mov platformSprite.pointer, eax
		mov eax, (Platform PTR[esi]).x_pos
		mov platformSprite.x_pos, eax
		mov eax, (Platform PTR[esi]).y_pos
		mov platformSprite.y_pos, eax

		INVOKE CheckIntersectBetter, spriteOne, ADDR platformSprite

		ret
CheckIntersectSpriteAndPlatform ENDP

CheckSpritePlatformInteraction PROC uses eax esi sprite:PTR Sprite, platform:PTR Platform

		mov esi, sprite

		INVOKE CheckIntersectSpriteAndPlatform, sprite,  platform
		cmp eax, 1
		jne done

		mov eax, (Sprite PTR[esi]).vertical_velocity
		cmp eax, 0
		jge done
		mov (Sprite PTR[esi]).vertical_velocity, 0
		mov (Sprite PTR[esi]).jumping, 0

		done:

		;make sure it's on top of not inside of the ground
		ret
CheckSpritePlatformInteraction ENDP


END
