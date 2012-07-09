; Include file for A51
; Routines for working with data and text
; Author:      (c) Pavel LANG 2003
; -------------------------------------------------------------------------
; DESCRIPTION: Program routines (8051) designed for working with text data
; -------------------------------------------------------------------------

WRITEHEX:
WRITE_HEX:            ; convert number in A to ASCII hexadecimal coded
                      ; number on address R0
   PUSH  ACC
   SWAP  A
   ANL   A,#0Fh
   ADD   A,#48        ; ASCII '0'
   CJNE  A,#58,WRITE_HEX_COMPARE1
  WRITE_HEX_COMPARE1:
   JC    WRITE_HEX_NOADD1
   ADD   A,#65-48-10 
  WRITE_HEX_NOADD1:
   MOV   @R0,A
   POP   ACC
   INC   R0

   PUSH  ACC
   ANL   A,#0Fh
   ADD   A,#48        ; ASCII '0'
   CJNE  A,#58,WRITE_HEX_COMPARE2
  WRITE_HEX_COMPARE2:
   JC    WRITE_HEX_NOADD2
   ADD   A,#65-48-10
  WRITE_HEX_NOADD2:
   MOV   @R0,A
   POP   ACC
   INC   R0
RET

WRITEBIN:
WRITE_BIN:            ; convert number in A to ASCII binary coded
                      ; number on address R0
   PUSH  ACC
   PUSH  1
   MOV   R1,#8        ; 8 bit
  WRITE_BIN_CYCLE:
   RLC   A
   PUSH  ACC
   CLR   A
   MOV   ACC.0,C
   ADD   A,#48        ; ASCII '0'
   MOV   @R0,A
   INC   R0
   POP   ACC
  DJNZ  R1,WRITE_BIN_CYCLE
   POP   1
   POP   ACC
RET

FILLBLOCK:            ; fill block of RAM:
                      ; start:  R0
                      ; length: R1
                      ; value:  ACC
   MOV  @R0,A
   INC  R0
   DJNZ R1,FILLBLOCK
RET

COPYCODERAM:          ; from @A+DPTR to @R0 length R1
   PUSH ACC
   MOVC A,@A+DPTR
   MOV  @R0,A
   POP  ACC
   INC  A
   INC  R0
   DEC  R1
   CJNE R1,#0,COPYCODERAM
RET

COPYCODERAM0:         ; from @A+DPTR to @R0 - string terminated with 0
   PUSH ACC
   MOVC A,@A+DPTR
   JZ   COPYCODERAM0_END
   MOV  @R0,A
   POP  ACC
   INC  A
   INC  R0
   JMP  COPYCODERAM0
COPYCODERAM0_END:
   POP  ACC
RET

BCD_TO_BIN:     ;parametr v ACC, vraci v ACC
   PUSH 0
   PUSH ACC
   SWAP A
   ANL  A,#0fh
   MOV  B,#10
   MUL  AB
   MOV  0,A
   POP  ACC
   ANL  A,#0fh
   ADD  A,0
   POP  0
RET


INPUT:                  ;input:  R0 pointer to string save area in LCDBUF
                        ;output: R1 pointer to end of string
   PUSH ACC
   MOV  1,0
   MOV  A,0
   ADD  A,#-LCDBUF
   MOV  LCD_POS,A
INPUT_LOOP:
   JNB  KEY_WAIT,$
   CLR  KEY_WAIT
   JNB  KEY_EXTENDED,INPUT_READONE
   CLR  KEY_EXTENDED
   JMP  INPUT_LOOP
 INPUT_READONE:
   MOV  A,KEY_ASCII_CODE
   CJNE A,#13,INPUT_NOENTER
    POP  ACC
    DEC  R1
    MOV  LCD_POS,R0
    RET
   INPUT_NOENTER:
   CJNE A,#127,INPUT_NOBACKSPC
    MOV  A,R0
    CJNE A,1,INPUT_BSOK
     JMP INPUT_LOOP
    INPUT_BSOK:
    DEC  R1
    MOV  @R1,#' '
    DEC  LCD_POS
    CALL  LCD_WRITEBUF
    JMP INPUT_LOOP
   INPUT_NOBACKSPC:
   MOV @R1,A
   INC R1
   INC LCD_POS
   CALL  LCD_WRITEBUF
JMP INPUT_LOOP


COMPARESTR:             ;compare two strings
                        ;parameters: @R0 - pointer to 1st string
                        ;            @R1 - pointer to 2nd string
                        ;            A   - string length
                        ;returns:    C=1 => 1st = 2nd
     PUSH  B
     PUSH  0
     PUSH  1
     PUSH  7
     MOV   7,A
 COMPARESTR_LOOP:
     MOV   A,@R0
     MOV   B,A
     MOV   A,@R1
     CJNE  A,B,COMPARESTR_NOEQ
     INC   R0
     INC   R1
     DJNZ  7,COMPARESTR_LOOP
     SETB  C
     JMP   COMPARESTR_END
 COMPARESTR_NOEQ:
     CLR   C
 COMPARESTR_END:
     POP   7
     POP   1
     POP   0
     POP   B
RET

COPY_RAM_RAM:   ;@R0 = souce
                ;@R1 = destination
                ;2   = bytes
     MOV   A,@R0
     MOV   @R1,A
     INC   R0
     INC   R1
     DJNZ  2,COPY_RAM_RAM
RET

;OTESTOVAT
ASCII_TO_BCD:			;@R0 points to ASCII 2 bytes ('12')
				;return: A - BCD coded num
				;;set C if successfull - not yet
     CALL  CONVERT_ONE_NUM
     SWAP  A
     PUSH  ACC
     CALL  CONVERT_ONE_NUM
     POP   B
     ADD   A,B
RET

;OTESTOVAT
CONVERT_ONE_NUM:
     MOV   A,@R0
     INC   R0
     ADD   A,#-'0'		;subbstract
     CJNE  A,#10,$+3
     JNC   ASCII_TO_BCD1
;    SETB  C			;redundant
     RET   
ASCII_TO_BCD1:
     CLR   C
     ADD   A,#-('A'-'0')
     RET
