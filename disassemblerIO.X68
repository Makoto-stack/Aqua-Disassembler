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
    JMP prepare_buffer begin reading memory

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

*set line counter to 30
prepare_buffer
    JSR refresh_nibbles
    MOVE.B  #30, line_counter
    MOVE.B  #11, D0 clear screen
    MOVE.W  #$FF00, D1
    TRAP    #15

*print address location
*obtain word of memory
*jump to table based on first nibble
read_memory
    JSR print_memory_location
    MOVE.W  curr_four_nibbles, D0
    ANDI.L  #$0000FFFF, D0
    LSR.W   #8, D0
    LSR.W   #4, D0
    MULU    #6, D0
    LEA FIRST_NIBBLE_TABLE, A1
    JSR 0(A1, D0)
    JSR print_line
    JSR increment_by_word
    
*check if page needs to be advanced (30 lines)
advance_page_check
    SUBI.B  #1, line_counter
    BEQ advance_page
    BRA finish_disassembly

*advances page
advance_page
    MOVE.B  #30, line_counter
    LEA promptEnter, A1
    MOVE.B  #13, D0
    TRAP    #15
    MOVE.B  #5, D0
    TRAP    #15
    MOVE.B  #11, D0
    MOVE.W  #$FF00, D1
    TRAP    #15

*check if ending address has been parsed
finish_disassembly
    MOVE.L  curr_loc, D0
    MOVE.L  end_loc, D1
    CMP.L   D1, D0
    BGT disassemble_option
    JMP read_memory

*subroutine to increment curr_loc
increment_by_word
    MOVE.L  curr_loc, D0
    ADDI.W   #$2, D0
    MOVE.L  D0, curr_loc
    JSR refresh_nibbles
    RTS
    
*subroutine to refresh curr_four_nibbles
refresh_nibbles
    MOVE.L  curr_loc, A0
    MOVE.W  (A0), curr_four_nibbles
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
    JSR print_NOP
    RTS

RTS_check
    MOVE.W  curr_four_nibbles, D1
    CMP.W   #$4E75, D1
    BNE LEA_check
    JSR print_RTS
    RTS

LEA_check
    MOVE.W  curr_four_nibbles, D1
    JSR load_bit_triples
    ANDI.W  #$01C0, D1
    LSR.W   #6,D1
    CMP.W   #$7,D1
    BNE     NOT_check
    MOVE.B  bits3to5, D1
    CMP.B   #2, D1
    BEQ LEA_EA_010
    CMP.B   #7, D1
    BEQ LEA_EA_111
    JSR print_data
    RTS
LEA_EA_010
    JSR print_LEA
    JSR print_open_paren
    JSR print_A
    MOVE.B  bits0to2, D1
    JSR hex_to_ascii
    JSR print_char_of_D1
    JSR print_close_paren
    JSR print_comma
    JSR print_A
    MOVE.B  bits9to11, D1
    JSR hex_to_ascii
    JSR print_char_of_D1
    RTS
LEA_EA_111
    MOVE.B  bits0to2, D1
    CMP.B   #0, D1
    BEQ LEA_EA_111_W
    CMP.B   #1, D1
    BEQ LEA_EA_111_L
    JSR print_data
    RTS
LEA_EA_111_W
    JSR print_LEA
    JSR print_$
    JSR increment_by_word
    JSR print_word_of_data
    JSR print_comma
    JSR print_A
    MOVE.B  bits9to11, D1
    JSR hex_to_ascii
    JSR print_char_of_D1
    RTS
LEA_EA_111_L
    JSR print_LEA
    JSR print_$
    JSR increment_by_word
    JSR print_longword_of_data
    JSR print_comma
    JSR print_A
    MOVE.B  bits9to11, D1
    JSR hex_to_ascii
    JSR print_char_of_D1
    RTS

NOT_check
    MOVE.W  curr_four_nibbles, D1
    JSR load_bit_triples 
    LSR.W   #8,D1
    CMP.W   #$0046,D1
    BNE     JSR_check
    MOVE.B  bits3to5, D1
    CMP.B   #7, D1
    BEQ NOT_absolute_check
    BRA NOT_check_2
