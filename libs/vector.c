// vector.c

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vector.h"
#include <stdbool.h>
void vector_init(Vector *vector) {
  // initialize size and capacity
  vector->size = 0;
  vector->capacity = VECTOR_INITIAL_CAPACITY;
  // allocate memory for vector->data
  vector->data = malloc(sizeof(char) * vector->capacity);
  for(size_t i = 0;i <= vector->capacity;i++)
  {
    vector->data [i] = 0x00;
  }
}
//bool first = true;
bool vector_wait_slot = true;
bool vector_g_wait_slow = false;
void vector_append(Vector *vector, char value) {
  // make sure there's room to expand into
  if(/*vector->size == 0 && */(vector_wait_slot == true))
  {
    //vector_double_capacity_if_full(vector);
    vector_wait_slot = false;
    if(vector->max_size < vector->size)
    {
      vector->max_size = vector->size;
    }
  }
  else
  {
    vector_double_capacity_if_full(vector);
    vector->size++;
    if(vector->max_size < vector->size)
    {
      vector->max_size = vector->size;
    }
  }
  if(debug)
  {
    printf("Appending value: %x\n",value);
    printf("Index: %d\n", vector->size);
  }
  vector_double_capacity_if_full(vector);
  // append the value and increment vector->size
  vector->data[vector->size] = value;
}

char vector_get(Vector *vector, int index) {
  if (index >= vector->size || index < 0) {
    printf("Index %d out of bounds for vector of size %d\n", index, vector->size);
    exit(1);
  }
  return vector->data[index];
}

void vector_set(Vector *vector, int index, char value) {
  // zero fill the vector up to the desired index
  while (index >= vector->size) {
    vector_append(vector, 0);
  }

  // set the value at the desired index
  vector->data[index] = value;
}

void vector_double_capacity_if_full(Vector *vector) {
  if (vector->size >= vector->capacity) {
    // double vector->capacity and resize the allocated memory accordingly
    vector->capacity *= 2;
    //vector->data = realloc(vector->data, sizeof(char) * 200);
    char* saved_data = malloc(sizeof(char) * vector->size);
    memmove (saved_data, vector->data, vector->size);
    vector->data = (char*) calloc(vector->capacity,sizeof(char));
    memmove (vector->data, saved_data, vector->size);
    free(saved_data);
  }
}

void vector_free(Vector *vector) {
  free(vector->data);
}

void vector_set_capacity(Vector *vector, int capacity) {
    if(vector->capacity < capacity)
    {
      // double vector->capacity and resize the allocated memory accordingly
      vector->capacity *= capacity;
      //vector->data = realloc(vector->data, sizeof(char) * 200);
      char* saved_data = malloc(sizeof(char) * vector->size);
      memmove (saved_data, vector->data, vector->size);
      vector->data = (char*) calloc(vector->capacity,sizeof(char));
      memmove (vector->data, saved_data, vector->size);
      free(saved_data);
    }
}