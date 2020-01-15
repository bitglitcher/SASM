#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include "t_buffer.h"

void t_buffer_double_capacity_if_full(TAG_BUFFER *t_buffer)
{
    if(t_buffer->size >= t_buffer->capacity) 
    {
        t_buffer->capacity *= 2;
        t_buffer->data = realloc(t_buffer->data, sizeof(TAG_NODE) * t_buffer->capacity);
    }
}
void t_buffer_init(TAG_BUFFER *t_buffer)
{
    t_buffer->capacity = INIT_T_BUFFER_SIZE;
    t_buffer->size = 0;
    //Allocate TAG_NODES
    t_buffer->data = malloc(sizeof(TAG_NODE) * INIT_T_BUFFER_SIZE);
}
void t_append(TAG_BUFFER *t_buffer, const char *name, unsigned short int _addr)
{
    if(!t_buffer->first_iteration)
        t_buffer->first_iteration = true;
    else
        t_buffer->size++;
    t_buffer_double_capacity_if_full(t_buffer);
    t_buffer->data[t_buffer->size].addr = _addr;
    t_buffer->data[t_buffer->size].name = malloc(sizeof(char*) * strlen(name));
    strcpy(t_buffer->data[t_buffer->size].name, name);
}
void t_buffer_delete(TAG_BUFFER *t_buffer)
{
    //Free all strings
    if(t_buffer->first_iteration)
    {
        for(size_t i = 0;i <= t_buffer->size;i++)
        {
            free(t_buffer->data[i].name);
        }
    }
    //Then free all NODES
    free(t_buffer->data);
}
unsigned short int t_buffer_locate_tag_addr(TAG_BUFFER *t_buffer, const char* name)
{
    for(size_t i = 0;i <= t_buffer->size;i++)
	{
		if(strcmp(t_buffer->data[i].name, name) == 0)
		{
		    
			return t_buffer->data[i].addr; //Maching identity
		}
	}
	printf("No maching name tags localized\n");
    return 0; //No maching identytis
}
int t_buffer_find_maching_name(TAG_BUFFER* t_buffer, const char* name)
{
	for(size_t i = 0;i <= t_buffer->size;i++)
	{
		if(strcmp(t_buffer->data[i].name, name) == 0)
		{
			return 1; //Maching identity
			//printf("Maching identifier found!\n");
		}
	}
	return 0; //No maching identities
}

int t_buffer_is_prototype(TAG_BUFFER* t_buffer, const char* name)
{
	for(size_t i = 0;i <= t_buffer->size;i++)
	{
		if(strcmp(t_buffer->data[i].name, name) == 0)
		{
            if(t_buffer->data[i].prototype == true)
            {
			    return 1; //Maching identity
            }
            else
            {
                return 0;
            }
			//printf("Maching identifier found!\n");
		}
	}
}

void t_buffer_set_addr(TAG_BUFFER* t_buffer, const char* name, unsigned short int _addr)
{
	for(size_t i = 0;i <= t_buffer->size;i++)
	{
		if(strcmp(t_buffer->data[i].name, name) == 0)
		{
            t_buffer->data[i].addr = _addr;
			//printf("Maching identifier found!\n");
		}
	}
}
/*
int main()
{
    const char* str = "Hola Perros";
    TAG_BUFFER t_buffer;//TAG buffer doesnt need to be a pointer
    t_buffer_init(&t_buffer);
    printf("capacity :%d\n", t_buffer.capacity);
    printf("size :%d\n", t_buffer.size);
    t_append(&t_buffer, str, 0x0a);
    printf("capacity :%d\n", t_buffer.capacity);
    printf("size :%d\n", t_buffer.size);;
    printf("string :%s\n", t_buffer.data[0].name);
    if(t_buffer_find_maching_name(&t_buffer, str) == 1)
    {
        printf("Found 0x%x\n",t_buffer_locate_tag_addr(&t_buffer, str));

    }
    else{
        printf("Not Found\n");
    }
    t_buffer_delete(&t_buffer);
    return 0;
}*/