NOT_absolute_check
    MOVE.B  bits0to2, D1
    CMP.B   #1, D1
    BGT NOT_absolute_fail
    BRA NOT_check_2
NOT_absolute_fail
    JSR print_data
    RTS
NOT_check_2
    MOVE.B  bits6to8, D1
    ANDI.B  #$3, D1
    CMP.B   #1, D1
    BLT print_NOTB
    BEQ print_NOTW
    CMP.B   #2, D1
    BEQ print_NOTL
    JSR print_data
    RTS
print_NOTB
    JSR print_NOT
    JSR print_B
    BRA NOT_check_3
print_NOTW
    JSR print_NOT
    JSR print_W
    BRA NOT_check_3
print_NOTL
    JSR print_NOT
    JSR print_L
    BRA NOT_check_3
NOT_check_3
    MOVE.B  bits3to5, D1
    ANDI.L  #%111, D1
    MULU    #6, D1
    LEA NOT_EA_table, A2
    JSR 0(A2, D1)
    RTS
NOT_EA_table
    JMP NOT_EA_000
    JMP NOT_EA_001
    JMP NOT_EA_010
    JMP NOT_EA_011
    JMP NOT_EA_100
    JMP NOT_EA_101
    JMP NOT_EA_110
    JMP NOT_EA_111
NOT_EA_000
    JSR print_D
    MOVE.B  bits0to2, D1
    JSR hex_to_ascii
    JSR print_char_of_D1
    RTS
NOT_EA_001
    JSR print_data
    RTS
NOT_EA_010
    JSR print_open_paren
    JSR print_A
    MOVE.B  bits0to2, D1
    JSR hex_to_ascii
    JSR print_char_of_D1
    JSR print_close_paren
    RTS
NOT_EA_011
    JSR NOT_EA_010
    JSR print_plus
    RTS
NOT_EA_100
    JSR print_minus
    JSR NOT_EA_010
    RTS
NOT_EA_101
    JSR print_data
    RTS
NOT_EA_110
    JSR print_data
    RTS
NOT_EA_111
    MOVE.B  bits0to2, D1
    CMP.B   #1, D1
    BEQ NOT_EA_111_L
    BLT NOT_EA_111_W
    JSR print_data
    RTS
NOT_EA_111_W
    JSR print_$
    JSR increment_by_word
    JSR print_word_of_data
    RTS
NOT_EA_111_L
    JSR print_$
    JSR increment_by_word
    JSR print_longword_of_data
    RTS

JSR_check
    MOVE.W  curr_four_nibbles, D1
    JSR load_bit_triples
    LSR.W    #6,D1
    CMP.W   #$013A,D1
    BNE CODE0100_fail *will change to BNE MOVEM_check at some point, MOVEM will branch to CODE0100_fail
    MOVE.B  bits3to5, D1
    CMP.B   #7, D1
    BEQ JSR_absolute_check
    BRA JSR_check_2
JSR_absolute_check
    MOVE.B  bits0to2, D1
    CMP.B   #1, D1
    BGT JSR_absolute_fail
    BRA JSR_check_2
JSR_absolute_fail
    JSR print_data
    RTS
JSR_check_2
    MOVE.B  bits3to5, D1
    CMP.B   #2, D1
    BEQ JSR_EA_010
    CMP.B   #7, D1
    BEQ JSR_EA_111
    JSR print_data
    RTS
JSR_EA_010
    JSR print_JSR
    JSR print_open_paren
    JSR print_A
    MOVE.B  bits0to2, D1
    JSR hex_to_ascii
    JSR print_char_of_D1
    JSR print_close_paren
    RTS
JSR_EA_111
    MOVE.B  bits0to2, D1
    CMP.B   #1, D1
    BEQ JSR_EA_111_L
    BLT JSR_EA_111_W
    JSR print_data
    RTS
JSR_EA_111_W
    JSR print_JSR
    JSR print_$
    JSR increment_by_word
    JSR print_word_of_data
    RTS
JSR_EA_111_L
    JSR print_JSR
    JSR print_$
    JSR increment_by_word
    JSR print_longword_of_data
    RTS
    
CODE0100_fail
    JSR print_data
    RTS

*ADDQ
CODE0101
    JSR print_data
    RTS

