*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

*****DECODE*****
DECODE
   CLR D2
   CLR D3
   MOVE.W   #$1082, A3
   MOVE.W (A3),D2       *get the address over to D2
   MOVE.W D2,D3         *copy it over to make changes
   LSR    #8,D3         *get the first four bits
   LSR    #4,D3
   MULU   #6,D3
   LEA    FIRST_NIBBLE_TABLE,A5  *load the index to the opcode table
   JSR    0(A5,D3)         *indirect jump using the index in the opcode table
   RTS

*****JUMP TABLE*****
*LOOK AT FIRST FOUR BITS AND DETERMINE WHICH OPCODE TO USE
FIRST_NIBBLE_TABLE
   JMP CODE0000
   JMP CODE0001 MOVE.B
   JMP CODE0010
   JMP CODE0011
   JMP CODE0100   NOP, RTS, LEA
   JMP CODE0101
   JMP CODE0110
   JMP CODE0111
   JMP CODE1000
   JMP CODE1001
   JMP CODE1011
   JMP CODE1100
   JMP CODE1101
   JMP CODE1110
   JMP CODE1111
   RTS

*****OPCODE SUBROUTINES*****
*
CODE0000

*MOVE.B
CODE0001
    LEA printMove, A1
    MOVE.B  #14, D0
    TRAP    #15
    LEA printB, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS

*MOVE.L,MOVEA.L
CODE0010


*MOVE.W,MOVEA.W
CODE0011
   *check which one to use but we need to figure out how to make that determination




*NOP,LEA
CODE0100
NOP_check
    CMP.W   #$4E71, D2
    BNE RTS_check
    MOVE.B  #14, D0
    LEA printNOP, A1
    TRAP    #15
    RTS
RTS_check
    CMP.W   #$4E75, D2
    BNE done
    MOVE.B  #14, D0
    LEA printRTS, A1
    TRAP    #15
    RTS

CODE0110

*ADDQ
CODE0101

*BRA,BCC(BGT,BLE,BEQ)
CODE0101

*MOVEQ
CODE0111

*OR
CODE1000

*SUB,SUBX
CODE1001

*UNASSIGNED
CODE1010

*CMP
CODE1011

*AND,MUL
CODE1100
*need to check when we multiply bits by six...


*ADD,ADDA,ADDX
CODE1101

*ROL,ROR,LSL,LSR,ASR,ASL
CODE1110

*SPECIAL
CODE1111

done

*****SECOND_JUMP_TABLE*****
SECOND_0100_TABLE
   JMP  CODE0100_0000
   JMP  CODE0100_0001
   JMP  CODE0100_0010
   JMP  CODE0100_0011
   JMP  CODE0100_0100
   JMP  CODE0100_0101
   JMP  CODE0100_0110
   JMP  CODE0100_0111
   JMP  CODE0100_1000
   JMP  CODE0100_1001
   JMP  CODE0100_1010
   JMP  CODE0100_1011
   JMP  CODE0100_1100
   JMP  CODE0100_1101
   JMP  CODE0100_1110
   JMP  CODE0100_1111

*****EA_CODE_TABLE*****
EA_CODE_TABLE
   JMP  EACODE000 *
   JMP  EACODE001
   JMP  EACODE010
   JMP  EACODE011
   JMP  EACODE100
   JMP  EACODE101  *BAD
   JMP  EACODE110  *BAD
   JMP  EACODE111
   
 EACODE000
   JSR  printDataRegister
   JSR  printRegisterNumber
   RTS
 
 EACODE001
   JSR  printAddressRegister
   JSR  printRegisterNumber
   RTS
 
 EACODE010
   JSR  printOpenBracket
   JSR  EACODE001
   JSR  printCloseBracker
   RTS
 
 EACODE011
   JSR  MODE_010
   JSR  printPlus
   RTS
 
 EACODE100
   JSR  printMinus
   JSR  EACODE010
   RTS
 
 EACODE101
    JMP BADINST
 
 EACODE110
    JMP BADINST
 
 EACODE111


*****HANDLE_INVALID*****
BADINST







* Put variables and constants here
*****OPCODE_STRING*****
printNOP           DC.B    'NOP',0
printRTS           DC.B    'RTS',0
printMove          DC.B    'MOVE',0
printB             DC.B     '.B ',0
printMinus         DC.B     '-',0
printPlus          DC.B     '+',0
printOpenBracket   DC.B     '(',0
printOpenBracket   DC.B     ')',0
printDataRegister  DC.B     'D',0
printRegisterNumber    DC.B    'R',0
printAddressNumber     DC.B    'A',0


    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
