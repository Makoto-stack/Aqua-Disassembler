*-----------------------------------------------------------
* Title      : 68k Disassembler
* Written by : Aqua Axolotols
* Date       : 11/29/2020
* Description: I/O testing
*-----------------------------------------------------------
    ORG    $1000
START:
    
*subroutine to get and save starting location
get_start_loc
    LEA promptStart, A1 prompt user
    CLR.L   D2  make sure D2 is clear
    MOVE.B  #13, D0
    TRAP    #15
    LEA input, A1   get input
    MOVE.B  #2, D0
    TRAP    #15
    CMPI.B  #8, D1  check length
    BGT invalid_start
    BSR ascii_to_hex    convert to hex
    BTST    #0, D2  check last bit
    BNE invalid_start
    MOVE.L  D2, start_loc   save value

*subroutine to get and save ending location
get_end_loc    
    MOVE.B  #1, D7  keep track start or end address
    CLR.L   D2  make sure D2 is clear
    LEA promptEND, A1   prompt user
    MOVE.B  #13, D0
    TRAP    #15
    LEA input, A1   get input
    MOVE.B  #2, D0
    TRAP    #15
    CMPI.B  #8, D1  check length
    BGT invalid_end
    BSR ascii_to_hex    convert to hex
    BTST    #0, D2  check last bit
    BNE invalid_end
    CMP.L   start_loc, D2  make sure start < end
    BLE invalid_end
    MOVE.L  D2, end_loc save value
    JMP done    end I/O for now (will change later)

*ascii to hex subroutine
ascii_to_hex
    MOVE.B  (A1)+, D0   one byte of input
    CMP.B   #$30, D0
    BLT start_or_end    error message depending on address
    CMP.B   #$39, D0
    BGT ascii_to_letter
    SUBI.B  #$30, D0
    ASL.L   #4, D2
    ADD.L   D0, D2
    SUBI.W  #1, D1
    BNE ascii_to_hex
    RTS

*ascii to letter subroutine    
ascii_to_letter
    CMP.B   #$41, D0
    BLT start_or_end    error message depending on address
    CMP.B   #$46, D0
    BGT start_or_end    error message depending on address
    SUBI.B  #$37, D0
    ASL.L   #4, D2
    ADD.L   D0, D2
    SUBI.W  #1, D1
    BNE ascii_to_hex
    RTS

*error message for start or end address
start_or_end
    CMP.B   #1, D7
    BNE invalid_start
    BRA invalid_end

*error message for start
invalid_start
    BSR disp_error_message
    *JSR clear_registers
    BRA get_start_loc

*error message for end
invalid_end
    BSR disp_error_message
    *JSR clear_registers
    BRA get_end_loc

*error message dispay
disp_error_message
    LEA inputError, A1
    MOVE.B  #13, D0
    TRAP    #15
    RTS
    
done

*CR, LF, user input
CR  EQU $0D
LF  EQU $0A
input   EQU $500

*data and address storage
start_loc   DS.L    1
end_loc     DS.L    1

*I/O messages
promptStart DC.B    'Enter a starting address (8 hex digits):',CR,0
promptEnd   DC.B    'Enter an ending address (8 hex digits):',CR,0
inputError DC.B    'Invalid address. Must have < 9 hex digits, start_addr < end_addr, last bit even',CR,0

    END    START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
