; Include file for A51
; LCD routines (HD44780)
; Author:      (c) Pavel LANG 2003
; -------------------------------------------------------------------------
; DESCRIPTION: Program routines (8051) designed for LCD driver
;              MC2004 (20 chars in 4 lines) in 8 bit mode
; -------------------------------------------------------------------------
; NEEDED DEFINED BY USER OF THE LIBRARY:
;   LCD_EN   BIT  - signal for enable transfer pin 6 on LCD module
;   LCD_RS   BIT  - signal selecting register pin 4 (1 = data, 0 = command)
;   LCD_DATA DATA - data bus (for example P1)
; -------------------------------------------------------------------------
; PROCEDURES:
;  LCD_SIG_ENTER          send enable signal to module
;
;  LCD_CLEAR              send clear command
;  LCD_RETURN_HOME        set DDRAM addres to 0 (1.52 ms execution time)
;  LCD_ENTRY_MODE         parameters: ACC.0 - '0' shift cursor after write
;                                           - '1' shift display after write
;                                 ACC.1 - '0' decrement address after write
;                                       - '1' increment addr after write
;
;  LCD_DISPLAY_ON         parameters: ACC.0 - blink
;                                     ACC.1 - cursor '_'
;                                     ACC.2 - display on
;  LCD_SHIFT              parameters: ACC.2 - right or left
;                                     ACC.3 - cursor or display
;  LCD_FUNCTION_SET       parameters: ACC.2 - '0'=5x7 char cell, '1'=5x10
;                                     ACC.3 - num. of lines ('1'=2,4; '0'=1)
;                         note:  bus is set to 8 bits in this library
;  LCD_SET_ADDRESS        parameters: A = address in data memory (DDRAM)
;  LCD_SET_DDRAM_ADDRESS  same as LCD_SET_ADDRESS
;  LCD_SET_CGRAM_ADDRESS  parameters: A = address in character
;                                         generator memory (CGRAM)
;  LCD_WRITE              parameters: A = data
; -------------------------------------------------------------------------
; IMPLEMENTATION:

LCD_POS_HOME EQU 0

LCD_SIG_ENTER:          ; send enable signal to module
   SETB LCD_EN
   PUSH 0
   NOP
   NOP
   CLR  LCD_EN
   MOV  0,#50           ; 2 cycles
   DJNZ 0,$             ; 50x2 cycles = 102 cycles -> 37misrosec 33MHz osc
   SETB LCD_EN
   POP  0
RET

LCD_LONG_WAIT_CYCLE:
   PUSH 0
   PUSH 1
   MOV  1,#40           ; 40
   LCD_CLEAR_WCYCLE:
    MOV  0,#50          ; 50
    DJNZ 0,$
   DJNZ 1,LCD_CLEAR_WCYCLE
   SETB LCD_EN
   POP  1
   POP  0
RET

LCD_CLEARRAM:           ; clear display ...
   MOV  LCD_POS,#0
   MOV  R0,#LCDBUF
 LCD_CLRLOOP:
   MOV  @R0,#020h       ; ... and fill memory with space
   INC  R0
   CJNE R0,#LCDBUFEND,LCD_CLRLOOP
   MOV  R0,#LCDBUF
RET

LCD_CLEAR:              ; clear display ...
   MOV  LCD_POS,#LCD_POS_HOME
   CALL LCD_CLEARRAM
   CALL LCD_WRITEBUF
RET

LCD_RETURN_HOME:        ; set DDRAM addres to 0 (1.52 ms execution time)
   CLR  LCD_RS
   MOV  LCD_DATA,#002h
   CALL LCD_SIG_ENTER
   CALL LCD_LONG_WAIT_CYCLE
RET

LCD_ENTRY_MODE:         ; parameters: ACC.0 - '0' shift cursor after write
                        ;                   - '1' shift display after write
                        ;             ACC.1 - '0' decrement address after write
                        ;                   - '1' increment after write
   CLR  LCD_RS
   ANL  A,#007h
   SETB ACC.2
   MOV  LCD_DATA,A
   CALL LCD_SIG_ENTER
RET

LCD_DISPLAY_ON:         ; parameters: (ACC.0 - blink       - LCD_CURBL bit)
                        ;             (ACC.1 - cursor '_'  - LCD_CURON bit)
                        ;             ACC.2 - display on
   CLR  LCD_RS
   MOV  C,LCD_CURBL
   MOV  ACC.0,C
   MOV  C,LCD_CURON
   MOV  ACC.1,C
   ANL  A,#00Fh
   SETB ACC.3
   MOV  LCD_DATA,A
   CALL LCD_SIG_ENTER
RET

LCD_SHIFT:              ; parameters: ACC.2 - right or left
                        ;             ACC.3 - cursor or display
   CLR  LCD_RS
   ANL  A,#01Fh
   SETB ACC.4
   MOV  LCD_DATA,A
   CALL LCD_SIG_ENTER
