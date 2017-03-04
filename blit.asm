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
include blit.inc

.DATA

	my_array BYTE 0deh, 0adh, 0beh, 0efh
	;; If you need to, you can place global variables here

.CODE

DrawPixel PROC USES eax edx ebx x:DWORD, y:DWORD, color:DWORD

	;validate x
	mov	eax, x
	cmp eax, 0			;verify it's less than 0
	jl 	invalid
	cmp eax, 640 		;verify it's bigger than 640
	jge invalid


	;validate y
	mov	eax, y
	cmp eax, 0			;verify it's less than 0
	jl 	invalid
	cmp eax, 480 		;verify it's bigger than 640
	jge invalid

	mov eax, y 				;    Y
	mov ebx, 640
	mul ebx 				; * 480
	add eax, x 				; +  X
	add eax, ScreenBitsPtr  ; + ScreenBitsPtr ==> Address

	mov edx, color
	and edx, 0ffh 			; get only the bit we want from color *****CHECK THIS!!!

	mov ebx, [eax]			; load set of data into ebx
	and ebx, 0ffffff00h		; our byte we want to change is the lsb due to endianness, clear it

	or ebx, edx 			; Combine the old memory and the new color
	mov [eax], ebx 			; put it back

 invalid:
	ret 			; Don't delete this line!!!
DrawPixel ENDP

BasicBlit PROC USES eax ebx esi ptrBitmap:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD
	LOCAL pic_width:DWORD, pic_height:DWORD, transparentColor:dword, start_x:DWORD, start_y:DWORD, end_x:DWORD, end_y:DWORD


  	xor eax, eax
  	xor ebx, ebx
  	xor esi, esi
  	mov ecx, ptrBitmap		;put the value of ptrBitMap into edx so we can use that to find our struct values
  	mov eax, [ecx]
  	mov ebx, [ecx+4]
   	mov esi, [ecx+8]
   	mov transparentColor,esi	;transparentColor = bm.trans
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

      mov esi, [ecx + 16 + edx] ;	thisColor = pixels[index]

    	and esi, 0ffh			;			 //remove other colors from registr ***CHECK THIS

    	cmp esi, transparentColor 		; 	if(thisColor = transparentColor){"
    	jz	Transparent 				;   	continue;
    									;	}
    	INVOKE DrawPixel, eax, ebx,  esi	;	drawPixel(x=eax, y=ebx, color=esi)

    Transparent:

      inc eax 				;			index ++
      inc edx					; 			col ++
      jmp InnerLoop			;		}
    DoneWithRow:
    	inc ebx					; row++
    	jmp	OuterLoop			;}
    DoneWithDrawing:





	ret 			; Don't delete this line!!!
BasicBlit ENDP


