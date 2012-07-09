; Include file for A51
; Routines for 8kB serial EEPROM filesystem
; Author:      (c) Pavel LANG 2003
; -------------------------------------------------------------------------
; DESCRIPTION: Program routines (8051) designed for working with
;              AT24LC64 FLASH MEMORY - filesystem services "FAT8"
; -------------------------------------------------------------------------
;Schema rozlozeni pameti:
;~~~~~~~~~~~~~~~~~~~~~~~~
;velikost pameti:                64 kb = 8 kB = 8192 B
;pocet bloku:                    8192 B / 64B = 128
;velikost jednoho bloku:         64B = 040h
;velikost FAT:                   128B -> 2 bloky
;
;-----------------------------------------------------
;
;Struktura po blocich:
;~~~~~~~~~~~~~~~~~~~~~
;jmeno bloku:         pozice:
;~~~~~~~~~~~~         ~~~~~~~
;  SYS                    0  (vzdy velikost 128)
;  FAT                    1  (128=080h)
;  FAT                    2  (256=100h)
;  ROOT                   3  (384=180h)
;  ...                  ...
;  DATA/DIR             ...
;  DATA/DIR             ...
;  ...                  ...
;  DATA/DIR             127  (16256=3F80h)
;
;-----------------------------------------------------
;BLOK SYS:
;~~~~~~~~~
;offset          jmeno                   popis
;~~~~~~          ~~~~~                   ~~~~~
;0,1             MAGIC_WORD              055h 0AAh
;2,3             VELIKOST_BLOKU          000h 040h (=64)
;4,5             POCET_BLOKU             000h 080h (=128=24LC64)
;6,7             VERZE_FORMATU           001h 000h (=v1.0 - BCD)
;8..127          SWAP_SPACE              pro swapovani pameti
;
;-----------------------------------------------------
;
;BLOK FAT
;hodnota:        vyznam
;~~~~~~~~        ~~~~~~
;00h             volne misto
;01h             konec souboru (nebo take tabulka fat, systemova oblast)
;jina hodnota    index dalsiho bloku souboru
;
;-----------------------------------------------------
;
;BLOK ROOT/DIR:
;~~~~~~~~~~~~~~
;offset velikost jmeno                   popis
;~~~~~~ ~~~~~~~~ ~~~~~                   ~~~~~
;00h 01h      1  ATTRIB                  SUBDIR  READ    WRITE     EXEC
;                                        LOCKED  HIDDEN  PASSWORD  VALID
;01h 09h      8  FILE_NAME               jmeno souboru
;0Ah 0Bh      1  FAT_ENTRY               vstupni bod v tabulce fat
;                                        (U DIR index struktury)
;0Bh 0Fh      6  MODIFIED_DATE_TIME      YY.MM.DD HH:MM.SS
;
;10h 1Fh     15  FILE_NAME,ATTRIB,MDT
;20h 2Fh     15  FILE_NAME,ATTRIB,MDT
;30h 3Fh     15  FILE_NAME,ATTRIB,MDT
;- CODE ----------------------------------------------

FS_BLOCKSIZE            EQU 040h
FS_FILENAME_LENGTH      EQU 8
FS_ROOTINDEX            EQU 3
FS_FATSTART             EQU FS_BLOCKSIZE
FS_FATSIZE              EQU 080h
FS_BLOCK_CNT            EQU FS_FATSIZE
FS_FILESTRUCT_SIZE      EQU 010h
FS_FILESTRUCTS_IN_BLOCK EQU 4

FS_SYSTABLE:    DB 055h,0aah,000h,FS_BLOCKSIZE,000h,080h,001h,000h
FS_SYSTABLEEND:
FS_CLEAR_FAT:   DB 001h,001h,001h,001h, 000h,000h,000h,000h
                DB 000h,000h,000h,000h, 000h,000h,000h,000h
FS_16CLEAR:     DB 000h,000h,000h,000h, 000h,000h,000h,000h
                DB 000h,000h,000h,000h, 000h,000H,000h,000h

FS_DIR_EMPTY:   DB 'ADRESAR JE PRAZDNY!',0

;--------------------------------------------------------------

