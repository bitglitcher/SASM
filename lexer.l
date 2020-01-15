%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include "arch/D16i/OPCODES/inset.h"
#include "arch/D16i/OPCODES/alu_ops.h"
#include "arch/D16i/OPCODES/addressing_modes.h"
//[a-zA-Z0-9]*+":"	{tag_name = yytext; *(tag_name + strlen(tag_name) - 1) = '\0'; return TAG;};

//[a-f]+"x"			{set_values(parse_register_type(yytext)); return GPR;};
//[A-Za-z0-9]*+":"	{tag_name = yytext; *(tag_name + strlen(tag_name) - 1) = '\0'; return TAG;};

//"usp"               {set_values(0x02); set_reg_gs(0x01); return REG;};
//"ubp"               {set_values(0x03); set_reg_gs(0x01); return REG;};
//"ssp"               {set_values(0x04); set_reg_gs(0x01); return REG;};

unsigned char op_addr;
unsigned char reg_segment;
unsigned char branch_op_address; 

char *ptr;
extern int parse_register_type(char* buffer);
extern void set_values(int);

extern void set_carry_mode(int);
extern void set_reg_segment(int);
char * tag_name;
char * identifier_name;
//STRING_P "\""+[a-zA-Z0-9\\.]*+"\""
char* string_buffer;

extern void set_reg_gs(int type);

%}
%option nounput yylineno
%option noyywrap
STRING_P L?\"(\\.|[^\\"])*\"
IDENTIFIER [A-Za-z0-9_]+[A-Za-z0-9_]*
%%
"add"               {op_addr = op_type_add	; return OPERATION;};
"sub"               {op_addr = op_type_sub	; return OPERATION;};
"and"               {op_addr = op_type_and	; return OPERATION;};
"xor"               {op_addr = op_type_xor	; return OPERATION;};
"or"                {op_addr = op_type_or	; return OPERATION;};
"not"				{op_addr = op_type_not	; return OPERATION;};
"shftl"				{op_addr = op_type_shftl; return OPERATION;};
"shftr"				{op_addr = op_type_shftr; return OPERATION;};

"ci"				{set_carry_mode(op_type_ci); return CARRY;};
"co"				{set_carry_mode(op_type_co); return CARRY;};

(0x)+[a-z0-9]+		{set_values(strtol(yytext,NULL,0)); return NUMBER;};

{STRING_P}			{string_buffer = yytext; *(string_buffer + strlen(string_buffer) - 1) = '\0'; return STRING;};

"load"				return LOAD;
"store"				return STORE;
"mov"				return MOV;
"jmp"				return JMP;
"noop"				return NOOP;

"lo"				{set_reg_segment(reg_lo); return REG_SEG;};
"hi"				{set_reg_segment(reg_hi); return REG_SEG;};

"ax"				{set_values(0x00); set_reg_gs(0x00); return REG;};
"bx"				{set_values(0x01); set_reg_gs(0x00); return REG;};
"cx"				{set_values(0x02); set_reg_gs(0x00); return REG;};
"dx"				{set_values(0x03); set_reg_gs(0x00); return REG;};
"ex"				{set_values(0x04); set_reg_gs(0x00); return REG;};
"fx"				{set_values(0x05); set_reg_gs(0x00); return REG;};
"gx"				{set_values(0x06); set_reg_gs(0x00); return REG;};
"hx"				{set_values(0x07); set_reg_gs(0x00); return REG;};

"sp"                {set_values(0x00); set_reg_gs(0x01); return REG;};
"bp"                {set_values(0x01); set_reg_gs(0x01); return REG;};
"dmap"              {set_values(0x02); set_reg_gs(0x01); return REG;};
"krnlp"             {set_values(0x03); set_reg_gs(0x01); return REG;};
"tmrip"             {set_values(0x04); set_reg_gs(0x01); return REG;};
"syscr"             {set_values(0x05); set_reg_gs(0x01); return REG;};
"lpr"               {set_values(0x06); set_reg_gs(0x01); return REG;};
"stmr"              {set_values(0x07); set_reg_gs(0x01); return REG;};

"ab"				{branch_op_address = branch_ab  ; return CONDITIONAL;};
"eq"				{branch_op_address = branch_eq  ; return CONDITIONAL;};
"ba"				{branch_op_address = branch_ba  ; return CONDITIONAL;};
"zero"				{branch_op_address = branch_zero; return CONDITIONAL;};
"ovr"				{branch_op_address = branch_ovr ; return CONDITIONAL;};
"neg"				{branch_op_address = branch_noop; return CONDITIONAL;};

"mma"               {set_values(0x00); return DMAR;};
"mmc"               {set_values(0x01); return DMAR;};
"dma"               return DMA;

"mem"               {set_values(0x00); return DMAOP;};
"dev"               {set_values(0x01); return DMAOP;};

"reserve"			return RESERVE;
"alloc"				return ALLOC;
"word"				return WORD;
"single"			return SINGLE;
"continous"			return CONTINOUS;
"halt"              return HALT;
"proto"             return PROTO;
"lenght"            return LENGHT;

"push"              return PUSH;
"pop"               return POP;

"+"					return PLUS;
","					return COMMA;
";"                 return SEMICOLON;
"("                 return PARENTESIS_OPEN;
")"                 return PARENTESIS_CLOSE;
":"                 return COLON;
"."                 return POINT;


{IDENTIFIER}        {identifier_name = strdup(yytext); return IDENTIFIER;};

[ \r\n]             ;
.                   ;
[ \t]+              ;
%%
