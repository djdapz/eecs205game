; #########################################################################
;
;   blit.inc - Includes for EECS205 Assignment 3
;
;
; #########################################################################


_EECS205BITMAP STRUCT
 dwWidth      DWORD  ?
 dwHeight     DWORD  ?
 bTransparent BYTE   ?
              BYTE   3 DUP(?)
 lpBytes      DWORD  ?
_EECS205BITMAP ENDS

Platform STRUCT
  x_pos 			DWORD ?    ;FIXED
  y_pos 			DWORD ?    ;FIXED
  p_height 			DWORD ? ;DWORD
  p_width       DWORD ? ;DWORD
  color       DWORD 0ffh
Platform ENDS

EECS205BITMAP TYPEDEF _EECS205BITMAP

EXTERNDEF ScreenBitsPtr:DWORD

BasicBlit PROTO STDCALL ptrBitmap:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD
RotateBlit PROTO STDCALL ptrBitmap:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
BasicPlatform PROTO STDCALL platform:PTR Platform, xcenter:DWORD, ycenter:DWORD
DrawPlatform PROTO STDCALL platform:PTR Platform
