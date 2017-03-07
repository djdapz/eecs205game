; #########################################################################
;
;   trig.inc - Includes for EECS205 Assignment 3
;
;
; #########################################################################
Sprite STRUCT
  ;physics variables
  global_x    DWORD ? ;NO global Y since camera cannot vary in Y
  x_pos 			DWORD ?
  y_pos 			DWORD ?
  previous_y  DWORD 0
  angle 			DWORD 0
  horizontal_velocity    DWORD 0
  vertical_velocity      DWORD 0

  ;bitmap variables
  pointer 		DWORD ?   ;what the image actually is
  straightBMP DWORD ?
  rightBMP    DWORD ?
  leftBMP     DWORD ?

  ;booleans
  jumping       DWORD 0
  dead          DWORD 0
  flipping      DWORD 0

  ;constants
  horizontal_accel       DWORD 0
  vertical_accel         DWORD 0ffff0000h
  max_speed              DWORD 0affffh
  jump_velocity          DWORD 010ffffh
  angular_velocity       DWORD 0ffffh
Sprite ENDS

DrawSprite PROTO STDCALL sprite:Sprite
ChangeSpritePosition_Keyboard PROTO STDCALL spriteAddress:PTR Sprite
Keyboard_Check PROTO STDCALL spriteAddress:PTR Sprite
ChangeSpritePosition_MOUSE PROTO STDCALL spriteAddress:PTR Sprite
CheckSpritePlatformVerticalInteraction PROTO STDCALL spriteAddress:PTR Sprite, platformAddress:PTR Platform
UpdateSpritePositions PROTO STDCALL spriteAddress:PTR Sprite
UpdateSpriteVelocities PROTO STDCALL spriteAddress:PTR Sprite
CheckIntersectBetter PROTO STDCALL spriteOne:PTR Sprite, spriteTwo:PTR Sprite, sprite_y:DWORD
CheckIntersectSpriteAndPlatform PROTO STDCALL spriteOne:PTR Sprite, platform:PTR Platform, sprite_y:DWORD
CheckSpritePlatformInteraction PROTO STDCALL sprite:PTR Sprite, platform:PTR Platform
AnimateMainCharacter PROTO STDCALL sprite:PTR Sprite
CheckCharacterCupInteraction PROTO STDCALL character:ptr Sprite, cup:ptr Sprite
CheckCharacterFlipping PROTO STDCALL character:PTR Sprite
