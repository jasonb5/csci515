#include "print_stmt.h"

Print_stmt::Print_stmt(int line, Expression *exp)
	:	Statement(),
		line_(line),
		exp_(exp) {

}

Print_stmt::~Print_stmt() {

}

void Print_stmt::execute() {
	string value;

	exp_->eval_string(value);

	cout << "gpl[" << line_ << "]: " << value << endl;
}
