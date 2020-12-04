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
   MOVE.W (A3),D2       *get the address over to D2
   MOVE.W D2,D3         *copy it over to make changes
   LSR    #8,D3         *get the first four bits
   LSR    #4,D3
   MULU   #6,D3
   LEA    OPCODE_TABLE,A5  *load the index to the opcode table
   JSR    0(A5,D3)         *indirect jump using the index in the opcode table
   RTS

*****JUMP TABLE*****
*LOOK AT FIRST FOUR BITS AND DETERMINE WHICH OPCODE TO USE
OPCODE_TABLE
   JMP CODE0000
   JMP CODE0001
   JMP CODE0010
   JMP CODE0011
   JMP CODE0100
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



*MOVE.L,MOVEA.L
CODE0010


*MOVE.W,MOVEA.W
CODE0011
   *check which one to use but we need to figure out how to make that determination




*NOP,LEA
CODE0100

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


*****EA CODES*****



*****BUFFER*****

*****PRINT BAD DATA TO CONSOLE*****



*word



* Put variables and constants here
*****OPCODE_STRING*****



    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
