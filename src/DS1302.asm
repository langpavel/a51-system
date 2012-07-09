; Include file for A51
; Routines for DS1302 Trickle Charge Timekeeping Chip
; Author:      (c) Pavel LANG 2003
; -------------------------------------------------------------------------
; DESCRIPTION: Program routines (8051) designed for working with
;              DS1302 RTC
; -------------------------------------------------------------------------
; NEEDED DEFINED BY USER OF THE LIBRARY:
;  DS_RST        BIT
;  DS_IO         BIT
;  DS_SCLK       BIT
; -------------------------------------------------------------------------
; PROCEDURES:
;  DS_BYTEREAD:     Adress in ACC
;                   Data readed to ACC
;  DS_BYTEWRITE:    Adress in ACC
;                   Data in R0
;  DS_RESET_ALL:    Initial full reset circuit
;
; -------------------------------------------------------------------------
; IMPLEMENTATION:
; ADDRESS CONSTANTS:
DS_ASEC     EQU 0         ; 00-59
DS_AMIN     EQU 1         ; 00-59
DS_AHOUR    EQU 2         ; 01-12 or 00-23
DS_ADATE    EQU 3         ; 01-28/29 or 01-30 or 01-31
DS_AMONTH   EQU 4         ; 01-12
DS_ADAY     EQU 5         ; 01-07
DS_AYEAR    EQU 6         ; 00-99
DS_ACONTROL EQU 7         ; WP 0 0 0 0 0 0 0 - usefull write-protect
DS_ATRICHAR EQU 8         ; TCS TCS TCS TCS DS DS RS RS

; -- DATA TABLES ----------------------------------------------------------
DAYS2: DB 'PO','UT','ST','CT','PA','SO','NE'

DAYS_LONG_LENGTH EQU 7    ; length of one string
DAYS_LONG: DB 'PONDELI'
           DB 'UTERY  '
           DB 'STREDA '
           DB 'CTVRTEK'
           DB 'PATEK  '
           DB 'SOBOTA '
           DB 'NEDELE '
MOUNTHS_LENGTH EQU 8
MOUNTHS:   DB 'LEDEN   '
           DB 'UNOR    '
           DB 'BREZEN  '
           DB 'DUBEN   '
           DB 'KVETEN  '
           DB 'CERVEN  '
           DB 'CERVENEC'
           DB 'SRPEN   '
           DB 'ZARI    '
           DB 'RIJEN   '
           DB 'LISTOPAD'
           DB 'POSINEC '

; -- BASIC I/O ------------------------------------------------------------
DS_WRITEONEBYTE:    ;Data in ACC
     CLR     DS_SCLK
     NOP
     NOP
     PUSH    0        ;work with R0
     MOV     R0,#8
      DS_WRITEBYTE_LOOP:
       MOV     C,ACC.0
       MOV     DS_IO,C
       SETB    DS_SCLK                  ;send clock
       RR      A
       CLR     DS_SCLK
      DJNZ     R0,DS_WRITEBYTE_LOOP
     POP     0
RET

DS_READONEBYTE:    ;Data saved to ACC
     SETB      DS_IO
     NOP
     NOP
     PUSH    0        ;work with R0
     MOV     R0,#8
      DS_READBYTE_LOOP:
       MOV     C,DS_IO
       MOV     ACC.0,C
       SETB    DS_SCLK                  ;send clock
       RR      A
       CLR     DS_SCLK
      DJNZ     R0,DS_READBYTE_LOOP
     POP     0
RET

; -- COMPLEX I/O ----------------------------------------------------------

DS_BYTEREAD:     ;Adress in ACC
                 ;Data readed to ACC
     SETB    DS_RST
     RL      A
     ORL     A,#081h                    ;1 because read
     CALL    DS_WRITEONEBYTE
     CALL    DS_READONEBYTE
     CLR     DS_RST
RET

DS_BYTEWRITE:     ;Adress in ACC
                  ;Data in R0
     SETB    DS_RST
     RL      A
     ORL     A,#080h                    ;0 because write
     CLR     ACC.0
     CALL    DS_WRITEONEBYTE
     MOV     A,R0
     CALL    DS_WRITEONEBYTE
     CLR     DS_RST
RET

; -- ADVANCED PROCEDURES --------------------------------------------------

DS_DAY_IN_WEEK_LO:      ; R0 - address of memory to save day name
     MOV  A,#DS_ADAY
     CALL DS_BYTEREAD
     DEC  A
     MOV  B,#DAYS_LONG_LENGTH
     MUL  AB
     MOV  DPTR,#DAYS_LONG
     MOV  R1,#DAYS_LONG_LENGTH
     CALL COPYCODERAM
RET

DS_RESET_ALL:           ; reset all time registers without memory
     MOV  A,#7          ; CONTROL
     MOV  R0,#0         ; DISABLE WRITE PROTECT BIT
     CALL DS_BYTEWRITE
     MOV  A,#8          ; TRICKLE CHAGER
     MOV  R0,#0         ; DISABLE CHARGER
     CALL DS_BYTEWRITE
     MOV  A,#0          ; SEC
     MOV  R0,#0
     CALL DS_BYTEWRITE
     MOV  A,#1          ; MIN
     MOV  R0,#59h
     CALL DS_BYTEWRITE
     MOV  A,#2          ; 24 HOUR
     MOV  R0,#23h
     CALL DS_BYTEWRITE
     MOV  A,#3          ; DATE
     MOV  R0,#023h
     CALL DS_BYTEWRITE
     MOV  A,#4          ; MONTH
     MOV  R0,#3
     CALL DS_BYTEWRITE
     MOV  A,#5          ; DAY
     MOV  R0,#7
     CALL DS_BYTEWRITE
     MOV  A,#6          ; YEAR
     MOV  R0,#3
     CALL DS_BYTEWRITE
RET
