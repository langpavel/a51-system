; Include file for A51
; Routines for working with data and text
; Author:      (c) Pavel LANG 2003
; -------------------------------------------------------------------------
; DESCRIPTION: Program routines (8051) designed for working with menu
; -------------------------------------------------------------------------
; list of types:
; type ITEM (FIRSTITEM)
;      DPTR - pointer to data in CODE
;      CPTR - pointer to procedure in CODE (ends with RET)
; --------------------------------------------------------------------------
; MENUTEXT: DB 'SETTINGS - MAIN MENU',0
; menu item table:                            data length (dec) offset type
; ITEM:                                                          0
; DW ITEM                   ;next item     (right)           2   0 DPTR->ITEM
; DW ITEM                   ;prewious item (left)            2   2 DPTR->ITEM
; DW 0                      ;enter menu (DW 0 == run proc)   2   4 DPTR->ITEM
; DW PROC                   ;procedure pointer               2   6 CPTR
; DW MENUTEXT               ;pointer to text (upper line)    2   8 DPTR->TEXT
; DB 'MENU TEXT MENU TEXT',0 ;text (lower line)               20 10 TEXT
; --------------------------------------------------------------------------

;- 1. uroven ---------------------------------------------------------------

TEXTLENGTH EQU 20
MAIN_TEXT:
 DB 'HLAVNI NABIDKA',0

BUDIKY:                    ;                                 OFFSET:
 DW SOUBORY                ;next item     (right)           2   0 DPTR->ITEM
 DW BUDIKY                 ;prewious item (left)            2   2 DPTR->ITEM
 DW 0                      ;enter menu (DW 0 == run proc)   2   4 DPTR->ITEM
 DW NASTAV_BUDIK           ;procedure pointer               2   6 CPTR
 DW MAIN_TEXT              ;pointer to text (upper line)    2   8 DPTR->TEXT
 DB 'BUDIK',0              ;text (lower line)               20 10 TEXT

SOUBORY:                   ;                                 OFFSET:
 DW NASTAVENI              ;next item     (right)           2   0 DPTR->ITEM
 DW BUDIKY                 ;prewious item (left)            2   2 DPTR->ITEM
 DW DIR                    ;enter menu (DW 0 == run proc)   2   4 DPTR->ITEM
 DW 0                      ;procedure pointer               2   6 CPTR
 DW MAIN_TEXT              ;pointer to text (upper line)    2   8 DPTR->TEXT
 DB 'SOUBORY',0            ;text (lower line)               20 10 TEXT

NASTAVENI:                 ;                                 OFFSET:
 DW LADENI                 ;next item     (right)           2   0 DPTR->ITEM
 DW SOUBORY                ;prewious item (left)            2   2 DPTR->ITEM
 DW CAS                    ;enter menu (DW 0 == run proc)   2   4 DPTR->ITEM
 DW 0                      ;procedure pointer               2   6 CPTR
 DW MAIN_TEXT              ;pointer to text (upper line)    2   8 DPTR->TEXT
 DB 'NASTAVENI',0          ;text (lower line)               20 10 TEXT

LADENI:                    ;                                 OFFSET:
 DW LADENI                 ;next item     (right)           2   0 DPTR->ITEM
 DW NASTAVENI              ;prewious item (left)            2   2 DPTR->ITEM
 DW FORCEREAD              ;enter menu (DW 0 == run proc)   2   4 DPTR->ITEM
 DW 0                      ;procedure pointer               2   6 CPTR
 DW MAIN_TEXT              ;pointer to text (upper line)    2   8 DPTR->TEXT
 DB 'LADICI PROSTREDKY',0  ;text (lower line)               20 10 TEXT
;- 2. uroven - NASTAVENI ---------------------------------------------------
CAS:                       ;                                 OFFSET:
 DW DATUM                  ;next item     (right)           2   0 DPTR->ITEM
 DW CAS                    ;prewious item (left)            2   2 DPTR->ITEM
 DW 0                      ;enter menu (DW 0 == run proc)   2   4 DPTR->ITEM
 DW PISKNI                 ;procedure pointer               2   6 CPTR
 DW NASTAVENI+10           ;pointer to text (upper line)    2   8 DPTR->TEXT
 DB 'NASTAVIT CAS',0       ;text (lower line)               20 10 TEXT

