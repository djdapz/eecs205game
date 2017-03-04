; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;
;   DJD809 - Devon D'Apuzzo
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA

	;; If you need to, you can place global variables here

.CODE

DrawStarField proc

    

    INVOKE DrawStar, 611, 101
INVOKE DrawStar, 506, 238
INVOKE DrawStar, 321, 171
INVOKE DrawStar, 484, 3
INVOKE DrawStar, 56, 44
INVOKE DrawStar, 594, 367
INVOKE DrawStar, 340, 444
INVOKE DrawStar, 540, 176
INVOKE DrawStar, 284, 431
INVOKE DrawStar, 143, 294
INVOKE DrawStar, 65, 291
INVOKE DrawStar, 362, 264
INVOKE DrawStar, 314, 57
INVOKE DrawStar, 203, 111
INVOKE DrawStar, 417, 387
INVOKE DrawStar, 261, 3
INVOKE DrawStar, 505, 388
INVOKE DrawStar, 637, 297
INVOKE DrawStar, 294, 78
INVOKE DrawStar, 126, 17
INVOKE DrawStar, 171, 455
INVOKE DrawStar, 487, 255
INVOKE DrawStar, 20, 296
INVOKE DrawStar, 476, 265
INVOKE DrawStar, 554, 456
INVOKE DrawStar, 390, 145
INVOKE DrawStar, 26, 386
INVOKE DrawStar, 157, 353
INVOKE DrawStar, 293, 477
INVOKE DrawStar, 245, 83
INVOKE DrawStar, 26, 334
INVOKE DrawStar, 344, 382
INVOKE DrawStar, 582, 269
INVOKE DrawStar, 59, 18
INVOKE DrawStar, 36, 268
INVOKE DrawStar, 213, 295

    jmp away

  ;SMILEY FACE CONSTELLATION :-)
    ;LEFT EYE
    INVOKE DrawStar, 220, 100
    INVOKE DrawStar, 220, 120
    INVOKE DrawStar, 220, 140
    INVOKE DrawStar, 220, 160

    ;RIGHT EYE
    INVOKE DrawStar, 380, 100
    INVOKE DrawStar, 380, 120
    INVOKE DrawStar, 380, 140
    INVOKE DrawStar, 380, 160

    ;NOSE
    INVOKE DrawStar, 300, 220
    INVOKE DrawStar, 300, 230

    ;SMILE!
    INVOKE DrawStar, 220, 300
    INVOKE DrawStar, 230, 320
    INVOKE DrawStar, 240, 340
    INVOKE DrawStar, 250, 348
    INVOKE DrawStar, 260, 354
    INVOKE DrawStar, 270, 358
    INVOKE DrawStar, 280, 360
    INVOKE DrawStar, 290, 361
    INVOKE DrawStar, 300, 361
    INVOKE DrawStar, 310, 361
    INVOKE DrawStar, 320, 360
    INVOKE DrawStar, 330, 358
    INVOKE DrawStar, 340, 354
    INVOKE DrawStar, 350, 348
    INVOKE DrawStar, 360, 340
    INVOKE DrawStar, 370, 320
    INVOKE DrawStar, 380, 300



    away:



	;; Place your code here

	ret  			; Careful! Don't remove this line
DrawStarField endp



END
