#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
//Struct for the tag names
#define INIT_S_BUFFER_SIZE 100
#define debug false

typedef struct
{
	char * name;
	unsigned short int addr;
    unsigned short int lenght;
} STR_NODE;
typedef struct
{
    bool first_iteration;
	int size;
	int capacity;
	STR_NODE *data;
} STR_BUFFER;
void s_buffer_double_capacity_if_full(STR_BUFFER *s_buffer);
void s_buffer_init(STR_BUFFER *s_buffer);
void s_append(STR_BUFFER *s_buffer, const char *name, unsigned short int _addr, int lenght);
void s_buffer_delete(STR_BUFFER *s_buffer);
unsigned short int s_buffer_locate_tag_addr(STR_BUFFER *s_buffer, const char* name);
unsigned short int s_buffer_get_str_len(STR_BUFFER *s_buffer, const char* name);
int s_buffer_find_maching_name(STR_BUFFER* s_buffer, const char* name);
