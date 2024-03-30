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
    double num;    
    enum operations op;           
};


%left ADD NEG

%left <op> MUL_DIV

%left FACTOR

%right SQRT MODULO POWER

%token <num> NUM

%nterm <num> expression


%define parse.error verbose
/* %error-verbose */

%%



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


void yyerror(const char *s)
{
    error++;
    printf("\n%s\n",s);
    strcpy(error_Message, error_messages[SYNTAX_ERROR]);
}

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