FS_FORMAT:     ;make a header and format FAT
     ;head
     MOV   DPTR,#0                          ;flash address
     MOV   R0,#LOW(FS_SYSTABLE)             ;low of code address
     MOV   R2,#HIGH(FS_SYSTABLE)            ;high of code address
     MOV   R1,#FS_SYSTABLEEND-FS_SYSTABLE   ;length
     CALL  MEM_BLOCKWRITE_CODE
     ;all
     PUSH  7
     MOV   7,#01                            ;clear all blocks from FAT (1)
      FS_FORMAT_LOOP:
       MOV   A,7
       CALL  FS_CLEARBLOCK
       INC   7
      CJNE  R7,#FS_BLOCK_CNT,FS_FORMAT_LOOP
     POP   7
     ;fat
     MOV   DPTR,#FS_BLOCKSIZE               ;flash address - FAT
     MOV   R0,#LOW(FS_CLEAR_FAT)            ;low of code address
     MOV   R2,#HIGH(FS_CLEAR_FAT)           ;high of code address
     MOV   R1,#16                           ;length
     CALL  MEM_BLOCKWRITE_CODE
RET

;--------------------------------------------------------------

FS_CLEARBLOCK:          ;fill block A with 0
     PUSH  ACC
     PUSH  0
     PUSH  1
     PUSH  2
     PUSH  7
     CALL  FS_CALCULATE_OFFSET
     MOV   7,#FS_BLOCKSIZE/16
   FS_CLEARB_LOOP:
      MOV   R0,#LOW(FS_16CLEAR)             ;low of code address
      MOV   R2,#HIGH(FS_16CLEAR)            ;high of code address
      MOV   R1,#16                          ;length
      CALL  MEM_BLOCKWRITE_CODE
      XCH   A,DPL
      ADD   A,#16
      XCH   A,DPL
      XCH   A,DPH
      ADDC  A,#0
      XCH   A,DPH
     DJNZ  7,FS_CLEARB_LOOP
     POP   7
     POP   2
     POP   1
     POP   0
     POP   ACC
RET

;--------------------------------------------------------------
FS_TEST:                                ;set C if success <=> data format OK
     MOV   DPTR,#0
     CALL  MEM_SETADDRESS
     CALL  MEM_BYTEREAD
     CJNE  A,#055h,FS_TEST_FAIL
     CALL  MEM_BYTEREAD
     CJNE  A,#0AAh,FS_TEST_FAIL
     SETB  C                            ;success
RET
FS_TEST_FAIL:
     CLR   C                            ;KO
RET

;--------------------------------------------------------------
FS_FAT_READ:    ;parameter in A - index of FAT entry
     PUSH  DPH
     PUSH  DPL
     MOV   DPTR,#FS_FATSTART
     ADD   A,DPL
     MOV   DPL,A
     MOV   A,DPH
     ADDC  A,#0
     MOV   DPH,A
     CALL  MEM_SETADDRESS       ;DPTR
     CALL  MEM_BYTEREAD         ;read to A
     POP   DPL
     POP   DPH
RET
;--------------------------------------------------------------------
FS_FAT_NEXT:    ;parameter in A - index of actual FAT entry
                ;return A - next block index, 
                ;           A=01h - end, C <- 1
     CALL  FS_FAT_READ
     CJNE  A,#01,FS_FAT_NOEOF
     SETB  C    ;KO
 RET
 FS_FAT_NOEOF:  ;OK - in A index of next entry
     CLR   C
RET
;--------------------------------------------------------------------
FS_FAT_WRITE:   ;parameter in A - index of FAT entry
                ;   B - index of next entry (byte writed on A pos in FAT)
     PUSH  DPH
     PUSH  DPL
     PUSH  ACC
     MOV   DPTR,#FS_FATSTART
     ADD   A,DPL
     MOV   DPL,A
     MOV   A,DPH
     ADDC  A,#0
     MOV   DPH,A
     MOV   A,B
     CALL  MEM_BYTEWRITE        ;on DPTR write A
     POP   ACC
     POP   DPL
     POP   DPH
RET
;--------------------------------------------------------------------
FS_CALCULATE_OFFSET:    ;A - index of data block
                        ;set DPTR
     PUSH  ACC
     PUSH  B
     MOV   B,#FS_BLOCKSIZE
     MUL   AB
     MOV   DPH,B
     MOV   DPL,A
     POP   B
     POP   ACC
