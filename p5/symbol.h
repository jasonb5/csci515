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

class Symbol { 
 public:
  Symbol(string name, int value);
  Symbol(string name, double value);
  Symbol(string name, string value);

  string name() { return name_; }
  enum Gpl_type type() { return type_; }

  int get_int_value();
  double get_double_value();
  string get_string_value();

	friend ostream &operator<<(ostream &os, Symbol &symbol);

 private:
  enum Gpl_type type_;
  string name_;
  Symbol_value value_;
};

#endif // GPL_SYMBOL_H_
