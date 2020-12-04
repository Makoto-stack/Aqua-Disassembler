*-----------------------------------------------------------
* Title      : potentially useful subroutines
* Written by : Aqua Axolotls
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program


*useful for printing out instruction addresses, effective addresses
*ascii value will need to be in D1, print with trap task 6
hex_to_ascii
    CMPI.B  #$9,D3
    BGT     letter_to_ascii
num_to_ascii
    ADDI.B   #$30,D3
    RTS
letter_to_ascii
    ADDI.B   #$37,D3
    RTS
    
*clear address registers
clr_addr_regs
    MOVE.L  #0,A0
    MOVE.L  #0,A1
    MOVE.L  #0,A2
    MOVE.L  #0,A3
    MOVE.L  #0,A4
    MOVE.L  #0,A5
    MOVE.L  #0,A6
    RTS

*clear data registers
clr_data_regs
    CLR.L   D0
    CLR.L   D1
    CLR.L   D2
    CLR.L   D3
    CLR.L   D4
    CLR.L   D5
    CLR.L   D6
    CLR.L   D7
    RTS
    


done
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