*BRA, BGT, BLE, BEQ
CODE0110
    MOVE.W  curr_four_nibbles, D1
    LSR.W   #8, D1
    ANDI.W  #$000F, D1
    CMP.W   #0, D1    *Check if BRA
    BEQ     BRA_check
    CMP.W   #$E, D1   *Check if BGT
    BEQ     BGT_check
    CMP.W   #$F, D1   *Check if BLE
    BEQ     BLE_check
    CMP.W   #$7, D1   *Check if BEQ
    BEQ     BEQ_check
    JSR     print_data
    RTS
    
BRA_check
    MOVE.W  curr_four_nibbles, D1
    CMP.B   #$00, D1
    BEQ BRA_16_bit
    CMP.B   #$FF, D1
    BEQ BRA_32_bit
BRA_8_bit
    MOVE.L  curr_loc, D2
    MOVE.W  curr_four_nibbles, D3
    ANDI.L  #$000000FF, D3
    CMP.B   #0, D3
    BGE BRA_8_bit_add
    SUBI.B  #1, D3
    NOT.B   D3
    SUB.L   D3, D2
    ADD.L   #2, D2
    BRA BRA_8_bit_abs
BRA_8_bit_add
    ADD.L   D3, D2
    ADD.L   #2, D2
BRA_8_bit_abs
    MOVE.L  D2, abs_address
    JSR print_BRA
    JSR print_B
    JSR print_$
    LSR.L   #8, D2
    LSR.L   #8, D2
    MOVE.W  D2, curr_four_nibbles
    JSR print_word_of_data
    MOVE.L  abs_address, D2
    MOVE.W  D2, curr_four_nibbles
    JSR print_word_of_data
    RTS
BRA_16_bit
    JSR increment_by_word
    MOVE.L  curr_loc, D2
    MOVE.W  curr_four_nibbles, D3
    ANDI.L  #$0000FFFF, D3
    CMP.W   #0, D3
    BGE BRA_16_bit_add
    SUBI.W  #1, D3
    NOT.W   D3
    SUB.L   D3, D2
    BRA BRA_16_bit_abs
BRA_16_bit_add
    ADD.L   D3, D2
BRA_16_bit_abs
    MOVE.L  D2, abs_address
    JSR print_BRA
    JSR print_W
    JSR print_$
    LSR.L   #8, D2
    LSR.L   #8, D2
    MOVE.W  D2, curr_four_nibbles
    JSR print_word_of_data
    MOVE.L  abs_address, D2
    MOVE.W  D2, curr_four_nibbles
    JSR print_word_of_data
    RTS
BRA_32_bit
    JSR print_data not supported
    RTS

BGT_check
    MOVE.W  curr_four_nibbles, D1
    CMP.B   #$00, D1
    BEQ BGT_16_bit
    CMP.B   #$FF, D1
    BEQ BGT_32_bit
BGT_8_bit
    MOVE.L  curr_loc, D2
    MOVE.W  curr_four_nibbles, D3
    ANDI.L  #$000000FF, D3
    CMP.B   #0, D3
    BGE BGT_8_bit_add
    SUBI.B  #1, D3
    NOT.B   D3
    SUB.L   D3, D2
    ADD.L   #2, D2
    BRA BGT_8_bit_abs
BGT_8_bit_add
    ADD.L   D3, D2
    ADD.L   #2, D2
BGT_8_bit_abs
    MOVE.L  D2, abs_address
    JSR print_BGT
    JSR print_B
    JSR print_$
    LSR.L   #8, D2
    LSR.L   #8, D2
    MOVE.W  D2, curr_four_nibbles
    JSR print_word_of_data
    MOVE.L  abs_address, D2
    MOVE.W  D2, curr_four_nibbles
    JSR print_word_of_data
    RTS
BGT_16_bit
    JSR increment_by_word
    MOVE.L  curr_loc, D2
    MOVE.W  curr_four_nibbles, D3
    ANDI.L  #$0000FFFF, D3
    CMP.W   #0, D3
    BGE BGT_16_bit_add
    SUBI.W  #1, D3
    NOT.W   D3
    SUB.L   D3, D2
    BRA BGT_16_bit_abs
BGT_16_bit_add
    ADD.L   D3, D2
