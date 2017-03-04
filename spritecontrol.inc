; #########################################################################
;
;   trig.inc - Includes for EECS205 Assignment 3
;
;
; #########################################################################
Sprite STRUCT
  pointer 		DWORD ?
  x_pos 			DWORD ?
  y_pos 			DWORD ?
  angle 			DWORD 0
  velocity    DWORD 04ffffh
Sprite ENDS

DrawSprite PROTO STDCALL sprite:Sprite
ChangeSpritePosition_Keyboard PROTO STDCALL spriteAddress:PTR Sprite
ChangeSpritePosition_MOUSE PROTO STDCALL spriteAddress:PTR Sprite
