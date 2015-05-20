#ifndef IF_STMT_H
#define IF_STMT_H

#include "statement.h"
#include "statement_block.h"
#include "expression.h"

class If_stmt : public Statement {
 public:
	If_stmt(Expression *exp, Statement_block *if_block);
	If_stmt(Expression *exp, Statement_block *if_block, Statement_block *else_block);
	~If_stmt();

	virtual void execute();

 private:
	Expression *exp_;
	Statement_block *if_block_;
	Statement_block *else_block_;
};

#endif // IF_STMT_H
