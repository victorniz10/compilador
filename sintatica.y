%{
#include <iostream>
#include <string>
#include <sstream>
#include <map>

#define YYSTYPE atributos

using namespace std;

struct atributos
{
	string label;
	string traducao;
	string tipo;
	string valor;
};

int yylex(void);

string MSG_ERRO = "Errore:";

void yyerror(string);

static int ctdDInt = 0, ctdDFloat = 0, ctdDChar = 0, ctdDBool = 0;

std::map<string,atributos> mapaDeVariaveis; 

string tabelaDeTipos(string tipo1, string tipo2){

	if(tipo1 == "inteiro" && tipo2 == "inteiro"){
		ctdDInt += 1;
		return "int";
	}
	else{
		ctdDFloat += 1;
		return "float";
	}
}

string geraVarTemp(string tipo){

	static int nI = 0, nF = 0, nC = 0, nB = 0;
	
	if(tipo == "int"){
		nI++;
		return "TMP_INT_" + to_string(nI);
	}
	if(tipo == "float"){
		nF++;
		return "TMP_FLOAT_" + to_string(nF);
	}
	if(tipo == "char"){
		nC++;
		return "TMP_CHAR_" + to_string(nC);
	}
	if(tipo == "bool"){
		nB++;
		return "TMP_BOOL_" + to_string(nB);
	}
}

string geraLabelFinal(){
	int i = 1;
	string declaracao = ""; 

	if(ctdDInt > 0){
		declaracao = declaracao + "\tint ";
		while(i < ctdDInt){
			declaracao = declaracao + "TMP_INT_" + to_string(i) + ", ";
			i++;
		}
		declaracao = declaracao + "TMP_INT_" + to_string(i) + ";\n";
		i = 1;
	}
	if(ctdDFloat > 0){
		declaracao = declaracao + "\tfloat ";
		while(i < ctdDFloat){
			declaracao = declaracao + "TMP_FLOAT_" + to_string(i) + ", ";
			i++;
		}
		declaracao = declaracao + "TMP_FLOAT_" + to_string(i) + ";\n";
		i = 1;
	}
	if(ctdDChar > 0){
		declaracao = declaracao + "\tchar ";
		while(i < ctdDChar){
			declaracao = declaracao + "TMP_CHAR_" + to_string(i) + ", ";
			i++;
		}
		declaracao = declaracao + "TMP_CHAR_" + to_string(i) + ";\n";
		i = 1;
	}
	if(ctdDBool > 0){
		declaracao = declaracao + "\tbool ";
		while(i < ctdDBool){
			declaracao = declaracao + "TMP_BOOL_" + to_string(i) + ", ";
			i++;
		}
		declaracao = declaracao + "TMP_BOOL_" + to_string(i) + ";\n";
		i = 1;
	}

	return declaracao + "\n";
}

/*string geraLabelFinalAtribuicao(){
	int i = 1;
	string declaracao = ""; 

	if(ctdDInt > 0){
		declaracao = declaracao + "\tint ";
		while(i < ctdDInt){
			declaracao = declaracao + "TMP_INT_" + to_string(i) + ", ";
			i++;
		}
		declaracao = declaracao + "TMP_INT_" + to_string(i) + ";\n";
		i = 1;
	}
	if(ctdDFloat > 0){
		declaracao = declaracao + "\tfloat ";
		while(i < ctdDFloat){
			declaracao = declaracao + "TMP_FLOAT_" + to_string(i) + ", ";
			i++;
		}
		declaracao = declaracao + "TMP_FLOAT_" + to_string(i) + ";\n";
		i = 1;
	}
	if(ctdDChar > 0){
		declaracao = declaracao + "\tchar ";
		while(i < ctdDChar){
			declaracao = declaracao + "TMP_CHAR_" + to_string(i) + ", ";
			i++;
		}
		declaracao = declaracao + "TMP_CHAR_" + to_string(i) + ";\n";
		i = 1;
	}
	if(ctdDBool > 0){
		declaracao = declaracao + "\tbool ";
		while(i < ctdDBool){
			declaracao = declaracao + "TMP_BOOL_" + to_string(i) + ", ";
			i++;
		}
		declaracao = declaracao + "TMP_BOOL_" + to_string(i) + ";\n";
		i = 1;
	}

	return declaracao + "\n";
}*/

%}

