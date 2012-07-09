; Include file for A51
; Routines for printing on paralel printer port (line printer routines)
; Author:      (c) Pavel LANG 2003
; -------------------------------------------------------------------------
; DESCRIPTION: Program routines (8051) designed for working with
;              printing on paralel printer port
; -------------------------------------------------------------------------
PRN_CHARS_PER_LINE   EQU   80

PRN_PORT       EQU   P0
PRN_STROBE     BIT   P1.6
PRN_AUTOFEED   BIT   P1.5
PRN_INIT       BIT   P1.4
PRN_SELECT     BIT   P1.3
PRN_SELECTIN   BIT   P1.7
PRN_ACK        BIT   P3.3
PRN_BUSY       BIT   P3.4
PRN_ERROR      BIT   P3.5
PRN_PAPEREND   BIT   P2.7


PRN_TEST_TEXT:
     DB    27,'(s1P'		;Proportional spacing
     DB    27,'(s14V'           ;14 points
     DB    13,10
     DB    27,'&d3D'            ;floating underline
     DB    '* * * Mikroprocesorovy system - maturitni prace - 2003 * * *',13,10
     DB    13,10
     DB    27,'(s10V'           ;10 points
     DB    'Adresa skoly:',13,10
     DB    27,'&d@'             ;floating underline end
     DB    ' Stredni prumyslova skola elektrotechnicka a Vyssi odborna skola',13,10
     DB    ' Pardubice, Karla IV. 13',13,10
     DB    13,10
     DB    27,'&d3D'            ;floating underline
     DB    'Autor:',13,10
     DB    27,'&d@'             ;floating underline end
     DB    ' Pavel Lang',13,10
     DB    ' Mirova 1436',13,10
     DB    ' 516 01 Rychnov nad Kneznou',13,10
     DB    ' Czech Republic',13,10
     DB    13,10
     DB    ' email: langpa@seznam.cz',13,10
     DB    ' tel.:  494 533 890',13,10
     DB    13,10
     DB    'Software i hardware muze byt siren v ramci licence GPL',13,10
     DB    'Tento produkt k Vam prichazi bez jakekoli zaruky !!!',13,10
     DB    'Preji Vam prijemnou praci !',13,10
PRN_PAGE_END:
     DB    27,'&l0H'
     DB    0
PRN_ECONO_FAST:
     DB    27,'*o-1M',0
PRN_LINEWRAP:
     DB    27,'&s0C',0


PRN_TEST:
     CALL  PRN_INITPRINT
     MOV   DPTR,#PRN_TEST_TEXT

PRN_SENDCODE:  ;parameters: DPTR - code address of data - terminated by 0
     PUSH  7
PRN_SENDCODE_LOOP2:
     MOV   7,#PRN_CHARS_PER_LINE
PRN_SENDCODE_LOOP:
     CLR   A
     MOVC  A,@A+DPTR
      CJNE  A,#13,PRN_SENDCODE_CONT1
       MOV  7,#PRN_CHARS_PER_LINE+1     ;one byte is CR
      PRN_SENDCODE_CONT1:
      CJNE  A,#10,PRN_SENDCODE_CONT2
       INC  7                           ;LF do not change horizontal position
      PRN_SENDCODE_CONT2:
     JZ    PRN_SENDCODE_END
     CALL  PRN_SENDBYTE
     INC   DPTR
     DJNZ  7,PRN_SENDCODE_LOOP
     CALL  PRN_NEWLINE
     JMP   PRN_SENDCODE_LOOP2
PRN_SENDCODE_END:
     POP   7
RET

PRN_NEWLINE:
     MOV   A,#13
     CALL  PRN_SENDBYTE
     MOV   A,#10
     CALL  PRN_SENDBYTE
RET

PRN_SENDBYTE:  ;parameter in A
     CALL  PRN_WAITNBUSY
     MOV   PRN_PORT,A
     CALL  PRN_SENDSTROBE
RET

PRN_WAITNBUSY:
     SETB  PRN_BUSY
     MOV   C,PRN_BUSY
     JC    PRN_WAITNBUSY
RET

PRN_SENDSTROBE:
     CLR   PRN_STROBE
     NOP
     NOP
     SETB  PRN_STROBE
RET

PRN_INITPRINT:
     CLR   PRN_SELECT
     CLR   PRN_INIT
     PUSH  7
     MOV   7,#0
     DJNZ  7,$
     POP   7
     SETB  PRN_INIT
     PUSH  DPH
     PUSH  DPL
     MOV   DPTR,#PRN_LINEWRAP
     CALL  PRN_SENDCODE
     POP   DPL
     POP   DPH
RET

PRN_PRINT_FLASH_DEBUG:
     PUSH  7
     PUSH  6
     PUSH  5
     CALL  PRN_INITPRINT
     MOV   DPTR,#PRN_ECONO_FAST
     CALL  PRN_SENDCODE

     MOV   DPTR,#0
     CALL  MEM_SETADDRESS
     MOV   6,#000h
     PRN_PFD6:
      MOV   A,DPH
      CALL  PRN_WRITEHEX
      MOV   A,DPL
      CALL  PRN_WRITEHEX
      MOV   A,#':'
      CALL  PRN_SENDBYTE
      MOV   A,#9
      CALL  PRN_SENDBYTE

       MOV   5,#010h
       MOV   7,#0
      PRN_PFD5:
       CALL  MEM_BYTEREAD
       CALL  PRN_WRITEHEX
       MOV   A,#020h
       CALL  PRN_SENDBYTE
       INC   7
       MOV   A,7
        CJNE  A,#4,PRN_PFD7
         MOV   A,#' '
         CALL  PRN_SENDBYTE
         MOV   7,#0
        PRN_PFD7:
      DJNZ   5,PRN_PFD5

       MOV   A,#' '
       CALL  PRN_SENDBYTE
       MOV   A,#'|'
       CALL  PRN_SENDBYTE
       MOV   A,#27
       CALL  PRN_SENDBYTE
       MOV   A,#'&'
       CALL  PRN_SENDBYTE
       MOV   A,#'p'
       CALL  PRN_SENDBYTE
       MOV   A,#'1'
       CALL  PRN_SENDBYTE
       MOV   A,#'6'
       CALL  PRN_SENDBYTE
       MOV   A,#'X'
       CALL  PRN_SENDBYTE

       CALL  MEM_SETADDRESS

       MOV   5,#010h
      PRN_PFD5b:
       CALL  MEM_BYTEREAD
       INC   DPTR
       CALL  PRN_SENDBYTE
      DJNZ   5,PRN_PFD5b

      MOV   A,#'|'
      CALL  PRN_SENDBYTE
      MOV   A,#13
      CALL  PRN_SENDBYTE
      MOV   A,#10
      CALL  PRN_SENDBYTE

     DJNZ   6,PRN_PFD6
     MOV   DPTR,#PRN_PAGE_END
     CALL  PRN_SENDCODE
     POP   5
     POP   6
     POP   7
RET

PRN_WRITEHEX:
     PUSH  0
     MOV   R0,#1
     CALL  WRITEHEX
     MOV   A,1
     CALL  PRN_SENDBYTE
     MOV   A,2
     CALL  PRN_SENDBYTE
     POP   0
RET
