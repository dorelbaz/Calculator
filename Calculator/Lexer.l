%{

#include "Data_File.h"
#include "Parser.tab.h"

const char *ops[] = {
    "-",
    "+",
    "*", 
    "/"
};

%}


%%

"(" {return '(';}

")" {return ')';}


"mod"       {return MODULO;}

"^"         {return POWER;}

"sqrt"      {return SQRT;}

"!"         {return FACTOR;}



"*"         {yylval.op = mul; return MUL_DIV;}

"/"         {yylval.op = di; return MUL_DIV;}


"-"         {return NEG;}

"+"         {return ADD;}


[0-9]+ |

[0-9]+?[.][0-9]+ {yylval.num = atof(yytext); return NUM;}




. {;}

%%

int yywrap()
{
    return 1;
}