DATUM:                     ;                                 OFFSET:
 DW DATUM                  ;next item     (right)           2   0 DPTR->ITEM
 DW CAS                    ;prewious item (left)            2   2 DPTR->ITEM
 DW 0                      ;enter menu (DW 0 == run proc)   2   4 DPTR->ITEM
 DW PISKNI                 ;procedure pointer               2   6 CPTR
 DW NASTAVENI+10           ;pointer to text (upper line)    2   8 DPTR->TEXT
 DB 'NASTAVIT DATUM',0     ;text (lower line)               20 10 TEXT

;- 2. uroven - SOUBORY -----------------------------------------------------
DIR:                       ;                                 OFFSET:
 DW EDIT                   ;next item     (right)           2   0 DPTR->ITEM
 DW DIR                    ;prewious item (left)            2   2 DPTR->ITEM
 DW 0                      ;enter menu (DW 0 == run proc)   2   4 DPTR->ITEM
 DW FS_LIST_ROOT           ;procedure pointer               2   6 CPTR
 DW SOUBORY+10             ;pointer to text (upper line)    2   8 DPTR->TEXT
 DB 'VYPIS SOUBORY',0      ;text (lower line)               20 10 TEXT

EDIT:                      ;                                 OFFSET:
 DW PRINT                  ;next item     (right)           2   0 DPTR->ITEM
 DW DIR                    ;prewious item (left)            2   2 DPTR->ITEM
 DW 0                      ;enter menu (DW 0 == run proc)   2   4 DPTR->ITEM
 DW FS_EDIT                ;procedure pointer               2   6 CPTR
 DW SOUBORY+10             ;pointer to text (upper line)    2   8 DPTR->TEXT
 DB 'EDITUJ SOUBOR',0      ;text (lower line)               20 10 TEXT

PRINT:                     ;                                 OFFSET:
 DW NEW                    ;next item     (right)           2   0 DPTR->ITEM
 DW EDIT                   ;prewious item (left)            2   2 DPTR->ITEM
 DW 0                      ;enter menu (DW 0 == run proc)   2   4 DPTR->ITEM
 DW PISKNI                 ;procedure pointer               2   6 CPTR
 DW SOUBORY+10             ;pointer to text (upper line)    2   8 DPTR->TEXT
 DB 'VYTISKNI SOUBOR',0    ;text (lower line)               20 10 TEXT

NEW:                       ;                                 OFFSET:
 DW DEL                    ;next item     (right)           2   0 DPTR->ITEM
 DW PRINT                  ;prewious item (left)            2   2 DPTR->ITEM
 DW 0                      ;enter menu (DW 0 == run proc)   2   4 DPTR->ITEM
 DW MENU_NEWFILE           ;procedure pointer               2   6 CPTR
 DW SOUBORY+10             ;pointer to text (upper line)    2   8 DPTR->TEXT
 DB 'VYTVORIT NOVY SOUBOR',0 ;text (lower line)               20 10 TEXT

DEL:                       ;                                 OFFSET:
 DW DEL                    ;next item     (right)           2   0 DPTR->ITEM
 DW NEW                    ;prewious item (left)            2   2 DPTR->ITEM
 DW 0                      ;enter menu (DW 0 == run proc)   2   4 DPTR->ITEM
 DW MENU_DELFILE           ;procedure pointer               2   6 CPTR
 DW SOUBORY+10             ;pointer to text (upper line)    2   8 DPTR->TEXT
 DB 'ODSTRANIT SOUBOR',0   ;text (lower line)               20 10 TEXT

