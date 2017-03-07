; #########################################################################
;
;   trig.inc - Includes for EECS205 Assignment 3
;
;
; #########################################################################
Sprite STRUCT
  pointer 		DWORD ?
  global_x    DWORD ? ;NO global Y since camera cannot vary in Y
  x_pos 			DWORD ?
  y_pos 			DWORD ?
  previous_y  DWORD 0
  angle 			DWORD 0
  horizontal_velocity    DWORD 0
  vertical_velocity      DWORD 0

  ;booleans
  jumping       DWORD 0
  dead          DWORD 0

  ;constants
  horizontal_accel       DWORD 0
  vertical_accel         DWORD 0ffff0000h
  max_speed              DWORD 06ffffh
  jump_velocity          DWORD 010ffffh
Sprite ENDS

DrawSprite PROTO STDCALL sprite:Sprite
ChangeSpritePosition_Keyboard PROTO STDCALL spriteAddress:PTR Sprite
Keyboard_Check PROTO STDCALL spriteAddress:PTR Sprite
ChangeSpritePosition_MOUSE PROTO STDCALL spriteAddress:PTR Sprite
CheckSpritePlatformVerticalInteraction PROTO STDCALL spriteAddress:PTR Sprite, platformAddress:PTR Platform
UpdateSpritePositions PROTO STDCALL spriteAddress:PTR Sprite
UpdateSpriteVelocities PROTO STDCALL spriteAddress:PTR Sprite
CheckIntersectBetter PROTO STDCALL spriteOne:PTR Sprite, spriteTwo:PTR Sprite, sprite_y:DWORD
CheckIntersectSpriteAndPlatform PROTO spriteOne:PTR Sprite, platform:PTR Platform, sprite_y:DWORD
CheckSpritePlatformInteraction PROTO sprite:PTR Sprite, platform:PTR Platform
