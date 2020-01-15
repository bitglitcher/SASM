#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include "s_buffer.h"

void s_buffer_double_capacity_if_full(STR_BUFFER *s_buffer)
{
    if(s_buffer->size >= s_buffer->capacity) 
    {
        s_buffer->capacity *= 2;
        s_buffer->data = realloc(s_buffer->data, sizeof(STR_NODE) * s_buffer->capacity);
    }
}
void s_buffer_init(STR_BUFFER *s_buffer)
{
    s_buffer->capacity = INIT_S_BUFFER_SIZE;
    s_buffer->size = 0;
    s_buffer->first_iteration = true;
    //Allocate STR_NODES
    s_buffer->data = malloc(sizeof(STR_NODE) * INIT_S_BUFFER_SIZE);
}
void s_append(STR_BUFFER *s_buffer, const char *name, unsigned short int _addr, int _lenght)
{
    if(s_buffer->first_iteration)
        s_buffer->first_iteration = false;
    else
        s_buffer->size++;
    s_buffer_double_capacity_if_full(s_buffer);
    s_buffer->data[s_buffer->size].lenght = _lenght;
    s_buffer->data[s_buffer->size].addr = _addr;
    s_buffer->data[s_buffer->size].name = malloc(sizeof(char*) * strlen(name));
    strcpy(s_buffer->data[s_buffer->size].name, name);

    if(debug)
    {
        printf("\tAppended: %s\n",s_buffer->data[s_buffer->size].name);
        printf("\tAppending: %s\n",name);
        printf("\tSize: %d\n", s_buffer->size);
        printf("\tLenght: %d\n", s_buffer->data[s_buffer->size].lenght);
    }
}
void s_buffer_delete(STR_BUFFER *s_buffer)
{
    //Free all strings
    if(s_buffer->first_iteration)
    {
        for(size_t i = 0;i <= s_buffer->size;i++)
        {
            free(s_buffer->data[i].name);
        }
    }
    //Then free all NODES
    free(s_buffer->data);
}
unsigned short int s_buffer_locate_tag_addr(STR_BUFFER *s_buffer, const char* name)
{
    for(size_t i = 0;i <= s_buffer->size;i++)
	{
		if(strcmp(s_buffer->data[i].name, name) == 0)
		{
		    
			return s_buffer->data[i].addr; //Maching identity
		}
	}
	printf("No maching name tags localized\n");
    return 0; //No maching identytis
}
unsigned short int s_buffer_get_str_len(STR_BUFFER *s_buffer, const char* name)
{
    for(size_t i = 0;i <= s_buffer->size;i++)
	{
		if(strcmp(s_buffer->data[i].name, name) == 0)
		{
			return s_buffer->data[i].lenght; //Maching identity
		}
	}
	printf("No maching name tags localized\n");
    return 0; //No maching identytis
}
int s_buffer_find_maching_name(STR_BUFFER* s_buffer, const char* name)
{
    if(debug)
        printf("ITER\n");
	for(size_t i = 0;i <= s_buffer->size;i++)
	{
        if(debug)
        {
            printf("\tTMP DATA: %s", s_buffer->data[i].name);
            printf(" TMP DATA INDEX: %d\n", i);
        }
        if(s_buffer->data[i].name != NULL)
        {
            if(debug) printf("NOT NULL\n");
    		if(memcmp(s_buffer->data[i].name, name, strlen(s_buffer->data[i].name)) == 0)
    		{
    			//printf("Maching identifier found!\n");
    			return 1; //Maching identity
    		}
        }
	}
	return 0; //No maching identities
}
/*
int main()
{
    const char* str = "Hola Perros";
    STR_BUFFER s_buffer;//TAG buffer doesnt need to be a pointer
    s_buffer_init(&s_buffer);
    printf("capacity :%d\n", s_buffer.capacity);
    printf("size :%d\n", s_buffer.size);
    t_append(&s_buffer, str, 0x0a);
    printf("capacity :%d\n", s_buffer.capacity);
    printf("size :%d\n", s_buffer.size);;
    printf("string :%s\n", s_buffer.data[0].name);
    if(s_buffer_find_maching_name(&s_buffer, str) == 1)
    {
        printf("Found 0x%x\n",s_buffer_locate_tag_addr(&s_buffer, str));

    }
    else{
        printf("Not Found\n");
    }
    s_buffer_delete(&s_buffer);
    return 0;
}*/