BGT_16_bit_abs
    MOVE.L  D2, abs_address
    JSR print_BGT
    JSR print_W
    JSR print_$
    LSR.L   #8, D2
    LSR.L   #8, D2
    MOVE.W  D2, curr_four_nibbles
    JSR print_word_of_data
    MOVE.L  abs_address, D2
    MOVE.W  D2, curr_four_nibbles
    JSR print_word_of_data
    RTS
BGT_32_bit
    JSR print_data not supported
    RTS

BLE_check
    MOVE.W  curr_four_nibbles, D1
    CMP.B   #$00, D1
    BEQ BLE_16_bit
    CMP.B   #$FF, D1
    BEQ BLE_32_bit
BLE_8_bit
    MOVE.L  curr_loc, D2
    MOVE.W  curr_four_nibbles, D3
    ANDI.L  #$000000FF, D3
    CMP.B   #0, D3
    BGE BLE_8_bit_add
    SUBI.B  #1, D3
    NOT.B   D3
    SUB.L   D3, D2
    ADD.L   #2, D2
    BRA BLE_8_bit_abs
BLE_8_bit_add
    ADD.L   D3, D2
    ADD.L   #2, D2
BLE_8_bit_abs
    MOVE.L  D2, abs_address
    JSR print_BLE
    JSR print_B
    JSR print_$
    LSR.L   #8, D2
    LSR.L   #8, D2
    MOVE.W  D2, curr_four_nibbles
    JSR print_word_of_data
    MOVE.L  abs_address, D2
    MOVE.W  D2, curr_four_nibbles
    JSR print_word_of_data
    RTS
BLE_16_bit
    JSR increment_by_word
    MOVE.L  curr_loc, D2
    MOVE.W  curr_four_nibbles, D3
    ANDI.L  #$0000FFFF, D3
    CMP.W   #0, D3
    BGE BLE_16_bit_add
    SUBI.W  #1, D3
    NOT.W   D3
    SUB.L   D3, D2
    BRA BLE_16_bit_abs
BLE_16_bit_add
    ADD.L   D3, D2
BLE_16_bit_abs
    MOVE.L  D2, abs_address
    JSR print_BLE
    JSR print_W
    JSR print_$
    LSR.L   #8, D2
    LSR.L   #8, D2
    MOVE.W  D2, curr_four_nibbles
    JSR print_word_of_data
    MOVE.L  abs_address, D2
    MOVE.W  D2, curr_four_nibbles
    JSR print_word_of_data
    RTS
BLE_32_bit
    JSR print_data not supported
    RTS

BEQ_check
    MOVE.W  curr_four_nibbles, D1
    CMP.B   #$00, D1
    BEQ BEQ_16_bit
    CMP.B   #$FF, D1
    BEQ BEQ_32_bit
BEQ_8_bit
    MOVE.L  curr_loc, D2
    MOVE.W  curr_four_nibbles, D3
    ANDI.L  #$000000FF, D3
    CMP.B   #0, D3
    BGE BEQ_8_bit_add
    SUBI.B  #1, D3
    NOT.B   D3
    SUB.L   D3, D2
    ADD.L   #2, D2
    BRA BEQ_8_bit_abs
BEQ_8_bit_add
    ADD.L   D3, D2
    ADD.L   #2, D2
BEQ_8_bit_abs
    MOVE.L  D2, abs_address
    JSR print_BEQ
    JSR print_B
    JSR print_$
    LSR.L   #8, D2
    LSR.L   #8, D2
    MOVE.W  D2, curr_four_nibbles
    JSR print_word_of_data
    MOVE.L  abs_address, D2
    MOVE.W  D2, curr_four_nibbles
    JSR print_word_of_data
    RTS
BEQ_16_bit
    JSR increment_by_word
    MOVE.L  curr_loc, D2
    MOVE.W  curr_four_nibbles, D3
    ANDI.L  #$0000FFFF, D3
    CMP.W   #0, D3
    BGE BEQ_16_bit_add
    SUBI.W  #1, D3
    NOT.W   D3
    SUB.L   D3, D2
    BRA BEQ_16_bit_abs
BEQ_16_bit_add
    ADD.L   D3, D2