RET

LCD_FUNCTION_SET:       ; parameters: ACC.2 - '0'=5x7 char cell, '1'=5x10
                        ;             ACC.3 - num. of lines ('1'=2,4; '0'=1)
                        ; note: bus is set to 8 bits
   CLR  LCD_RS
   ANL  A,#03Fh
   ORL  A,#030h
   MOV  LCD_DATA,A
   CALL LCD_SIG_ENTER
RET

LCD_SET_ADDRESS:        ; parameters: A = address in data memory (DDRAM)
LCD_SET_DDRAM_ADDRESS:
   CLR  LCD_RS
   ORL  A,#080h
   MOV  LCD_DATA,A
   CALL LCD_SIG_ENTER
RET

LCD_SET_CGRAM_ADDRESS:  ; parameters: A = address in character
                        ;                 generator memory (CGRAM)
   CLR  LCD_RS
   CLR  ACC.7
   ORL  A,#040h
   MOV  LCD_DATA,A
   CALL LCD_SIG_ENTER
RET

LCD_WRITE:              ; parameters: A = data
   SETB LCD_RS
   MOV  LCD_DATA,A
   CALL LCD_SIG_ENTER
RET

LCD_INIT:               ; initialize 2004
   CALL LCD_CLEAR
   MOV  A,#8            ; 2 or 4 lines
   CALL LCD_FUNCTION_SET
;   CALL LCD_LONG_WAIT_CYCLE
   MOV  A,#4            ; only display on
   CLR  LCD_CURON
   CLR  LCD_CURBL
   CALL LCD_DISPLAY_ON
;   CALL LCD_LONG_WAIT_CYCLE
   MOV  A,#2            ; increment address after write
   CALL LCD_ENTRY_MODE
;   CALL LCD_LONG_WAIT_CYCLE
RET

LCD_WRITEBUF:
   PUSH 0               ; !!! USING REGISTER BANK 0 !!!
   PUSH 1
   PUSH 2
   PUSH ACC

   MOV  LCD_DATA,#4+8   ; disable cursor
   CALL LCD_SIG_ENTER

   MOV  A,#0
   CALL LCD_SET_ADDRESS ; set addres to 0 for 1st line
   MOV  R0,#LCDBUF      ; source data
   MOV  R1,#0
   MOV  R2,#0
   XCH  A,LCD_POS
   ADD  A,#LCDBUF
   XCH  A,LCD_POS

   LCD_WRITEBUF_LOOP1:
    MOV  A,@R0
    CALL LCD_WRITE
    MOV  A,R0
    CJNE A,LCD_POS,LCD_WB_L1
    MOV  2,1
  LCD_WB_L1:
    INC  R0
    INC  R1
   CJNE R0,#LCDBUF+20,LCD_WRITEBUF_LOOP1
   XCH  A,R0
   ADD  A,#20           ; 3rd line in memory
   XCH  A,R0
   LCD_WRITEBUF_LOOP2:
    MOV  A,@R0
    CALL LCD_WRITE
    MOV  A,R0
    CJNE A,LCD_POS,LCD_WB_L2
    MOV  2,1
  LCD_WB_L2:
    INC  R0
    INC  R1
   CJNE R0,#LCDBUF+60,LCD_WRITEBUF_LOOP2

   MOV  A,#040h
   MOV  R1,#040h
   CALL LCD_SET_ADDRESS ; set addres to 64 for 2nd line
   MOV  R0,#LCDBUF+20   ; source data 2nd line

   LCD_WRITEBUF_LOOP3:
    MOV  A,@R0
    CALL LCD_WRITE
    MOV  A,R0
    CJNE A,LCD_POS,LCD_WB_L3
    MOV  2,1
  LCD_WB_L3:
    INC  R0
    INC  R1
   CJNE R0,#LCDBUF+40,LCD_WRITEBUF_LOOP3
   XCH  A,R0
   ADD  A,#20           ; 4rd line in memory
   XCH  A,R0
   LCD_WRITEBUF_LOOP4:
    MOV  A,@R0
    CALL LCD_WRITE
    MOV  A,R0
    CJNE A,LCD_POS,LCD_WB_L4
    MOV  2,1
  LCD_WB_L4:
    INC  R0
    INC  R1
   CJNE R0,#LCDBUF+80,LCD_WRITEBUF_LOOP4

   XCH  A,LCD_POS
   ADD  A,#-LCDBUF                ;odcitani
   XCH  A,LCD_POS
   MOV  A,R2
   CALL LCD_SET_ADDRESS

   MOV   A,#004h
   CALL  LCD_DISPLAY_ON

   POP  ACC
   POP  2
   POP  1
   POP  0
RET

; LCD routines (HD44780)
; END of include file


