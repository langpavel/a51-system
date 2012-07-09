; Include file for A51
; Routines for keyboard conected on INT0
; Author:      (c) Pavel LANG 2003
; -------------------------------------------------------------------------
; DESCRIPTION: Program routines (8051) designed for working with
;              PC keyboard
; -------------------------------------------------------------------------
; NEEDED DEFINED BY USER OF THE LIBRARY:
; KEY_DATA        BIT      pin connected to keyboard serial data
; KEY_WAIT        BIT      key code received and waiting for process
; KEY_TVAL        BIT      Transfer Valid
; KEY_SHIFT       BIT      Shift flag
; KEY_SCAN_CODE   DATA
; KEY_ASCII_CODE  DATA
; KEY_EXTENDED_CODE  DATA
; note: EXT0INT is local routine and it's necessary to call it everytime
;       when interrupt request come.
; -------------------------------------------------------------------------
; PROCEDURES:
;
; -------------------------------------------------------------------------
; IMPLEMENTATION:

; dodelat nulovani neplatneho slova casovacem

KEY_TRANSLATE_TABLE_UNSHIFTED:
;    x0   x1   x2   x3   x4   x5   x6   x7   x8   x9   xA   xB   xC   xD   xE   xF
DB 000h,0F9h,000h,0F5h,0F3h,0F1h,0F2h,0FCh,000h,0FAh,0F8h,0F6h,0F4h,009h,'`', 000h  ;0
DB 000h,000h,000h,000h,000h,'q', 'l', 000h,000h,000h,'z', 's', 'a', 'w', '2', 000h  ;1
DB 000h,'c' ,'x', 'd', 'e', '4', '3', 000h,000h,' ', 'v', 'f', 't', 'r', '5', 000h  ;2
DB 000h,'n' ,'b', 'h', 'g', 'y', '6', 000h,000h,000h,'m', 'j', 'u', '7', '8', 000h  ;3
DB 000h,',' ,'k', 'i', 'o', '0', '9', 000h,000h,'.', '/', 'l', ';', 'p', '-', 000h  ;4
DB 000h,',' ,000h,000h,'[', '=', 000h,000h,000h,000h,00Dh,']', 000h,05Ch,000h,000h  ;5
DB 000h,000h,000h,000h,000h,000h, 127,000h,000h,000h,000h,000h,000h,000h,000h,000h  ;6
DB 000h,07Fh,000h,000h,000h,01Bh,01bh,000h,0FBh,'+', 000h,'-', '*', 000h,000h,000h  ;7
DB 000h,000h,000h,0F7h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ;8
DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ;9
DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ;A
DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ;B
DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ;C
DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ;D
DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ;E
DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ;F

KEY_TRANSLATE_TABLE_SHIFTED:
;    x0   x1   x2   x3   x4   x5   x6   x7   x8   x9   xA   xB   xC   xD   xE   xF
DB 000h,0F9h,000h,0F5h,0F3h,0F1h,0F2h,0FCh,000h,0FAh,0F8h,0F6h,0F4h,009h,'~' ,000h  ;0
DB 000h,000h,000h,000h,000h,'Q' ,'!' ,000h,000h,000h,'Z' ,'S' ,'A' ,'W' ,'@' ,000h  ;1
DB 000h,'C' ,'X' ,'D' ,'E' ,'$' ,'#' ,000h,000h,' ' ,'V' ,'F' ,'T' ,'R' ,'%' ,000h  ;2
DB 000h,'N' ,'B' ,'H' ,'G' ,'Y' ,'^' ,000h,000h,000h,'M' ,'J' ,'U' ,'&' ,'*' ,000h  ;3
DB 000h,'<' ,'K' ,'I' ,'O' ,')' ,'(' ,000h,000h,'>' ,'?' ,'L' ,':' ,'P' ,'_' ,000h  ;4
DB 000h,'"' ,000h,000h,'{' ,'+' ,000h,000h,000h,000h,00Dh,'}' ,000h,'|' ,000h,000h  ;5
DB 000h,000h,000h,000h,000h,000h, 127,000h,000h,'1' ,000h,'4' ,'7' ,000h,000h,000h  ;6
DB '0' ,'.' ,'2' ,'5' ,'6' ,'8' ,01bh,000h,000h,'+' ,'3' ,'-' ,000h,'9' ,000h,000h  ;7
DB 000h,000h,000h,0F7h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ;8
DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ;9
DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ;A
DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ;B
DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ;C
DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ;D
DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ;E
DB 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h  ;F


