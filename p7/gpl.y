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
#include <vector>

using namespace std;

// Helper function for creating unary expressions, handles type checking
Expression *create_unary_expression(Operator_type t, Expression *exp, int lvalid) {
	Gpl_type type;

	bool valid = exp->type(type);

  if (!valid || !(type & lvalid)) {
		if (valid) {
			Error::error(Error::INVALID_RIGHT_OPERAND_TYPE, operator_to_string(t));
		}

		return new Expression(0);
  }

  return new Expression(t, exp);
}

// Helper function for creating binary expressions, handles type checking
Expression *create_binary_expression(Operator_type t, Expression *lexp, Expression *rexp, int lvalid, int rvalid) {
	bool valid;
	Gpl_type ltype, rtype;

	valid = lexp->type(ltype);

  if (!valid || !(ltype & lvalid)) {
		if (valid) {
			Error::error(Error::INVALID_LEFT_OPERAND_TYPE, operator_to_string(t));
		}

		return new Expression(0);
	}

	valid = rexp->type(rtype);

	if (!valid || !(rtype & rvalid)) {
		if (valid) {
			Error::error(Error::INVALID_RIGHT_OPERAND_TYPE, operator_to_string(t));
		}

		return new Expression(0);
  }

  return new Expression(t, lexp, rexp);
}

// Helper function for validating array index type
bool validate_array_index_type(string name, Expression *exp) {
	Gpl_type type;

	exp->type(type);

	if (type != INT) {
		string desc;

		switch (type) {
		case DOUBLE:
			desc = "A double expression";
			break;
		case STRING:
			desc = "A string expression";
			break;
		case ANIMATION_BLOCK:
			desc = "A animation_block expression";
			break;
		}	

		Error::error(Error::ARRAY_INDEX_MUST_BE_AN_INTEGER, name, desc);
	
		return false;
	}	

	return true;
}

// Helper function for validating arrays, validates index type,
// and index value
bool validate_array_variable(Variable *var) {
	Expression *index_exp = var->get_expression();

	if (validate_array_index_type(var->id(), index_exp)) {
		int index;
		ostringstream oss;
	
		index_exp->eval_int(index);

		oss << var->id() << "[" << index << "]";

		if (!Symbol_table::instance()->Exists(oss.str())) {
			oss.str(string());

			oss << var->id() << "[0]";

			if (Symbol_table::instance()->Exists(oss.str())) {
				oss.str(string());

				oss << index;

				Error::error(Error::ARRAY_INDEX_OUT_OF_BOUNDS, var->id(), oss.str()); 
      } else if (Symbol_table::instance()->Exists(var->id())) {
        Error::error(Error::VARIABLE_NOT_AN_ARRAY, var->id());
			} else {
				Error::error(Error::UNDECLARED_VARIABLE, var->id());	
			}
		} else {
			var->eval_symbol();

      return true;
		}
	}	

  return false;
}

string cur_name;
Game_object *cur_object;
vector<Statement_block*> stmt_stack;

%}

