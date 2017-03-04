; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
TABLE_INCREMENT = 804		;; 	PI/256
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI
TWO_PI	= 411774                ;;  2 * PI
PI_INC_RECIP =  5340353        	;;  Use reciprocal to find the table entry for a given angle
	                        ;;              (It is easier to use than divison would be)

	;; If you need to, you can place global variables here

.CODE

FixedDivide PROC uses ebx a_val:SDWORD, b_val:SDWORD
	LOCAL neg_mask:DWORD, pos_mask:DWORD, a_sign:DWORD, b_sign:DWORD,  result_sign:DWORD

	mov neg_mask, 80000000h

	mov eax, a_val			;load a into eax
	and eax, neg_mask		;and a with the negative mask --> if negative eax will be > 0, else eax = 0
	mov a_sign, eax			;move this into a_pos
	cmp a_sign, 0
	je  check_b

	mov eax, a_val
	xor eax, 0ffffffffh		; invert all of the bits
	add eax, 1
	mov a_val, eax

 check_b:
	mov eax, b_val			;load b into eax
	and eax, neg_mask		;and b with the negative mask --> if negative eax will be > 0, else eax = 0
	mov b_sign, eax			;move this into a_pos
	cmp b_sign, 0
	je  compare_signs

	mov eax, b_val
	xor eax, 0ffffffffh		; invert all of the bits
	add eax, 1
	mov b_val, eax

  compare_signs:
	mov eax, a_sign
	xor eax, b_sign
	mov	result_sign, eax	; Now we just OR the result sign with whatever we get at the END!


	mov edx, a_val
  mov eax, a_val
  shr edx, 16
  shl eax, 16


	div ebx					;do the multiplication

	cmp result_sign, 0		;if the result sign is negative, make num neg
	je	done
	xor eax, 0ffffffffh		; invert all of the bits
	add eax, 1				; add 1
  done:

	ret
FixedDivide ENDP


FixedMultiply PROC uses ebx a_val:SDWORD, b_val:SDWORD
	LOCAL neg_mask:DWORD, pos_mask:DWORD, a_sign:DWORD, b_sign:DWORD,  result_sign:DWORD

	mov neg_mask, 80000000h

	mov eax, a_val			;load a into eax
	and eax, neg_mask		;and a with the negative mask --> if negative eax will be > 0, else eax = 0
	mov a_sign, eax			;move this into a_pos
	cmp a_sign, 0
	je  check_b

	mov eax, a_val
	xor eax, 0ffffffffh		; invert all of the bits
	add eax, 1
	mov a_val, eax

 check_b:
	mov eax, b_val			;load b into eax
	and eax, neg_mask		;and b with the negative mask --> if negative eax will be > 0, else eax = 0
	mov b_sign, eax			;move this into a_pos
	cmp b_sign, 0
	je  compare_signs

	mov eax, b_val
	xor eax, 0ffffffffh		; invert all of the bits
	add eax, 1
	mov b_val, eax

  compare_signs:
	mov eax, a_sign
	xor eax, b_sign
	mov	result_sign, eax	; Now we just OR the result sign with whatever we get at the END!


	mov ebx, b_val
	mov eax, a_val

	mul ebx					;do the multiplication

	shr eax, 16
	shl edx, 16
	or eax, edx

	cmp result_sign, 0		;if the result sign is negative, make num neg
	je	done
	xor eax, 0ffffffffh		; invert all of the bits
	add eax, 1				; add 1


  done:


	ret
FixedMultiply ENDP



FixedSin PROC USES ebx edx esi angle:FXPT
	LOCAL sine_neg:DWORD

    mov     sine_neg, 0
	xor		esi, esi			;clear our sign bit
								;going to have to mask away the negative part, do that later
	mov		eax, angle
	mov 	ebx, TWO_PI
  NegCheck:
	cmp 	eax, 0
	jge 	AnglePositive
	add 	eax, ebx			; if eax < 0, add two PI untill it's > 0
	cmp 	eax, 0
	jl  	NegCheck

  AnglePositive:
	cmp 	eax, ebx
	jle		WithinTwoPi			; if the angle is greater than two pi,
	sub		eax, ebx			;   --> Subtract 2pi from it
	cmp 	eax, ebx
	jge 	AnglePositive


  WithinTwoPi:
    cmp  	eax, PI 			;now that we know eax is within 2PI, we're checking if sine is positive or negative
    jg		SineIsNegative      ;if eax > pi, then sine is engative, so we should set a bit and subtract pi away
    jmp 	CheckIfAscendingOrDescending

  SineIsNegative:				;meaning theta is between pi and 2pi

  	mov 	sine_neg, 1			; shift left by pi
  	sub 	eax, PI 			; Since it's just a negation now

  CheckIfAscendingOrDescending:
  	cmp 	eax, PI_HALF
  	jle		TableLookup			; if pi is less than pi/2 than we just jump to the lookup
  	mov 	ebx, PI 			; PI/ - angle will give us the propper theta to use if  pi/2 < angle < pi
  	sub 	ebx, eax 			; subtrack angle from pi
  	mov 	eax, ebx  			; place result in eax
  	 							; no need for any flags since it's just a reflection

  TableLookup:
	xor 	edx, edx 			;clear edx so it's not used
	mov		ebx, PI_INC_RECIP
	INVOKE 	FixedMultiply, ebx, eax	;essentially divide our angle by the increment --> now in eax
	shr		eax, 16				;clear the decimal bits for the reference and to allow easy multiplication in lookup
	movzx	eax, WORD PTR [SINTAB + eax*2];look up corTresponding value and put in bx since it's just a word, not a DWORD

	mov 	ebx, sine_neg 		; if the sineNeg variable is set, then we must negate eax
	cmp 	ebx, 0
	jz 		Finished
    xor		eax, 0ffffffffh		; flip the bits

  Finished:

	ret
FixedSin ENDP

FixedCos PROC uses ebx angle:FXPT

	;mov		eax, angle
	;mov		ebx, 80000000h			; check if sign flag is 1
	;and		ebx, eax					; if this
	;jz		AnglePositive		;if it isn't jump away to AnglePositive

 ; AngleNegative:
	;get rid of sign
	;add 3pi/2
	;put sign flag back
	;mov 	ebx, PI_HALF
	;add 	eax, ebx			; eax = angle + pi/2
	;add 	eax, ebx			; eax = angle + 2pi/2
	;add 	ebx, ebx			; eax = angle + 3pi/2
	;jmp 	CalcSin


  ;AnglePositive:
	mov		eax, angle
  	mov 	ebx, PI_HALF		;just shift right by pi/2
	add 	eax, ebx
	mov 	ebx, eax

  CalcSin:

	INVOKE FixedSin, ebx

	ret			; Don't delete this line!!!
FixedCos ENDP

END
