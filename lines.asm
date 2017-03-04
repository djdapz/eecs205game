; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
;	Devon D'Apuzzo - DJD809
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here

.CODE


;; Don't forget to add the USES the directive here
;;   Place any registers that you modify (either explicitly or implicitly)
;;   into the USES list so that caller's values can be preserved

;;   For example, if your procedure uses only the eax and ebx registers
;;      DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
DrawLine PROC uses eax edx ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	;; Feel free to use local variables...declare them here
	;; For example:
	;; 	LOCAL foo:DWORD, bar:DWORD

	LOCAL delta_x:DWORD, delta_y:DWORD, inc_x:SDWORD, inc_y:SDWORD, error:SDWORD, curr_x:DWORD, curr_y:DWORD, prev_error:SDWORD, test_counter:SDWORD

	;; Place your code here

;;CALCULATE ABS_X
    mov eax, x0
    mov ebx, x1
    cmp eax, ebx
    jg do_sub_abs_x      	;if(x0 < x1) --> Straight to x1-x2
    mov eax, x1    			;else --> Swap so we can subtract
    mov ebx, x0

  do_sub_abs_x:
    sub eax, ebx    		;Subtract --> Abs shold be in eax
    mov delta_x, eax

;;CALCULATE ABS_Y
    mov eax, y0
    mov ebx, y1
    cmp eax, ebx
    jg  do_sub_abs_y      	;if(y0 < y1) --> Straight to y0-y1
    mov eax, y1 	 		;else --> Swap so we can subtract
    mov ebx, y0

  do_sub_abs_y:
    sub eax, ebx   			;Subtract --> Abs shold be in eax
    mov delta_y, eax


  check_inc_y:
    mov eax, y0
    cmp eax, y1        ;; IF y0 < y1 --> inc_y =1 else inc_y = -1
    jl y_pos          ;if y0 is less than y1 --> inc_y should be positive --> jump to y_pos
    mov inc_y, -1     ; else, make it negative
    jmp check_inc_x   ; jump out to x
  y_pos:
    mov inc_y, 1

  check_inc_x:
    mov eax, x0
    cmp eax, x1
    jl x_pos        ; if xo < x1 --> inx_z = -1 --> jump to x_pos
    mov inc_x, -1       ; else, --> inc_x = -1
    jmp check_deltas   ;jump out oto deltas
  x_pos:
    mov inc_x, 1

  check_deltas:
    mov eax, delta_x
    cmp eax, delta_y  ; delta_x vs delta_y
    jg delta_x_greater_than_delta_y
    mov edx, 0        ;clear edx so it's not messed with
    mov eax, delta_y  ;move delta_y in position to be manip
    mov ebx, -1       ;move divisor into ebx
    imul ebx           ;negate delta_y
    mov ebx, 2        ;move divisor into ebx
    idiv ebx           ;divide result by 2
    mov error, eax    ; move the result to the error variable
    jmp curr_stuff;
  delta_x_greater_than_delta_y:
    mov edx, 0        ; make the top half of the divisor 0
    mov eax, delta_x  ; move delta_x in position to be divided
    mov ebx, 2        ; move divisor into ebx
    div ebx             ; divide delta_x by 2
    mov error, eax    ; move the result to the error variable
    jmp curr_stuff


  curr_stuff:
    mov eax, x0
    mov curr_x, eax
    mov eax, y0
    mov curr_y, eax

    INVOKE DrawPixel, curr_x, curr_y, color

    mov test_counter, 0
  while_check:
  	;safety check, force it to terminate incase of ifinite loop...
  	;could do less than or equal to rather than !=...
  	mov eax, test_counter
    cmp test_counter, 1000
    jz while_loop_over

    mov eax, curr_x
    cmp eax, x1
    jne while_body    ; jum to loop if currx != x1

    mov eax, curr_y
    cmp eax, y1
    jne while_body    ; jump to loop if curry != x1


    jmp while_loop_over ; both were false, so jump out
    ;;while check complete, do stuff

  while_body:
    INVOKE DrawPixel, curr_x, curr_y, color ;draw currs

    add test_counter, 1
    mov eax, error
    mov prev_error, eax   ; prev_error = error

  if_statement_1:
    mov eax, -1
    imul delta_x          ; put -delta_x in eax
    cmp prev_error, eax   ; compare prev_error to -delta_x
    jle if_statement_2    ; if prev_error is not greater, jump out to the next if
    ;compute arithmatic
    mov eax, delta_y
    sub error, eax
    mov eax, inc_x
    add curr_x, eax

  if_statement_2:
    mov eax, error
    cmp eax, delta_y    ;check if prev_error < delta_y
    jge end_ifs      ;if false, just go back to
    mov eax, delta_x
    add error, eax
    mov eax, inc_y
    add curr_y, eax

  end_ifs:
    jmp while_check



  while_loop_over:

	ret        	;;  Don't delete this line...you need it
DrawLine ENDP


END
