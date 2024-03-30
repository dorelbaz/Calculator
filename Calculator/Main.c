#include <gtk/gtk.h>
#include "Data_File.h"
#include <sys/types.h>
#include <signal.h>
#include <unistd.h>
#include <gtk/gtkx.h>
#include <ctype.h>

GtkButton *BSPACE;
GtkButton *RP;
GtkButton *LP;
GtkButton *CLR;
GtkButton *MOD;
GtkButton *POW;
GtkButton *DIV;
GtkButton *NINE;
GtkButton *EIGHT;              
GtkButton *SEVEN;
GtkButton *SIX;
GtkButton *FIVE;
GtkButton *FOUR;
GtkButton *THREE; 
GtkButton *TWO;
GtkButton *ONE;
GtkButton *ZERO;
GtkButton *DOT;
GtkButton *PI;
GtkButton *SQRT;
GtkButton *MUL;
GtkButton *FACTOR;
GtkButton *MINUS;
GtkButton *PLUS;
GtkButton *EQUALS;
GtkLabel *Display1;
GtkLabel *Display2; 
GtkWidget *window;
GtkBuilder *builder;

void on_Button_Clicked(GtkButton *button);
enum button_values select_OP(const gchar *text);

static FILE *input;
static char expression[EXPRESSION_MAX_LENGTH+1];
char error_Message[ERROR_MAX_LENGTH];
int iexpr;
double result;
int error;

const char *buttons[] = {
    "0", 
    "1", 
    "2", 
    "3", 
    "4", 
    "5", 
    "6", 
    "7", 
    "8", 
    "9", 
    ".",
    "π",
    "Backspace", 
    "(", 
    ")", 
    "Clear", 
    "Mod(x)", 
    "/", 
    "x^y", 
    "*", 
    "Sqrt(x)", 
    "-",
    "!", 
    "+", 
    "=" 
};

// gcc -o calc Main.c -Wall `pkg-config --cflags --libs gtk+-3.0` -export-dynamic

int main (int argc, char **argv)
{
    gtk_init(&argc, &argv);

    builder = gtk_builder_new();
    gtk_builder_add_from_file(builder, "Calculator.glade", NULL);

    set_GUI();
    error = 0;
    strncpy(expression, "\0", EXPRESSION_MAX_LENGTH+1);
    iexpr = 0;

    gtk_label_set_max_width_chars(Display1, EXPRESSION_MAX_LENGTH);
    gtk_label_set_max_width_chars(Display2, EXPRESSION_MAX_LENGTH + strlen(" = ") + FLT_MAX_DIGIT_NUMBER);

    g_signal_connect(window, "destroy", G_CALLBACK(gtk_main_quit), NULL);
    gtk_builder_connect_signals(builder, NULL);
    g_object_unref(builder);
    
    gtk_widget_show_all(window);
    gtk_main();

    return EXIT_SUCCESS;
}


void on_Button_Clicked(GtkButton *button)
{
    const gchar *button_text = gtk_button_get_label(button);
    int button_value = select_OP(button_text);

    set_Expression(button_value);

    if (error)
    {
        gtk_label_set_text(Display1, error_Message);
        strncpy(expression, "\0", EXPRESSION_MAX_LENGTH+1);
        error = 0;
        iexpr = 0;
    }
    else if (button_value == Equals)
    {
        format_Result();
    }
    else
    {
        gtk_label_set_text(Display1, expression);
    } 

    result = 0;
}

enum button_values select_OP(const gchar *text)
{
    for (int i = Zero; i < Equals; i++)
    {
        if (!strcmp(text, buttons[i]))
        {
            return i;
        }
    }
    return Equals;
}