RET
;--------------------------------------------------------------------
FS_FIND_EMPTY_DIR_STRUCT:       ;parameter: A-index of dir. entry (FAT index)
                                ;return:
                                ;  DPTR points to free struct entry
                                ;  A - index of dir. block with free struct
                                ;  C is set if ERROR
     PUSH  7
     PUSH  6
     MOV   7,A
  FS_FIND_EMPTY_NEXTA:
     MOV   6,#FS_FILESTRUCTS_IN_BLOCK   ;4
     CALL  FS_CALCULATE_OFFSET          ;A - index
  FS_FIND_EMPTY_NEXT:
     CALL  MEM_SETADDRESS
     CALL  MEM_BYTEREAD                 ;read to A
      JNB   ACC.0,FS_FIND_EMPTY_SUCCESS ;empty flag
       XCH   A,DPL                       ;not empty
       ADD   A,#LOW(FS_FILESTRUCT_SIZE)  ;16
       XCH   A,DPL
       XCH   A,DPH
       ADDC  A,#HIGH(FS_FILESTRUCT_SIZE) ;0
       XCH   A,DPH
     DJNZ  6,FS_FIND_EMPTY_NEXT
     MOV   A,7
     CALL  FS_FAT_NEXT
      JNC   FS_FIND_EMPTY_NO_EXPAND
       MOV   A,7
       CALL  FS_EXPAND                  ;expand directory to new block
       MOV   7,A
       CALL  FS_CALCULATE_OFFSET
       JMP   FS_FIND_EMPTY_SUCCESS
      FS_FIND_EMPTY_NO_EXPAND:
     MOV   7,A
  JMP   FS_FIND_EMPTY_NEXTA
  FS_FIND_EMPTY_SUCCESS:
     MOV   A,7
     CALL  MEM_SETADDRESS
     CLR   C
     POP   6
     POP   7
RET
;--------------------------------------------------------------------
FS_EXPAND:                      ;parameter: A - index of last block of
                                ;               file or directory stucture
                                ;return:    A - new free structure
                                ;           C = 0 if successfull
     PUSH  ACC
     CALL  FS_FIND_EMPTY_BLOCK
     JC    FS_EXPAND_END        ;if error, jump; C is set
     MOV   B,A                  ;address of new block
     POP   ACC
     PUSH  B
     CALL  FS_FAT_WRITE         ;write index of new datablock
     POP   ACC                  ;new address
     MOV   B,#01h               ;end
     CALL  FS_FAT_WRITE         ;write EOF
     CALL  FS_CLEARBLOCK        ;clear free block
     CLR   C
 FS_EXPAND_END:
RET
;--------------------------------------------------------------------
FS_FIND_EMPTY_BLOCK:            ;find first free block in FAT and save index
                                ;to A
                                ;if memory full set C, A<-0FFh
     PUSH  7                    ;counter of index in FAT
     PUSH  DPL
     PUSH  DPH
     MOV   DPTR,#FS_FATSTART
     CALL  MEM_SETADDRESS
     MOV   7,#0
 FS_FIND_EB_LOOP:
     CALL  MEM_BYTEREAD
     JZ    FS_FIND_EMPTY_BLOCK_SUCCESS  ;if in FAT is zero, block is returned
     INC   7
     CJNE  R7,#FS_FATSIZE,FS_FIND_EB_LOOP
     SETB  C
     MOV   A,#0FFh
     POP   DPH
     POP   DPL
     POP   7
RET
 FS_FIND_EMPTY_BLOCK_SUCCESS:
     CLR   C
     MOV   A,7  ;return value
     POP   DPH
     POP   DPL
     POP   7
RET
;--------------------------------------------------------------------
FS_NEW:         ;parameters:    @R0 -> address of filename (length 8)
                ;               A      index of directory
                ;               B      file params
                ;               C=1 -> error
     PUSH  ACC
     CALL  FS_FILEENTRY ;file exist?
     POP   ACC
     JC    FS_NEW_FAIL  ;if file exist, jump = error
     PUSH  7
     PUSH  B
     MOV   7,B
     CALL  FS_FIND_EMPTY_DIR_STRUCT
;     MOV   7,A  ;index of new block
     POP   B                    ;params
     PUSH  B
     MOV   A,B
     CALL  MEM_BYTEWRITE        ;write params

     PUSH  1
     MOV   R1,#8                ;filename size
     CALL  MEM_BLOCKWRITE       ;write filename
     CALL  FS_FIND_EMPTY_BLOCK  ;find free block
     CALL  MEM_BYTEWRITE        ;write block index
     MOV   B,#01h               ;EOF
     CALL  FS_FAT_WRITE
     POP   1

