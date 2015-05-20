/* declaration section */
%{

extern int yylex();
extern int yyerror(const char *);
extern int line_count;

#include "error.h"
#include "parser.h"
#include <iostream>
#include <sstream>
#include <string>

using namespace std;

// Helper function for creating unary expressions, handles type checking
Expression *create_unary_expression(Operator_type t, Expression *exp, int valid) {
  if (!(exp->type() & valid)) {
    Error::error(Error::INVALID_RIGHT_OPERAND_TYPE, operator_to_string(t));

		return new Expression(0);
  }

  return new Expression(t, exp);
}

// Helper function for creating binary expressions, handles type checking
Expression *create_binary_expression(Operator_type t, Expression *lexp, Expression *rexp, int lvalid, int rvalid) {
  if (!(lexp->type() & lvalid)) {
    Error::error(Error::INVALID_LEFT_OPERAND_TYPE, operator_to_string(t));

		return new Expression(0);
	}

	if (!(rexp->type() & rvalid)) {
    Error::error(Error::INVALID_RIGHT_OPERAND_TYPE, operator_to_string(t));

		return new Expression(0);
  }

  return new Expression(t, lexp, rexp);
}

%}

%union {
	double				union_double;
	int						union_int;
  Gpl_type      union_type;
  Operator_type union_op_type;
	std::string 	*union_string;
  Variable      *union_var;
	Expression 		*union_exp;
}

%error-verbose

%token T_INT                 "int"
%token T_DOUBLE              "double"
%token T_STRING              "string"
%token T_TRIANGLE            "triangle"
%token T_PIXMAP              "pixmap"
%token T_CIRCLE              "circle"
%token T_RECTANGLE           "rectangle"
%token T_TEXTBOX             "textbox"
%token <union_int> T_FORWARD "forward" // value is line number
%token T_INITIALIZATION      "initialization" 

%token T_TRUE                "true"
%token T_FALSE               "false"

%token T_ON                  "on"
%token T_SPACE               "space"
%token T_LEFTARROW           "leftarrow"
%token T_RIGHTARROW          "rightarrow"
%token T_UPARROW             "uparrow"
%token T_DOWNARROW           "downarrow"
%token T_LEFTMOUSE_DOWN      "leftmouse_down"
%token T_MIDDLEMOUSE_DOWN    "middlemouse_down"
%token T_RIGHTMOUSE_DOWN     "rightmouse_down"
%token T_LEFTMOUSE_UP        "leftmouse_up"
%token T_MIDDLEMOUSE_UP      "middlemouse_up"
%token T_RIGHTMOUSE_UP       "rightmouse_up"
%token T_MOUSE_MOVE          "mouse_move"
%token T_MOUSE_DRAG          "mouse_drag"
%token T_F1                  "f1"
%token T_AKEY                "akey"
%token T_SKEY                "skey"
%token T_DKEY                "dkey"
%token T_FKEY                "fkey"
%token T_HKEY                "hkey"
%token T_JKEY                "jkey"
%token T_KKEY                "kkey"
%token T_LKEY                "lkey"
%token T_WKEY                "wkey"

%token T_TOUCHES             "touches"
%token T_NEAR                "near"

%token T_ANIMATION           "animation"

%token T_IF                  "if"
%token T_FOR                 "for"
%token T_ELSE                "else"
%token <union_int> T_PRINT   "print" // value is line number
%token <union_int> T_EXIT    "exit" // value is line number

%token T_LPAREN              "("
%token T_RPAREN              ")"
%token T_LBRACE              "{"
%token T_RBRACE              "}"
%token T_LBRACKET            "["
%token T_RBRACKET            "]"
%token T_SEMIC               ";"
%token T_COMMA               ","
%token T_PERIOD              "."

%token T_ASSIGN              "="
%token T_PLUS_ASSIGN         "+="
%token T_MINUS_ASSIGN        "-="

%token T_ASTERISK            "*"
%token T_DIVIDE              "/"
%token T_MOD                 "%"
%token T_PLUS                "+"
%token T_MINUS               "-"
%token T_SIN                 "sin"
%token T_COS                 "cos"
%token T_TAN                 "tan"
%token T_ASIN                "asin"
%token T_ACOS                "acos"
%token T_ATAN                "atan"
%token T_SQRT                "sqrt"
%token T_FLOOR               "floor"
%token T_ABS                 "abs"
%token T_RANDOM              "random"