void set_Expression(enum button_values val)
{
    switch(val)
    {
        case Pi:
            if (iexpr + strlen("3.14") < EXPRESSION_MAX_LENGTH)
            {
                strcat(expression, "3.14");
                iexpr += strlen("3.14");
            }
            else
            {
                error++;
            }
            break;

        case Bspace:
            if (iexpr)
            {
                expression[iexpr-1] = '\0';
                iexpr--;
            }
            break;

        case Clr:
            strncpy(expression, "\0", EXPRESSION_MAX_LENGTH+1);
            gtk_label_set_text(Display2, expression);
            error = 0;
            iexpr = 0;
            break;

        case Mod:
            if (iexpr + strlen("mod(") < EXPRESSION_MAX_LENGTH)
            {
                strcat(expression, "mod(");
                iexpr += strlen("mod(");
            }
            else
            {
                error++;
            }
            break;                        

        case Sqrt:
            if (iexpr + strlen("sqrt(") < EXPRESSION_MAX_LENGTH)
            {
                strcat(expression, "sqrt(");
                iexpr += strlen("sqrt(");
            }
            else
            {
                error++;
            }
            break;

        case Equals:
            remove("input.txt");
            input = fopen("input.txt","a");
            if (!input)
            {
                printf("\nAn Error Has Occured\n");
                EXIT_FAILURE;
            }
            fprintf(input, "%s", expression);
            if (strcmp(expression,"\0") == 0) {break;}
            fclose(input);
            execute();
            break;

        default:
            if (iexpr < EXPRESSION_MAX_LENGTH)
            {
                if (val == Pow) 
                {
                    strcat(expression, "^");
                }
                else
                {
                    strcat(expression, buttons[val]);
                }
                iexpr++;
            }
            else
            {
                error++;
            }
    }  

    if (error != 0 && val != Equals)
    {
        strcpy(error_Message, "Maximum Length Of Expression Has Been Exceeded.\n");
    }
}

void format_Result()
{
    char result_expression[FLT_MAX_DIGIT_NUMBER];
    strncpy(result_expression, "\0", FLT_MAX_DIGIT_NUMBER);

    if (strcmp(expression,"\0"))
    {
        if (roundf(result) != result)
        {
            sprintf(result_expression, "%f\n", result);
        }
        else
        {
            sprintf(result_expression, "%ld\n", (long) (result));
        }
    }

    gtk_label_set_text(Display2, result_expression);
}

void set_GUI()
{
    window = GTK_WIDGET(gtk_builder_get_object(builder, "Calculator_Interface"));

    BSPACE = GTK_BUTTON(gtk_builder_get_object(builder, "BSPACE"));
    RP = GTK_BUTTON(gtk_builder_get_object(builder, "RP"));
    LP = GTK_BUTTON(gtk_builder_get_object(builder, "LP"));
    CLR = GTK_BUTTON(gtk_builder_get_object(builder, "CLR"));
    MOD = GTK_BUTTON(gtk_builder_get_object(builder, "MOD"));
    POW = GTK_BUTTON(gtk_builder_get_object(builder, "POW"));
    DIV = GTK_BUTTON(gtk_builder_get_object(builder, "DIV"));
    NINE = GTK_BUTTON(gtk_builder_get_object(builder, "NINE"));
    EIGHT = GTK_BUTTON(gtk_builder_get_object(builder, "EIGHT"));               
    SEVEN = GTK_BUTTON(gtk_builder_get_object(builder, "SEVEN"));
    SIX = GTK_BUTTON(gtk_builder_get_object(builder, "SIX"));
    FIVE = GTK_BUTTON(gtk_builder_get_object(builder, "FIVE"));
    FOUR = GTK_BUTTON(gtk_builder_get_object(builder, "FOUR"));
    THREE = GTK_BUTTON(gtk_builder_get_object(builder, "THREE"));
    TWO = GTK_BUTTON(gtk_builder_get_object(builder, "TWO"));
    ONE = GTK_BUTTON(gtk_builder_get_object(builder, "ONE"));
    ZERO = GTK_BUTTON(gtk_builder_get_object(builder, "ZERO"));
    DOT = GTK_BUTTON(gtk_builder_get_object(builder, "DOT"));
    PI = GTK_BUTTON(gtk_builder_get_object(builder, "PI"));
    SQRT = GTK_BUTTON(gtk_builder_get_object(builder, "SQRT"));
    MUL = GTK_BUTTON(gtk_builder_get_object(builder, "MUL"));
    FACTOR = GTK_BUTTON(gtk_builder_get_object(builder, "FACTOR"));
    MINUS = GTK_BUTTON(gtk_builder_get_object(builder, "MINUS"));
    PLUS = GTK_BUTTON(gtk_builder_get_object(builder, "PLUS"));
    EQUALS = GTK_BUTTON(gtk_builder_get_object(builder, "EQUALS"));
    
    Display1 = GTK_LABEL(gtk_builder_get_object(builder, "Display1"));
    Display2 = GTK_LABEL(gtk_builder_get_object(builder, "Display2"));
}




