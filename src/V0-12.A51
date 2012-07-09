; Pilotni program pro maturitni vyrobek
; V 0.12
$NOPAGING
$MOD52
$NODEBUG
$OBJECT(!hex.hex)
$PRINT(!list.lst)
$LIST

;KONSTANTY
KRYSTAL EQU  24000 ;kHz

; prirazeni pinu na mP
DBUS0   BIT  P0.0
DBUS1   BIT  P0.1
DBUS2   BIT  P0.2
DBUS3   BIT  P0.3
DBUS4   BIT  P0.4
DBUS5   BIT  P0.5
DBUS6   BIT  P0.6
DBUS7   BIT  P0.7

LCD_RS  BIT  P2.0	; LCD Register Select
LCD_EN  BIT  P2.1	; LCD Enable
LCD_DATA DATA P0        ; LCD Data bus

MEM_SDA BIT  P3.7	; EEPROM Serial Data
MEM_SCL BIT  P3.6	; EEPROM Serial Clock

KEY_CLK BIT  P3.2	; PC keyboard Clock - /INT0
KEY_DATA BIT P3.1	; PC keyboard Data

PIEZO   BIT  P3.0	; tranzistor sepnut v logicke 1

DS_RST  BIT  P1.2
DS_IO   BIT  P1.1
DS_SCLK BIT  P1.0

;dopsat DS1302, Paralel port

;----------------------------------------------------------------------------
DSEG AT 030H             ;free RAM data 30h-7fh
LCDBUF:
LCD_L0: DS 20
LCD_L1: DS 20
LCD_L2: DS 20
LCD_L3: DS 20
LCDBUFEND:
; zde je hranice 080h

DSEG AT 008H
KEY_READED:     DS 1
KEY_ASCII_CODE: DS 1
KEY_EXTENDED_CODE: DS 1
LCD_POS:        DS 1     ;poloha kurzoru - zacina od 0

ISEG AT 080h

;----------------------------------------------------------------------------
BSEG AT 000h
KEY_WAIT:  DBIT 1         ;key code received
KEY_TVAL:  DBIT 1         ;Transfer Valid
KEY_SHIFT: DBIT 1
KEY_UP:    DBIT 1         ;uvolneni klavesy
KEY_EXTENDED: DBIT 1
LCD_CURON: DBIT 1         ;cursor on
LCD_CURBL: DBIT 1         ;cursor blink
;PISKA:    DBIT 1



;----------------------------------------------------------------------------
CSEG AT 00000H           ;instrukcni pocatek
JMP     START

ORG	00003H		 ;preruseni od klavesnice
JMP	EXT0INT

ORG     0000BH           ;preruseni od casovace 0
LJMP    TIMER0INT

ORG	00013H		 ;preruseni od LPT portu sig. ACK
JMP	EXT1INT

ORG     0001BH           ;preruseni od casovace 1
LJMP    TIMER1INT

ORG     00030H           ;pocatek kodu
;------------------------ KONSTANTY --------------------------------------
UVODNITEXT:
DB 'Mikroprocesor.system'
DB 'Verze softwaru: 0.12'
DB 07Eh,07Eh,07Eh,020h,0E0h,' protoverze ',07Fh,07Fh,07Fh
DB '(C)  Pavel Lang 2003'

;------------------------ PODPROGRAMY ------------------------------------
;PRERUSENI
;EXT0INT:       defined in KEYBOARD.A51
;RETI

TIMER0INT:
RETI

EXT1INT:
RETI

TIMER1INT:
RETI
;------------------------ PODPROGRAMY ---------------------------------------
$INCLUDE(MENU.A51)
$INCLUDE(LCD.A51)
$INCLUDE(KEYBOARD.A51)
$INCLUDE(TEXTWORK.A51)
$INCLUDE(DS1302.A51)
$INCLUDE(AT24LC64.A51)
$INCLUDE(FILESYS.A51)
$INCLUDE(RAM.A51)
$INCLUDE(PRINT.A51)
;------------------------ HLAVNI KOD ----------------------------------------

PISKNI:
      PUSH  0
      PUSH  1
      MOV   R0,#100
PISK_SM:
      MOV   R1,#50
      DJNZ  R1,$
      CPL   PIEZO
      DJNZ  R0,PISK_SM
      CLR   PIEZO
      POP   1
      POP   0
RET

START:
      MOV   SP,#STACK-1         ;inicializace stack pointeru
                                ;u 8052 nebo 8055 dat na 080h
      SETB  EA                  ;povol preruseni
      CLR   MEM_SCL
      CALL  PISKNI
