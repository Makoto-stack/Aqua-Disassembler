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
    LEA finishedMsg, A1
    MOVE.B  #13, D0
    TRAP    #15
    LEA introOptionMsg, A1
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
    JSR clr_all_regs
    LEA promptStart, A1 prompt user
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
*end of I/O section
***

***
*the following section is where memory reading begins
***

*print address location
*obtain word of memory
*jump to table based on first nibble
read_memory
    JSR print_memory_location
    MOVE.L  curr_loc, A0
    MOVE.W  (A0), curr_four_nibbles
    MOVE.W  curr_four_nibbles, D0
    LSR.L   #8, D0
    LSR.L   #4, D0
    MULU    #6, D0
    LEA FIRST_NIBBLE_TABLE, A1
    JSR 0(A1, D0)
    JSR increment_by_word

*check if page needs to be advanced (30 lines)
advance_page
    *JMP done    temporarily branches to done

*check if ending address has been parsed
finish_disassembly
    *some type of check here
    JMP disassemble_option

*subroutine to increment curr_loc
increment_by_word
    MOVE.L  curr_loc, D0
    ADDI.W   #$2, D0
    MOVE.L  D0, curr_loc
    RTS

***
*end of memory reading section
***

***
*beginning of parsing opword subroutines
***

*****JUMP TABLE*****
*LOOK AT FIRST FOUR BITS AND DETERMINE WHICH OPCODE TO USE
FIRST_NIBBLE_TABLE
   JMP CODE0000 not supported
   JMP CODE0001 MOVE.B
   JMP CODE0010 MOVE.L, MOVEA.L
   JMP CODE0011 MOVE.W, MOVEA.W
   JMP CODE0100 NOP, JSR, LEA, MOVEM, NOT, RTS
   JMP CODE0101 ADDQ
   JMP CODE0110 BRA, BGT, BLE, BEQ
   JMP CODE0111 MOVEQ
   JMP CODE1000 OR
   JMP CODE1001 SUB
   JMP CODE1010 not supported
   JMP CODE1011 not supported
   JMP CODE1100 AND
   JMP CODE1101 ADD, ADDA
   JMP CODE1110 LSR, LSL, ASR, ASL, ROR, ROL
   JMP CODE1111 not supported
   

*not supported
CODE0000
    JSR print_data
    RTS

*MOVE.B
CODE0001
    JSR print_data
    RTS

*MOVE.L, MOVEA.L
CODE0010
    JSR print_data
    RTS

*MOVE.W, MOVEA.W
CODE0011
    JSR print_data
    RTS

*NOP, JSR, LEA, MOVEM, NOT, RTS
CODE0100
NOP_check
    MOVE.W  curr_four_nibbles, D1
    CMP.W   #$4E71, D1
    BNE RTS_check
    MOVE.B  #13, D0
    LEA printNOP, A1
    TRAP    #15
    RTS
RTS_check
    MOVE.W  curr_four_nibbles, D1
    CMP.W   #$4E75, D1
    BNE done
    MOVE.B  #13, D0
    LEA printRTS, A1
    TRAP    #15
    RTS

*ADDQ
CODE0101
    JSR print_data
    RTS

*BRA, BGT, BLE, BEQ
CODE0110
    JSR print_data
    RTS

*MOVEQ
CODE0111
    JSR print_data
    RTS

*OR
CODE1000
    JSR print_data
    RTS

*SUB
CODE1001
    JSR print_data
    RTS

*not supported
CODE1010
    JSR print_data
    RTS

*not supported
CODE1011
    JSR print_data
    RTS

*AND
CODE1100
    JSR print_data
    RTS

*ADD, ADDA
CODE1101
    JSR print_data
    RTS

*LSR, LSL, ASR, ASL, ROR, ROL
CODE1110
    JSR print_data
    RTS

*not supported
CODE1111
    JSR print_data
    RTS


*put any needed subroutines/jump tables for size, register, EA mode below here


*put any needed printing subroutines below here


***
*beginning of print memory specific subroutines
***
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
    
*isolate subroutines are for printing memory location
isolate_first_nibble
    MOVE.W  curr_word, D1
    LSR.W   #8, D1
    LSR.W   #4, D1
    ANDI.W  #$000F, D1
    RTS

