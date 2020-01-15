#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>
#include "libs/vector.h"
#include "libs/t_buffer.h"
#include "libs/s_buffer.h"


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


extern int yyparse();
extern int yy_scan_bytes ( const char *, int);
extern int yylex();

extern bool non_linear_allocation_used;

extern char* remove_line_comment(char *str, size_t size);
extern char* remove_block_comment(char *str, size_t size);

extern unsigned short int max_size;
extern unsigned short int addr_p;
//My input buffer
char* memblock;
//Output Buffer
Vector output_bin_buffer;
TAG_BUFFER t_buffer;
enum registers {ax,bx,cx,dx,ex,fx,gx,hx};
enum registers_names {ax_n = 0x61,bx_n,cx_n,dx_n,ex_n,fx_n,gx_n,hx_n};
TAG_BUFFER str_ident_buffer;

STR_BUFFER s_buffer;
 
char* gpr_names[] = {"ax","bx","cx","dx","ex","fx","gx","hx"};
char* spr_names[] = {"sp","bp","dmap","krnlp","trmip","syscr","lpr","stmr"};
//int val1, val2, val3;
int val[2];
int val_pointer = 0;
void set_values(int in_val)
{
	switch(val_pointer)
	{
		case 0: val[0] = in_val;
		case 1: val[1] = in_val;
		case 2: val[2] = in_val;
	}
	val_pointer++;
}
void reset_values()
{
	val[0] = 0;
	val[1] = 0;
	val[2] = 0;
	val_pointer = 0;
}

int carry_mode_0, carry_mode_1;
int carry_mode_pointer = 0;
void set_carry_mode(int carry_mode_t)
{
	switch(carry_mode_pointer)
	{
		case 0x0: carry_mode_0 = carry_mode_t;
		case 0x1: carry_mode_1 = carry_mode_t;
	}	
	carry_mode_pointer++;
}
void reset_carry_modes()
{
	carry_mode_0 = 0x0;
	carry_mode_1 = 0x0;
	carry_mode_pointer = 0x0;
}

int reg_seg_0, reg_seg_1;
int reg_seg_pointer = 0;
void set_reg_segment(int reg_seg_t)
{
	switch(reg_seg_pointer)
	{
		case 0x0: reg_seg_0 = reg_seg_t;
		case 0x1: reg_seg_1 = reg_seg_t;
	}
	reg_seg_pointer++;
}
void reset_reg_segments()
{
	reg_seg_0 = 0x0;
	reg_seg_1 = 0x0;
	reg_seg_pointer = 0x0;
}

char* remove_quotes(char* buffer)
{
	//Create Now eliminate the first character and shift string
	memmove(&*(buffer), &*(buffer + 1), (strlen(buffer)));
	return buffer;
}