BEQ_16_bit_abs
    MOVE.L  D2, abs_address
    JSR print_BEQ
    JSR print_W
    JSR print_$
    LSR.L   #8, D2
    LSR.L   #8, D2
    MOVE.W  D2, curr_four_nibbles
    JSR print_word_of_data
    MOVE.L  abs_address, D2
    MOVE.W  D2, curr_four_nibbles
    JSR print_word_of_data
    RTS
BEQ_32_bit
    JSR print_data not supported
    RTS

*MOVEQ
CODE0111
    *check if bit 8 is 0, if not then print data
    *other wise, bits9to11 are data reg to transfer to
    *bits 0 through 7 are byte to transfer -- add 1 to most significant (sign extend)
    *do this by moving 1 to a data register, shifting left to bit 8, then moving
    *bits 0 through 7 to the same register
    *then the .B of the reg will contain the immediate value to move, use hex_to_ascii
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
    JSR load_bit_triples
    MOVE.B  bits6to8, D1    *checking bits 6 and 7 (mem relevant)
    ANDI.B  #$3, D1
    MOVE.B  D1, op_size
    CMP.B   #3, D1
    BEQ CODE1110_mem_check
    MOVE.B  bits3to5, D1    *checking bits 3 and 4 (reg)
    ANDI.B  #$3, D1
    CMP.B   #1, D1
    BEQ LS_check
    CMP.B   #0, D1
    BEQ AS_check
    CMP.B   #3, D1
    BEQ RO_check
    JSR print_data
    RTS
CODE1110_mem_check
    MOVE.W  curr_four_nibbles, D1
    LSR.W   #8, D1
    LSR.W   #1, D1
    CMP.W   #$71, D1
    BEQ LS_memory
    CMP.W   #$70, D1
    BEQ AS_memory
    CMP.W   #$73, D1
    BEQ RO_memory
    JSR print_data
    RTS

LS_check
    MOVE.B  bits6to8, D1
    ANDI.B  #$3, D1
    MOVE.B  D1, op_size
    CMP.B   #3, D1
    BEQ LS_memory   *reuse code somewhere around here for AS, RO? (memory)
LS_register *LS register mode
    MOVE.B  bits6to8, D1
    ANDI.B  #$4, D1
    LSR.B   #2, D1
    MOVE.B  D1, dr
    MOVE.B  bits3to5, D1
    ANDI.B  #$4, D1
    LSR.B   #2, D1
    MOVE.B  D1, ir
    JSR print_LS
shift_reuse
    MOVE.B  dr, D1  reuse code from here for AS, RO? (register)
    CMP.B   #1, D1
    BEQ LSL_register_pre
    JMP LSR_register
LSL_register_pre
    JSR print_left
LSL_register
    MOVE.B  op_size, D1
    CMP.B   #1, D1
    BLT LSL_register_B
    BEQ LSL_register_W
    BGT LSL_register_L
LSL_register_B
    JSR print_B
    BRA LSL_register_ir_check
LSL_register_W
    JSR print_W
    BRA LSL_register_ir_check
LSL_register_L
    JSR print_L
    BRA LSL_register_ir_check
LSL_register_ir_check
    MOVE.B  ir, D1
    CMP.B   #0, D1
    BEQ LSL_register_ir_0
    BRA LSL_register_ir_1
LSL_register_ir_0
    JSR print_hashtag
    MOVE.B  bits9to11, D1
    CMP.B   #0, D1
    BEQ LSL_register_ir_0_8
    BRA LSL_register_ir_0_other
LSL_register_ir_0_8
    MOVE.B  #8, D1
    JSR hex_to_ascii
    JSR print_char_of_D1
    JSR print_comma
    JSR print_D
    MOVE.B  bits0to2, D1
    JSR hex_to_ascii
    JSR print_char_of_D1
    RTS
LSL_register_ir_0_other
    MOVE.B  bits9to11, D1
    JSR hex_to_ascii
    JSR print_char_of_D1
    JSR print_comma
    JSR print_D
    MOVE.B  bits0to2, D1
    JSR hex_to_ascii
    JSR print_char_of_D1
    RTS
LSL_register_ir_1
    JSR print_D
    MOVE.B  bits9to11, D1
    JSR hex_to_ascii
    JSR print_char_of_D1
    JSR print_comma
    JSR print_D
    MOVE.B  bits0to2, D1
    JSR hex_to_ascii
    JSR print_char_of_D1
    RTS