%token TOKEN_MAIN
%token TOKEN_BEGIN

%token TOKEN_INT
%token TOKEN_FLOAT
%token TOKEN_DOUBLE
%token TOKEN_CHAR
%token TOKEN_BOOL

%token TOKEN_NULL
%token TOKEN_VOID
%token TOKEN_IF
%token TOKEN_ELSE
%token TOKEN_SWITCH
%token TOKEN_CASE
%token TOKEN_BREAK
%token TOKEN_DO
%token TOKEN_FOR
%token TOKEN_RETURN
%token TOKEN_PRINT
%token TOKEN_ERROR
%token TOKEN_STRUCT

%token TOKEN_NOMEVAR
%token TOKEN_NUM_INT
%token TOKEN_NUM_FLOAT
%token TOKEN_BOOLEAN_FALSE
%token TOKEN_BOOLEAN_TRUE
%token TOKEN_CARACTERE

%token TOKEN_MAIOR
%token TOKEN_MENOR
%token TOKEN_DIF
%token TOKEN_IGUAL
%token TOKEN_MAIORIGUAL
%token TOKEN_MENORIGUAL
%token TOKEN_E
%token TOKEN_OU

%token TOKEN_CONV_FLOAT
%token TOKEN_CONV_INT


%token TOKEN_ATR

%left TOKEN_E TOKEN_OU 
%left TOKEN_MAIOR TOKEN_MENOR TOKEN_MAIORIGUAL TOKEN_MENORIGUAL TOKEN_DIF TOKEN_IGUAL 
%left ','
%left '+' '-'
%left '*' '/'
%left '(' 
%left TOKEN_CONV_FLOAT TOKEN_CONV_INT


%start S

%%

S		    : TOKEN_BEGIN TOKEN_MAIN '(' ')' BLOCO 
            {
				cout << "/*Compilador ITL*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" <<
				$5.traducao << "\treturn 0;\n}" << endl; 							
			}
			;

BLOCO		: '{' COMANDOS '}'
			{
				$$.label = geraLabelFinal();
				$$.traducao = $$.label + $2.traducao;
			}
			;

COMANDOS	: COMANDO COMANDOS
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			| 
			{
				$$.traducao = "";
			}
			;

COMANDO 	: E ';' 
			| ERL ';' 
			| DCL ';'
			;