;- 2. uroven - LADENI ------------------------------------------------------
FORCEREAD:
 DW FORMAT                 ;next item     (right)           2   0 DPTR->ITEM
 DW FORCEREAD              ;prewious item (left)            2   2 DPTR->ITEM
 DW 0                      ;enter menu (DW 0 == run proc)   2   4 DPTR->ITEM
 DW FS_FORCESHOW           ;procedure pointer               2   6 CPTR
 DW LADENI+10              ;pointer to text (upper line)    2   8 DPTR->TEXT
 DB 'ZOBRAZIT PAMET V HEX',0 ;text (lower line)               20 10 TEXT

FORMAT:                    ;                                 OFFSET:
 DW SHOWRAM                ;next item     (right)           2   0 DPTR->ITEM
 DW FORCEREAD              ;prewious item (left)            2   2 DPTR->ITEM
 DW 0                      ;enter menu (DW 0 == run proc)   2   4 DPTR->ITEM
 DW MENU_FORMAT            ;procedure pointer               2   6 CPTR
 DW LADENI+10              ;pointer to text (upper line)    2   8 DPTR->TEXT
 DB 'SMAZAT VSECHNA DATA!',0 ;text (lower line)               20 10 TEXT

SHOWRAM:                   ;                                 OFFSET:
 DW PRINTTEST              ;next item     (right)           2   0 DPTR->ITEM
 DW FORMAT                 ;prewious item (left)            2   2 DPTR->ITEM
 DW 0                      ;enter menu (DW 0 == run proc)   2   4 DPTR->ITEM
 DW MENU_SHOWRAM           ;procedure pointer               2   6 CPTR
 DW LADENI+10              ;pointer to text (upper line)    2   8 DPTR->TEXT
 DB 'ZOBRAZIT ZASOBNIK',0  ;text (lower line)               20 10 TEXT

PRINTTEST:                 ;                                 OFFSET:
 DW PRINTFLASH             ;next item     (right)           2   0 DPTR->ITEM
 DW SHOWRAM                ;prewious item (left)            2   2 DPTR->ITEM
 DW 0                      ;enter menu (DW 0 == run proc)   2   4 DPTR->ITEM
 DW PRN_TEST               ;procedure pointer               2   6 CPTR
 DW LADENI+10              ;pointer to text (upper line)    2   8 DPTR->TEXT
 DB 'VYTISKNOUT TEST',0    ;text (lower line)               20 10 TEXT

PRINTFLASH:                ;                                 OFFSET:
 DW PRINTFLASH             ;next item     (right)           2   0 DPTR->ITEM
 DW PRINTTEST              ;prewious item (left)            2   2 DPTR->ITEM
 DW 0                      ;enter menu (DW 0 == run proc)   2   4 DPTR->ITEM
 DW PRN_PRINT_FLASH_DEBUG  ;procedure pointer               2   6 CPTR
 DW LADENI+10              ;pointer to text (upper line)    2   8 DPTR->TEXT
 DB 'VYTISKNOUT FLASH',0   ;text (lower line)               20 10 TEXT

;- CODE --------------------------------------------------------------------
MENU_BUDIK_SETTINGS:
DB 'ZADEJTE CAS: HH.MM',0
NASTAV_BUDIK:
     MOV   R0,#LCD_L2
     MOV   DPTR,#MENU_BUDIK_SETTINGS
     CALL  COPYCODERAM0
     CALL LCD_WRITEBUF
     MOV   R0,#LCD_L3
     CALL  INPUT
     MOV   R0,#LCD_L3
     CALL  ASCII_TO_BCD
     PUSH  ACC
     MOV   DPTR,#0100h		;;;;;;;;;;
     CALL  MEM_SETADDRESS
     POP   B
     CALL  FS_BYTEWRITE
     INC   R0			;dot
     CALL  ASCII_TO_BCD
     MOV   B,A
     CALL  FS_BYTEWRITE
RET

MENU_FORMAT:
CALL MENU_WRITE_WORKING
JMP  FS_FORMAT

MENU_TEXT_WORKING:
 DB 'PRACUJI ...',0

MENU_WRITE_WORKING:
 PUSH 1
 PUSH DPH
 PUSH DPL
 MOV  R1,#020           ;length
 MOV  R0,#LCD_L3
 CLR  A
 MOV  DPTR,#MENU_TEXT_WORKING
 CALL COPYCODERAM0
 CALL LCD_WRITEBUF
 POP  DPL
 POP  DPH
 POP  1