void increment_ins()
{
	addr_p = addr_p + 2;
	//printf("addr_p: %d\n", addr_p);
}
int reg_gs_ptr;
int reg_gs [2];
//int reg_gs0;
//int reg_gs1;
//int reg_gs2;
void set_reg_gs(unsigned short int type)
{
	//printf("register set index: %d type: %d\n", reg_gs_ptr, type);
	//switch(reg_gs_ptr)
	//{
	//	case 0x00: reg_gs [0] = type;
	//	case 0x01: reg_gs [1] = type;
	//	case 0x02: reg_gs [2] = type;
	//}
	reg_gs [reg_gs_ptr] = type;
	reg_gs_ptr++;
}
void reset_gs()
{
	reg_gs_ptr = 0;
	reg_gs [0] = 0;
	reg_gs [1] = 0;
	reg_gs [2] = 0;
}
int get_not_gpr()
{
	for(size_t i = 0;i <= 2;i++)
	{
		if(reg_gs[i] == 1) return i;
	}	
}
int check_val_dup()
{
	for(size_t i = 0;i <= 2;i++)
	{
		for(size_t x = 0;x <= 2;x++)
		{
			if((val[i] == val[x]) && (reg_gs[i] == reg_gs[x]) && (x != i)) return 1;
		}
	}
	return 0;
}
int val_duplicated()
{
	for(size_t i = 0;i <= 2;i++)
	{
		for(size_t x = 0;x <= 2;x++)
		{
			if((val[i] == val[x]) && (reg_gs[i] == reg_gs[x]) && (x != i)) return i;
		}
	}
}
int main(int argc, char **argv)
{
	argc -= 1;
    
    if(argc == 0)
    {
		printf("\033[31m Error \033[0m No input parameters\n");
		exit(1);
    }
	else if(argc == 1)
	{
		printf("\033[31m Error \033[0m No output parameters\n");
		exit(1);
	}
	char* PATH = (char*)malloc(sizeof(PATH) * strlen (*(argv + 1)));
	char* OutputPATH = (char*)malloc(sizeof(OutputPATH) * strlen (*(argv + 2)));

	PATH = *(argv + 1);
	OutputPATH = *(argv + 2);
	FILE * MainFile;
	MainFile = fopen(PATH,"rb");
	if(MainFile == NULL)
    {
        printf("Error Opening File\n");
        exit(1);
    }
    fseek(MainFile, 0, SEEK_END);
    long File_Lenght = ftell(MainFile);
    rewind(MainFile);
    memblock  = (char*)malloc(sizeof(char) * (File_Lenght + 2));
    size_t state = fread (memblock, 1, File_Lenght, MainFile);
    if(memblock == NULL)
    {
        printf("Error Allocating Memory\n");
    }
    if(state != File_Lenght)
    {
        printf("Error Reading File\n");
        exit(1);
    }
    fclose(MainFile);
    //Setup Output Bin Buffer
    vector_init(&output_bin_buffer);
    //Setup Tag names bin buffer
    t_buffer_init(&t_buffer);
	t_buffer_init(&str_ident_buffer);
	s_buffer_init(&s_buffer);
	//Reset Values
	reset_values();
	reset_gs();
    //Parsing
	//Preprocessor remove Comments from buffe
	memblock = remove_line_comment(memblock, File_Lenght);
	memblock = remove_block_comment(memblock, File_Lenght);
	//printf("%s\n", memblock);
	//Using strlen is bad practice to tell the size of a buffer
	//Only use it when working with strings
    yy_scan_bytes(memblock, File_Lenght);
    yyparse();
	
	//Only set if memory allocation was used
	/*if(non_linear_allocation_used == true)
	{
		output_bin_buffer.size = max_size;
	}*/
	//It now uses a variable to determine that
	
	int address_pointer = 0;
	/*Output File Buffer removed because is best to use Output Bin Buffer Duh*/
	//char *OutputFileBuffer = (char*)malloc(sizeof(OutputFileBuffer) * output_bin_buffer.size);
	//memcpy(OutputFileBuffer, output_bin_buffer.data, output_bin_buffer.size);
	printf("strlen of buffer: %d\n",output_bin_buffer.max_size);
	/*
	for(int i = 0;i <= output_bin_buffer.size - 2;i = i + 2)
	{
		printf("16'h%x : data = 16'b"BYTE_TO_BINARY_PATTERN""BYTE_TO_BINARY_PATTERN";\n", address_pointer,
  BYTE_TO_BINARY(vector_get(&output_bin_buffer,i)), BYTE_TO_BINARY(vector_get(&output_bin_buffer,i + 1)));
		address_pointer++;
	}*/

	//printf("%s %d \n", t_buffer.data[0]->name, t_buffer.data[0]->addr);
	//printf("%s %d \n", t_buffer.data->name, t_buffer.data->addr);
    //Free all buffers
	FILE *write_ptr;
	write_ptr = fopen(OutputPATH,"wb");  // w for write, b for binary
	fwrite(output_bin_buffer.data, sizeof(char), output_bin_buffer.max_size + 2, write_ptr); // write 10 bytes from our buffer
	fclose(write_ptr);
    vector_free(&output_bin_buffer);
	t_buffer_delete(&t_buffer);
	//s_buffer_delete(&s_buffer);
	//free(OutputFileBuffer);
    return 0;
}
