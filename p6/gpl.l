/* definition section that gets copied to output file */
%{

#include "error.h"
#include "parser.h"

#include <iostream>
using namespace std;

Error error_handler;

int line_count = 1; // track current line

void set_line_number() {
  yylval.union_int = line_count;
}

void get_string_value() {
	int end = strlen(yytext);

  yylval.union_string = new string(yytext);

	// check and remove front quote
	if (yytext[0] == 0x22) {
		yylval.union_string->erase(0, 1);
	}

	// check and remove end quote
	if (yytext[end-1] == 0x22) {
		yylval.union_string->erase(end-2, 1);
	}
}

void get_double_value() {
  yylval.union_double = atof(yytext);
}

void get_int_value() {
  yylval.union_int = atoi(yytext);
}

void error() {
	error_handler.error(Error::ILLEGAL_TOKEN, yytext);

	yylval.union_string = new string(yytext);
}

%}

/* pattern and action definitions */
%%

[\n]						    line_count++;
[ \t\r]					    ;

"int"								return T_INT;
"double"						return T_DOUBLE;
"string"						return T_STRING;
"triangle"					return T_TRIANGLE;
"pixmap"						return T_PIXMAP;
"circle"						return T_CIRCLE;
"rectangle"					return T_RECTANGLE;
"textbox"						return T_TEXTBOX;
"forward"           set_line_number(); return T_FORWARD; 
"initialization"		return T_INITIALIZATION;

"true"							return T_TRUE;
"false"							return T_FALSE;

"on" 								return T_ON;
"space" 						return T_SPACE;
"leftarrow"					return T_LEFTARROW;
"rightarrow"				return T_RIGHTARROW;
"uparrow"						return T_UPARROW;
"downarrow"					return T_DOWNARROW;
"leftmouse_down" 		return T_LEFTMOUSE_DOWN;
"middlemouse_down"	return T_MIDDLEMOUSE_DOWN;
"rightmouse_down"		return T_RIGHTMOUSE_DOWN;
"leftmouse_up"			return T_LEFTMOUSE_DOWN;
"middlemouse_up"		return T_MIDDLEMOUSE_UP;
"rightmouse_up"			return T_RIGHTMOUSE_UP;
"mouse_move"				return T_MOUSE_MOVE;
"mouse_drag"				return T_MOUSE_DRAG;
"f1"								return T_F1;
"akey"							return T_AKEY;
"skey"							return T_SKEY;
"dkey"							return T_DKEY;
"fkey"							return T_FKEY;
"hkey"							return T_HKEY;
"jkey"							return T_JKEY;
"kkey"							return T_KKEY;
"lkey"							return T_LKEY;
"wkey"							return T_WKEY;

"touches"						return T_TOUCHES;
"near"							return T_NEAR;
"animation"					return T_ANIMATION;

"if"								return T_IF;
"for"								return T_FOR;
"else"							return T_ELSE;
"print"             set_line_number(); return T_PRINT;
"exit"              set_line_number(); return T_EXIT;

"("									return T_LPAREN;
")"									return T_RPAREN;
"{"									return T_LBRACE;
"}"									return T_RBRACE;
"["									return T_LBRACKET;
"]"									return T_RBRACKET;
";"									return T_SEMIC;
","									return T_COMMA;
"."									return T_PERIOD;

"="									return T_ASSIGN;
"+="								return T_PLUS_ASSIGN;
"-="								return T_MINUS_ASSIGN;

"*"									return T_ASTERISK;
"/"									return T_DIVIDE;
"%"									return T_MOD;
"+"									return T_PLUS;
"-"									return T_MINUS;
"sin"								return T_SIN;
"cos"								return T_COS;
"tan"								return T_TAN;
"asin"							return T_ASIN;
"acos"							return T_ACOS;
"atan"							return T_ATAN;
"sqrt"							return T_SQRT;
"floor"							return T_FLOOR;
"abs"								return T_ABS;
"random"						return T_RANDOM;

"<"									return T_LESS;
">"									return T_GREATER;
"<="								return T_LESS_EQUAL;
">="								return T_GREATER_EQUAL;
"=="								return T_EQUAL;
"!="								return T_NOT_EQUAL;

"&&"								return T_AND;
"||"								return T_OR;
"!"									return T_NOT;

\/\/.*                    ;
\"[A-Za-z0-9\ <>,.=+-\[\]\(\)\_]*\"			get_string_value(); return T_STRING_CONSTANT;
[0-9]*\.[0-9]*						get_double_value(); return T_DOUBLE_CONSTANT;
[0-9]+										get_int_value(); return T_INT_CONSTANT;
[A-Za-z\_][A-Za-z0-9\_]*	get_string_value(); return T_ID;

.										      error(); return T_ERROR;
