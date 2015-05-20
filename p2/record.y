/*

  This file contains the input to the bison compiler generator.
  bison will use this file to generate a C/C++ parser.

  The default output file for bison is: y.tab.c

    $ bison record.y    will produce the file y.tab.c

  This grammar describes a language that is a collection of record
  declarations.  Each has a name and zero or more fields.

    record sally
    {
      height = 63;
      weight = 132;
      age = 42;
    }

    record george
    {
      age = 31;
      phone = 5551212;
    }

  This example DOES NOT demonstrate how a real language would
  create records.  It is a contrived and overly simplified 
  example to demonstrate the bison/flex syntax.
  
*/

%{  // bison syntax to indicate the start of the header
    // the header is copied directly into y.tab.c (the generated parser)

extern int yylex();               // this lexer function returns next token
extern int yyerror(const char *); // used to print errors
extern int line_count;            // current line in the input; from record.l

#include "error.h"      // class for printing errors (used by gpl)
#include "parser.h"
#include <iostream>
#include <string>
using namespace std;

// bison syntax to indicate the end of the header
%} 

// The union is used to declare the variable yylval which is used to
// pass data between the flex generated lexer and the bison generated parser, 
// and to pass values up/down the parse tree.
// 
// A union is kind of like a structure or class, but you can only use one 
// field at a time.  Each line describes one item in the union.  The left hand
// side is the type, the right hand side is a name for the type.
// 
// Unions do not have any error checking.  For example, if you put an int in
// the following union  (my_union.union_int = 42)  and then attempt to use it
// as a string (cout << my_union.union_string) you will get garbage.

// The "%union" is bison syntax
// The "union_" is my convention to indicate a member of the union 
//     (it can be hard to tell what is a union field and what is not)
//
// In this example, the union only has one member (union_int).  You will
// be adding a double declaration to the union.

%union {
 double 				union_double;
 int            union_int;
 std::string    *union_string;  // MUST be a pointer to a string (this sucks!)
}

// turn on verbose (longer) error messages
%error-verbose

// A token is like an enumerated type.  It is used to pass information
// between the lexer and the parser.
// Each token in the language is defined here.  By convention, all tokens
// start with T_ and are upper case.

%token T_ASSIGN   "="  // this string is used in the error messages
%token T_LBRACE   "{"
%token T_RBRACE   "}"
%token T_SEMIC    ";"
%token T_RECORD   "record"
%token T_COMMA		","

// if a token has a type associated with it, put that type (as named in the
// union) inside of <> after the %token
// the value is put in the union by the scanner (in the .l file ) so it can be
// used by the parser (in the .y file)

%token <union_int>    T_INT_CONSTANT      "int constant"
%token <union_string> T_STR_CONSTANT			"string constant"
%token <union_double> T_DOUBLE_CONSTANT		"double constant"
%token <union_string> T_MONTH							"month"
%token <union_string> T_ID                "identifier"
%token <union_string> T_ERROR             "error"

// Just like tokens, grammar symbols can be associated with a type
// This allows values to be passed up (and down) the parse tree
%type <union_int> declaration_list
%type <union_int> field_list;

%% // indicates the start of the rules

//---------------------------------------------------------------------
program:
  declaration_list
  {
    // this code is executed after entire input has been parsed
    if ($1 == 1)
      cout << "1 record was declared.\n";
    else
      cout << $1 << " records were declared.\n";
  }
  ;
//---------------------------------------------------------------------
declaration_list:
  declaration_list declaration
  {
    $$ = $1 + 1;
  }
  | empty
  {
    $$ = 0;
  }
  ;

//---------------------------------------------------------------------
declaration:
  T_RECORD T_ID 
	{
		cout << "record " << *$2 << "\n{\n\n";
	} 
	T_LBRACE field_list T_RBRACE
  {
      cout << "\n} " << $5;

			if ($5 == 0 || $5 > 1)
				cout << " fields were";
			else
				cout << " field was";

			cout << " declared\n\n";
  }
  ;


//---------------------------------------------------------------------
field_list:
  field_list field
	{
		$$ = $1 + 1;
	}
  | empty 
	{
		$$ = 0;
	}
  ;

//---------------------------------------------------------------------
field:
  T_ID T_ASSIGN T_INT_CONSTANT T_SEMIC
  {
    cout << "  " << *$1 << " = " << $3 << " (int)\n";
  }
	| T_ID T_ASSIGN T_DOUBLE_CONSTANT T_SEMIC
	{
		cout << "  " << *$1 << " = " << $3 << " (double)\n";
	}
	| T_ID T_ASSIGN	T_STR_CONSTANT T_SEMIC
	{
		cout << "  " << *$1 << " = ";

		size_t index = 0;

		while ((index = $3->find("\"", index)) != string::npos) {
			$3->replace(index++, 1, "\'");
		}

		cout << *$3;

		cout << " (string)\n";
	}
	| T_ID T_ASSIGN T_MONTH T_INT_CONSTANT T_COMMA T_INT_CONSTANT T_SEMIC
	{
		cout << "  " << *$1 << " = " << *$3 << " " << $4 << ", " << $6 << " (date)\n";
	}
  ;
  
//---------------------------------------------------------------------
empty:
  ;

