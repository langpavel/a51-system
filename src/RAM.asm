; Include file for Assembler 51
; Routines for working with memory (8052)
; Author:      (c) Pavel LANG 2003 (langpa@seznam.cz)
; -------------------------------------------------------------------------
; DESCRIPTION: Program routines (8051) designed for working with memory
; -------------------------------------------------------------------------
; NOTE:
; * GETMEM and FREEMEM must be used on same level of procedure
;   calling because of using STACK as storage space
; 

DSEG
     RAM_RETADDR: DS 2
CSEG

GETMEM:         ;alocate memory on stack - see note
                ;parameters:  A - block size
                ;returns:     @R0 - address of free memory area
                ;if not successfull reset procesor
     POP   RAM_RETADDR
     POP   RAM_RETADDR+1
     MOV   R0,SP
     INC   R0
     ADD   A,SP
     JC    GETMEM_NORAM     ;if cary no memory avaiable (maximal addr. 0FFh)
;    JB    OV,GETMEM_NORAM  ;for 8051 replace with this
     MOV   SP,A
     PUSH  RAM_RETADDR+1
     PUSH  RAM_RETADDR
RET

GETMEM_NORAM:   ;internaly used by GETMEM - change it as you wish
     MOV   IE,#0
     MOV   TCON,#0
     MOV   TMOD,#0
     MOV   SP,#7
JMP   0    ;reset

FREEMEM:         ;dealocate memory on stack
                 ;parameters: A - block size
     POP   RAM_RETADDR
     POP   RAM_RETADDR+1
     XCH   A,SP
     CLR   C
     SUBB  A,SP
     XCH   A,SP
     PUSH  RAM_RETADDR+1
     PUSH  RAM_RETADDR
RET