LSR_register
    JSR print_right
    JMP LSL_register apart from direction, exactly the same
LS_memory   *LS memory mode
    MOVE.B  bits3to5, D1
    CMP.B   #2, D1
    BEQ LS_memory_010
    CMP.B   #3, D1
    BEQ LS_memory_011
    CMP.B   #4, D1
    BEQ LS_memory_100
    CMP.B   #7, D1
    BEQ LS_memory_111
    BRA LS_invalid
LS_memory_010
    JSR print_LS
AS_RO_010
    JSR LS_memory_dr
    JSR print_W
    JSR print_space
    JSR print_open_paren
    JSR print_A
    MOVE.B  bits0to2, D1
    JSR hex_to_ascii
    JSR print_char_of_D1
    JSR print_close_paren
    RTS
LS_memory_011
    JSR print_LS
AS_RO_011
    JSR LS_memory_dr
    JSR print_W
    JSR print_space
    JSR print_open_paren
    JSR print_A
    MOVE.B  bits0to2, D1
    JSR hex_to_ascii
    JSR print_char_of_D1
    JSR print_close_paren
    JSR print_plus
    RTS
LS_memory_100
    JSR print_LS
AS_RO_100
    JSR LS_memory_dr
    JSR print_W
    JSR print_space
    JSR print_minus
    JSR print_open_paren
    JSR print_A
    MOVE.B  bits0to2, D1
    JSR hex_to_ascii
    JSR print_char_of_D1
    JSR print_close_paren
    RTS
LS_memory_111
    MOVE.B  bits0to2, D1
    CMP.B   #1, D1
    BGT LS_invalid
    BLT LS_memory_111_W
    BEQ LS_memory_111_L
LS_memory_111_W
    JSR print_LS
AS_RO_111_W
    JSR LS_memory_dr
    JSR print_W
    JSR print_space
    JSR print_$
    JSR increment_by_word
    JSR print_word_of_data
    RTS
LS_memory_111_L
    JSR print_LS
AS_RO_111_L
    JSR LS_memory_dr
    JSR print_W
    JSR print_space
    JSR print_$
    JSR increment_by_word
    JSR print_longword_of_data
    RTS
LS_memory_dr
    MOVE.B  bits6to8, D1
    ANDI.B  #$4, D1
    LSR.B   #2, D1
    MOVE.B  D1, dr
    CMP.B   #1, D1
    BEQ LS_memory_L
    BRA LS_memory_R
LS_memory_L
    JSR print_left
    RTS
LS_memory_R
    JSR print_right
    RTS
LS_invalid
    JSR print_data
    RTS

AS_check
    MOVE.B  bits6to8, D1
    ANDI.B  #$3, D1
    MOVE.B  D1, op_size
    CMP.B   #3, D1
    BEQ AS_memory
AS_register
    MOVE.B  bits6to8, D1
    ANDI.B  #$4, D1
    LSR.B   #2, D1
    MOVE.B  D1, dr
    MOVE.B  bits3to5, D1
    ANDI.B  #$4, D1
    LSR.B   #2, D1
    MOVE.B  D1, ir
    JSR print_AS
    JMP shift_reuse
AS_memory
    MOVE.B  bits3to5, D1
    CMP.B   #2, D1
    BEQ AS_memory_010
    CMP.B   #3, D1
    BEQ AS_memory_011
    CMP.B   #4, D1
    BEQ AS_memory_100
    CMP.B   #7, D1
    BEQ AS_memory_111
    BRA LS_invalid
AS_memory_010
    JSR print_AS
    BRA AS_RO_010
AS_memory_011
    JSR print_AS
    BRA AS_RO_011
AS_memory_100
    JSR print_AS
    BRA AS_RO_100
AS_memory_111
    MOVE.B  bits0to2, D1
    CMP.B   #1, D1
    BGT LS_invalid
    BLT AS_memory_111_W
    BEQ AS_memory_111_L
AS_memory_111_W
    JSR print_AS
    BRA AS_RO_111_W
AS_memory_111_L
    JSR print_AS
    BRA AS_RO_111_L

