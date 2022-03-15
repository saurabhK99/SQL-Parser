/* Lex file for generating tokens for parser*/ 

%{
    #include "y.tab.h" 
    #include <string.h>   
%}

%%
(?i:update)    {return UPDATE; /* on using ?i: regex search will be case-insensitive  */}
(?i:set)      {return SET;}
(?i:where)     {return WHERE;}

[a-zA-Z]+   {yylval.str = strdup(yytext); return ID; /* store the searched pattern in yylval as str */}
[0-9]+      {yylval.str = strdup(yytext); return ID;}

"="             {yylval.str = strdup(yytext); return EQ;}
"<"             {yylval.str = strdup(yytext); return LT;}
">"             {yylval.str = strdup(yytext); return GT;}
"<="            {yylval.str = strdup(yytext); return LE;}
">="            {yylval.str = strdup(yytext); return GE;}
"<>"            {yylval.str = strdup(yytext); return NE;}
";"             {return DELIM;}
","             {return SEP;}
[ \n\t]         ;
%%

int yywrap() {
    return 1;
}