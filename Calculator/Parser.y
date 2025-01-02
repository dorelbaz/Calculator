
/*
    Examines the expression for its validity and calculates valid expressions during the parsing process (on the fly).
*/

%{

#include "Data_File.h"
#include "Parser.tab.h"

const char *error_messages[] = {
    "Division With 0.\n",
    "Result Exceeds Numerical Limit.\n",
    "Undefined Expression.\n",
    "Syntax Error.\n"
};

%}


%union {
    double num;            // Keeps track of numbers.
    enum operations op;    // Keeps track of the arithmetical operations.       
};

// Sets the operation precedence of the arithmetical operations (left to right or right to left) for the parser.
%left ADD NEG              

// <op> refers to '*' and '/' and op field within the union.
%left <op> MUL_DIV         

%left FACTOR               

%right SQRT MODULO POWER

// Defines the terminals (leaf nodes, also known as tokens) and none-terminals for the parser. The above are also tokens.
%token <num> NUM

%nterm <num> expression

// Enable parser error messages.
%define parse.error verbose
/* %error-verbose */

%%

/*
    The following rules define the general structure of a valid, arithmetical expression. Such as:
    (arithmetical expression) = [+|-] number,
    (arithmetical expression) [+|-|*|/] (arithmetical expression),
     sqrt (arithmetical expression),
    (arithmetical expression) mod (arithmetical expression).
*/

// Result gets the final answer of the calculation.
answer :         expression                                         {result = $1;}


expression :     expression ADD expression                          {

    int flag = calculate(&$$,$1,add,$3);
    if (flag == ERROR)
    {
        YYABORT;           
    }

}


expression :     expression NEG expression                          {
    
    int flag = calculate(&$$,$1,sub,$3);
    if (flag == ERROR)
    {
        YYABORT;           
    }

}


|               expression MUL_DIV expression                       {

    // Checks division by 0 (whether the operation (MUL_DIV) is division and the right expression is 0). 
    if ($2 == di && $3 == 0)
    {
        error++;
        strcpy(error_Message, error_messages[UNDEFINED_EXPRESSION]);
        YYABORT;
    }
    else
    {
        int flag = calculate(&$$,$1,$2,$3);
        if (flag == ERROR)
        {
            YYABORT;           
        }
    }

}



|           expression POWER expression                             {

    // The expression 0^n is illegal in this calculator.
    if ($1 == 0)
    {
        error++;
        strcpy(error_Message, error_messages[UNDEFINED_EXPRESSION]);
        YYABORT;       
    }
    int flag = calculate(&$$, $1, power, $3); 
    if (flag == ERROR)
    {
        YYABORT;           
    }   

}



|           expression MODULO  '(' expression ')'                   {

    // Modulo only accepts none-0, whole numbers.
    if (ceilf($1) != $1  || ceilf($4) != $4 || $4 == 0)
    {
        error++;
        strcpy(error_Message, error_messages[UNDEFINED_EXPRESSION]);
        YYABORT;
    }
    int flag = calculate(&$$, $1, mod, $4); 
    if (flag == ERROR)
    {
        YYABORT;           
    } 

}


|            expression SQRT '(' expression ')'                     {

    // Checks for negatives in the root.
    if ($4 < 0)
    {
        error++;
        strcpy(error_Message, error_messages[UNDEFINED_EXPRESSION]);
        YYABORT;
    }
    int flag = calculate(&$$, $1, sroot, $4);
    if (flag == ERROR)
    {
        YYABORT;           
    }        

}



|             SQRT  '(' expression ')'                              {

    if ($3 < 0)
    {
        error++;
        strcpy(error_Message, error_messages[UNDEFINED_EXPRESSION]);
        YYABORT;
    }
    int flag = calculate(&$$, 1, sroot, $3);
    if (flag == ERROR)
    {
        YYABORT;           
    } 

}



|               expression  FACTOR                                  {

    // Factorial only accepts 0 or positive whole numbers.
    if (ceilf($1) == $1 && $1 >= 0)
    {
        int flag = factor(&$$, $1); 
        if (flag == ERROR)
        {
            YYABORT;           
        }
    }
    else
    {
        error++;
        strcpy(error_Message, error_messages[UNDEFINED_EXPRESSION]);
        YYABORT;
    }

}



|               '(' expression ')'                                  {$$ = $2;}


|               NEG NUM                                             {$$ = (-1) * $2;}


|               ADD NUM                                             {$$ = $2;}


|               NUM                                                 {$$ = $1;}



%%

/*
    Prints the error message found during the parsing process.
*/
void yyerror(const char *s)
{
    error++;
    printf("\n%s\n",s);
    strcpy(error_Message, error_messages[SYNTAX_ERROR]);
}

/*
    Calculates valid expressions during the parsing process, stores it in result 
    and returns if the calculation is valid.
*/
int calculate(double *result, double val1, enum operations op, double val2)
{
    switch(op)
    {
        case sub:
            *result = val1 - val2;
            break;

        case add:
            *result = val1 + val2;
            break;

        case mul:
            *result = val1 * val2;
            break;

        case di:
            *result = val1 / val2;
            break;

        case power:
            *result = pow(val1, val2);
            break;

        case sroot:
            *result = val1 * sqrt(val2);
            break;

        case mod:
            *result = fmod(val1,val2);
    }

    return examine_Value(*result);
}
    
/*
    Calculates n! stores it in result and returns if the calculation is valid.
*/
int factor(double *result, int n)
{
    *result = 1;

    if (n <= 1)
    {
        return SUCCESS;
    }

    while (1 < n)
    {
        (*result) *= n;
        if (examine_Value((*result)) == ERROR)
        {
            return ERROR;
        }
        n--;
    }

    return SUCCESS;
}

/*
    Examines if a calculation exceeds the minimum or maximum limit.
*/
int examine_Value(double value)
{
    if (value < (-1)*FLT_MAX  || FLT_MAX < value)
    {
        error++;
        strcpy(error_Message, error_messages[LIMIT_EXCEEDED]);
        return ERROR;
    }
    return SUCCESS;
}