;    CALL  FS_SET_FILE_DATE_TIME ;later
     POP   B
     POP   7
     CLR   C
FS_NEW_FAIL:
RET
;--------------------------------------------------------------------
FS_FORCESHOW:
 PUSH       7
 PUSH       6
 PUSH       5
 MOV        DPTR,#0
 CALL       MEM_SETADDRESS
 MOV        5,#0
 CLR        KEY_WAIT
  FS_FORCESHOW_L1:
   MOV      R0,#LCDBUF
   MOV      6,#4
    FS_FORCESHOW_L2:
     MOV    7,#8
     MOV    A,DPH
     CALL   WRITEHEX
     MOV    A,DPL
     CALL   WRITEHEX
      FS_FORCESHOW_L3:
       CALL MEM_BYTEREAD
       INC  DPTR
       CALL WRITEHEX
      DJNZ  7,FS_FORCESHOW_L3
    DJNZ    6,FS_FORCESHOW_L2
   CALL     LCD_WRITEBUF
   JNB      KEY_WAIT,$
   CLR      KEY_WAIT
   MOV      A,KEY_ASCII_CODE
   CJNE     A,#01bh,FS_FORCESHOW_CONT
   JMP      FS_FORCESHOW_END
 FS_FORCESHOW_CONT:
  DJNZ      5,FS_FORCESHOW_L1
 FS_FORCESHOW_END:
 POP        5
 POP        6
 POP        7
RET

;--------------------------------------------------------------------

FS_FILEENTRY:           ;parameters: A - index of directory
                        ;            @R0 - pointer to filename - size 8
                        ;returns:    A - entry point (FAT index)
                        ;            C=1 => file exist
                        ;            DPTR - points to actual block
     PUSH  1            ;temp for @R0 - filename
     PUSH  2            ;temp for storage space pointer
     PUSH  3            ;temp for A - dir
     MOV   1,R0
     MOV   3,A
     MOV   A,#FS_FILESTRUCT_SIZE
     CALL  GETMEM       ;in: A       out: @R0

     MOV   2,R0
     MOV   A,3          ;dir
     CALL  FS_CALCULATE_OFFSET
     INC   SP           ;space for DPTR
     INC   SP
      FS_FILEENTRY_LOOP:
       MOV  A,3         ;dir
       MOV  R0,2        ;storage
       DEC  SP
       DEC  SP
       PUSH DPH
       PUSH DPL
       CALL FS_FINDNEXT         ;write on @R0
       MOV  3,A                 ;save dir change
       JNC  FS_FILEENTRY_KO     ;file not found
       MOV  A,#FS_FILENAME_LENGTH
       MOV  R0,2                ;get position
       INC  R0                  ;on name
       CALL COMPARESTR          ;R0,R1,A=size; C if eq
      JNC FS_FILEENTRY_LOOP     ;not eq => jump
     MOV   A,R0
     ADD   A,#FS_FILENAME_LENGTH ;calculate pos. of FAT entry
     MOV   R0,A
     MOV   A,@R0
     MOV   3,A                  ;save file entry
     POP   DPL                  ;real DPTR on filestruct
     POP   DPH
     MOV   A,#FS_FILESTRUCT_SIZE
     CALL  FREEMEM
     MOV   A,3                  ;return file FAT entry point
     MOV   R0,1                 ;restore R0
     POP   3
     POP   2
     POP   1
     SETB  C                    ;OK
RET
 FS_FILEENTRY_KO:
     DEC   SP
     DEC   SP
     MOV   A,#FS_FILESTRUCT_SIZE
     CALL  FREEMEM
     MOV   R0,1
     POP   3
     POP   2
     POP   1
     CLR   C                    ;file not found
RET

;--------------------------------------------------------------------

