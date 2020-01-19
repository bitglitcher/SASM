%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include "libs/vector.h"
#include "libs/t_buffer.h"
#include "libs/s_buffer.h"
#include "arch/D16i/OPCODES/alu_ops.h"
#include "arch/D16i/OPCODES/inset.h"
#include "arch/D16i/OPCODES/addressing_modes.h"
#include "arch/D16i/OPCODES/dma_ops.h"

#define BYTE_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c"
#define BYTE_TO_BINARY(byte)  \
  (byte & 0x80 ? '1' : '0'), \
  (byte & 0x40 ? '1' : '0'), \
  (byte & 0x20 ? '1' : '0'), \
  (byte & 0x10 ? '1' : '0'), \
  (byte & 0x08 ? '1' : '0'), \
  (byte & 0x04 ? '1' : '0'), \
  (byte & 0x02 ? '1' : '0'), \
  (byte & 0x01 ? '1' : '0') 

extern char* yytext;
extern int yylineno;
void yyerror(const char *str)
{
        fprintf(stderr,"error: on line %d, %s before token: %s\n",yylineno ,str, yytext);
}
void syntax_error(const char *str)
{
	printf("error: on line %d, at %s before: %s\n",yylineno ,str, yytext);
}
void syntax_error_invalid()
{
	printf("error: on line %d. Invalid Operation. %s\n",yylineno, yytext);
}
void syntax_invalid_arg(int argn)
{
	printf("error: on line %d. Invalid Argument: %d\n",yylineno, argn);
}
extern Vector output_bin_buffer;
extern int hexadecimal_to_decimal(int x);
extern int yylval;

//extern int val1, val2, val3;
extern int val[2];
extern int val_pointer;
extern void reset_values();

extern unsigned char branch_op_address;
extern int yylex();
extern int reg_seg_0;

extern int reg_seg_1;
extern void reset_reg_segments();
extern TAG_BUFFER t_buffer;

extern unsigned char op_addr;
extern unsigned char reg_segment;
extern int carry_mode_0, carry_mode_1;

extern TAG_BUFFER str_ident_buffer;
extern char *identifier_name;
extern STR_BUFFER s_buffer;

union ALUF_ENCODING ALUF_DATA_ADDRESSING;
union LI_ENCODING LI_DATA_ADDRESSING;
union MOVF_ENCODING MOVF_DATA_ADDRESSING;
union JMPI_ENCODING JMPI_DATA_ADDRESSING;
union JMPFR_ENCODING JMPFR_DATA_ADDRESSING;

unsigned char alu_op;
unsigned short int addr_p = 0x00;
extern char* tag_name;

extern char* string_buffer;
extern char* remove_quotes(char*);
extern bool vector_wait_slot;

unsigned short int label_addr = 0x00;
extern void increment_ins();
extern char* cnvrt_schar(char *str, size_t size);

char *string_buffer_0; //Saved variables for parsing multiple string tokens
char *string_buffer_1; //Saved variables for parsing multiple string tokens

bool non_linear_allocation_used = false;
//Pointers and
unsigned short int max_size;
extern void reset_gs();
//extern int reg_gs0, reg_gs1, reg_gs2;
extern int reg_gs[2];

#define reg_gs0 reg_gs [0]
#define reg_gs1 reg_gs [1]
#define reg_gs2 reg_gs [2]

extern int val_duplicated();
extern int check_val_dup();

#define val1 val[0]
#define val2 val[1]
#define val3 val[2]

extern char* gpr_names [];
extern char* spr_names [];
extern int get_not_gpr();
%}
%token OPERATION SEMICOLON REG COMMA LOAD STORE MOV
%token JMP CONDITIONAL NUMBER CARRY NOOP REG_SEG TAG
%token STRING RESERVE ALLOC WORD SINGLE CONTINOUS PLUS
%token HALT PARENTESIS_OPEN PARENTESIS_CLOSE COLON
%token IDENTIFIER PROTO DMAR DMA DMAOP POINT LENGHT
%token PUSH POP CALL RETURN

%%
commands: /* empty */
    | commands command
    ;

command:
    operation
    |
    load
    |
    store
    |
    mov
    |
    jmp
    |
    noop
    |
    tag
    |
    alloc
	|
	halt
	|
	dma
	|
	stack
	|
	call
	|
	return
    ;
