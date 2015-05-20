#include "for_stmt.h"

For_stmt::For_stmt(Expression *exp, Statement_block *init_block, Statement_block *inc_block, Statement_block *body_block)
	:	Statement(),
		exp_(exp),
		init_block_(init_block),
		inc_block_(inc_block),
		body_block_(body_block) {

}

For_stmt::~For_stmt() {

}

void For_stmt::execute() {
	int comp;	

	init_block_->execute();

	exp_->eval_int(comp);	

	while (comp) {
		body_block_->execute();

		inc_block_->execute();

		exp_->eval_int(comp);	
	}
}
