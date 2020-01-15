#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define N_SUPPORTED_ARGS 3

char* HELP_ARG = "--help";
char* VER_ARG = "--ver";
char* OUTPUT_ARG = "-o";
//Declared or detected flags
bool help_d;
bool ver_d;
bool output_d;
bool input_set = false;
#define HELP 0
#define VER 1
#define OUT_NAME 2

const char* help_msg = "DASM Assembler\n--help\t\tObiously HELP\n-o\t\tOutput File Name\n--ver\t\tBuild Version\n";
const char* build_version = "VERSION:\tBETA\n";
char* OutputFile = "ROM.bin"; //Default
char* InputFile;
void parse_arguments(int argc, char** argv)
{
char **args = malloc(sizeof(char**) * N_SUPPORTED_ARGS);
    *(args + 0) = &*HELP_ARG;
    *(args + 1) = &*VER_ARG;
    *(args + 2) = &*OUTPUT_ARG;
    //for(int i = 0;i <= 2;i++) printf("%s\n",*(args + i));
    argc = argc - 1;
    if(argc == 0)
    {
        printf("error: no input file\n");
    }
    //Check for valid arguments
    //Valid arguments should start with -- and a options letter
    for(int i = 0; i <= argc;i++)
    {
        for(int x = 0;x <= 2;x++)
        {
            if(strcmp(*(args + x), *(argv + i)) == 0)
            {
                switch(x)
                {
                    case HELP:      printf("%s",help_msg); break;
                    case VER:       printf("%s",build_version); break;
                    case OUT_NAME:  
                        //Check if there is another argument
                        if(argc > i)
                        {
                            OutputFile = malloc(sizeof(char*) *  strlen(*(argv + i++)));
                            OutputFile = *(argv + i);
                        }
                        else
                        {
                            printf("error: no name specified\n");
                        }
                    break;
                }
            }
        }
    }
    printf("Arguments argc %d\n", argc);
    printf("Output File %s\n", OutputFile);
}
enum letters {q = 61,w,e,r,t,y,u,i,o,p,a,s,d,f,g,h,j,k,l,z,x,c,v,b,n,m};
int check_identifier()
{
    //Identifiers are [A-Za-z]+[A-Za-z0-9]
}
int check_if_option(int argc, char** argv)
{
    char **args = malloc(sizeof(char**) * N_SUPPORTED_ARGS);
    *(args + 0) = &*HELP_ARG;
    *(args + 1) = &*VER_ARG;
    *(args + 2) = &*OUTPUT_ARG;
    //for(int i = 0;i <= 2;i++) printf("%s\n",*(args + i));
    argc = argc - 1;
    for(int i = 0; i <= argc;i++)
        {
            for(int x = 0;x <= 2;x++)
            {
                if(strcmp(*(args + x), *(argv + i)) == 0)
                {
                    switch(x)
                    {
                        case HELP:      return 1; break;
                        case VER:       return 1; break;
                        case OUT_NAME:  return 1; break;
                    }
                }
            }
        }
    return 0;
}
int main(int argc, char **argv)
{
    //argc = argc - 1;
    if(argc != 0)
    {
        if(argc == 1 && check_if_option(argc, argv) == 0)
        {
            if(check_if_option(argc, argv) == 1)
            {
                parse_arguments(argc, argv);
                printf("error: no input file\n");
            }
            else
            {
                input_set = true;
                InputFile = malloc(sizeof(char) * strlen(*(argv + 1)));
                InputFile = *(argv + 1);
            }
        }
        else
        {
            parse_arguments(argc, argv);
            printf("No input file\n");
            exit(1);
        }
    }
    else
    {
        printf("error: no input file\n");
    }
    if(input_set)
    {
        printf("error: no input file\n");
    }
    printf("Arguments argc %d\n", argc);
    printf("Output File %s\n", OutputFile);
    printf("Input File %s\n", InputFile);
    return 0;
}