operation:
    OPERATION REG COMMA REG COMMA REG SEMICOLON
    {
		/*
        printf("OPERATION DETECTED!\n");
        printf("gpr %d!\n",val1);
        printf("gpr %d!\n",val2);
        printf("gpr %d!\n",val3);
        */
		if(((reg_gs0 != iGPR) || (reg_gs1 != iGPR) || (reg_gs2 != iGPR)))
		{
			printf("error: argument %s not GPR\n", spr_names[val[get_not_gpr()]]);
		}
		if(check_val_dup() == 1)
		{
			printf("warning: same maching argument %s in line %d\n", gpr_names[val_duplicated() + 1], yylineno);
		}
		//Check if all args are GPR
        switch(op_addr)
        {
			case op_type_add	: alu_op = iADD; break;
			case op_type_sub	: alu_op = iSUB; break;
			case op_type_and	: alu_op = iAND; break;
			case op_type_xor	: alu_op = iXOR; break;
			case op_type_or		: alu_op = iOR; break;
			case op_type_not	: alu_op = iNOT; break;
			case op_type_shftl	: alu_op = iSHFTL; break;
			case op_type_shftr	: alu_op = iSHFTR; break;
        } 
        
        //encode instruction and push it to buffer
		vector_append(&output_bin_buffer,(ALUF_ADDR_MODE (iALUF, alu_op, val1, val2, val3) >> 8 ) & 0xff);
		vector_append(&output_bin_buffer,(ALUF_ADDR_MODE (iALUF, alu_op, val1, val2, val3) & 0xff));
        reset_values();
        increment_ins();
		reset_gs();
    }
    ;