%token T_LESS                "<"
%token T_GREATER             ">"
%token T_LESS_EQUAL          "<="
%token T_GREATER_EQUAL       ">="
%token T_EQUAL               "=="
%token T_NOT_EQUAL           "!="

%token T_AND                 "&&"
%token T_OR                  "||"
%token T_NOT                 "!"

%token <union_string> T_ID              "identifier"
%token <union_int> 		T_INT_CONSTANT    "int constant"
%token <union_double> T_DOUBLE_CONSTANT "double constant"
%token <union_string> T_STRING_CONSTANT "string constant"

// special token that does not match any production
// used for characters that are not part of the language
%token T_ERROR               "error"

%left "||"
%left "&&"
%left "==" "!="
%left "<" ">" "<=" ">="
%left "+" "-"
%left "*" "/" "%"
%left "!"
%nonassoc UNARY_OPS

%nonassoc	IF_NO_ELSE
%nonassoc T_ELSE

%type <union_type>    simple_type 
%type <union_op_type> math_operator
%type <union_exp>     primary_expression expression optional_initializer
%type <union_var>     variable

%%
// Grammar rules for gpl
program:
		declaration_list block_list
    ;

//---------------------------------------------------------------------
declaration_list:
    declaration_list declaration
    | empty
    ;

//---------------------------------------------------------------------
declaration:
    variable_declaration T_SEMIC
    | object_declaration T_SEMIC
    | forward_declaration T_SEMIC
    ;

//---------------------------------------------------------------------
variable_declaration:
    simple_type  T_ID  optional_initializer
		{
			Symbol *s;

      // Process assignment type
			if ($1 == INT) {
        int initial_value = 0;

        // Check if we have an initializer
        if ($3 != NULL) {
					#ifdef DEBUG 
            cout << "Assigning to int" << endl <<  *$3 << endl; 
          #endif
          // Check if initializer type is correct for assignment
          if ($3->type() == INT) {
            initial_value = $3->eval_int();
          } else {
						Error::error(Error::INVALID_TYPE_FOR_INITIAL_VALUE, *$2);
					}
        }

				s = new Symbol(*$2, initial_value);
			} else if ($1 == DOUBLE) {
        double initial_value = 0.0;

        // Check if we have an initializer
        if ($3 != NULL) {
					#ifdef DEBUG 
            cout << "Assigning to double" << endl << *$3 << endl; 
          #endif
          // Check if initializer type is correct for assignment
          if ($3->type() & (INT | DOUBLE)) {
            initial_value = $3->eval_double();
          } else {
						Error::error(Error::INVALID_TYPE_FOR_INITIAL_VALUE, *$2);
					}
        }

				s = new Symbol(*$2, initial_value);
			} else if ($1 == STRING) {
        string initial_value = "";
        
        // Check if we have an initializer
        if ($3 != NULL) {
					#ifdef DEBUG 
            cout << "Assigning to string" << endl << *$3 << endl; 
          #endif
          // Check if initializer type is correct for assignment
          if ($3->type() & (INT | DOUBLE | STRING)) {
            initial_value = $3->eval_string();
          } else {
						Error::error(Error::INVALID_TYPE_FOR_INITIAL_VALUE, *$2);
					}
        }

				s = new Symbol(*$2, initial_value);
			}

			// cheesy way to check if an array exists already
			ostringstream oss;
	
			oss << s->name() << "[0]";

			if (Symbol_table::instance()->Exists(oss.str())) {
				Error::error(Error::PREVIOUSLY_DECLARED_VARIABLE, s->name());	
			} else if (!Symbol_table::instance()->Put(s)) {
				Error::error(Error::PREVIOUSLY_DECLARED_VARIABLE, s->name());
			}
		}
    | simple_type  T_ID  T_LBRACKET expression T_RBRACKET
		{
			int size;
			ostringstream oss;

      // Checks for invalid index type or size
      if ($4->type() & (DOUBLE | STRING) || (size = $4->eval_int()) <= 0) {
				if ($4->type() & (DOUBLE | STRING)) {
          // invalid index type
					oss << $4->eval_string();
				} else {
          // invalid index size
					oss << size;
				}

        Error::error(Error::INVALID_ARRAY_SIZE, *$2, oss.str()); 
      } else {
        Symbol *s;

        // Create a symbol for each value in the array
        for (int x = 0; x < size; ++x) {
          oss.str(string());

          oss << *$2 << "[" << x << "]";

          string var_name = oss.str();

          if ($1 == INT) {
            s = new Symbol(var_name, 0);
          } else if ($1 == DOUBLE) {
            s = new Symbol(var_name, 0.0);
          } else if ($1 == STRING) {
            s = new Symbol(var_name, "");
          }

					if (Symbol_table::instance()->Exists(*$2)) {
						Error::error(Error::PREVIOUSLY_DECLARED_VARIABLE, *$2);

						break;
					} else if (!Symbol_table::instance()->Put(s)) {
            Error::error(Error::PREVIOUSLY_DECLARED_VARIABLE, s->name());

						break;
          }
        }
      }
		}
    ;

