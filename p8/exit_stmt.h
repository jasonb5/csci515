#ifndef EXIT_STMT_H
#define EXIT_STMT_H

#include "statement.h"
#include "expression.h"

class Exit_stmt : public Statement {
 public:
	Exit_stmt(int line, Expression *exp);
	~Exit_stmt();	

	virtual void execute();
	
 private:
	int line_;
	Expression *exp_;
};

#endif // EXIT_STMT_H