RET

MENU_SHOWRAM:
     PUSH 7
     PUSH 1

     MOV  R1,#STACK
     MOV  R0,#LCDBUF
     MOV  7,#40
M_SHOWRAM_LOOP1:
     MOV  A,@R1
     INC  R1
     CALL WRITEHEX
     DJNZ 7,M_SHOWRAM_LOOP1
     CALL LCD_WRITEBUF
     JNB  KEY_WAIT,$
     CLR  KEY_WAIT
     CALL LCD_CLEAR

     MOV  R1,#40
     MOV  R0,#LCDBUF
     MOV  7,#8
M_SHOWRAM_LOOP2:
     MOV  A,@R1
     INC  R1
     CALL WRITEHEX
     DJNZ 7,M_SHOWRAM_LOOP2

     MOV  LCD_L1+0,#'S'
     MOV  LCD_L1+1,#'P'
     MOV  LCD_L1+2,#':'
     MOV  R0,#LCD_L1+3
     MOV  A,SP
     CALL WRITEHEX

     CALL LCD_WRITEBUF
     JNB      KEY_WAIT,$
     CLR      KEY_WAIT

     POP  1
     POP  7
RET

MENU_FILE_TEXT:
     DB 'JMENO:',0
MENU_NEWFILE:
     MOV  R0,#LCD_L2
     CLR  A
     MOV  DPTR,#MENU_FILE_TEXT
     CALL COPYCODERAM0
     CALL LCD_WRITEBUF
     CALL INPUT
     MOV   A,@R0
      CJNE  A,#020h,NEW_F_FILENAME_OK
       JMP MENU_NEWFILE_FAIL  ;filename cannot start with space
      NEW_F_FILENAME_OK:
     MOV  A,#FS_ROOTINDEX
     MOV  B,#0FFh
     CALL FS_NEW
     JC   MENU_NEWFILE_FAIL
RET
MENU_NEWFILE_FAIL_TEXT:
     DB 'NEW: NEPLATNE JMENO!',0
MENU_NEWFILE_FAIL:
     MOV  R0,#LCD_L3
     CLR  A
     MOV  DPTR,#MENU_NEWFILE_FAIL_TEXT
     CALL COPYCODERAM0
     CALL LCD_WRITEBUF
     JNB  KEY_WAIT,$
     CLR  KEY_WAIT
RET


MENU_DELFILE:
     MOV  R0,#LCD_L2
     CLR  A
     MOV  DPTR,#MENU_FILE_TEXT
     CALL COPYCODERAM0
     CALL LCD_WRITEBUF
     CALL INPUT
      CJNE  A,#020h,DEL_F_FILENAME_OK
       JMP MENU_DELFILE_FAIL  ;filename cannot start with space
      DEL_F_FILENAME_OK:
     MOV  A,#FS_ROOTINDEX
     MOV  B,#0FFh
     CALL FS_DEL
     JNC  MENU_DELFILE_FAIL
RET
MENU_DELFILE_FAIL_TEXT:
     DB 'DEL: NEPLATNE JMENO!',0
MENU_DELFILE_FAIL:
     MOV  R0,#LCD_L3
     CLR  A
     MOV  DPTR,#MENU_DELFILE_FAIL_TEXT
     CALL COPYCODERAM0
     CALL LCD_WRITEBUF
     JNB  KEY_WAIT,$
     CLR  KEY_WAIT
RET