DCL 		: TOKEN_INT TOKEN_NOMEVAR MLTVAR_INT
			{	
				if(mapaDeVariaveis.find($2.label) != mapaDeVariaveis.end()){
					std::cout <<"\n"<<MSG_ERRO<<"\nVariabile già dichiarata\n" << std::endl;
					exit(1);
				}else{
					$$.tipo = "int";
					ctdDInt += 1;

					$$.label = geraVarTemp($$.tipo);
					$$.traducao = "";

					mapaDeVariaveis[$2.label] = $$;
				}
			}
			| TOKEN_INT TOKEN_NOMEVAR TOKEN_ATR E_BASICA MLTVAR_INT
			{

				if(mapaDeVariaveis.find($2.label) != mapaDeVariaveis.end()){
					std::cout <<"\n"<<MSG_ERRO<<"\nVariabile già dichiarata\n" << std::endl;
					exit(1);
				}else{
					$$.tipo = "int";
					ctdDInt += 1;

					$$.label = geraVarTemp($$.tipo);
					$$.traducao = $4.traducao + "\t" + $$.label + " = " + $4.label + ";\n";

					mapaDeVariaveis[$2.label] = $$;
				}

			}
			| TOKEN_FLOAT TOKEN_NOMEVAR MLTVAR_FLOAT
			{
				if(mapaDeVariaveis.find($2.label) != mapaDeVariaveis.end()){
					std::cout <<"\n"<<MSG_ERRO<<"\nVariabile già dichiarata\n" << std::endl;
					exit(1);
				}else{
					$$.tipo = "float";
					ctdDFloat += 1;

					$$.label = geraVarTemp($$.tipo);
					$$.traducao = "";

					mapaDeVariaveis[$2.label] = $$;
				}	
			}
			| TOKEN_FLOAT TOKEN_NOMEVAR TOKEN_ATR E_BASICA MLTVAR_FLOAT
			{

				if(mapaDeVariaveis.find($2.label) != mapaDeVariaveis.end()){
					std::cout <<"\n"<<MSG_ERRO<<"\nVariabile già dichiarata\n" << std::endl;
					exit(1);
				}else{
					$$.tipo = "float";
					ctdDFloat += 1;

					$$.label = geraVarTemp($$.tipo);
					$$.traducao = $4.traducao + "\t" + $$.label + " = " + $4.label + ";\n";

					mapaDeVariaveis[$2.label] = $$;
				}

			}
			| TOKEN_CHAR TOKEN_NOMEVAR MLTVAR_CHAR
			{	
				if(mapaDeVariaveis.find($2.label) != mapaDeVariaveis.end()){
					std::cout <<"\n"<<MSG_ERRO<<"\nVariabile già dichiarata\n" << std::endl;
					exit(1);
				}else {
					$$.tipo = "char";
					ctdDChar += 1;

					$$.label = geraVarTemp($$.tipo);
					$$.traducao = "";

					mapaDeVariaveis[$2.label] = $$;
				}

			}
			| TOKEN_CHAR TOKEN_NOMEVAR TOKEN_ATR E_CARACTER MLTVAR_CHAR
			{

				if(mapaDeVariaveis.find($2.label) != mapaDeVariaveis.end()){
					std::cout <<"\n"<<MSG_ERRO<<"\nVariabile già dichiarata\n" << std::endl;
					exit(1);
				}else{
					$$.tipo = "char";
					ctdDChar += 1;

					$$.label = geraVarTemp($$.tipo);
					$$.traducao = $4.traducao + "\t" + $$.label + " = " + $4.label + ";\n";

					mapaDeVariaveis[$2.label] = $$;
				}

			}
			| TOKEN_BOOL TOKEN_NOMEVAR MLTVAR_BOOL
			{	
				if(mapaDeVariaveis.find($2.label) != mapaDeVariaveis.end()){
					std::cout <<"\n"<<MSG_ERRO<<"\nVariabile già dichiarata\n" << std::endl;
					exit(1);
				}else{
					$$.tipo = "bool";
					ctdDBool += 1;

					$$.label = geraVarTemp($$.tipo);
					$$.traducao = "";

					mapaDeVariaveis[$2.label] = $$;
				}
			}
			| TOKEN_BOOL TOKEN_NOMEVAR TOKEN_ATR E_BOOLEAN MLTVAR_BOOL
			{

				if(mapaDeVariaveis.find($2.label) != mapaDeVariaveis.end()){
					std::cout <<"\n"<<MSG_ERRO<<"\nVariabile già dichiarata\n" << std::endl;
					exit(1);
				}else{
					$$.tipo = "bool";
					ctdDBool += 1;

					$$.label = geraVarTemp($$.tipo);
					$$.traducao = $4.traducao + "\t" + $$.label + " = " + $4.label + ";\n";

					mapaDeVariaveis[$2.label] = $$;
				}

			}
			;

MLTVAR_INT	: ',' TOKEN_NOMEVAR MLTVAR_INT
			{
				if(mapaDeVariaveis.find($2.label) != mapaDeVariaveis.end()){
					std::cout <<"\n"<<MSG_ERRO<<"\nVariabile già dichiarata\n" << std::endl;
					exit(1);
				}else {
					$$.tipo = "int";
					ctdDInt += 1;

					$$.label = geraVarTemp($$.tipo);
					$$.traducao = "";
					
					mapaDeVariaveis[$2.label] = $$;
				}
			}
			| ',' TOKEN_NOMEVAR TOKEN_ATR E_BASICA MLTVAR_INT
			{
				if(mapaDeVariaveis.find($2.label) != mapaDeVariaveis.end()){
					std::cout <<"\n"<<MSG_ERRO<<"\nVariabile già dichiarata\n" << std::endl;
					exit(1);
				}else{
					$$.tipo = "int";
					ctdDInt += 1;

					$$.label = geraVarTemp($$.tipo);
					$$.traducao = $4.traducao + "\t" + $$.label + " = " + $4.label + ";\n";

					mapaDeVariaveis[$2.label] = $$;
				}
			}
			|
			;