;---------------------------------------------
      CALL  LCD_INIT
      MOV   A,#004h
      CALL  LCD_DISPLAY_ON

      MOV   R0,#LCDBUF
      MOV   DPTR,#UVODNITEXT
      CLR   A
      MOV   R1,#LCDBUFEND-LCDBUF
      CALL  COPYCODERAM
      CALL  LCD_WRITEBUF

      CALL  KEY_GET_READY
      JNB   KEY_WAIT,$
      CLR   KEY_WAIT

      CALL  LCD_CLEAR

      SETB  LCD_CURON
      MOV   A,#004h
      CALL  LCD_DISPLAY_ON

GOMENU:
      MOV   DPTR,#BUDIKY
      CALL  MENU_ENTER

      CALL  LCD_CLEAR

      MOV   R0,#LCDBUF
MAIN_LOOP:
      NOP
      JNB   KEY_WAIT,MAIN_LOOP
      JB    KEY_EXTENDED,EXTENDED_KEY
      CLR   KEY_WAIT
      MOV   A,KEY_ASCII_CODE
      CALL  PISKNI
      CJNE  A,#127,NO_BACKSPACE
      JMP   BACKSPACE
NO_BACKSPACE:
      CJNE  A,#01Bh,NO_ESCAPE
      JMP   GOMENU              ;<ESC> doprava
NO_ESCAPE:
      MOV   @R0,A
      INC   R0
      INC   LCD_POS
      CJNE  R0,#LCDBUFEND+1,KLOK
      MOV   R0,#LCDBUF
      MOV   LCD_POS,#0
KLOK: CALL  LCD_WRITEBUF

      CJNE  R0,#LCDBUFEND,MAIN_LOOP
      MOV   R0,#LCDBUF
      MOV   LCD_POS,#0
      JMP   MAIN_LOOP

BACKSPACE:
      DEC   R0
      DEC   LCD_POS
      CJNE  R0,#LCDBUF-1,BS_OK
      MOV   R0,#LCDBUF
      MOV   LCD_POS,#0
BS_OK:
      MOV   @R0,#' '
      CALL  LCD_WRITEBUF

      CJNE  R0,#LCDBUFEND,MAIN_LOOP
      MOV   R0,#LCDBUF
      MOV   LCD_POS,#0
      JMP   MAIN_LOOP

EXTENDED_KEY:
      JNB   KEY_WAIT,EXTENDED_KEY
      CLR   KEY_WAIT
      CLR   KEY_EXTENDED
      MOV   A,KEY_EXTENDED_CODE
      CJNE  A,#075h,E_NOUP
      XCH   A,LCD_POS
      ADD   A,#-20        ;sipka nahoru
      XCH   A,LCD_POS
      XCH   A,R0
      ADD   A,#-20
      XCH   A,R0
      CJNE  R0,#LCDBUF,$+3
      JNC   J_MAIN_LOOP
      MOV   LCD_POS,#0
      MOV   R0,#LCDBUF
      JMP   J_MAIN_LOOP
E_NOUP:
      CJNE  A,#072h,E_NODOWN
      XCH   A,LCD_POS
      ADD   A,#20               ;sipka dolu
      XCH   A,LCD_POS
      XCH   A,R0
      ADD   A,#20
      XCH   A,R0
      CJNE  R0,#LCDBUFEND,$+3
      JC    J_MAIN_LOOP
      MOV   LCD_POS,#0
      MOV   R0,#LCDBUF
      JMP   J_MAIN_LOOP
E_NODOWN:
      CJNE  A,#06Bh,E_NOLEFT
      DEC   LCD_POS             ;sipka doleva
      DEC   R0
      CJNE  R0,#LCDBUF-1,J_MAIN_LOOP
      MOV   LCD_POS,#0
      MOV   R0,#LCDBUF
J_MAIN_LOOP:
      CALL  LCD_WRITEBUF
      JMP   MAIN_LOOP
E_NOLEFT:
      CJNE  A,#074h,E_NORIGHT
      INC   LCD_POS             ;sipka doprava
      INC   R0
      CJNE  R0,#LCDBUFEND,J_MAIN_LOOP
      MOV   LCD_POS,#0
      MOV   R0,#LCDBUF
      JMP   J_MAIN_LOOP
E_NORIGHT:
      JMP   J_MAIN_LOOP

ISEG
STACK:
_LAST_IDATA_ EQU $
DSEG
_LAST_DATA_  EQU $
CSEG
_LAST_CODE_  EQU $
BSEG
_LAST_BIT_   EQU $

;------------------------------------------------------------
;- END OF PROGRAM -------------------------------------------
;------------------------------------------------------------
END

