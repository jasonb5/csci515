#ifndef GPL_VARIABLE_H_
#define GPL_VARIABLE_H_

#include <string>

using namespace std;

#include "symbol.h"
#include "gpl_type.h"

class Expression;

class Variable {
 public:
  Variable(Symbol *sym);
  Variable(Symbol *sym, Expression *exp);
  ~Variable();

  string id() { return sym_->name(); }
	Gpl_type type();
	
	int get_int();
	double get_double();
	string get_string();

 private:
	Symbol *sym_;
  Expression *exp_;
};

#endif // GPL_VARIABLE_H_
