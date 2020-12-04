*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program


*****JUMP TABLE*****
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
   
*****OPCODE SUBROUTINES*****
*
CODE0000

*MOVE.B
CODE0001

*MOVE.L,MOVEA.L
CODE0010

*MOVE.W,MOVEA.W
CODE0011

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

*ADD,ADDA,ADDX
CODE1101

*ROL,ROR,LSL,LSR,ASR,ASL
CODE1110

*SPECIAL
CODE1111


*****EA CODES*****



*****BUFFER*****


* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
