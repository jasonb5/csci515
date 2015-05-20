#ifndef STATEMENT_H
#define STATEMENT_H

class Statement {
 public:
	Statement();
	~Statement();

	virtual void execute() = 0;

 private:

};

#endif // STATEMENT_H