RO_check
    MOVE.B  bits6to8, D1
    ANDI.B  #$3, D1
    MOVE.B  D1, op_size
    CMP.B   #3, D1
    BEQ RO_memory
RO_register
    MOVE.B  bits6to8, D1
    ANDI.B  #$4, D1
    LSR.B   #2, D1
    MOVE.B  D1, dr
    MOVE.B  bits3to5, D1
    ANDI.B  #$4, D1
    LSR.B   #2, D1
    MOVE.B  D1, ir
    JSR print_RO
    JMP shift_reuse
RO_memory
    MOVE.B  bits3to5, D1
    CMP.B   #2, D1
    BEQ RO_memory_010
    CMP.B   #3, D1
    BEQ RO_memory_011
    CMP.B   #4, D1
    BEQ RO_memory_100
    CMP.B   #7, D1
    BEQ RO_memory_111
    BRA LS_invalid
RO_memory_010
    JSR print_RO
    BRA AS_RO_010
RO_memory_011
    JSR print_RO
    BRA AS_RO_011
RO_memory_100
    JSR print_RO
    BRA AS_RO_100
RO_memory_111
    MOVE.B  bits0to2, D1
    CMP.B   #1, D1
    BGT LS_invalid
    BLT RO_memory_111_W
    BEQ RO_memory_111_L
RO_memory_111_W
    JSR print_RO
    BRA AS_RO_111_W
RO_memory_111_L
    JSR print_RO
    BRA AS_RO_111_L

*not supported
CODE1111
    JSR print_data
    RTS


*put any needed subroutines/jump tables for size, register, EA mode below here

get_bits_0_to_2
    MOVE.W  curr_four_nibbles, D1
    ANDI.W  #$0007, D1
    MOVE.B  D1, bits0to2
    RTS

get_bits_3_to_5
    MOVE.W  curr_four_nibbles, D1
    ANDI.W  #$0038, D1
    LSR.W   #3, D1
    MOVE.B  D1, bits3to5
    RTS
    
get_bits_6_to_8
    MOVE.W  curr_four_nibbles, D1
    ANDI.W  #$01C0, D1
    LSR.W   #6, D1
    MOVE.B  D1, bits6to8
    RTS

get_bits_9_to_11
    MOVE.W  curr_four_nibbles, D1
    ANDI.W  #$0E00, D1
    LSR.W   #8, D1
    LSR.W   #1, D1
    MOVE.B  D1, bits9to11
    RTS
    
load_bit_triples
    JSR get_bits_0_to_2
    JSR get_bits_3_to_5
    JSR get_bits_6_to_8
    JSR get_bits_9_to_11
    MOVE.W  curr_four_nibbles, D1
    RTS

***
*beginning of print memory specific subroutines
***
print_memory_location
    JSR clr_all_regs
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

print_NOP
    MOVE.B  #14, D0
    LEA printNOP, A1
    TRAP    #15
    RTS

print_RTS
    MOVE.B  #14, D0
    LEA printRTS, A1
    TRAP    #15
    RTS

print_LEA
    MOVE.B  #14, D0
    LEA     printLEA, A1
    TRAP    #15
    RTS
    
print_NOT
    MOVE.B  #14, D0
    LEA printNOT, A1
    TRAP    #15
    RTS
    
print_JSR
    MOVE.B  #14, D0
    LEA printJSR, A1
    TRAP    #15
    RTS
    
print_BRA
    MOVE.B  #14, D0
    LEA printBRA, A1
    TRAP    #15
    RTS
    
print_BGT
    MOVE.B  #14, D0
    LEA printBGT, A1
    TRAP    #15
    RTS

print_BLE
    MOVE.B  #14, D0
    LEA printBLE, A1
    TRAP    #15
    RTS

print_BEQ
    MOVE.B  #14, D0
    LEA printBEQ, A1
    TRAP    #15
    RTS
    
print_LS
    MOVE.B  #14, D0
    LEA printLS, A1
    TRAP    #15
    RTS

print_AS
    MOVE.B  #14, D0
    LEA printAS, A1
    TRAP    #15
    RTS

print_RO
    MOVE.B  #14, D0
    LEA printRO, A1
    TRAP    #15
    RTS

print_left
    MOVE.B  #14, D0
    LEA printLeft, A1
    TRAP    #15
    RTS

