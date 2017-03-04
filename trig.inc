; #########################################################################
;
;   trig.inc - Includes for EECS205 Assignment 3
;
;
; #########################################################################

FXPT TYPEDEF SDWORD

EXTERNDEF SINTAB:WORD

FixedSin PROTO STDCALL angle:FXPT
FixedCos PROTO STDCALL angle:FXPT
FixedMultiply PROTO STDCALL a_val:SDWORD, b_val:SDWORD
FixedMultiply PROTO STDCALL a_val:SDWORD, b_val:SDWORD
