#include "symbol.h"

#include "assert.h"

Symbol::Symbol(string name, int value)
  :	type_(INT), 
		name_(name) {
  value_.value_int = value;
}

Symbol::Symbol(string name, double value)
  : type_(DOUBLE),
		name_(name) {
  value_.value_double = value;
}

Symbol::Symbol(string name, string value)
  : type_(STRING),
		name_(name) {
  value_.value_string = new string(value);
}

int Symbol::get_int_value() {
  assert(type_ == INT);

  return value_.value_int;
}

double Symbol::get_double_value() {
  assert(type_ == DOUBLE);

  return value_.value_double;
}

string Symbol::get_string_value() {
  assert(type_ == STRING);

  return *value_.value_string;
}

ostream &operator<<(ostream &os, Symbol &symbol) {
  os << gpl_type_to_string(symbol.type()) << " " << symbol.name() << " ";

  switch (symbol.type()) {
  case INT: os << symbol.get_int_value(); break;
  case DOUBLE: os << symbol.get_double_value(); break;
  case STRING: os << "\"" << symbol.get_string_value() << "\""; break;
  default: os << "Invalid type " << gpl_type_to_string(symbol.type());
  }

  os << endl;

  return os;
}