%union {
	double				    union_double;
	int						    union_int;
  Gpl_type          union_type;
  Operator_type     union_op_type;
	std::string 	    *union_string;
  Variable          *union_var;
	Expression 		    *union_exp;
	Statement_block   *union_stmt_block;
	Window::Keystroke union_key;
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

%type <union_int>						object_type object_type_declaration
%type <union_type>    			simple_type 
%type <union_op_type> 			math_operator
%type <union_exp>     			primary_expression expression optional_initializer
%type <union_var>     			variable
%type <union_key> 					keystroke
%type <union_stmt_block> 		if_block statement_block end_of_statement_block

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
			Gpl_type type;

      // Process assignment type
			if ($1 == INT) {
        int initial_value = 0;

        // Check if we have an initializer
        if ($3 != NULL) {
					#ifdef DEBUG 
            cout << "Assigning to int" << endl <<  *$3 << endl; 
          #endif

					if ($3->type(type)) {
            // Check if initializer type is correct for assignment
            if (type == INT) {
              $3->eval_int(initial_value);
            } else {
              Error::error(Error::INVALID_TYPE_FOR_INITIAL_VALUE, *$2);
            }
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

					if ($3->type(type)) {	
            // Check if initializer type is correct for assignment
            if (type & (INT | DOUBLE)) {
              $3->eval_double(initial_value);
            } else {
              Error::error(Error::INVALID_TYPE_FOR_INITIAL_VALUE, *$2);
            }
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

					if ($3->type(type)) {
            // Check if initializer type is correct for assignment
            if (type & (INT | DOUBLE | STRING)) {
              $3->eval_string(initial_value);
            } else {
              Error::error(Error::INVALID_TYPE_FOR_INITIAL_VALUE, *$2);
            }
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
			Gpl_type type;
			ostringstream oss;

			$4->type(type);

      // Checks for invalid index type or size
      if (type & (DOUBLE | STRING)) {
        string value;

        // invalid index type
        $4->eval_string(value);

        Error::error(Error::INVALID_ARRAY_SIZE, *$2, value); 
      } else {
        Symbol *s;

        $4->eval_int(size);

        if (size > 0) {
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
        } else {
          oss.str(string());

          oss << size;

          Error::error(Error::INVALID_ARRAY_SIZE, *$2, oss.str()); 
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
      // first time we're sure this is an expression being used to initialize a
      // value and we provide error checking for arrays
			if ($2->is_array()) {
				validate_array_variable($2->get_variable());
			}

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
    object_type_declaration T_LPAREN parameter_list_or_empty T_RPAREN 
		{
			Symbol *sym = new Symbol(cur_name, cur_object);

			Symbol_table::instance()->Put(sym);

			cur_object = NULL;
		}
    | object_type T_ID T_LBRACKET expression T_RBRACKET
		{
			int size;
			Gpl_type type;
			ostringstream oss;

			$4->type(type);

      // Checks for invalid index type or size
      if (type & (DOUBLE | STRING)) {
        string value;

        // invalid index type
        $4->eval_string(value);

        Error::error(Error::INVALID_ARRAY_SIZE, cur_name, value); 
      } else {
        Symbol *s;

        $4->eval_int(size);

        if (size > 0) {
          // Create a symbol for each value in the array
          for (int x = 0; x < size; ++x) {
            oss.str(string());

            oss << *$2 << "[" << x << "]";

            string var_name = oss.str();

            switch ($1) {
            case T_TRIANGLE:
              cur_object = new Triangle();
              break;
            case T_PIXMAP:
              cur_object = new Pixmap();
              break;
            case T_CIRCLE:
              cur_object = new Circle();
              break;
            case T_RECTANGLE:
              cur_object = new Rectangle();
              break;
            case T_TEXTBOX:
              cur_object = new Textbox();
              break;
            }

            s = new Symbol(var_name, cur_object);

            if (Symbol_table::instance()->Exists(cur_name)) {
              Error::error(Error::PREVIOUSLY_DECLARED_VARIABLE, cur_name);

              break;
            } else if (!Symbol_table::instance()->Put(s)) {
              Error::error(Error::PREVIOUSLY_DECLARED_VARIABLE, s->name());

              break;
            }

						cur_object = NULL;
          }
        } else {
          oss.str(string());

          oss << size;

          Error::error(Error::INVALID_ARRAY_SIZE, cur_name, oss.str()); 
        }
      }
		}
    ;

//---------------------------------------------------------------------
object_type_declaration:
	object_type T_ID
	{
		cur_name = *$2;

		switch ($1) {
		case T_TRIANGLE:
			cur_object = new Triangle();
			break;
		case T_PIXMAP:
			cur_object = new Pixmap();
			break;
		case T_CIRCLE:
			cur_object = new Circle();
			break;
		case T_RECTANGLE:
			cur_object = new Rectangle();
			break;
		case T_TEXTBOX:
			cur_object = new Textbox();
			break;
		}	

		$$ = $1;
	}
	;

//---------------------------------------------------------------------
object_type:
    T_TRIANGLE { $$ = T_TRIANGLE; }
    | T_PIXMAP { $$ = T_PIXMAP; }
    | T_CIRCLE { $$ = T_CIRCLE; }
    | T_RECTANGLE { $$ = T_RECTANGLE; }
    | T_TEXTBOX { $$ = T_TEXTBOX; }
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
		{
			Status status;
			Gpl_type mem_type;
      bool valid = false;

      // checks if member variable exists
			if ((status = cur_object->get_member_variable_type(*$1, mem_type)) 
				!= Status::OK) {
        Error::error(Error::UNKNOWN_CONSTRUCTOR_PARAMETER, cur_object->type(), *$1);
			} else {
        // member exists, evaluate expression and asssign value
				switch (mem_type) {
				case INT: {
					int value;
          
          valid = $3->eval_int(value);

					status = cur_object->set_member_variable(*$1, value);
					break;	
				}
				case DOUBLE: {
					double value;
            
          valid = $3->eval_double(value);

					status = cur_object->set_member_variable(*$1, value);
					break;
				}
				case STRING: {
					string value;
          
          valid = $3->eval_string(value);

					status = cur_object->set_member_variable(*$1, value);
					break;
				}
				case ANIMATION_BLOCK: {
					Animation_block *value;
          
          valid = $3->eval_animation_block(&value);

          // check if member variable is of type ANIMATION_BLOCK
          if (cur_object->type() != value->get_parameter_symbol()->get_gobject_value()->type()) {
            Error::error(Error::TYPE_MISMATCH_BETWEEN_ANIMATION_BLOCK_AND_OBJECT, cur_name, value->name());
          } else {
            status = cur_object->set_member_variable(*$1, value);
          }
					break;
				}
				}

        // Error if we couldn't evaluate to correct type
				if (!valid) {
					Error::error(Error::INCORRECT_CONSTRUCTOR_PARAMETER_TYPE, cur_name, *$1);
				}
			}
		}
    ;

//---------------------------------------------------------------------
forward_declaration:
    T_FORWARD T_ANIMATION T_ID T_LPAREN animation_parameter T_RPAREN
		{
      // retrieve current objects symbol
			Symbol *para_sym = Symbol_table::instance()->Get(cur_name);

      // create a symbol for the animation block
      // associate object parameter to animation_block
			Symbol *sym = new Symbol(*$3, new Animation_block(para_sym, *$3));

      // try to insert the new symbol
		  if (!Symbol_table::instance()->Put(sym)) {
        Error::error(Error::PREVIOUSLY_DECLARED_VARIABLE, *$3);
      }
		}
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
    object_type_declaration
		{
      // mark object to be a placeholder
			cur_object->never_animate();
			cur_object->never_draw();

      // create a new symbol for newly created object
			Symbol *sym = new Symbol(cur_name, cur_object);

      // try to insert the new symbol
			if (!Symbol_table::instance()->Put(sym)) {
        Error::error(Error::ANIMATION_PARAMETER_NAME_NOT_UNIQUE, cur_name);
      }
		}
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
		{
      // Add statement_block to key
			Event_manager::instance()->set_stmt($2, $3);
		}
    ;

//---------------------------------------------------------------------
keystroke:
    T_SPACE { $$ = Window::Keystroke::SPACE; }
    | T_UPARROW { $$ = Window::Keystroke::UPARROW; }
    | T_DOWNARROW { $$ = Window::Keystroke::DOWNARROW; }
    | T_LEFTARROW { $$ = Window::Keystroke::LEFTARROW; }
    | T_RIGHTARROW { $$ = Window::Keystroke::RIGHTARROW; }
    | T_LEFTMOUSE_DOWN { $$ = Window::Keystroke::LEFTMOUSE_DOWN; }
    | T_MIDDLEMOUSE_DOWN { $$ = Window::Keystroke::MIDDLEMOUSE_DOWN; }
    | T_RIGHTMOUSE_DOWN { $$ = Window::Keystroke::RIGHTMOUSE_DOWN; }
    | T_LEFTMOUSE_UP { $$ = Window::Keystroke::LEFTMOUSE_UP; }
    | T_MIDDLEMOUSE_UP { $$ = Window::Keystroke::MIDDLEMOUSE_UP; }
    | T_RIGHTMOUSE_UP { $$ = Window::Keystroke::RIGHTMOUSE_UP; }
    | T_MOUSE_MOVE { $$ = Window::Keystroke::MOUSE_MOVE; }
    | T_MOUSE_DRAG { $$ = Window::Keystroke::MOUSE_DRAG; }
    | T_AKEY { $$ = Window::Keystroke::AKEY; }
    | T_SKEY { $$ = Window::Keystroke::SKEY; }
    | T_DKEY { $$ = Window::Keystroke::DKEY; }
    | T_FKEY { $$ = Window::Keystroke::FKEY; }
    | T_HKEY { $$ = Window::Keystroke::HKEY; }
    | T_JKEY { $$ = Window::Keystroke::JKEY; }
    | T_KKEY { $$ = Window::Keystroke::KKEY; }
    | T_LKEY { $$ = Window::Keystroke::LKEY; }
    | T_WKEY { $$ = Window::Keystroke::WKEY; }
    | T_F1 { $$ = Window::Keystroke::F1; }
    ;

//---------------------------------------------------------------------
if_block:
    statement_block_creator statement end_of_statement_block
		{
			// push statement_block up tree
			$$ = $3;
		}
    | statement_block
		{
			// push statement_block up tree
			$$ = $1;
		}
    ;

//---------------------------------------------------------------------
statement_block:
    T_LBRACE statement_block_creator statement_list T_RBRACE end_of_statement_block
		{
      // push statement_block up tree
			$$ = $5;
		}
    ;

//---------------------------------------------------------------------
statement_block_creator:
    // this goes to nothing so that you can put an action here in p7
		{
      // push a new statement_block onto global stack
			stmt_stack.push_back(new Statement_block());
		}
    ;

//---------------------------------------------------------------------
end_of_statement_block:
    // this goes to nothing so that you can put an action here in p7
		{
      // retrieve the most recent statement_block
      // from the global stack
			Statement_block *stmt_block = stmt_stack.back();
	
      // pop the statement_block from the stack
			stmt_stack.pop_back();

      // push the statement_block up the tree
			$$ = stmt_block;
		}
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
		{	
			Gpl_type type;

			$3->type(type);

			if (type == INT) {
				// pushes a new if statment without else block onto stack
				stmt_stack.back()->push_stmt(new If_stmt($3, $5));
			} else {
				Error::error(Error::INVALID_TYPE_FOR_IF_STMT_EXPRESSION);
			}
		}
    | T_IF T_LPAREN expression T_RPAREN if_block T_ELSE if_block
		{
			Gpl_type type;

			$3->type(type);

			if (type == INT) {
				// pushes a new if statment with else block onto stack
				stmt_stack.back()->push_stmt(new If_stmt($3, $5, $7));	
			} else {
				Error::error(Error::INVALID_TYPE_FOR_IF_STMT_EXPRESSION);
			}
		}
    ;

//---------------------------------------------------------------------
for_statement:
    T_FOR T_LPAREN statement_block_creator assign_statement end_of_statement_block T_SEMIC expression T_SEMIC statement_block_creator assign_statement end_of_statement_block T_RPAREN statement_block
		{
			Gpl_type type;

			$7->type(type);

			if (type == INT) {
				// pushes new for statment onto stack
				stmt_stack.back()->push_stmt(new For_stmt($7, $5, $11, $13));		
			} else {
				Error::error(Error::INVALID_TYPE_FOR_FOR_STMT_EXPRESSION);
			}
		}
    ;

//---------------------------------------------------------------------
print_statement:
    T_PRINT T_LPAREN expression T_RPAREN
		{
			Gpl_type type;

			$3->type(type);

			if (type & (INT | DOUBLE | STRING)) {
				// push a new print statement onto current 
				// statement block
				stmt_stack.back()->push_stmt(new Print_stmt($1, $3));	
			} else {
				Error::error(Error::INVALID_TYPE_FOR_PRINT_STMT_EXPRESSION);
			}
		}
    ;

//---------------------------------------------------------------------
exit_statement:
    T_EXIT T_LPAREN expression T_RPAREN
		{
			Gpl_type type;

			$3->type(type);

			if (type == INT) {
				// pushes new print statment onto stack
				stmt_stack.back()->push_stmt(new Exit_stmt($1, $3));
			} else {
				Error::error(Error::EXIT_STATUS_MUST_BE_AN_INTEGER, gpl_type_to_string(type));
			}		
		}
    ;

//---------------------------------------------------------------------
assign_statement:
    variable T_ASSIGN expression
    {
      Gpl_type ltype, rtype;

      $1->type(ltype);
     
      $3->type(rtype);

      if (ltype < rtype) {
        Error::error(Error::ASSIGNMENT_TYPE_ERROR, gpl_type_to_string(ltype), gpl_type_to_string(rtype));
      } else if (ltype == GAME_OBJECT) {
        Error::error(Error::INVALID_LHS_OF_ASSIGNMENT, $1->id(), gpl_type_to_string(ltype));
      } else {
				if ($1->is_array()) {
					if (!Symbol_table::instance()->Exists($1->id() + "[0]") && Symbol_table::instance()->Exists($1->id())) {
						Error::error(Error::VARIABLE_NOT_AN_ARRAY, $1->id());	
					}	else {
						validate_array_index_type($1->id(), $1->get_expression());
					}
				}

        // push assign statement onto global stack
        stmt_stack.back()->push_stmt(new Assignment_stmt(ASSIGN, $1, $3));
      }
    }
    | variable T_PLUS_ASSIGN expression
    {
			Gpl_type ltype, rtype;

			$1->type(ltype);

			$3->type(rtype);

			if (ltype != STRING && rtype == STRING || ltype < rtype) {
				Error::error(Error::PLUS_ASSIGNMENT_TYPE_ERROR, gpl_type_to_string(ltype), gpl_type_to_string(rtype));	
      } else if (ltype == GAME_OBJECT) {
        Error::error(Error::INVALID_LHS_OF_PLUS_ASSIGNMENT, $1->id(), gpl_type_to_string(ltype));
			} else {
				if ($1->is_array()) {
					if (!Symbol_table::instance()->Exists($1->id() + "[0]") && Symbol_table::instance()->Exists($1->id())) {
						Error::error(Error::VARIABLE_NOT_AN_ARRAY, $1->id());	
					}	else {
						validate_array_index_type($1->id(), $1->get_expression());
					}
				}

				// push plus assign statement onto global stack
				stmt_stack.back()->push_stmt(new Assignment_stmt(PLUS_ASSIGN, $1, $3));
			}
    }
    | variable T_MINUS_ASSIGN expression
    {
			Gpl_type ltype, rtype;

			$1->type(ltype);

			$3->type(rtype);

			if (ltype == STRING && rtype == STRING) {
        Error::error(Error::INVALID_LHS_OF_MINUS_ASSIGNMENT, $1->id(), gpl_type_to_string(ltype));   
      } else if (ltype == GAME_OBJECT) {
        Error::error(Error::INVALID_LHS_OF_MINUS_ASSIGNMENT, $1->id(), gpl_type_to_string(ltype));
      } else if (ltype < rtype) {
				Error::error(Error::MINUS_ASSIGNMENT_TYPE_ERROR, gpl_type_to_string(ltype), gpl_type_to_string(rtype));	
			} else {
				if ($1->is_array()) {
					if (!Symbol_table::instance()->Exists($1->id() + "[0]") && Symbol_table::instance()->Exists($1->id())) {
						Error::error(Error::VARIABLE_NOT_AN_ARRAY, $1->id());	
					}	else {
						validate_array_index_type($1->id(), $1->get_expression());
					}
				}

				// push minus assign statement on global stack
				stmt_stack.back()->push_stmt(new Assignment_stmt(MINUS_ASSIGN, $1, $3));
			}
    }
    ;

//---------------------------------------------------------------------
variable:
    T_ID
    {
      // creates plain variable
      $$ = new Variable(*$1);

      // provides error checking for parse/runtime
      // variable calls
			if (!$$->valid()) {
				Error::error(Error::UNDECLARED_VARIABLE, *$1);
			}
    }
    | T_ID T_LBRACKET expression T_RBRACKET
    {
      // creates variable for array value
      $$ = new Variable(*$1, $3);

			if ($$->valid()) {
				Gpl_type type;

				$$->symbol_type(type);
			}
    }
    | T_ID T_PERIOD T_ID
    {
			Gpl_type type;

      // creates variable for member of an object
      $$ = new Variable(*$1, *$3);

			if ($$->valid()) {
				$$->symbol_type(type);

				if (type != GAME_OBJECT) {
					Error::error(Error::LHS_OF_PERIOD_MUST_BE_OBJECT, *$1);
				} else {
					Status status = $$->member_type(type);		
		
					if (status == Status::MEMBER_NOT_DECLARED) {
						Error::error(Error::UNDECLARED_MEMBER, *$1, *$3);
					}
				}					
			} else {
				Error::error(Error::UNDECLARED_VARIABLE, *$1);
			}
    }
    | T_ID T_LBRACKET expression T_RBRACKET T_PERIOD T_ID
    {
      // creates variable for member of an object in an array
			$$ = new Variable(*$1, $3, *$6);

			if ($$->valid()) {
				Gpl_type type;

				$$->symbol_type(type);

				if (type != GAME_OBJECT) {
					Error::error(Error::LHS_OF_PERIOD_MUST_BE_OBJECT, *$1);
				}
			}
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
