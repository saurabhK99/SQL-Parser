%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<ctype.h>
    #include<string.h>
    #include <unistd.h>

    /* a dummy table for performing update operation */
    struct table {
        int sno;
        char* name;
        int CD;
        int DBA;
    }demo[10];

    /* used for storing the column, operator and value passed in WHERE clause */
    char* column;
    char* op;
    char* val;

    /* Function to initialize demo table and other global variables */
    void init();

    /* Funciton to print the table */
    void show();

    /* Funciton to store the values from WHERE clause to the above mentioned variables */
    void filter(char*, const char*, const char*);

    /* Funciton to check for some syntax errors */
    int find(const char*, const char*);

    /* Function to update the value in the table */
    void setValue(char*, char*);

    /* Utility function for relational operators */
    int check(int, char*, char*);
%}

/* defining the tokens to be used */
%token<str> ID NE EQ GE LE LT GT
%token WHERE UPDATE SET DELIM SEP

/* defining the type of the NT */
%type <str> relop

/* specifyng the datatype to be used by yylval */
%union {
    char* str;
}

%%

query : |
        query UPDATE ID SET columns DELIM{
            if(strcmp($3, "demo")) yyerror("Use Table : demo!");

            printf("\nTABLE UPDATED!\n");
            show();
            column = strdup("invalid");
            printf("\n> ");
        }
      ;

columns : ID EQ ID SEP columns {
            setValue($1, $3);
        }
        | ID EQ ID cond {
            setValue($1, $3); 
        }
        ;

cond : |
       WHERE condition  
     ;

condition : ID relop ID {
                filter($1, $2, $3); 
            }
          ;

relop : EQ  {$$ = $1;} 
      | NE  {$$ = $1;} 
      | LE  {$$ = $1;} 
      | GE  {$$ = $1;} 
      | LT  {$$ = $1;} 
      | GT  {$$ = $1;} 
      ;


%%

/* function to print error */
void yyerror(const char *e) {
    printf("\n%s\n\n", e);
    exit(1);
}

/* main funcion */
int main() {
    init();
    show();
    printf("\n> ");
    yyparse();

    return 0;
}

void show() {
    printf("------------------------------------\n");
    printf("sno\t name\t\t cd\t dba\n");
    printf("------------------------------------\n");
    for(int i = 0; i < 10; i++) {
        printf("%-5d\t %-10s\t %-5d\t %-5d\n", demo[i].sno, demo[i].name, demo[i].CD, demo[i].DBA);
    }
}

void init() {
    column = strdup("invalid");
    char* op = (char*) malloc(5);
    char* val = (char*) malloc(20);
    
    char ch = 'A';
    for(int i = 0; i < 10; i++) {
        demo[i].sno = i+1;

        demo[i].name = (char*) malloc(25);
        memset(demo[i].name, '\0', sizeof(demo[i].name));
        demo[i].name[0] = ch;
        ch++;

        demo[i].CD = 75 + i;
        demo[i].DBA = 85 - i;
    }
}

void filter(char* col, const char* relop, const char* v) {
    //convert the column to lowercase
    for(int i = 0; col[i] != '\0'; i++)
        col[i] = tolower(col[i]);

    //assign the values to the global variables
    column = strdup(col);
    op = strdup(relop);
    val = strdup(v);

    //check if column exists in table
    if(!find(column, "column")) {
        yyerror("Invalid Column!");
    }

    //check if operator valid
    if(!find(op, "operator")) {
        yyerror("Invalid operator!");
    }
}

int find(const char* str, const char* type) {
    if(!strcmp(type, "column")) {
        if(!strcmp(str, "sno")
            || !strcmp(str, "name")
            || !strcmp(str, "cd")
            || !strcmp(str, "dba")) {
                return 1;
            }
    }

    if(!strcmp(type, "operator")) {
        if(!strcmp(str, "<=")
            || !strcmp(str, ">=")
            || !strcmp(str, "<")
            || !strcmp(str, ">")
            || !strcmp(str, "=")
            || !strcmp(str, "<>")) {
                return 1;
            }
    }

    return 0;
}

void setValue(char* col, char* v) {
    //convert to lowercase
    for(int i = 0; col[i] != '\0'; i++)
        col[i] = tolower(col[i]);
        
    //check if column exists
    if(!find(col, "column")) {
        yyerror("Invalid column in set clause!");
    }

    //loop for all the rows in the table
    for(int i = 0; i < 10; i++) {
        //check whether where clause mentioned or not
        if(strcmp(column, "invalid")) {
            if(!strcmp(column, "sno")) {
                if(!(check(demo[i].sno, val, op))) {
                    continue;
                }
            }

            else if(!strcmp(column, "name")) {
                if(strcmp(op, "=") && strcmp(op, "<>"))
                    yyerror("Invalid operator in where clause!");

                if(!strcmp(op, "=") && strcmp(demo[i].name, val)) {
                    continue;
                }

                else if(!strcmp(op, "<>") && !strcmp(demo[i].name, val)) {
                    continue;
                }
            }

            else if(!strcmp(column, "cd")) {
                if(!(check(demo[i].CD, val, op)))
                    continue;
            }

            else if(!strcmp(column, "dba")) {
                if(!(check(demo[i].DBA, val, op)))
                    continue;
            }
        }

        //update the values
        if(!strcmp(col, "sno"))
            demo[i].sno = atoi(v);

        if(!strcmp(col, "name"))
            demo[i].name = v;

        if(!strcmp(col, "cd"))
            demo[i].CD = atoi(v);

        if(!strcmp(col, "dba"))
            demo[i].DBA = atoi(v);
    }
}

int check(int tableVal, char* val, char* op) {
    if(!strcmp(op, "="))
        return tableVal == atoi(val);

    if(!strcmp(op, ">"))
        return tableVal > atoi(val);

    if(!strcmp(op, ">="))
        return tableVal >= atoi(val);

    if(!strcmp(op, "<"))
        return tableVal < atoi(val);

    if(!strcmp(op, "<="))
        return tableVal <= atoi(val);

    if(!strcmp(op, "<>"))
        return tableVal != atoi(val);
}