MLTVAR_FLOAT: ',' TOKEN_NOMEVAR MLTVAR_FLOAT
			{
				if(mapaDeVariaveis.find($2.label) != mapaDeVariaveis.end()){
					std::cout <<"\n"<<MSG_ERRO<<"\nVariabile già dichiarata\n" << std::endl;
					exit(1);
				}else {
					$$.tipo = "float";
					ctdDFloat += 1;

					$$.label = geraVarTemp($$.tipo);
					$$.traducao = "";

					mapaDeVariaveis[$2.label] = $$;
				}
			}
			| ',' TOKEN_NOMEVAR TOKEN_ATR E_BASICA MLTVAR_FLOAT
			{
				if(mapaDeVariaveis.find($2.label) != mapaDeVariaveis.end()){
					std::cout <<"\n"<<MSG_ERRO<<"\nVariabile già dichiarata\n" << std::endl;
					exit(1);
				}else {
					$$.tipo = "float";
					ctdDFloat += 1;

					$$.label = geraVarTemp($$.tipo);
					$$.traducao = $$.label + " = " + $4.traducao;
					
					mapaDeVariaveis[$2.label] = $$;
				}
			}
			|
			;			

MLTVAR_CHAR	: ',' TOKEN_NOMEVAR MLTVAR_CHAR
			{
				if(mapaDeVariaveis.find($2.label) != mapaDeVariaveis.end()){
					std::cout <<"\n"<<MSG_ERRO<<"\nVariabile già dichiarata\n" << std::endl;
					exit(1);
				}else {
					$$.tipo = "char";
					ctdDChar += 1;

					$$.label = geraVarTemp($$.tipo);
					$$.traducao = "";

					mapaDeVariaveis[$2.label] = $$;
				}
			}
			| ',' TOKEN_NOMEVAR TOKEN_ATR E_CARACTER MLTVAR_CHAR
			{
				if(mapaDeVariaveis.find($2.label) != mapaDeVariaveis.end()){
					std::cout <<"\n"<<MSG_ERRO<<"\nVariabile già dichiarata\n" << std::endl;
					exit(1);
				}else {
					$$.tipo = "char";
					ctdDChar += 1;

					$$.label = geraVarTemp($$.tipo);
					$$.traducao = $$.label + " = " + $4.traducao;
					
					mapaDeVariaveis[$2.label] = $$;
				}
			}
			|
			;

MLTVAR_BOOL : ',' TOKEN_NOMEVAR MLTVAR_BOOL
			{
				if(mapaDeVariaveis.find($2.label) != mapaDeVariaveis.end()){
					std::cout <<"\n"<<MSG_ERRO<<"\nVariabile già dichiarata\n" << std::endl;
					exit(1);
				}else {
					$$.tipo = "bool";
					ctdDBool += 1;

					$$.label = geraVarTemp($$.tipo);
					$$.traducao = "";

					mapaDeVariaveis[$2.label] = $$;
				}
			}
			| ',' TOKEN_NOMEVAR TOKEN_ATR E_BOOLEAN MLTVAR_BOOL
			{
				if(mapaDeVariaveis.find($2.label) != mapaDeVariaveis.end()){
					std::cout <<"\n"<<MSG_ERRO<<"\nVariabile già dichiarata\n" << std::endl;
					exit(1);
				}else {
					$$.tipo = "bool";
					ctdDBool += 1;

					$$.label = geraVarTemp($$.tipo);
					$$.traducao = $$.label + " = " + $4.traducao;
					
					mapaDeVariaveis[$2.label] = $$;
				}
			}
			|
			;			


