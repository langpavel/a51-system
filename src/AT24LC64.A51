; Include file for A51
; Routines for AT24LC64 - 8kB serial EEPROM
; Author:      (c) Pavel LANG 2003
; -------------------------------------------------------------------------
; DESCRIPTION: Program routines (8051) designed for working with
;              AT24LC64 FLASH MEMORY
; -------------------------------------------------------------------------
; NEEDED DEFINED BY USER OF THE LIBRARY:
;  MEM_SDA BIT  P3.7     ; EEPROM Serial Data
;  MEM_SCL BIT  P3.6     ; EEPROM Serial Clock
; -------------------------------------------------------------------------
; PROCEDURES:
;  MEM_BYTEREAD  - read one byte
;                - value returned in ACC
;  MEM_BYTEWRITE - write one byte to address in DPTR
;                - value in ACC
;  MEM_BLOCKWRITE                  ; EEPOM address in DPTR
;                                  ; RAM addres in R0
;                                  ; size in R1
;  MEM_BLOCKREAD                   ;
;                                  ; RAM addres in R0
;                                  ; size in R1
; -------------------------------------------------------------------------
; IMPLEMENTATION:
; -- DATA -----------------------------------------------------------------
BSEG
MEM_DOACK:      DBIT 1
CSEG

; -- BASIC I/O ------------------------------------------------------------

MEM_WAIT7:     ;wait 7 uS
               ;2 cycles call   1.0 us
NOP            ;1 cycle         1.5 us
NOP            ;1 cycle         2.0 us
NOP            ;1 cycle         2.5 us
NOP            ;1 cycle         3.0 us
NOP            ;1 cycle         3.5 us
NOP            ;1 cycle         4.0 us
NOP            ;1 cycle         4.5 us
NOP            ;1 cycle         5.0 us
RET            ;2 cycles ret    6.0 us

MEM_STARTBIT:
     SETB  MEM_SDA      ; SDA normally high
     SETB  MEM_SCL
     CALL  MEM_WAIT7
     CLR   MEM_SDA
     CALL  MEM_WAIT7
     CLR   MEM_SCL
     CALL  MEM_WAIT7
RET

MEM_STOPBIT:
     CLR   MEM_SDA
     NOP
     SETB  MEM_SCL
     CALL  MEM_WAIT7
     SETB  MEM_SDA
     CALL  MEM_WAIT7
     CLR   MEM_SCL
     CALL  MEM_WAIT7
RET

MEM_CLK:                ; send SCL pulse
     CALL  MEM_WAIT7
     SETB  MEM_SCL
     CALL  MEM_WAIT7
     CLR   MEM_SCL
     CALL  MEM_WAIT7
RET

MEM_WRITEONEBYTE:       ; write byte in ACC
     PUSH    0          ; work with R0
     MOV     R0,#8
      MEM_WRITEBYTE_LOOP:
       RLC     A
       MOV     MEM_SDA,C
       CALL    MEM_CLK
      DJNZ     R0,MEM_WRITEBYTE_LOOP
     RLC     A
     POP     0
     SETB    MEM_SDA    ; Acknowledge
     NOP
     SETB    MEM_SCL
     CALL    MEM_WAIT7
     MOV     C,MEM_SDA
     CLR     MEM_SCL
RET

MEM_READONEBYTE:        ; read byte in ACC
     CLR     MEM_SCL
     PUSH    0          ; work with R0
     SETB    MEM_SDA
     MOV     R0,#8
      MEM_READBYTE_LOOP:
       SETB    MEM_SCL
       CALL    MEM_WAIT7
       MOV     C,MEM_SDA
       RLC     A
       CALL    MEM_WAIT7
       CLR     MEM_SCL
       CALL    MEM_WAIT7
      DJNZ     R0,MEM_READBYTE_LOOP
     MOV     C,MEM_DOACK
     MOV     MEM_SDA,C
     CALL    MEM_CLK
     POP     0
RET

MEM_BYTEWRITE:                  ; address in DPTR
                                ; value in ACC
     PUSH    ACC
     CALL    MEM_WAITFINISH
     CALL    MEM_STARTBIT       ; start
     MOV     A,#0A0h            ; device address + write
     CALL    MEM_WRITEONEBYTE
     JC      MEM_BYTEWRITE
     MOV     A,DPH              ; hi address
     CALL    MEM_WRITEONEBYTE
     MOV     A,DPL              ; lo address
     CALL    MEM_WRITEONEBYTE
     POP     ACC                ; data
     PUSH    ACC
     CALL    MEM_WRITEONEBYTE
     CALL    MEM_STOPBIT        ; stop
     INC     DPTR
     POP     ACC                ; data