//---------------------------------------------------------------------
simple_type:
    T_INT { $$ = INT; }
    | T_DOUBLE { $$ = DOUBLE; }
    | T_STRING { $$ = STRING; }
    ;

//---------------------------------------------------------------------
optional_initializer:
    T_ASSIGN expression
		{
			$$ = $2;
		}
    | empty 
		{
      // propagates null value for compiler warning
			$$ = NULL;
		}
    ;

//---------------------------------------------------------------------
object_declaration:
    object_type T_ID T_LPAREN parameter_list_or_empty T_RPAREN
    | object_type T_ID T_LBRACKET expression T_RBRACKET
    ;

//---------------------------------------------------------------------
object_type:
    T_TRIANGLE
    | T_PIXMAP
    | T_CIRCLE
    | T_RECTANGLE
    | T_TEXTBOX
    ;

//---------------------------------------------------------------------
parameter_list_or_empty :
    parameter_list
    | empty
    ;

//---------------------------------------------------------------------
parameter_list :
    parameter_list T_COMMA parameter
    | parameter
    ;

//---------------------------------------------------------------------
parameter:
    T_ID T_ASSIGN expression
    ;

//---------------------------------------------------------------------
forward_declaration:
    T_FORWARD T_ANIMATION T_ID T_LPAREN animation_parameter T_RPAREN
    ;

//---------------------------------------------------------------------
block_list:
    block_list block
    | empty
    ;

//---------------------------------------------------------------------
block:
    initialization_block
    | animation_block
    | on_block
    ;

//---------------------------------------------------------------------
initialization_block:
    T_INITIALIZATION statement_block
    ;

//---------------------------------------------------------------------
animation_block:
    T_ANIMATION T_ID T_LPAREN check_animation_parameter T_RPAREN T_LBRACE { } statement_list T_RBRACE end_of_statement_block
    ;

//---------------------------------------------------------------------
animation_parameter:
    object_type T_ID
    ;

//---------------------------------------------------------------------
check_animation_parameter:
    T_TRIANGLE T_ID
    | T_PIXMAP T_ID
    | T_CIRCLE T_ID
    | T_RECTANGLE T_ID
    | T_TEXTBOX T_ID
    ;

//---------------------------------------------------------------------
on_block:
    T_ON keystroke statement_block
    ;

//---------------------------------------------------------------------
keystroke:
    T_SPACE
    | T_UPARROW
    | T_DOWNARROW
    | T_LEFTARROW
    | T_RIGHTARROW
    | T_LEFTMOUSE_DOWN
    | T_MIDDLEMOUSE_DOWN
    | T_RIGHTMOUSE_DOWN
    | T_LEFTMOUSE_UP
    | T_MIDDLEMOUSE_UP
    | T_RIGHTMOUSE_UP
    | T_MOUSE_MOVE
    | T_MOUSE_DRAG
    | T_AKEY 
    | T_SKEY 
    | T_DKEY 
    | T_FKEY 
    | T_HKEY 
    | T_JKEY 
    | T_KKEY 
    | T_LKEY 
    | T_WKEY 
    | T_F1
    ;

