

Platform STRUCT
  x_pos 			DWORD ?    ;FIXED
  global_x    DWORD ?
  y_pos 			DWORD ?    ;FIXED
  p_height 			DWORD ? ;DWORD
  p_width       DWORD ? ;DWORD
  color       DWORD 0ffh
Platform ENDS

BasicPlatform PROTO STDCALL platform:PTR Platform, xcenter:DWORD, ycenter:DWORD
DrawPlatform PROTO STDCALL platform:PTR Platform