isolate_second_nibble
    MOVE.W  curr_word, D1
    LSR.W   #8, D1
    ANDI.W  #$000F, D1
    RTS

isolate_third_nibble
    MOVE.W  curr_word, D1
    LSR.W   #4, D1
    ANDI.W  #$000F, D1
    RTS

isolate_fourth_nibble
    MOVE.W  curr_word, D1
    ANDI.W  #$000F, D1
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
    
***
*end of print memory specific subroutines
***

***
*beginning of printing subroutines
***

*print data if cannot decode
print_data
    LEA printData, A1
    MOVE.B  #14, D0
    TRAP    #15
    JSR print_word_of_data
    JSR print_line
    RTS
    
print_word_of_data
    JSR get_first_nibble
    JSR hex_to_ascii
    JSR print_char_of_D1
    JSR get_second_nibble
    JSR hex_to_ascii
    JSR print_char_of_D1
    JSR get_third_nibble
    JSR hex_to_ascii
    JSR print_char_of_D1
    JSR get_fourth_nibble
    JSR hex_to_ascii
    JSR print_char_of_D1
    RTS

*subroutine for trap task 14    
print_char_of_D1
    CLR.L   D0
    MOVE.B      #6,D0
    TRAP        #15
    RTS
    
*subroutine to print a space    
print_space
    LEA printSpace, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS
    
*subroutine to print a line
print_line
    LEA newLine, A1
    MOVE.B  #13, D0
    TRAP    #15
    RTS
    
***
*end of printing subroutines
***
    
***
*beginning of miscellaneous subroutines
***
    
*get subroutines are for printing data in memory
get_first_nibble
    MOVE.W  curr_four_nibbles, D1
    LSR.W   #8, D1
    LSR.W   #4, D1
    ANDI.W  #$000F, D1
    RTS

get_second_nibble
    MOVE.W  curr_four_nibbles, D1
    LSR.W   #8, D1
    ANDI.W  #$000F, D1
    RTS

get_third_nibble
    MOVE.W  curr_four_nibbles, D1
    LSR.W   #4, D1
    ANDI.W  #$000F, D1
    RTS

get_fourth_nibble
    MOVE.W  curr_four_nibbles, D1
    ANDI.W  #$000F, D1
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
    
***
*end of miscellaneous subroutines
***
    
done
    SIMHALT

*CR, LF, user input
CR  EQU $0D
LF  EQU $0A
input   EQU $500

* Put variables and constants here
*****OPCODE_STRING*****
printDATA   DC.B    'DATA ',0
printNOP           DC.B    'NOP',0
printRTS           DC.B    'RTS',0
printMove          DC.B    'MOVE',0
printB             DC.B     '.B ',0
printMinus         DC.B     '-',0
printPlus          DC.B     '+',0
printOpenBracket   DC.B     '(',0
printCloseBracket   DC.B     ')',0
printDataRegister  DC.B     'D',0
printRegisterNumber    DC.B    'R',0
printAddressNumber     DC.B    'A',0

*data and address storage
start_loc   DS.L    1
end_loc     DS.L    1
curr_loc    DS.L    1
curr_word   DS.W    1   used for printing memory location
curr_four_nibbles   DS.W    1   used to store actual data in memory
curr_nibble DS.B    1   stores one nibble
line_counter    DS.B    1   stores lines, advance page based on this value

*I/O messages
introMsg   DC.B    'Welcome to the Motorola 68k disassembler!',CR,0
introOptionMsg  DC.B    'Type "y" to initiate disassembly, any other character to exit:',CR,0
finishedMsg DC.B    'Finished disassembly.',CR,0
promptStart DC.B    'Enter a starting address (8 hex digits):',CR,0
promptEnd   DC.B    'Enter an ending address (8 hex digits):',CR,0
inputError DC.B    'Invalid address. Must have < 9 hex digits, start_addr < end_addr, last bit even',CR,0

*formatting
newLine DC.B    '',0 use with trap task 13
printSpace  DC.B    ' ',0 use with trap task 14

    END    START
    
    
    
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
