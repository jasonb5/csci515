#ifndef GPL_SYMBOL_H_
#define GPL_SYMBOL_H_

#include <string>
#include <iostream>

using namespace std;

#include "gpl_type.h"

union Symbol_value {
  int value_int;
  double value_double;
  string *value_string;
};

// Encapsulates a Symbol to be used in 
// a Symbol_table. A Symbol is represented
// by a name, value, type. 
class Symbol { 
 public:
	// Integer constructor
  Symbol(string name, int value);
	// Double constructor
  Symbol(string name, double value);
	// String constructor
  Symbol(string name, string value);

	// Returns  name
  string name() { return name_; }
	// Returns type
  enum Gpl_type type() { return type_; }

	// Returns integer value
  int get_int_value();
	// Returns double value	
  double get_double_value();
	// Returns string value
  string get_string_value();

	friend ostream &operator<<(ostream &os, Symbol &symbol);

 private:
  enum Gpl_type type_;
  string name_;
  Symbol_value value_;
};

#endif // GPL_SYMBOL_H_