RET

MEM_SETADDRESS:                 ; address in DPTR
     CALL    MEM_WAITFINISH
     CALL    MEM_STARTBIT       ; start
     MOV     A,#0A0h            ; device address + dummy write
     CALL    MEM_WRITEONEBYTE
     JC      MEM_SETADDRESS
     MOV     A,DPH              ; hi address
     CALL    MEM_WRITEONEBYTE
     MOV     A,DPL              ; lo address
     CALL    MEM_WRITEONEBYTE
     CALL    MEM_STOPBIT        ; stopbit
RET

MEM_BYTEREAD:                   ; NO ADDRESS SETTING
                                ; value returned in ACC
     CALL    MEM_WAITFINISH
     CALL    MEM_STARTBIT       ; start
     MOV     A,#0A1h            ; device address + read
     CALL    MEM_WRITEONEBYTE
     JC      MEM_BYTEREAD
     SETB    MEM_DOACK          ; terminate comunication
     CALL    MEM_READONEBYTE
     CALL    MEM_STOPBIT        ; stop
RET



MEM_BLOCKWRITE:                 ; EEPOM address in DPTR
                                ; RAM addres in R0
                                ; size in R1
     PUSH    ACC
     CALL    MEM_WAITFINISH
     CALL    MEM_STARTBIT       ; start
     MOV     A,#0A0h            ; device address + write
     CALL    MEM_WRITEONEBYTE
     MOV     A,DPH              ; hi address
     CALL    MEM_WRITEONEBYTE
     MOV     A,DPL              ; lo address
     CALL    MEM_WRITEONEBYTE
      MEM_BLOCKWRITELOOP:
       MOV     A,@R0
       INC     R0
       CALL    MEM_WRITEONEBYTE
       INC     DPTR
      DJNZ R1,MEM_BLOCKWRITELOOP
     CALL    MEM_STOPBIT        ; stop
     CALL    MEM_WAITFINISH
     POP     ACC                ; data
RET

MEM_BLOCKREAD:                ; NO ADDRESS SETTING - user call MEM_SETADDRESS
                                ; RAM addres in R0
                                ; size in R1
     PUSH    ACC
     CALL    MEM_WAITFINISH
     CALL    MEM_STARTBIT       ; start
     MOV     A,#0A1h            ; device address + read
     CALL    MEM_WRITEONEBYTE
     CLR     MEM_DOACK          ; don't terminate comunication
     DEC     R1
      MEM_BLOCKREADLOOP:
       CALL    MEM_READONEBYTE
       MOV     @R0,A
       INC     R0
      DJNZ R1,MEM_BLOCKREADLOOP
     SETB    MEM_DOACK          ; terminate comunication
     CALL    MEM_READONEBYTE
     MOV     @R0,A
     INC     R0
     CALL    MEM_STOPBIT        ; stop
     POP     ACC
RET

MEM_WAITFINISH:
     CALL    MEM_STARTBIT       ; start
     MOV     A,#0A0h            ; device address + write
     CALL    MEM_WRITEONEBYTE
     JC      MEM_WAITFINISH
     CALL    MEM_STOPBIT        ; start
RET

MEM_BLOCKWRITE_CODE:            ; EEPOM address in DPTR
                                ; ROM addres in R0 - lower
                                ;               R2 - higher
                                ; size in R1
     PUSH    ACC
     CALL    MEM_WAITFINISH
     CALL    MEM_STARTBIT       ; start
     MOV     A,#0A0h            ; device address + write
     CALL    MEM_WRITEONEBYTE
     MOV     A,DPH              ; hi address
     CALL    MEM_WRITEONEBYTE
     MOV     A,DPL              ; lo address
     CALL    MEM_WRITEONEBYTE
      MEM_BLOCKWRITECODELOOP:
       PUSH    DPH
       PUSH    DPL
       CLR     A
       MOV     DPH,R2
       MOV     DPL,R0
       MOVC    A,@A+DPTR
       INC     DPTR
       MOV     R2,DPH
       MOV     R0,DPL
       POP     DPL
       POP     DPH
       CALL    MEM_WRITEONEBYTE
      DJNZ R1,MEM_BLOCKWRITECODELOOP
     CALL    MEM_STOPBIT        ; stop
     POP     ACC
RET