load:
	LOAD REG COMMA REG_SEG COMMA NUMBER SEMICOLON
	{
		if(reg_gs0 == iGPR)
		{
			vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, reg_seg_0, 0x00, val1, val2) >> 8 ) & 0xff);
			vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, reg_seg_0, 0x00, val1, val2) & 0xff));
		}
		else if(reg_gs0 == iSPR)
		{
			vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, reg_seg_0, 0x01, val1, val2) >> 8 ) & 0xff);
			vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, reg_seg_0, 0x01, val1, val2) & 0xff));
		}
		//vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x00, 0x00, 0x00) >> 8 ) & 0xff);
		//vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x00, 0x00, 0x00) & 0xff));
		//printf("load hl: %x gs: %x rt: %x imm: %x\n",reg_seg_0, 0x00, val1, val2);
		reset_reg_segments();
		reset_gs();
		reset_values();
		increment_ins();
	}
	|
	LOAD REG COMMA REG_SEG COMMA IDENTIFIER SEMICOLON
	{
		if(s_buffer_find_maching_name(&s_buffer, identifier_name) == 0)
		{
			printf("Syntax error: No maching identifier, %s\n", identifier_name);
			syntax_error(identifier_name);
		}
		else
		{
			label_addr = s_buffer_locate_tag_addr(&s_buffer, identifier_name);
			//printf("Index: %d\n", label_addr);
			//printf("Jumping to label %s %d\n", string_buffer, label_addr);
			if(reg_gs0 == iGPR)
			{
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, reg_seg_0, 0x00, val1, label_addr) >> 8 ) & 0xff);
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, reg_seg_0, 0x00, val1, label_addr) & 0xff));
			}
			else if(reg_gs0 == iSPR)
			{
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, reg_seg_0, 0x01, val1, label_addr) >> 8 ) & 0xff);
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, reg_seg_0, 0x01, val1, label_addr) & 0xff));
			}
		}
		//vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x00, 0x00, 0x00) >> 8 ) & 0xff);
		//vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x00, 0x00, 0x00) & 0xff));
		//printf("load hl: %x gs: %x rt: %x imm: %x\n",reg_seg_0, 0x00, val1, val2);
		reset_reg_segments();
		reset_values();
		reset_gs();
		increment_ins();
	}
	|
	LOAD REG COMMA REG_SEG COMMA IDENTIFIER PLUS NUMBER SEMICOLON
	{
		if(s_buffer_find_maching_name(&s_buffer, identifier_name) == 0)
		{
			printf("Syntax error: No maching identifier, %s\n", identifier_name);
			syntax_error(identifier_name);
		}
		else
		{
			label_addr = s_buffer_locate_tag_addr(&s_buffer, identifier_name);
			//printf("Index: %d\n", label_addr);
			//printf("Jumping to label %s %d\n", string_buffer, label_addr);
			if(reg_gs0 == iGPR)
			{
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, reg_seg_0, 0x00, val1, (label_addr + val2)) >> 8 ) & 0xff);
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, reg_seg_0, 0x00, val1, (label_addr + val2)) & 0xff));
			}
			else if(reg_gs0 == iSPR)
			{
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, reg_seg_0, 0x01, val1, (label_addr + val2)) >> 8 ) & 0xff);
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, reg_seg_0, 0x01, val1, (label_addr + val2)) & 0xff));
			}
		}
		//vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x00, 0x00, 0x00) >> 8 ) & 0xff);
		//vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x00, 0x00, 0x00) & 0xff));
		//printf("load hl: %x gs: %x rt: %x imm: %x\n",reg_seg_0, 0x00, val1, val2);
		reset_reg_segments();
		reset_values();
		reset_gs();
		increment_ins();
	}
	|
	LOAD REG COMMA REG_SEG COMMA REG PLUS NUMBER SEMICOLON
	{
		//LOAD 16bit
		if(reg_gs0 == iGPR)
		{
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x00, 0x00, reg_seg_0, val1, val2, val3) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x00, 0x00, reg_seg_0, val1, val2, val3) & 0xff));
		}
		else if(reg_gs0 == iSPR)
		{
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x00, 0x01, reg_seg_0, val1, val2, val3) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x00, 0x01, reg_seg_0, val1, val2, val3) & 0xff));
		}
		reset_gs();
		reset_reg_segments();
		reset_values();
		increment_ins();
	}
	|
	LOAD REG COMMA REG_SEG COMMA IDENTIFIER POINT LENGHT SEMICOLON
	{
		if(s_buffer_find_maching_name(&s_buffer, identifier_name) == 0)
		{
			printf("Syntax error: No maching identifier, %s\n", identifier_name);
			syntax_error(identifier_name);
		}
		else
		{
			label_addr = s_buffer_get_str_len(&s_buffer, identifier_name);
			printf("Index: %d\n", label_addr);
			//printf("Jumping to label %s %d\n", string_buffer, label_addr);
			if(reg_gs0 == iGPR)
			{
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, reg_seg_0, 0x00, val1, label_addr) >> 8 ) & 0xff);
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, reg_seg_0, 0x00, val1, label_addr) & 0xff));
			}
			else if(reg_gs0 == iSPR)
			{
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, reg_seg_0, 0x01, val1, label_addr) >> 8 ) & 0xff);
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, reg_seg_0, 0x01, val1, label_addr) & 0xff));
			}
		}
		//vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x00, 0x00, 0x00) >> 8 ) & 0xff);
		//vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x00, 0x00, 0x00) & 0xff));
		//printf("load hl: %x gs: %x rt: %x imm: %x\n",reg_seg_0, 0x00, val1, val2);
		reset_reg_segments();
		reset_values();
		increment_ins();
		reset_gs();
	}
	|
	LOAD REG COMMA NUMBER SEMICOLON
	{
		//
		if(val2 < 0xff)
		{
			if(reg_gs0 == iGPR)
			{
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x00, val1, val2) >> 8 ) & 0xff);
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x00, val1, val2) & 0xff));
				increment_ins();
			}
			if(reg_gs0 == iSPR)
			{	
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x01, val1, val2) >> 8 ) & 0xff);
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x01, val1, val2) & 0xff));
				increment_ins();
			}
		}
		else
		{
			if(reg_gs0 == iGPR)
			{
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x01, 0x00, val1, ((val2 >> 8) & 0xff)) >> 8 ) & 0xff);
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x01, 0x00, val1, ((val2 >> 8) & 0xff)) & 0xff));
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x00, val1, (val2 & 0xff)) >> 8 ) & 0xff);
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x00, val1, (val2 & 0xff)) & 0xff));
				increment_ins();
				increment_ins();
			}
			else if(reg_gs0 == iSPR)
			{
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x01, 0x01, val1, ((val2 >> 8) & 0xff)) >> 8 ) & 0xff);
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x01, 0x01, val1, ((val2 >> 8) & 0xff)) & 0xff));
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x01, val1, (val2 & 0xff)) >> 8 ) & 0xff);
				vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x01, val1, (val2 & 0xff)) & 0xff));
				increment_ins();
				increment_ins();
			}
		}
		reset_gs();
		reset_values();
		reset_values();
	}
	;
