#include "Data_File.h"


/*
    Furthers the expression to the lexer and the parser for examination and execution.
*/
void execute()
{
    yyin = fopen("input.txt", "r");
    yyrestart(yyin);
    if (!yyin)
    {
        printf("\nAn Error Has Occured\n");
        exit(1);
    }
    yyparse();
    remove("input.txt");
    fclose(yyin);
    yyin = NULL;
}
