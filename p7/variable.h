#ifndef GPL_VARIABLE_H_
#define GPL_VARIABLE_H_

#include <string>

using namespace std;

#include "symbol.h"
#include "gpl_type.h"

class Expression;

class Variable {
 public:
	Variable(string id);
	Variable(string id, string mem_id);
	Variable(string id, Expression *exp);
	Variable(string id, Expression *exp, string mem_id);
  ~Variable();

	string id() { return id_; }
	bool type(Gpl_type &type);
	void symbol_type(Gpl_type &type);
	Status member_type(Gpl_type &type);
	bool valid() { return (sym_ != NULL) ? true : false; }
	bool is_array() { return (exp_ == NULL) ? false : true; }
  bool valid_array_index(int &index);
  void set_array_index(int index);
	
	int get_int();
	double get_double();
	string get_string();
	Animation_block *get_animation_block();
	Expression *get_expression() { return exp_; }

  void set_value(int value);
  void set_value(double value);
  void set_value(string value);
  void set_value(Animation_block *anim_blk);

	bool eval_symbol();

 private:
	Symbol *sym_;
	string id_;
	string mem_id_;
  Expression *exp_;
};

#endif // GPL_VARIABLE_H_