print_right
    MOVE.B  #14, D0
    LEA printRight, A1
    TRAP    #15
    RTS

*print data if cannot decode
print_data
    LEA printData, A1
    MOVE.B  #14, D0
    TRAP    #15
    JSR print_word_of_data
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

print_longword_of_data
    JSR print_word_of_data
    JSR increment_by_word
    JSR print_word_of_data
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
    
print_0
    LEA print0, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS
    
print_1
    LEA print1, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS

print_2
    LEA print2, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS

print_3
    LEA print3, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS

print_4
    LEA print4, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS

print_5
    LEA print5, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS

print_6
    LEA print6, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS

print_7
    LEA print7, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS

print_A
    LEA printA, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS

print_D
    LEA printD, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS
    
print_comma
    LEA printComma, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS
    
print_open_paren
    LEA printOpenParen, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS

print_close_paren
    LEA printCloseParen, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS
    
print_minus
    LEA printMinus, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS

print_plus
    LEA printPlus, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS
    
print_$
    LEA print$, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS
    
print_hashtag
    LEA printHashtag, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS

print_S
    LEA printS, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS

print_B
    LEA printB, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS

print_W
    LEA printW, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS

print_L
    LEA printL, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS
    
***
*end of printing subroutines
***
    
***
*beginning of miscellaneous subroutines
***
    
*get subroutines are for getting data in memory
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
printJSR    DC.B    'JSR ',0
printNOT    DC.B    'NOT',0
printLEA    DC.B    'LEA ',0
printDATA   DC.B    'DATA ',0
printNOP    DC.B    'NOP',0
printRTS    DC.B    'RTS',0
printBRA    DC.B    'BRA',0
printBGT    DC.B    'BGT',0
printBLE    DC.B    'BLE',0
printBEQ    DC.B    'BEQ',0
printMove   DC.B    'MOVE',0
printS  DC.B    '.S ',0
printB  DC.B     '.B ',0
printW  DC.B    '.W ',0
printL  DC.B    '.L ',0
printMinus  DC.B     '-',0
printPlus   DC.B     '+',0
printComma  DC.B    ',',0
printOpenParen   DC.B     '(',0
printCloseParen   DC.B     ')',0
printD  DC.B     'D',0
printA    DC.B    'A',0
print0  DC.B    '0',0
print1  DC.B    '1',0
print2  DC.B    '2',0
print3  DC.B    '3',0
print4  DC.B    '4',0
print5  DC.B    '5',0
print6  DC.B    '6',0
print7  DC.B    '7',0
print$  DC.B    '$',0
printHashtag  DC.B    '#',0
printLS DC.B    'LS',0
printAS DC.B    'AS',0
printRO DC.B    'RO',0
printLeft   DC.B    'L',0    left shift
printRight  DC.B    'R',0   right shift

*data and address storage
start_loc   DS.L    1
end_loc     DS.L    1
curr_loc    DS.L    1
curr_word   DS.W    1   used for printing memory location
curr_four_nibbles   DS.W    1   used to store actual data in memory
curr_nibble DS.B    1   stores one nibble
abs_address DS.L    1   absolute address for branching
op_size DS.B    1   size of operation
dr  DS.B    1   direction of shift
ir  DS.B    1   immediate or register
bits0to2 DS.B    1
bits3to5    DS.B    1
bits6to8    DS.B    1
bits9to11   DS.B    1
line_counter    DS.B    1   stores lines, advance page based on this value

*I/O messages
introMsg   DC.B    'Welcome to the Motorola 68k disassembler!',CR,0
introOptionMsg  DC.B    'Type "y" to initiate disassembly, any other character to exit:',CR,0
finishedMsg DC.B    'Finished disassembly.',CR,0
promptStart DC.B    'Enter a starting address (8 hex digits):',CR,0
promptEnd   DC.B    'Enter an ending address (8 hex digits):',CR,0
inputError DC.B    'Invalid address. Must have < 9 hex digits, start_addr < end_addr, last bit even',CR,0
promptEnter DC.B    'Press enter to advance page:',CR,0

*formatting
newLine DC.B    '',0 use with trap task 13
printSpace  DC.B    ' ',0 use with trap task 14

    END    START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
