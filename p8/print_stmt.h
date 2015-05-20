#ifndef PRINT_STMT_H
#define PRINT_STMT_H

#include "statement.h"
#include "expression.h"

class Print_stmt : public Statement {
 public:
	Print_stmt(int line, Expression *exp);
	~Print_stmt();

	virtual void execute();

 private:
	int line_;
	Expression *exp_;
};

#endif // PRINT_STMT_H
