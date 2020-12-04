*-----------------------------------------------------------
* Title      : 68k Disassembler
* Written by : Aqua Axolotols
* Date       : 11/29/2020
* Description: I/O testing
*-----------------------------------------------------------
    ORG    $1000
START:

***
*this whole section is dedicated to I/O
*prints intro, asks user if they want to disassemble (loop)
*obtains start and end addresses, stores in memory
***

intro
    LEA introMsg, A1
    MOVE.B  #13, D0
    TRAP    #15
    BRA get_start_loc

disassemble_option
    LEA introOptionMsg, A1
    MOVE.B  #13, D0
    TRAP    #15
    MOVE.B  #5, D0
    TRAP    #15
    CMP.B   #$79, D1
    BNE done
    LEA newLine, A1
    MOVE.B  #13, D0
    TRAP    #15
    
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
    MOVE.L  D2, curr_loc    current location is start

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
    JSR clr_all_regs
    JMP read_memory begin reading memory

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
    BRA get_start_loc

*error message for end
invalid_end
    BSR disp_error_message
    BRA get_end_loc

*error message dispay
disp_error_message
    LEA inputError, A1
    MOVE.B  #13, D0
    TRAP    #15
    RTS

***
*the following section is where memory reading begins
***

*print address location
*obtain word of memory
*jump to table based on first nibble
read_memory
    JSR print_memory_location
    JMP done

*check if page needs to be advanced (30 lines)
advance_page

*check if ending address has been parsed
finish_disassembly

print_memory_location
    MOVE.L  curr_loc, D0    *load current address
    LSR.L   #8, D0
    LSR.L   #8, D0
    MOVE.W  D0, curr_word
    JSR print_word_of_memloc
    MOVE.L  curr_loc, D0
    MOVE.W  D0, curr_word
    JSR print_word_of_memloc
    JSR print_space
    RTS
    
print_word_of_memloc
    JSR isolate_first_nibble
    JSR hex_to_ascii
    JSR print_char_of_D1
    JSR isolate_second_nibble
    JSR hex_to_ascii
    JSR print_char_of_D1
    JSR isolate_third_nibble
    JSR hex_to_ascii
    JSR print_char_of_D1
    JSR isolate_fourth_nibble
    JSR hex_to_ascii
    JSR print_char_of_D1
    RTS
    
isolate_first_nibble
    MOVE.W  curr_word, D1
    LSR.W   #8, D1
    LSR.W   #4, D1
    ANDI.W  #$000F, D1
    MOVE.B  D1, curr_nibble
    RTS

isolate_second_nibble
    MOVE.W  curr_word, D1
    LSR.W   #8, D1
    ANDI.W  #$000F, D1
    MOVE.B  D1, curr_nibble
    RTS

isolate_third_nibble
    MOVE.W  curr_word, D1
    LSR.W   #4, D1
    ANDI.W  #$000F, D1
    MOVE.B  D1, curr_nibble
    RTS

isolate_fourth_nibble
    MOVE.W  curr_word, D1
    ANDI.W  #$000F, D1
    MOVE.B  D1, curr_nibble
    RTS
    
*subroutine for hex to ascii
hex_to_ascii
    CMPI.B  #$9,D1
    BGT     letter_to_ascii
num_to_ascii
    ADDI.B   #$30,D1
    RTS
letter_to_ascii
    ADDI.B   #$37,D1
    RTS

*subroutine for trap task 14    
print_char_of_D1
    CLR.L   D0
    MOVE.B      #6,D0
    TRAP        #15
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
    
*clear all registers
clr_all_regs
    JSR clr_addr_regs
    JSR clr_data_regs
    RTS

*subroutine to print a space    
print_space
    LEA printSpace, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS
    
done
    SIMHALT

*CR, LF, user input
CR  EQU $0D
LF  EQU $0A
input   EQU $500

*data and address storage
start_loc   DS.L    1
end_loc     DS.L    1
curr_loc    DS.L    1
curr_word   DS.W    1
curr_nibble DS.B    1

*I/O messages
introMsg   DC.B    'Welcome to the Motorola 68k disassembler!',CR,0
introOptionMsg  DC.B    'Type "y" to initiate disassembly, any other character to exit',CR,0
promptStart DC.B    'Enter a starting address (8 hex digits):',CR,0
promptEnd   DC.B    'Enter an ending address (8 hex digits):',CR,0
inputError DC.B    'Invalid address. Must have < 9 hex digits, start_addr < end_addr, last bit even',CR,0

*formatting
newLine DC.B    '',CR,0 use with trap task 13
printSpace  DC.B    ' ',CR,0 use with trap task 14

    END    START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
