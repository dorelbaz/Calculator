#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <float.h>

#define EXPRESSION_MAX_LENGTH 32
#define ERROR_MAX_LENGTH 100
#define FLT_MAX_DIGIT_NUMBER 50
#define ERROR 0
#define SUCCESS 1

#define ILLEGAL_DIVISION 0
#define LIMIT_EXCEEDED 1
#define UNDEFINED_EXPRESSION 2
#define SYNTAX_ERROR 3

enum button_values
{
    Zero, 
    One, 
    Two, 
    Three, 
    Four, 
    Give, 
    Six, 
    Seven, 
    Eight, 
    Nine, 
    Dot,
    Pi,
    Bspace, 
    Lp, 
    Rp, 
    Clr, 
    Mod, 
    Div, 
    Pow, 
    Mul, 
    Sqrt, 
    Minus,
    Factor, 
    Plus, 
    Equals     
};

enum operations {
    sub,
    add,
    mul,
    di,
    sroot,
    power,
    mod
};


extern FILE *yyin;
extern void yyrestart(FILE *);
extern int yyparse();
extern int yylex();

void execute();

void set_Expression(enum button_values val);
void format_Result();
void set_GUI();
extern int error;
extern char error_Message[ERROR_MAX_LENGTH];
extern double result;

void yyerror(const char *s);
int calculate(double *result, double val1, enum operations op, double val2);
int factor(double *result, int n);
int examine_Value(double value);