store:
	STORE REG COMMA REG PLUS NUMBER SEMICOLON
	{
		if(reg_gs1 != iGPR)
		{
			printf("error: argument %s not GPR\n", spr_names[val[get_not_gpr()]]);
		}
		if(check_val_dup() == 1)
		{
			printf("error: same maching argument %d\n", val_duplicated() + 1);
		}
		//printf("STORE DETECTED!\n");
		if((reg_gs0 == iGPR))
		{
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x00, 0x0, val1, val2, val3) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x00, 0x0, val1, val2, val3) & 0xff));
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x00, 0x1, val1, val2, val3) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x00, 0x1, val1, val2, val3) & 0xff));
		}
		else if(reg_gs0 == iSPR)
		{
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x01, 0x0, val1, val2, val3) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x01, 0x0, val1, val2, val3) & 0xff));
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x01, 0x1, val1, val2, val3) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x01, 0x1, val1, val2, val3) & 0xff));
		}
		
		reset_values();
		reset_gs();
		increment_ins();
		increment_ins();
	}
	|
	STORE REG COMMA REG SEMICOLON
	{
		//printf("STORE DETECTED!\n");
		if((reg_gs0 == iGPR))
		{
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x00, 0x0, val1, val2, 0x00) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x00, 0x0, val1, val2, 0x00) & 0xff));
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x00, 0x1, val1, val2, 0x00) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x00, 0x1, val1, val2, 0x00) & 0xff));
		}
		else if(reg_gs0 == iSPR)
		{
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x01, 0x0, val1, val2, 0x00) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x01, 0x0, val1, val2, 0x00) & 0xff));
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x01, 0x1, val1, val2, 0x00) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x01, 0x1, val1, val2, 0x00) & 0xff));
		}
		reset_gs();
		reset_values();
		increment_ins();
		increment_ins();
	}
	|
	STORE REG COMMA REG_SEG COMMA REG SEMICOLON
	{
		printf("Bit set %d\n",reg_seg_0);
		if((reg_gs0 == iGPR))
		{
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x00, reg_seg_0, val1, val2, 0x00) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x00, reg_seg_0, val1, val2, 0x00) & 0xff));
		}
		else if(reg_gs0 == iSPR)
		{
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x01, reg_seg_0, val1, val2, 0x00) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (LSINS_ADDR_MODE(iLSINS, 0x01, 0x01, reg_seg_0, val1, val2, 0x00) & 0xff));
		}
		reset_gs();
		reset_reg_segments();
		reset_values();
		increment_ins();
	}
	;