//---------------------------------------------------------------------
if_block:
    statement_block_creator statement end_of_statement_block
    | statement_block
    ;

//---------------------------------------------------------------------
statement_block:
    T_LBRACE statement_block_creator statement_list T_RBRACE end_of_statement_block
    ;

//---------------------------------------------------------------------
statement_block_creator:
    // this goes to nothing so that you can put an action here in p7
    ;

//---------------------------------------------------------------------
end_of_statement_block:
    // this goes to nothing so that you can put an action here in p7
    ;

//---------------------------------------------------------------------
statement_list:
    statement_list statement
    | empty
    ;

//---------------------------------------------------------------------
statement:
    if_statement
    | for_statement
    | assign_statement T_SEMIC
    | print_statement T_SEMIC
    | exit_statement T_SEMIC
    ;

//---------------------------------------------------------------------
if_statement:
    T_IF T_LPAREN expression T_RPAREN if_block %prec IF_NO_ELSE
    | T_IF T_LPAREN expression T_RPAREN if_block T_ELSE if_block
    ;

//---------------------------------------------------------------------
for_statement:
    T_FOR T_LPAREN statement_block_creator assign_statement end_of_statement_block T_SEMIC expression T_SEMIC statement_block_creator assign_statement end_of_statement_block T_RPAREN statement_block
    ;

//---------------------------------------------------------------------
print_statement:
    T_PRINT T_LPAREN expression T_RPAREN
    ;

//---------------------------------------------------------------------
exit_statement:
    T_EXIT T_LPAREN expression T_RPAREN
    ;

//---------------------------------------------------------------------
assign_statement:
    variable T_ASSIGN expression
    | variable T_PLUS_ASSIGN expression
    | variable T_MINUS_ASSIGN expression
    ;

//---------------------------------------------------------------------
variable:
    T_ID
    {
      // Retrieves symbol
			Symbol *s = Symbol_table::instance()->Get(*$1);

      // Throw error if symbol doesn't exist
			if (s == NULL) {
				Error::error(Error::UNDECLARED_VARIABLE, *$1);
			}

      $$ = new Variable(s);
    }
    | T_ID T_LBRACKET expression T_RBRACKET
    {
			Symbol *s(NULL);
			Gpl_type t = $3->type();

      // Check for correct index type
			if (t == INT) {
				ostringstream oss;
				int index = $3->eval_int();

				oss << *$1 << "[" << index << "]";

        // Retrieves symbol
				s = Symbol_table::instance()->Get(oss.str());	
			
        // Throw error if symbol doesn't exist
				if (s == NULL) {
					if (!Symbol_table::instance()->Exists(oss.str())) {
						oss.str(string());

						oss << index;

						Error::error(Error::ARRAY_INDEX_OUT_OF_BOUNDS, *$1, oss.str());
					} else {
						Error::error(Error::UNDECLARED_VARIABLE, *$1);
					}
				}
			} else {
        // Throw error on invalid array index type
				if (t == DOUBLE) {
					Error::error(Error::ARRAY_INDEX_MUST_BE_AN_INTEGER, *$1, "A double expression");
				} else if (t == STRING) {
					Error::error(Error::ARRAY_INDEX_MUST_BE_AN_INTEGER, *$1, "A string expression");
				}
			}

      $$ = new Variable(s, $3);
    }
    | T_ID T_PERIOD T_ID
    {
      $$ = new Variable(NULL);
    }
    | T_ID T_LBRACKET expression T_RBRACKET T_PERIOD T_ID
    {
      $$ = new Variable(NULL);
    }
    ;

