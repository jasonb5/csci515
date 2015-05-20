#ifndef FOR_STMT_H
#define FOR_STMT_H

#include "statement.h"
#include "statement_block.h"
#include "expression.h"

class For_stmt : public Statement {
 public:
	For_stmt(Expression *exp, Statement_block *init_block, Statement_block *inc_block, Statement_block *body_block);	
	~For_stmt();

	virtual void execute();

 private:
	Expression *exp_;
	Statement_block *init_block_;
	Statement_block *inc_block_;
	Statement_block *body_block_;
};

#endif // FOR_STMT_H
