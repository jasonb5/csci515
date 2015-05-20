#ifndef GPL_EXPRESSION_H_
#define GPL_EXPRESSION_H_

#include <string>

using namespace std;

#include "variable.h"
#include "gpl_type.h"

class Expression {
 public:
	Expression(int value);
	Expression(double value);
	Expression(string value);
  Expression(Gpl_type gpl_type, int ival, double dval, string sval);
  Expression(Variable *var);
  Expression(Operator_type op_type, Expression *exp);
  Expression(Operator_type op_type, Expression *lexp, Expression *rexp);

	bool eval_int(int &value);
	bool eval_double(double &value);
	bool eval_string(string &value);
	bool eval_animation_block(Animation_block **value);

  bool type(Gpl_type &type);

  friend ostream &operator<<(ostream &os, Expression &exp);

 private:
	int eval_comparison();
	int eval_string_comp(string v1, string v2);
	template<typename T>
	int eval_numerical_comp(T v1, T v2);

	int get_int();
	double get_double();
	string get_string();

  Variable *var_;
	Gpl_type type_;
	int const_int_;
	double const_double_;
	string const_string_;
  Operator_type op_type_;
  Expression *lexp_;
  Expression *rexp_;
};


#endif // GPL_EXPRESSION_H_
