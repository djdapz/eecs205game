
.586
.MODEL FLAT,STDCALL
.STACK 4096
option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc
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
  LOCAL velocity:DWORD
  mov esi, spriteAddress

  mov eax, (Sprite PTR [esi]).velocity 		  ;put velocity in local  var
  mov velocity, eax

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
    xor velocity, 0ffffffffh    ;we want to move it negative in the velocity if we're going left
    inc velocity
	moveRight:
	  INVOKE MoveSpriteHoriz, spriteAddress, velocity
    jmp done

  moveUp:
    xor velocity, 0ffffffffh    ; we want to edincrment the y_position if moving up
    inc velocity
	moveDown:
	  INVOKE MoveSpriteVert, spriteAddress, velocity
    jmp done

	done:
	  ret
ChangeSpritePosition_Keyboard ENDP

ChangeSpritePosition_MOUSE PROC uses eax ebx edx esi spriteAddress:PTR Sprite
    LOCAL velocity
    mov esi, spriteAddress

    mov eax, (Sprite PTR [esi]).velocity 		  ;put velocity in local  var
    mov velocity, eax

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
    xor velocity, 0ffffffffh    ; we want to edincrment the y_position if moving up
    inc velocity
  moveDown:
    INVOKE MoveSpriteVert, spriteAddress, velocity
    jmp done



  horizontalMovement:
    ;setup necessary variables
    mov eax,  MouseStatus.horiz         ;eax = mouse
    shl eax, 16                          ;convert mouse to fixed
    mov ebx,  (Sprite PTR [esi]).x_pos   ;ebx = sprite


    cmp eax, ebx
    jg  moveRight
  moveLeft:
    xor velocity, 0ffffffffh    ;we want to move it negative in the velocity if we're going left
    inc velocity
  moveRight:
    INVOKE MoveSpriteHoriz, spriteAddress, velocity
    jmp done

  	done:
  	  ret
ChangeSpritePosition_MOUSE ENDP


END
