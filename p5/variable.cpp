#include "variable.h"

#include <sstream>

using namespace std;

#include "assert.h"
#include "error.h"
#include "expression.h"
#include "symbol_table.h"

Variable::Variable(Symbol *sym)
  : Variable(sym, NULL) {
}

Variable::Variable(Symbol *sym, Expression *exp)
  : sym_(sym),
    exp_(exp) {

}

Variable::~Variable() {

}

Gpl_type Variable::type() {
	return (sym_ == NULL) ? INT : sym_->type();	
}

int Variable::get_int() {
  return (sym_ == NULL) ? 0 : sym_->get_int_value();
}

double Variable::get_double() {
  return (sym_ == NULL) ? 0.0 : sym_->get_double_value();
}

string Variable::get_string() {
  return (sym_ == NULL) ? "" : sym_->get_string_value();
}
