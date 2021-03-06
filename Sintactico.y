%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
#include "tabla_simbolos.h"

/* Desde el lexer. */
extern int yylineno; 
extern simbolo tabla_simbolos[1000];
extern tope;

FILE *yyin;
%}

%token ASIG COMA PAR_A PAR_C COR_A COR_C OP_SUM OP_RES OP_MUL OP_DIV
%token COMP_MEN COMP_MAY COMP_MEN_IGL COMP_MAY_IGL OP_AND OP_OR NOT
%token WHILE IN DO ENDWHILE IF ELSE ENDIF DISPLAY GET DIM AS FOR IGUAL TO STEP NEXT
%token ID VAR_INT VAR_REAL VAR_STR CONST_INT CONST_REAL CONST_STR
                                                
%%                                              
programa: bloque { printf("\nCompilacion OK\n"); }
bloque: bloque sentencia | sentencia
sentencia: asignacion | declaracion | decision | display | get | for | while

asignacion: ID ASIG expresion { printf("Regla -> asignacion expresion\n"); }
		  | ID ASIG CONST_STR { printf("Regla -> asignacion constante string\n"); }
		  
expresion: expresion OP_SUM termino
		 | expresion OP_RES termino
         | termino
termino: termino OP_MUL factor
       | termino OP_DIV factor
       | factor
factor: PAR_A expresion PAR_C 
      | ID
      | CONST_INT
      | CONST_REAL

declaracion: DIM COR_A lista_dec COR_C { printf("Regla -> declaracion\n"); }
lista_dec: ID COMA lista_dec COMA tipo { printf("Regla -> lista_dec: ID COMA lista_dec COMA tipo\n"); }
lista_dec: ID COR_C AS COR_A tipo { printf("Regla -> lista_dec: ID COR_C AS COR_A tipo\n"); }
tipo: VAR_INT { printf("Regla -> tipo: VAR_INT\n"); }
	| VAR_REAL { printf("Regla -> tipo: VAR_REAL\n"); }
	| VAR_STR { printf("Regla -> tipo: VAR_STR\n"); }
	
decision: IF PAR_A condicion_simple PAR_C bloque ENDIF { printf("Regla -> decision con condicion simple\n"); }
		| IF PAR_A condicion_simple PAR_C bloque ELSE bloque ENDIF { printf("Regla -> decision con condicion simple con ELSE\n"); }
		| IF NOT PAR_A condicion_simple PAR_C bloque ENDIF { printf("Regla -> decision NOT con condicion simple\n"); }
		| IF NOT PAR_A condicion_simple PAR_C bloque ELSE bloque ENDIF { printf("Regla -> decision NOT con condicion simple con ELSE\n"); }
		| IF PAR_A condicion_mult PAR_C bloque ENDIF { printf("Regla -> decision con condicion multiple\n"); }
		| IF PAR_A condicion_mult PAR_C bloque ELSE bloque ENDIF { printf("Regla -> decision con condicion multiple con ELSE\n"); }
condicion_simple: expresion comparador expresion
condicion_mult: expresion comparador expresion and_or expresion comparador expresion
comparador: IGUAL | COMP_MEN | COMP_MEN_IGL | COMP_MAY | COMP_MAY_IGL
and_or: OP_AND | OP_OR

display: DISPLAY CONST_STR { printf("Regla -> display constante string\n"); }
	   | DISPLAY ID { printf("Regla -> display ID\n"); }

get: GET ID { printf("Regla -> get ID\n"); }

for: FOR ID IGUAL expresion TO expresion bloque NEXT ID { printf("Regla -> for sin Step\n"); }
   | FOR ID IGUAL expresion TO expresion COR_A STEP CONST_INT COR_C bloque NEXT ID { printf("Regla -> for con Step\n"); }

while: WHILE condicion_simple DO bloque ENDWHILE { printf("Regla -> while\n"); }
while: WHILE condicion_mult DO bloque ENDWHILE { printf("Regla -> while\n"); }
while: WHILE ID IN COR_A lista_expresiones COR_C DO bloque ENDWHILE { printf("Regla -> while especial\n"); }
lista_expresiones: lista_expresiones COMA expresion
lista_expresiones: expresion
%%

int main(int argc, char *argv[])
{
	if ((yyin = fopen(argv[1], "rt")) == NULL)
	{
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
	}
	else
	{
		printf("\n");
		yyparse();
		
		printf("\nTabla de simbolos\n");
		printf("-----------------\n");
		mostrar_ts (tabla_simbolos, tope);
		guardar_ts (tabla_simbolos, tope);
		fclose(yyin);
	}

	return 0;
}

int yyerror()
{
    printf("Error sintactico en linea %d\n", yylineno);
    return 1;
}
