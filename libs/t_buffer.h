#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
//Struct for the tag names
#define INIT_T_BUFFER_SIZE 100
#define debug false

typedef struct
{
	char * name;
	unsigned short int addr;
	bool prototype;
} TAG_NODE;
typedef struct
{
    bool first_iteration;
	int size;
	int capacity;
	TAG_NODE *data;
} TAG_BUFFER;
void t_buffer_double_capacity_if_full(TAG_BUFFER *t_buffer);
void t_buffer_init(TAG_BUFFER *t_buffer);
void t_append(TAG_BUFFER *t_buffer, const char *name, unsigned short int _addr);
void t_buffer_delete(TAG_BUFFER *t_buffer);
unsigned short int t_buffer_locate_tag_addr(TAG_BUFFER *t_buffer, const char* name);
int t_buffer_find_maching_name(TAG_BUFFER* t_buffer, const char* name);
int t_buffer_is_prototype(TAG_BUFFER* t_buffer, const char* name);
void t_buffer_set_addr(TAG_BUFFER* t_buffer, const char* name, unsigned short int _addr);