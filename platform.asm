; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include lines.inc
include trig.inc
include platform.inc
include blit.inc

.DATA

.CODE

BasicPlatform PROC USES eax ebx esi platform:PTR Platform, xcenter:DWORD, ycenter:DWORD
	LOCAL pic_width:DWORD, pic_height:DWORD, color:dword, start_x:DWORD, start_y:DWORD, end_x:DWORD, end_y:DWORD
  	xor eax, eax
  	xor ebx, ebx
  	xor esi, esi
  	mov ecx, platform		;put the value of ptrBitMap into edx so we can use that to find our struct values
  	mov eax, (Platform PTR [ecx]).p_width
  	mov ebx, (Platform PTR [ecx]).p_height

   	mov esi, (Platform PTR [ecx]).color
    and esi, 0ffh			;			 //remove other colors from registr ***CHECK THIS

   	mov color,esi	;transparentColor = bm.trans
  	mov pic_width, eax				;store width and height for easy access
  	mov pic_height, ebx

  	shr eax, 1				;eax = width/2
  	shr ebx, 1				;ebx = height/2

  	mov start_x, eax		;temp movement
  	mov start_y, ebx		;temp movement

  	mov eax, xcenter		;put x and y center in place so we can subtract the halves
  	mov ebx, ycenter

  	sub eax, start_x		; by doing cetnter - w/2 and
  	sub ebx, start_y		; 			center - h/2 we now have top left forner in (eax, ebx)

  	mov start_x, eax
  	mov start_y, ebx

  	add eax, pic_width			; end_x = start x + width
  	add ebx, pic_height			; end_y = start y + width

  	mov end_x, eax
  	mov end_y, ebx




  	mov eax, start_x			;eax will be xPos (outer for loop)
  	mov ebx, start_y 			;ebx will be yPos(inner for loop)
  								;ecx will hold the pointer to ptrBitMap
  								;esi will be our temp variable for the color
  	mov edx, 0					;edx will be the position in the array

  							; index = edx = 0

    OuterLoop:
      cmp ebx, end_y			; for(row = start_y; row < end_x; row ++) (eax = row){
      jge DoneWithDrawing
      mov eax, start_x

    InnerLoop:
      cmp eax, end_x			; 		for(col = start_x; col < end_y; col ++)(ebx = col){
      jge DoneWithRow

    									;	}
    	INVOKE DrawPixel, eax, ebx,  color	;	drawPixel(x=eax, y=ebx, color=esi)

    Transparent:

      inc eax 				;			index ++
      inc edx					; 			col ++
      jmp InnerLoop			;		}
    DoneWithRow:
    	inc ebx					; row++
    	jmp	OuterLoop			;}
    DoneWithDrawing:

	ret 			; Don't delete this line!!!
BasicPlatform ENDP

DrawPlatform PROC USES eax ebx ecx platform:PTR Platform
  mov ecx, platform		;put the value of ptrBitMap into edx so we can use that to find our struct values
  mov eax, (Platform PTR [ecx]).x_pos
  mov ebx, (Platform PTR [ecx]).y_pos

  sar eax, 16
  sar ebx, 16  ;CONVERT both from fixed to reg


  INVOKE BasicPlatform, ecx, eax, ebx


  ret
DrawPlatform ENDP



END
