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
	Variable(Symbol *sym, string mem_id);
  Variable(Symbol *sym, Expression *exp);
  ~Variable();

  string id() { return sym_->name(); }
	bool type(Gpl_type &type);
	
	int get_int();
	double get_double();
	string get_string();
	Animation_block *get_animation_block();

 private:
	Symbol *sym_;
	string mem_id_;
  Expression *exp_;
};

#endif // GPL_VARIABLE_H_
