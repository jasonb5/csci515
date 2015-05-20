#ifndef ASSIGNMENT_STMT_H
#define ASSIGNMENT_STMT_H

#include "statement.h"

#include "gpl_type.h"
#include "variable.h"
#include "expression.h"

class Assignment_stmt : public Statement {
 public:
  Assignment_stmt(Operator_type op_type, Variable *var, Expression *exp);
  ~Assignment_stmt();

  virtual void execute();

 private:
	void execute_assign();
	void execute_plus_assign();
	void execute_minus_assign();

  Variable *var_;
  Expression *exp_;
  Operator_type op_type_;
};

#endif