mov:
	MOV REG COMMA REG SEMICOLON
	{
		if((reg_gs0 == iGPR) && (reg_gs1 == iGPR))
		{
			vector_append(&output_bin_buffer, (MOVF_ADDR_MODE(iMOVF, 0x0, 0x0, 0x1, iMOVGPRGPR, val1, val2) >> 8 ) & 0xff);
			vector_append(&output_bin_buffer, (MOVF_ADDR_MODE(iMOVF, 0x0, 0x0, 0x1, iMOVGPRGPR, val1, val2) & 0xff));
		}
		else if((reg_gs0 == iGPR) && (reg_gs1 == iSPR))
		{
			vector_append(&output_bin_buffer, (MOVF_ADDR_MODE(iMOVF, 0x0, 0x0, 0x1, iMOVGPRSPR, val1, val2) >> 8 ) & 0xff);
			vector_append(&output_bin_buffer, (MOVF_ADDR_MODE(iMOVF, 0x0, 0x0, 0x1, iMOVGPRSPR, val1, val2) & 0xff));
		}
		else if((reg_gs0 == iSPR) && (reg_gs1 == iGPR))
		{
			vector_append(&output_bin_buffer, (MOVF_ADDR_MODE(iMOVF, 0x0, 0x0, 0x1, iMOVSPRGPR, val1, val2) >> 8 ) & 0xff);
			vector_append(&output_bin_buffer, (MOVF_ADDR_MODE(iMOVF, 0x0, 0x0, 0x1, iMOVSPRGPR, val1, val2) & 0xff));
		}
		reset_values();
		reset_gs();
		increment_ins();
	}
	|
	MOV REG REG_SEG COMMA REG REG_SEG SEMICOLON
	{
		//MOVF_ADDR_MODE(iMOVF, reg_seg_0, reg_seg_1, iMOVGPRGPR, val1, val2)
		if((reg_gs0 == iGPR) && (reg_gs1 == iGPR))
		{
			vector_append(&output_bin_buffer, (MOVF_ADDR_MODE(iMOVF, reg_seg_0, reg_seg_1, 0x0, iMOVGPRGPR, val1, val2) >> 8 ) & 0xff); 
			vector_append(&output_bin_buffer, (MOVF_ADDR_MODE(iMOVF, reg_seg_0, reg_seg_1, 0x0, iMOVGPRGPR, val1, val2) & 0xff));
		}
		if((reg_gs0 == iGPR) && (reg_gs1 == iSPR))
		{
			vector_append(&output_bin_buffer, (MOVF_ADDR_MODE(iMOVF, reg_seg_0, reg_seg_1, 0x0, iMOVGPRSPR, val1, val2) >> 8 ) & 0xff); 
			vector_append(&output_bin_buffer, (MOVF_ADDR_MODE(iMOVF, reg_seg_0, reg_seg_1, 0x0, iMOVGPRSPR, val1, val2) & 0xff));
		}
		if((reg_gs0 == iSPR) && (reg_gs1 == iGPR))
		{
			vector_append(&output_bin_buffer, (MOVF_ADDR_MODE(iMOVF, reg_seg_0, reg_seg_1, 0x0, iMOVSPRGPR, val1, val2) >> 8 ) & 0xff); 
			vector_append(&output_bin_buffer, (MOVF_ADDR_MODE(iMOVF, reg_seg_0, reg_seg_1, 0x0, iMOVSPRGPR, val1, val2) & 0xff));
		}
		reset_reg_segments();
		reset_gs();
		reset_values();
		increment_ins();
	}
	|
	MOV DMAR COMMA REG SEMICOLON
	{
		vector_append(&output_bin_buffer, (MOVF_ADDR_MODE(iMOVF, 0x0, 0x0, 0x1, iMOVGPRDMAR, val1, val2) >> 8 ) & 0xff);
		vector_append(&output_bin_buffer, (MOVF_ADDR_MODE(iMOVF, 0x0, 0x0, 0x1, iMOVGPRDMAR, val1, val2) & 0xff));
		reset_values();
		increment_ins();
	};