KEY_GET_READY:   ;get ready to comunication - set edge interrupt,
                 ;enable interrupt INT0, etc.
   SETB KEY_CLK  ;INT0 input
   SETB IT0      ;falling edge
   CLR  KEY_WAIT ;no key wait
   CLR  KEY_EXTENDED 
   CLR  KEY_SHIFT
   SETB EX0      ;enable INT0
RET

KEY_TRANSLATE:   ;Generate ASCII
   JB   KEY_EXTENDED,KEY_SETEXTENDED
   MOV  A,KEY_READED
   CJNE A,#0F0h,KEY_CTRANS1              ;uvolneni klavesy
   SETB KEY_UP
   RET
KEY_CTRANS1:
   CJNE A,#0E0h,KEY_NOEXTENDED
   SETB KEY_EXTENDED
   RET
KEY_NOEXTENDED:
   CJNE A,#012h,KEY_SHIFTCMP1            ;lshift
   MOV  C,KEY_UP
   CPL  C
   MOV  KEY_SHIFT,C
   CLR  KEY_UP
   RET
KEY_SHIFTCMP1:
   CJNE A,#059h,KEY_SHIFTCMP2            ;rshift
   MOV  C,KEY_UP
   CPL  C
   MOV  KEY_SHIFT,C
   CLR  KEY_UP
   RET
KEY_SHIFTCMP2:
   JNB  KEY_UP,KEY_CTRANS3
   CLR  KEY_UP
   RET
KEY_CTRANS3:
   PUSH DPH
   PUSH DPL
   JB   KEY_SHIFT,KEY_CTRANS2
   MOV  DPTR,#KEY_TRANSLATE_TABLE_UNSHIFTED
   JMP  KEY_CTRANSTAB
KEY_CTRANS2:
   MOV  DPTR,#KEY_TRANSLATE_TABLE_SHIFTED
KEY_CTRANSTAB:
   MOVC A,@A+DPTR
   JZ   KEY_DONTSET
   MOV  KEY_ASCII_CODE,A
   SETB KEY_WAIT
KEY_DONTSET:
   CLR  KEY_UP
   POP  DPL
   POP  DPH
RET

KEY_SETEXTENDED:
   MOV  A,KEY_READED
   CJNE A,#0F0h,KEY_SCTRANS1              ;uvolneni klavesy
   SETB KEY_UP
   CLR  KEY_EXTENDED
   RET
 KEY_SCTRANS1:
   MOV  KEY_ASCII_CODE,#0
   MOV  KEY_EXTENDED_CODE,A
   SETB KEY_WAIT
RET


KEY_WAITVALID:                  ;wait to ~\_/~
   MOV  C,KEY_CLK               ;can be trouble ...
   JC   KEY_WAITVALID
KEY_WAITVALID2:                 ;wait to _/~
   MOV  C,KEY_CLK
   JNC  KEY_WAITVALID2
   MOV  C,KEY_DATA
RET


EXT0INT:
   PUSH PSW
   PUSH ACC
   CLR  A
   CALL KEY_WAITVALID2          ;0.

   PUSH 0
   MOV  0,#8
    EXT_SM1:
     CALL KEY_WAITVALID         ;1. - 7.
     RRC  A
    DJNZ 0,EXT_SM1
   POP  0

   MOV  KEY_READED,A
   CALL KEY_WAITVALID           ;9.
   CALL KEY_WAITVALID           ;10.
   CALL KEY_TRANSLATE
 EXT0INT_END:
   CLR  IE0
   POP  ACC
   POP  PSW
RETI

; Keyboard routines
; END of include file


