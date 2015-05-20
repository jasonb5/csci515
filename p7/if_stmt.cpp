#include "if_stmt.h"

If_stmt::If_stmt(Expression *exp, Statement_block *if_block) 
	: Statement(),
		exp_(exp),
		if_block_(if_block),
		else_block_(NULL) {

}

If_stmt::If_stmt(Expression *exp, Statement_block *if_block, Statement_block *else_block) 
	: Statement(),
		exp_(exp),
		if_block_(if_block),
		else_block_(else_block) {

}

If_stmt::~If_stmt() {

}

void If_stmt::execute() {
	int result;

	exp_->eval_int(result);

	if (result) {
		if_block_->execute();
	} else {
		if (else_block_ != NULL) {
			else_block_->execute();
		}
	}	
}
