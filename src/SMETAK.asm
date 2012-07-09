;smetiste:
FS_LIST_ROOT:   ;list root directory
     MOV   A,#FS_ROOTINDEX
FS_LIST:        ;list files in directory - A = index in FAT
     PUSH  6
     PUSH  DPH
     PUSH  DPL
     PUSH  7
   FS_LIST_LOOP2:
     MOV   6,A
     CALL  FS_CALCULATE_OFFSET
     CALL  LCD_CLEAR
     MOV   R0,#LCDBUF
     CALL  FS_LISTONE
     MOV   7,#3
   FS_LISTLOOP:

      XCH   A,DPL
      ADD   A,#16
      XCH   A,DPL
      XCH   A,DPH
      ADDC  A,#0
      XCH   A,DPH

      CALL  FS_LISTONE
     DJNZ  7,FS_LISTLOOP
     CALL  LCD_WRITEBUF

     MOV   A,6
     CALL  FS_FAT_NEXT
     MOV   6,A
   
     JNB   KEY_WAIT,$
     CLR   KEY_WAIT

     JNC   FS_LIST_LOOP2

     POP   7
     POP   DPL
     POP   DPH
     POP   6
RET

FS_LISTONE:                             ;return C if no valid file entry
     CALL  MEM_SETADDRESS
     CALL  MEM_BYTEREAD
     JB    ACC.0,FS_LISTONECONT         ;not empty
     SETB  C
     RET
   FS_LISTONECONT:
     CALL  WRITEHEX
     MOV   @R0,#' '
     INC   R0
     MOV   R1,#FS_FILENAME_LENGTH
     CALL  MEM_BLOCKREAD
     MOV   @R0,#' '
     INC   R0
     PUSH  7
     MOV   7,#4
   FS_LLOOP1:
      CALL  MEM_BYTEREAD
      CALL  WRITEHEX
     DJNZ  7,FS_LLOOP1
     POP   7
     CLR   C
RET

