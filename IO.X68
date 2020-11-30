*-----------------------------------------------------------
* Title      : 68k Disassembler
* Written by : Aqua Axolotols
* Date       : 11/29/2020
* Description: I/O testing
*-----------------------------------------------------------
    ORG    $1000
START:
    
get_start_loc
    LEA promptStart, A1 prompt user
    MOVE.B  #13, D0
    TRAP    #15
    LEA input, A1   get input
    MOVE.B  #2, D0
    TRAP    #15
    CMPI.B  #8, D1  check length
    BGT invalid_start

get_end_loc    
    LEA promptEND, A1   prompt user
    MOVE.B  #13, D0
    TRAP    #15
    LEA input, A1   get input
    MOVE.B  #2, D0
    TRAP    #15
    CMPI.B  #8, D1  check length
    BGT invalid_end
    JMP done

ascii_to_hex

invalid_start
    BSR disp_error_message
    BRA get_start_loc

invalid_end
    BSR disp_error_message
    BRA get_end_loc

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
inputError DC.B    'Invalid address. Format: < 9 hex digits and start_addr < end_addr',CR,0

    END    START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
