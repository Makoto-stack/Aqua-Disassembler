*-----------------------------------------------------------
* Title      : Test Program
* Written by : Ira Yago, Makaoto Booth, Jamie Kim
* Date       : 11/11/20
* Description: Testing program for disassembler
*-----------------------------------------------------------
    ORG    $5000
START:      
        NOP

        MOVE.L  #1,D0
        MOVE.L  #11,D1
LOOP1   CMP.B   D0,D1      *For loop that loops 10 times
        BEQ     LOOP1END
        ADD.L   #1,D2      *Add 1 to D2
        ADDQ.L  #1,D0
        BRA     LOOP1
        
LOOP1END
        LEA     $6000,A0     *Load addr $6000 at A0
        ADDA.W  #$500,A0     *Change addr of A0 to $6500
        MOVEA.L A0,A1        *Copy A0 to A1
        MOVEQ.L #0,D0        *Clear D0
        MOVEQ.L #0,D1        *Clear D1
        MOVE.L  D2,D3        *Copy D2 to D3
        
        MOVEA.L A1,SP        *Load A1 into stack pointer
        JSR     do_test
        
        MOVE.L  D2,($6500)   *Copy D2 into $6500
        MOVE.L  D2,($22226500) *Copy D2 into $22226500
        
        MOVE.L  D4,D1        *Display value in D4
        MOVE.B  #3,D0    
        TRAP    #15
        
        JMP     continue         
do_test MOVEM.L A0/D2,-(SP)
        MOVE.L  #5,D3
        SUB.L   D3,D2
        MOVE.L  D2,D4        
        MOVEM.L (SP)+,A0/D2
exit    RTS

continue
        LSL     #4,D2       *Shift left a total of 3 hex digits
        ASL     #4,D2
        ROL     #4,D2
        
        LSR     #4,D2       *Shift right a total of 3 hex digits
        ASR     #4,D2
        ROR     #4,D2        
        
        MOVE.L  #%10111101,D2
        MOVE.L  #%11000011,D3
        MOVE.L  #%00111100,D4
        NOT.B   D2
        AND.W   D3,D2
        OR.W    D4,D2
* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