jmp:
	JMP NUMBER SEMICOLON
	{
		//MAX Range in this mode is 13 bits (8192) Bytes
		vector_append(&output_bin_buffer, (JMPD_ADDR_MODE(iJMPD, val1) >> 8) & 0xff);
		vector_append(&output_bin_buffer, (JMPD_ADDR_MODE(iJMPD, val1) & 0xff));
		reset_values();
		increment_ins();
	}
	|
	JMP REG NUMBER CONDITIONAL SEMICOLON
	{
		//val1
		//printf("JMP\n");
		reset_values();
		increment_ins();
	}
	|
	JMP REG COMMA REG CONDITIONAL REG SEMICOLON
	{
		//val1 val2 branch_op_address val3 
		//JMPFR_ADDR_MODE(ins, ivr, op, ap1, t1, t2)
		vector_append(&output_bin_buffer, (JMPFR_ADDR_MODE(iJMPR, 0x00, branch_op_address, val1, val2, val3) >> 8) & 0xff);
		vector_append(&output_bin_buffer, (JMPFR_ADDR_MODE(iJMPR, 0x00, branch_op_address, val1, val2, val3) & 0xff));
		increment_ins();
		reset_values();
	}
	|
	JMP REG NUMBER SEMICOLON
	{
		//printf("JMP\n");
		//JMPFR_ADDR_MODE(iJMPR,ivr, op, ap1, t1, t2)
		reset_values();

	}
	|
	JMP IDENTIFIER SEMICOLON
	{
		//Syntax change
		//JMP STRING SEMICOLON
		//identifier_name = remove_quotes(identifier_name);
		//Check if the tag exists
		
		if(t_buffer_find_maching_name(&t_buffer, identifier_name) == 0)
		{
			printf("Syntax error: No maching identifier, %s\n", identifier_name);
			syntax_error(identifier_name);
		}
		else
		{
			label_addr = t_buffer_locate_tag_addr(&t_buffer, identifier_name);
			//printf("Jumping to label %s %d\n", string_buffer, label_addr);
			vector_append(&output_bin_buffer, (JMPD_ADDR_MODE(iJMPD, label_addr) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (JMPD_ADDR_MODE(iJMPD, label_addr) & 0xff));
		}
		increment_ins();
	}
	;
noop:
	NOOP SEMICOLON
	{
		printf("%x\n",0x00);
		vector_append(&output_bin_buffer, (0x00));
		vector_append(&output_bin_buffer, (0x00));
		printf("No operation\n");
		increment_ins();
	};
tag:
	IDENTIFIER COLON
	{
		//identifier_name = strdup(identifier_name);
		// /printf("TAG DETECTED! %s\n", identifier_name);
		if(t_buffer_find_maching_name(&t_buffer, identifier_name) == 0)
		{
			//printf("addr_p : %x \n", addr_p);
			t_append(&t_buffer, identifier_name, addr_p);
		}
		else
		{
			printf("ERROR: Same maching identifier\n");
		}
	}
	|
	RESERVE IDENTIFIER COLON
	{
		//printf("TAG DETECTED! %s\n", tag_name);
		if(t_buffer_find_maching_name(&t_buffer, identifier_name) == 0)
		{
			vector_append(&output_bin_buffer, (0x00));
			vector_append(&output_bin_buffer, (0x00));
			addr_p++;
			//printf("addr_p : %x \n", addr_p);
			t_append(&t_buffer, identifier_name, addr_p);
		}
		else
		{
			printf("ERROR: Same maching identifier\n");
		}
	}
	|
	IDENTIFIER PARENTESIS_OPEN NUMBER PARENTESIS_CLOSE COLON
	{
		//val1;
		//printf("TAG DETECTED ALLOC %d\n",val1);
		//+100 Just to be safe
		if(t_buffer_find_maching_name(&t_buffer, identifier_name) == 0)
		{
			/*
			vector_append(&output_bin_buffer, (0x00));
			vector_append(&output_bin_buffer, (0x00));
			*/
			vector_set_capacity(&output_bin_buffer, val1);
			//Store old add_p to return to address
			addr_p = val1;
			output_bin_buffer.size = val1;
			vector_wait_slot = true;
			t_append(&t_buffer, identifier_name, val1);
		}
		else
		{
			if(t_buffer_is_prototype(&t_buffer, identifier_name) == 1)
			{
				vector_set_capacity(&output_bin_buffer, val1);
				//Store old add_p to return to address
				addr_p = val1;
				output_bin_buffer.size = val1;
				vector_wait_slot = true;
				//Set tag address
				t_buffer_set_addr(&t_buffer, identifier_name, val1);
				//t_append(&t_buffer, identifier_name, val1);
				printf("Prototype detected %d\n",val1);
			}
			else
			{
				printf("Syntax error: %s, was already declared\n",identifier_name);
			}
		}
		reset_values();
	}
	|
	PROTO IDENTIFIER SEMICOLON
	{
		if(t_buffer_find_maching_name(&t_buffer, identifier_name) == 0)
		{
			/*
			vector_append(&output_bin_buffer, (0x00));
			vector_append(&output_bin_buffer, (0x00));
			*/
			t_append(&t_buffer, identifier_name, 0x0000);
			t_buffer.data[t_buffer.size].prototype = true;
		}
		else
		{
			printf("Syntax error: %s, was already declared\n",identifier_name);
		}
		reset_values();
	}
	;
alloc:
	ALLOC NUMBER SEMICOLON
	{
		vector_append(&output_bin_buffer, (val1 >> 8) & 0xff);
		vector_append(&output_bin_buffer, (val1 & 0xff));
		reset_values();
		addr_p++;
	}
	|
	ALLOC STRING SEMICOLON
	{
		string_buffer = remove_quotes(string_buffer);
		//Set jump instructions to jump after the memory allocation
		/*if((strlen(string_buffer) % 2) == 0)
		{
			addr_p = ((addr_p + (strlen(string_buffer)) / 2) + 1);
		}
		else
		{
			addr_p = ((addr_p + (strlen(string_buffer)) / 2) + 2);
		}*/
		addr_p = (addr_p + strlen(string_buffer));
		//vector_append(&output_bin_buffer, (JMPD_ADDR_MODE(iJMPD, addr_p) >> 8) & 0xff);
		//vector_append(&output_bin_buffer, (JMPD_ADDR_MODE(iJMPD, addr_p) & 0xff));
		for(size_t i = 0;i <= strlen(string_buffer);i++)
		{
			vector_append(&output_bin_buffer, *(string_buffer + i));
		}
	}
	|
	ALLOC IDENTIFIER COMMA STRING SEMICOLON
	{

		if(s_buffer_find_maching_name(&s_buffer, identifier_name) == 0)
		{
			string_buffer = remove_quotes(string_buffer);
			string_buffer = cnvrt_schar(string_buffer, strlen(string_buffer));
			//printf("string buffer: %s\n", string_buffer);
			s_append(&s_buffer, identifier_name, addr_p, strlen(string_buffer));
			addr_p = (addr_p + strlen(string_buffer));
			//-1 to account for the indexing of 0
			for(size_t i = 0;i <= strlen(string_buffer) - 1;i++)
			{
				vector_append(&output_bin_buffer, *(string_buffer + i));
			}
		}
		else
		{
			printf("error: same maching identifier %s\n",identifier_name);
		}
	}
	|
	CONTINOUS ALLOC STRING SEMICOLON
	{
		string_buffer = remove_quotes(string_buffer);
		if((strlen(string_buffer) % 2) == 0)
		{
			addr_p = ((addr_p + (strlen(string_buffer)) / 2) + 1);
		}
		else
		{
			addr_p = ((addr_p + (strlen(string_buffer)) / 2) + 2);
		}
		vector_append(&output_bin_buffer, (JMPD_ADDR_MODE(iJMPD, addr_p) >> 8) & 0xff);
		vector_append(&output_bin_buffer, (JMPD_ADDR_MODE(iJMPD, addr_p) & 0xff));
		for(size_t i = 0;i <= strlen(string_buffer);i++)
		{
			vector_append(&output_bin_buffer, *(string_buffer + i));
		}
	}
	|
	SINGLE WORD ALLOC STRING SEMICOLON
	{
		string_buffer = remove_quotes(string_buffer);
		if((strlen(string_buffer) % 2) == 0)
		{
			addr_p = ((addr_p + (strlen(string_buffer)) / 2) + 1);
		}
		else
		{
			addr_p = ((addr_p + (strlen(string_buffer)) / 2) + 2);
		}
		vector_append(&output_bin_buffer, (JMPD_ADDR_MODE(iJMPD, addr_p) >> 8) & 0xff);
		vector_append(&output_bin_buffer, (JMPD_ADDR_MODE(iJMPD, addr_p) & 0xff));
		for(size_t i = 0;i <= strlen(string_buffer);i++)
		{
			vector_append(&output_bin_buffer, iNOOP);
			vector_append(&output_bin_buffer, *(string_buffer + i));
		}
	}
	|
	ALLOC NUMBER COMMA STRING COMMA
	{
		//Syntax alloc 0x0012, "Hola", "IDENTIFIER";
		//Size the buffer to the desired address & fill with 0x00
		//vector_set(&output_bin_buffer, val1, 0x00); //Fill with zeros
		//Write Data to the desired memory location
		vector_set_capacity(&output_bin_buffer, strlen(string_buffer) + output_bin_buffer.size + val1);
		string_buffer = remove_quotes(string_buffer);
		output_bin_buffer.size = val1 - 1;
		printf("val1 : %d\n",val1);
		printf("String from parsing stage 1: %s\n",string_buffer);
		for(size_t i = 0; i <= strlen(string_buffer);i++)
		{
			vector_append(&output_bin_buffer, *(string_buffer + i));
		}
		max_size = output_bin_buffer.size;
		output_bin_buffer.size =  addr_p;
		
	} alloc_follow;
alloc_follow:
	STRING SEMICOLON
	{
		//Identifier string stage
		//printf("Called from another rule!\n");
		string_buffer = remove_quotes(string_buffer);
		if(t_buffer_find_maching_name(&str_ident_buffer, string_buffer) == 0)
		{
			//printf("addr_p : %x \n", addr_p);
			t_append(&str_ident_buffer, string_buffer, val1);
		}
		else
		{
			printf("ERROR: Same maching identifier\n");
		}
		printf("String from parsing stage 2: %s\n",string_buffer);
		//output_bin_buffer.size = addr_p;
		reset_values();
	}
	;
halt:
	HALT SEMICOLON
	{
		//Big Endian architecture
		// /printf("HALT\n");
		vector_append(&output_bin_buffer, (INMI_ADDR_MODE_IMM(iINMI, iHALT, 0x00) >> 8) & 0xff);
		vector_append(&output_bin_buffer, (INMI_ADDR_MODE_IMM(iINMI, iHALT, 0x00) & 0xff));
		increment_ins();
	};
dma:
	DMA DMAOP SEMICOLON
	{
		if(val1 == memory_op)
		{
			vector_append(&output_bin_buffer, (INMI_ADDR_MODE_IMM(iINMI, iDMABMD, 0x00) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (INMI_ADDR_MODE_IMM(iINMI, iDMABMD, 0x00) & 0xff));
		}
		else if(val1 == dev_op)
		{
			vector_append(&output_bin_buffer, (INMI_ADDR_MODE_IMM(iINMI, iDMABDM, 0x00) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (INMI_ADDR_MODE_IMM(iINMI, iDMABDM, 0x00) & 0xff));
		}
		reset_values();
		increment_ins();
	};
stack:
	PUSH REG COMMA REG_SEG SEMICOLON
	{
		if(reg_gs0 == iGPR)
		{
			vector_append(&output_bin_buffer, (INMI_ADDR_MODE(iINMI, iSPUSH, 0x00, reg_seg_0, val1, 0x00) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (INMI_ADDR_MODE(iINMI, iSPUSH, 0x00, reg_seg_0, val1, 0x00) & 0xff));
			vector_append(&output_bin_buffer, (INMI_ADDR_MODE_IMM(iINMI, iSPss, 0x1) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (INMI_ADDR_MODE_IMM(iINMI, iSPss, 0x1) & 0xff));
		}
		else if(reg_gs0 == iSPR)
		{
			vector_append(&output_bin_buffer, (INMI_ADDR_MODE(iINMI, iSPUSH, 0x01, reg_seg_0, val1, 0x00) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (INMI_ADDR_MODE(iINMI, iSPUSH, 0x01, reg_seg_0, val1, 0x00) & 0xff));
			vector_append(&output_bin_buffer, (INMI_ADDR_MODE_IMM(iINMI, iSPss, 0x1) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (INMI_ADDR_MODE_IMM(iINMI, iSPss, 0x1) & 0xff));
		}
		reset_reg_segments();
		reset_values();
		reset_gs();
		increment_ins();
		increment_ins();
	}
	|
	POP NUMBER SEMICOLON
	{
		vector_append(&output_bin_buffer, (INMI_ADDR_MODE_IMM(iINMI, iSPpp, val1) >> 8) & 0xff);
		vector_append(&output_bin_buffer, (INMI_ADDR_MODE_IMM(iINMI, iSPpp, val1) & 0xff));
		increment_ins();
		reset_values();
	};
call:
	CALL IDENTIFIER COMMA REG SEMICOLON
	{
		if(t_buffer_find_maching_name(&t_buffer, identifier_name) == 0)
		{
			printf("Syntax error: No maching identifier, %s\n", identifier_name);
			syntax_error(identifier_name);
		}
		else
		{
			label_addr = t_buffer_locate_tag_addr(&t_buffer, identifier_name);
			vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x00, val1, (label_addr & 0xff)) >> 8 ) & 0xff);
			vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x00, 0x00, val1, (label_addr & 0xff)) & 0xff));
			vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x01, 0x00, val1, ((label_addr >> 0x8) & 0xff)) >> 8 ) & 0xff);
			vector_append(&output_bin_buffer, (LI_ADDR_MODE (iLI, 0x01, 0x00, val1, ((label_addr >> 0x8) & 0xff)) & 0xff));
			vector_append(&output_bin_buffer, (INMI_ADDR_MODE(iINMI, iCALL, 0x00, 0x00, val1, 0x00) >> 8) & 0xff);
			vector_append(&output_bin_buffer, (INMI_ADDR_MODE(iINMI, iCALL, 0x00, 0x00, val1, 0x00) & 0xff));
			increment_ins();
			increment_ins();
			increment_ins();
		}
		reset_values();
		reset_gs();
	};
return:
	RETURN SEMICOLON
	{
		vector_append(&output_bin_buffer, (INMI_ADDR_MODE_IMM(iINMI, iRETURN, 0x00) >> 8) & 0xff);
		vector_append(&output_bin_buffer, (INMI_ADDR_MODE_IMM(iINMI, iRETURN, 0x00) & 0xff));
		increment_ins();
	};
%%