//---------------------------------------------------------------------
expression:
    primary_expression
		{
			$$ = $1;
		}
    | expression T_OR expression
    {
      $$ = create_binary_expression(OR, $1, $3, INT | DOUBLE, INT | DOUBLE);
    }
    | expression T_AND expression
    {
      $$ = create_binary_expression(AND, $1, $3, INT | DOUBLE, INT | DOUBLE);
    }
    | expression T_LESS_EQUAL expression
    {
      $$ = create_binary_expression(LESS_THAN_EQUAL, $1, $3, INT | DOUBLE | STRING, INT | DOUBLE | STRING);
    }
    | expression T_GREATER_EQUAL  expression
    {
      $$ = create_binary_expression(GREATER_THAN_EQUAL, $1, $3, INT | DOUBLE | STRING, INT | DOUBLE | STRING);
    }
    | expression T_LESS expression 
    {
      $$ = create_binary_expression(LESS_THAN, $1, $3, INT | DOUBLE | STRING, INT | DOUBLE | STRING);
    }
    | expression T_GREATER  expression
    {
      $$ = create_binary_expression(GREATER_THAN, $1, $3, INT | DOUBLE | STRING, INT | DOUBLE | STRING);
    }
    | expression T_EQUAL expression
    {
      $$ = create_binary_expression(EQUAL, $1, $3, INT | DOUBLE | STRING, INT | DOUBLE | STRING);
    }
    | expression T_NOT_EQUAL expression
    {
      $$ = create_binary_expression(NOT_EQUAL, $1, $3, INT | DOUBLE | STRING, INT | DOUBLE | STRING);
    }
    | expression T_PLUS expression 
    {
      $$ = create_binary_expression(PLUS, $1, $3, INT | DOUBLE | STRING, INT | DOUBLE | STRING);
    }
    | expression T_MINUS expression
    {
      $$ = create_binary_expression(MINUS, $1, $3, INT | DOUBLE, INT | DOUBLE);
    }
    | expression T_ASTERISK expression
    {
      $$ = create_binary_expression(MULTIPLY, $1, $3, INT | DOUBLE, INT | DOUBLE);
    }
    | expression T_DIVIDE expression
    {
      $$ = create_binary_expression(DIVIDE, $1, $3, INT | DOUBLE, INT | DOUBLE);
    }
    | expression T_MOD expression
    {
      $$ = create_binary_expression(MOD, $1, $3, INT, INT);
    }
    | T_MINUS  expression %prec UNARY_OPS
    {
      $$ = create_unary_expression(UNARY_MINUS, $2, INT | DOUBLE);
    }
    | T_NOT  expression %prec UNARY_OPS
    {
      $$ = create_unary_expression(NOT, $2, INT | DOUBLE);
    }
    | math_operator T_LPAREN expression T_RPAREN
    {
      $$ = create_unary_expression($1, $3, INT | DOUBLE);
    }
    | variable geometric_operator variable
    {
			$$ = NULL;
    }
    ;

//---------------------------------------------------------------------
primary_expression:
    T_LPAREN  expression T_RPAREN
		{
			$$ = $2;
		}
    | variable
    {
      $$ = new Expression($1);
    }
    | T_INT_CONSTANT
		{
			$$ = new Expression($1);
		}
    | T_TRUE
		{
			$$ = new Expression(1);
		}
    | T_FALSE
		{
			$$ = new Expression(0);
		}
    | T_DOUBLE_CONSTANT
		{
			$$ = new Expression($1);
		}
    | T_STRING_CONSTANT
		{
			$$ = new Expression(*$1);
		}
    ;

//---------------------------------------------------------------------
geometric_operator:
    T_TOUCHES
    | T_NEAR
    ;

//---------------------------------------------------------------------
math_operator:
    T_SIN
		{
			$$ = SIN;
		}
    | T_COS
		{
			$$ = COS;
		}
    | T_TAN
		{
			$$ = TAN;
		}
    | T_ASIN
		{
			$$ = ASIN;
		}
    | T_ACOS
		{
			$$ = ACOS;
		}
    | T_ATAN
		{
			$$ = ATAN;
		}
    | T_SQRT
		{
			$$ = SQRT;
		}
    | T_ABS
		{
			$$ = ABS;
		}
    | T_FLOOR
		{
			$$ = FLOOR;
		}
    | T_RANDOM
		{
			$$ = RANDOM;
		}
    ;

//---------------------------------------------------------------------
empty:
    // empty goes to nothing so that you can use empty in productions
    // when you want a production to go to nothing
    ;
