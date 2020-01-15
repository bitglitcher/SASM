#include <stdbool.h>
// vector.h

#define VECTOR_INITIAL_CAPACITY 100
#define debug false

// Define a vector type
typedef struct {
  int size;      // slots used so far
  int max_size;
  int capacity;  // total available slots
  char *data;     // array of integers we're storing
} Vector;
//Has to have a prefix because the grammar internals already defines it

void vector_init(Vector *vector);

void vector_append(Vector *vector, char value);

char vector_get(Vector *vector, int index);

void vector_set(Vector *vector, int index, char value);

void vector_double_capacity_if_full(Vector *vector);

void vector_free(Vector *vector);

void vector_set_capacity(Vector *vector, int capacity);
