/***
  This file is a placeholder for the Statement_block class you will write in 
  the next assignment p7.

  You may use it w/o modification in p6.

  You may use it as a starting point for your Statement_block class for p7.

  I have put in just enough for it to work in p6.

***/
#ifndef STATEMENT_BLOCK_H
#define STATEMENT_BLOCK_H

#include <vector>
#include <iostream>

using namespace std;

#include "indent.h"
#include "statement.h"

class Game_object;

class Statement_block {
 public:
	Statement_block();

	// return true if the statement block contains no statements
	bool empty();

	// This is called when a statement block is executed
	// Implement it for p7
	void execute();

	void push_stmt(Statement *stmt);

 private:
	vector<Statement*> stmts_;
};

#endif // #ifndef STATEMENT_BLOCK_H