MENU_ENTER:                ;parameters: DPTR points to ITEM
 MENU_WRITE:
     ;clear display:
     CALL LCD_CLEARRAM
     ;write down line:
     MOV  A,#10            ;offset of TEXT                           *****
     MOV  R0,#LCD_L1       ;to LCD line 1
     CALL COPYCODERAM0     ;from @A+DPTR to @R0

     ;write upper line:
     PUSH DPH
     PUSH DPL
       ;set DPTR:
     MOV  A,#8             ;high byte offset
     MOVC A,@A+DPTR
     MOV  R0,A
     MOV  A,#9             ;low byte
     MOVC A,@A+DPTR
     MOV  DPL,A
     MOV  DPH,R0

     MOV  A,#0             ;offset of TEXT
     MOV  R0,#LCD_L0       ;to LCD line 0
     CALL COPYCODERAM0     ;from @A+DPTR to @R0
     CALL LCD_WRITEBUF
     POP  DPL
     POP  DPH

 MENU_LOOP:
     CALL READKEY_LEFT      ;if pressed, C <- 1
     JNC  MENU_L1
       ;set DPTR:
      MOV  A,#2             ;high byte offset
      MOVC A,@A+DPTR
      MOV  R0,A
      MOV  A,#3             ;low byte
      MOVC A,@A+DPTR
      MOV  DPL,A
      MOV  DPH,R0
      JMP  MENU_WRITE
 MENU_L1:

     CALL READKEY_RIGHT     ;if pressed, C <- 1
     JNC  MENU_L2
       ;set DPTR:
      MOV  A,#0             ;high byte offset
      MOVC A,@A+DPTR
      MOV  R0,A
      MOV  A,#1             ;low byte
      MOVC A,@A+DPTR
      MOV  DPL,A
      MOV  DPH,R0
      JMP  MENU_WRITE
 MENU_L2:

     CALL READKEY_ENTER     ;if pressed, C <- 1
     JNC  MENU_L3
       ;set DPTR:
      MOV  A,#4             ;high byte offset
      MOVC A,@A+DPTR
      MOV  R0,A
      MOV  A,#5             ;low byte
      MOVC A,@A+DPTR
      MOV  R1,A
      JNZ  MENU_GO
      MOV  A,R0
      JZ   MENU_RUNPROC
 MENU_GO:
      PUSH DPH
      PUSH DPL
      MOV  DPL,R1
      MOV  DPH,R0
      CALL MENU_ENTER           ;recursive !
      POP  DPL
      POP  DPH
      JMP  MENU_WRITE
 MENU_RUNPROC:
       ;set DPTR:
      MOV  A,#6             ;high byte offset
      MOVC A,@A+DPTR
      MOV  R0,A
      MOV  A,#7             ;low byte
      MOVC A,@A+DPTR
      PUSH DPH
      PUSH DPL
      MOV  DPL,A
      MOV  DPH,R0
      MOV  A,#LOW BACK_POINT
      PUSH ACC
      MOV  A,#HIGH BACK_POINT
      PUSH ACC
      MOV  A,#0
      JMP  @A+DPTR
 BACK_POINT:
      POP  DPL
      POP  DPH
      JMP  MENU_WRITE
 MENU_L3:
     CALL READKEY_ESC       ;if pressed, C <- 1
     JNC  MENU_LOOP
 MENU_EXIT:
RET

READKEY_LEFT:
     JNB  KEY_WAIT,RKL
     JNB  KEY_EXTENDED,RKL
     MOV  A,KEY_EXTENDED_CODE
     CJNE A,#06Bh,RKL
     CLR  KEY_WAIT
     CLR  KEY_EXTENDED
     SETB C
     RET
RKL:
     CLR  C
RET

READKEY_RIGHT:
     JNB  KEY_WAIT,RKR
     JNB  KEY_EXTENDED,RKR
     MOV  A,KEY_EXTENDED_CODE
     CJNE A,#074h,RKR
     CLR  KEY_WAIT
     CLR  KEY_EXTENDED
     SETB C
     RET
RKR:
     CLR  C
RET

READKEY_ENTER:
     JNB  KEY_WAIT,RKE
     MOV  A,KEY_ASCII_CODE
     CJNE A,#13,RKE       ;ENTER
     CLR  KEY_WAIT
     SETB C
     RET
RKE:
     CLR  C
RET

READKEY_ESC:
     JNB  KEY_WAIT,RKC
     MOV  A,KEY_ASCII_CODE
     CJNE A,#01Bh,RKC
     CLR  KEY_WAIT
     SETB C
     RET
RKC:
     CLR  C
RET

; -- MENU END ------------------