ERL         :'(' ERL ')'
			{
				$$.tipo = $2.tipo;
				$$.label = $2.label;
				$$.traducao = $2.traducao;
			}
 			| ERL TOKEN_MAIOR ERL
			{
				$$.tipo = tabelaDeTipos($1.tipo, $3.tipo);

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" +
				$$.label + " = " + $1.label + " > " + $3.label +
				";\n";
			}
			| ERL TOKEN_MENOR ERL
			{
				$$.tipo = tabelaDeTipos($1.tipo, $3.tipo);

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" +
				$$.label + " = " + $1.label + " < " + $3.label +
				";\n";
			}
			| ERL TOKEN_MAIORIGUAL ERL
			{
				$$.tipo = tabelaDeTipos($1.tipo, $3.tipo);

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" +
				$$.label + " = " + $1.label + " >= " + $3.label +
				";\n";
			}
			| ERL TOKEN_MENORIGUAL ERL
			{
				$$.tipo = tabelaDeTipos($1.tipo, $3.tipo);

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" +
				$$.label + " = " + $1.label + " <= " + $3.label +
				";\n";
			}
			| ERL TOKEN_DIF ERL
			{
				$$.tipo = tabelaDeTipos($1.tipo, $3.tipo);

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" +
				$$.label + " = " + $1.label + " != " + $3.label +
				";\n";
			}
			| ERL TOKEN_IGUAL ERL
			{
				$$.tipo = tabelaDeTipos($1.tipo, $3.tipo);

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" +
				$$.label + " = " + $1.label + " == " + $3.label +
				";\n";
			}
			| ERL TOKEN_E ERL
			{
				$$.tipo = tabelaDeTipos($1.tipo, $3.tipo);

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" +
				$$.label + " = " + $1.label + " && " + $3.label +
				";\n";
			}
			| ERL TOKEN_OU ERL
			{
				$$.tipo = tabelaDeTipos($1.tipo, $3.tipo);

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" +
				$$.label + " = " + $1.label + " || " + $3.label +
				";\n";
			}
			| E_BASICA
			{ }
			| E_BOOLEAN
			{ }
			| E_CARACTER
			{ }
			;	

E 			: '(' E ')'
			{
				$$.tipo = $2.tipo;
				$$.label = $2.label;
				$$.traducao = $2.traducao;
			}
			| E '+' E
			{
				$$.tipo = tabelaDeTipos($1.tipo, $3.tipo);

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" +
				$$.label + " = " + $1.label + " + " + $3.label +
				";\n";
				
			}
			| E '-' E
			{
				$$.tipo = tabelaDeTipos($1.tipo, $3.tipo);

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" +
				$$.label + " = " + $1.label + " - " + $3.label +
				";\n";
				
			}
			| E '*' E
			{
				$$.tipo = tabelaDeTipos($1.tipo, $3.tipo);

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" +
				$$.label + " = " + $1.label + " * " + $3.label +
				";\n";
				
			}
			| E '/' E
			{
				$$.tipo = tabelaDeTipos($1.tipo, $3.tipo);

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" +
				$$.label + " = " + $1.label + " / " + $3.label +
				";\n";
				
			}
			| TOKEN_CONV_FLOAT E
			{
				$$.tipo = "float";
				ctdDFloat += 1;

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = $2.traducao + "\t" + $$.label + " = (float) " + $2.label +
				";\n";
			}
			| TOKEN_CONV_INT E
			{
				$$.tipo = "int";
				ctdDInt += 1;

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = $2.traducao + "\t" + $$.label + " = (int) " + $2.label +
				";\n";
			}
			| '-' E
			{
				$$.tipo = $2.tipo;

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = $2.traducao + "\t" + $$.label + " = -" + $2.label +
				";\n";			
			}
			| E_BASICA
			{ }
			| E_BOOLEAN
			{ }
			| E_CARACTER
			{ }
			;

E_BASICA	: TOKEN_NUM_INT
			{
				ctdDInt += 1;
				$$.tipo = "int";


				$$.label = geraVarTemp($$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.traducao +
				";\n";
			}
			| TOKEN_NUM_FLOAT
			{
				ctdDFloat += 1;
				$$.tipo = "float";

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.traducao +
				";\n";
			}
			| TOKEN_NOMEVAR
			{
                $$.label = geraVarTemp("inteiro");
                $$.traducao = "\t" + $$.label +" = " + $1.label + 
                ";\n";
			}
			;

E_BOOLEAN	: TOKEN_BOOLEAN_FALSE
			{
				ctdDBool += 1;
				$$.tipo = "bool";

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.traducao +
				";\n";
			}
			| TOKEN_BOOLEAN_TRUE
			{
				ctdDBool += 1;
				$$.tipo = "bool";

				$$.label = geraVarTemp($$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.traducao +
				";\n";
			}
			;
E_CARACTER  : TOKEN_CARACTERE
			{
				ctdDChar += 1;
				$$.tipo = "char";


				$$.label = geraVarTemp($$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.traducao +
				";\n";
			}					
            ;
%%

#include "lex.yy.c"

int yyparse();

int main( int argc, char* argv[] )
{
	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}				