RotateBlit PROC USES eax ebx esi edx lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
	LOCAL cos_x:FXPT, sin_x:FXPT, shift_x:FXPT, shift_y:FXPT, dst_width:FXPT, dst_height:FXPT, dst_x:FXPT, dst_y:FXPT, transparentColor:FXPT, src_x: FXPT, src_y: FXPT


	mov ecx, lpBmp
	mov eax, [ecx+8]
	;mov eax, 0ffh ;;REMOVE
 	mov transparentColor,eax	;transparentColor = bm.trans

	mov eax, angle
	INVOKE FixedSin, angle
	mov sin_x, eax

	mov eax, angle
	INVOKE FixedCos, angle
	mov cos_x, eax


	mov eax, [ecx]						;eax = dwWidth
	shl eax, 16							;CONVERT TO FIXED
	INVOKE FixedMultiply, eax, cos_x	;eax = dWidth * cos_a ***VERIFY THIS]
	sar eax, 1							;divide by 2
	mov shift_x, eax					;move this term to both shift_x and shift_y since they both start with this

	mov eax, [ecx + 4]					;eax = dwHeight
	shl eax, 16							;CONVERT TO FIXED
	INVOKE FixedMultiply, eax, sin_x	;eax = dHeight * cos_a ***VERIFY THIS
	sar eax, 1							;divide by 2
	sub shift_x, eax					;shiftx = this - eax


	mov eax, [ecx + 4]						;eax = dwHeight
	shl eax, 16							;CONVERT TO FIXED
	INVOKE FixedMultiply, eax, cos_x	;eax = dWidth * cos_a ***VERIFY THIS
	sar eax, 1							;divide by 2
	mov shift_y, eax


	mov eax, [ecx]					;eax = dwHeight]
	shl eax, 16							;CONVERT TO FIXED
	INVOKE FixedMultiply, eax, sin_x	;eax = dWidth * cos_a ***VERIFY THIS]
	sar eax, 1							;divide by 2	\
	add shift_y, eax					;shifty = this + eax


	mov eax, [ecx]				;DST widht = dwWidth
	add eax, [ecx + 4]			;			+dwHeight
	shl eax, 16					;CONVERT TO FIXED

	mov dst_width, eax			;put in place
	mov dst_height, eax			; w = h


	mov eax, dst_width
	mov dst_x, eax
	neg dst_x		;dst_x = -dst_width
	mov edx, 0

  OuterForCheck:
  	mov eax, dst_x
  	cmp eax, dst_width		;jump away if dstx > dstWidth
  	jge DoneWithDrawing

  	;initialize inner loop
  	mov eax, dst_height
  	mov dst_y, eax
	neg dst_y		;dst_y = -dst_height

  InnerForCheck:
  	mov eax, dst_y
  	cmp eax, dst_height		;jump away if dst_y > dst_height
  	jge InnerLoopOver

  	;calc srcx
  	INVOKE FixedMultiply, dst_x, cos_x
  	mov src_x, eax							;src_x = cos*dstx

  	INVOKE FixedMultiply, dst_y, sin_x
  	add src_x, eax							;srcx = cos*dstx + dsty*sinx

	INVOKE FixedMultiply, dst_y, cos_x
  	mov src_y, eax							;src_x = cos*dsty

  	INVOKE FixedMultiply, dst_x, sin_x
  	sub src_y, eax							;srcx = cos*dsty - dstx*sinx

  Condition1:				;src_x >=0
  	cmp src_x, 0
  	jl	AConditionFailed

  Condition2:				;src_y >09
  	cmp src_y, 0
  	jl	AConditionFailed

  Condition3:				; srx_x < dwWidth
  	mov eax, [ecx]		; eax = dwWidth
	shl eax, 16
  	cmp src_x, eax
  	jge	AConditionFailed

  Condition4:				; srx_y < dwWidth
	mov eax, [ecx+4]		; eax = dwHeight
	;mov eax, 20	;REMOVE
	shl eax, 16
  	cmp src_y, eax
  	jge	AConditionFailed




  ; CONDITIONS 5-8 are already checked in DrawPixel, wasteful to do it twice

  AllTrue:

 	;;Calculate the offset of pixel


 	;;WORKS
	mov edx, [ecx]		;edx = width
	mov eax, src_y		; eax = src_y(fixed)
	shr	eax, 16		; convert to int
	mul	edx				;multiply by width
	mov edx, eax
	mov eax, src_x		; eax = src_x(fixed)
	shr eax, 16		; convert to int
	add edx, eax		; add to int



	;;calculate x position WROKSS
	mov eax, xcenter		;xcenter + dstx - shiftx >=0
	shl eax, 16		;convert to fixed
  	add eax, dst_x
  	sub eax, shift_x


  	;;calculate y position WORKSS
  	mov ebx, ycenter		;ycenter + dsty - shifty >=0
	shl ebx, 16		;Convert to fixed
  	add ebx, dst_y
  	sub ebx, shift_y

  	shr eax, 16
  	shr ebx, 16				;convert both back to INT


  	mov esi, [ecx + 16 + edx] 	;	thisColor = pixels[index]

  	and esi, 0ffh				;			 //remove other colors from registr ***CHECK THIS

  	cmp esi, transparentColor 	; 	if(thisColor = transparentColor){"
  	jz	AConditionFailed 		;   	continue;
  								;	}
  	INVOKE DrawPixel, eax, ebx,  esi	;	drawPixel(x=eax, y=ebx, color=esi)

  	add edx, 1					;still SHOULD want to incremend edx if we failed the conditions, because we don't want to draw that part of the pic



  AConditionFailed:
  	add dst_y, 10000h				;increment dsty by 1 in fixed
  	jmp InnerForCheck				;repeat inner loop
  InnerLoopOver:
  	add dst_x, 10000h				;increment dstx by 1 in fixed
  	jmp OuterForCheck				;repeat outer loop
  DoneWithDrawing:



  ret
RotateBlit ENDP


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
