#include "exit_stmt.h"

Exit_stmt::Exit_stmt(int line, Expression *exp) 
	: Statement(),
		line_(line),
		exp_(exp) {

}

Exit_stmt::~Exit_stmt() {

}

void Exit_stmt::execute() {
	int result;

	exp_->eval_int(result);

	cout << "gpl[" << line_ << "]: exit(" << result << ")" << endl;	

	exit(result);
}