FS_FINDNEXT:            ;parameters: A    - index of directory
                        ;            @R0  - storage space for FILESTRUCT
                        ;            DPTR - actual filestruct
                        ;return:     DPTR - point to next FILESTRUCT in FLASH
                        ;            C = 1 -> successfull
                        ;            A - index of directory - for next search

     PUSH  ACC
     CALL  MEM_SETADDRESS
     PUSH  1
     PUSH  0
     MOV   1,#FS_FILESTRUCT_SIZE
     CALL  MEM_BLOCKREAD        ;read 16B to @R0
     POP   0
     POP   1
     MOV   A,#FS_FILESTRUCT_SIZE
     CALL  FS_ADD_DPTR_A        ;next FS
     MOV   A,DPL
     ANL   A,#FS_BLOCKSIZE-1
      JNZ   FS_FINDNEXT_ADDR_OK
       POP   ACC                ;if all block readed
       CALL  FS_FAT_NEXT
       PUSH  ACC
       JC    FS_FINDNEXT_END
       CALL  FS_CALCULATE_OFFSET
       CALL  MEM_SETADDRESS
      FS_FINDNEXT_ADDR_OK:
     MOV   A,@R0        ;get attribute
     MOV   C,ACC.0
     POP   ACC
     JNC   FS_FINDNEXT
 RET
 FS_FINDNEXT_END:
     MOV   A,@R0        ;get attribute
     MOV   C,ACC.0
     POP   ACC
RET

;--------------------------------------------------------------------
FS_LIST_ROOT:   ;list root directory
     MOV   A,#FS_ROOTINDEX
;--------------------------------------------------------------------
FS_LIST:        ;list files in directory - A = index in FAT
     PUSH  1
     PUSH  2
     PUSH  3    ;temp for R0
     PUSH  4    ;temp for dir
     PUSH  7    ;loop counter
     MOV   1,0
     MOV   4,A
     MOV   3,R0

     MOV   A,4
     CALL  FS_CALCULATE_OFFSET
     CALL  LCD_CLEARRAM

     MOV   A,#FS_FILESTRUCT_SIZE
     CALL  GETMEM       ;in: A       out: @R0

     MOV   7,#8
     MOV   R1,#LCDBUF
      FS_LIST_LOOP:
       MOV   A,4
       CALL  FS_FINDNEXT  ;in: R0, DPTR  out:A, DPTR, C if OK
       MOV   4,A
       JNC   FS_LIST_END  ;if file not found - end
       MOV   2,#8
       INC   R0
       CALL  COPY_RAM_RAM ;R0=source R1=dest 2=delka
       XCH   A,1
       ADD   A,#10-8
       XCH   A,1
       MOV   R0,3
      DJNZ  7,FS_LIST_LOOP
       CALL  LCD_WRITEBUF
       JNB   KEY_WAIT,$
       CLR   KEY_WAIT
       CALL  LCD_CLEARRAM
       MOV   7,#8
       MOV   R1,#LCDBUF
     JMP   FS_LIST_LOOP
FS_LIST_END:
     CALL  LCD_WRITEBUF
     JNB   KEY_WAIT,$
     CLR   KEY_WAIT
     MOV   A,#FS_FILESTRUCT_SIZE
     CALL  FREEMEM
     MOV   A,4
     POP   7
     POP   4
     POP   3
     POP   2
     POP   1
RET
;--------------------------------------------------------------------
FS_DEL:                 ;A   - index of directory
                        ;@R0 - filename
                        ;C = 1 -> OK
     CALL  FS_FILEENTRY ;return in A entry point
     JNC   FS_DEL_FAIL
     PUSH  DPH
     PUSH  DPL
;    CALL  FS_FAT_ERASE ;IN FUTURE
     MOV   B,#0         
     CALL  FS_FAT_WRITE ;clear space in FAT
     POP   DPL
     POP   DPH
     CLR   A
     CALL  MEM_BYTEWRITE
     SETB  C
FS_DEL_FAIL:
RET
;--------------------------------------------------------------------
FS_ADD_DPTR_A:          ;addition A with DPTR
     ADD   A,DPL
     MOV   DPL,A
     CLR   A
     ADDC  A,DPH
     MOV   DPH,A
RET
;--------------------------------------------------------------------
FS_SUBB_DPTR_A:         ;substarction DPTR-A
     CLR   C
     XCH   A,DPL
     SUBB  A,DPL
     XCH   A,DPL
     XCH   A,DPH
     SUBB  A,#0
     XCH   A,DPH
RET
;--------------------------------------------------------------------
FS_EDIT:
RET

FS_BYTEWRITE:		;A - index of FAT entry
			;DPTR points to memory
			;data in B
     PUSH  ACC
     MOV   A,B
     CALL  MEM_BYTEWRITE
     POP   ACC
;dodelat !!!
RET
