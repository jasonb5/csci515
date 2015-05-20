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

Variable::Variable(Symbol *sym, string mem_id)
	: sym_(sym),
		mem_id_(mem_id) {

}	

Variable::Variable(Symbol *sym, Expression *exp)
  : sym_(sym),
    exp_(exp) {

}

Variable::~Variable() {

}

bool Variable::type(Gpl_type &type) {
  Status status = Status::OK;

  if (sym_ != NULL) {
    if (sym_->type() == GAME_OBJECT) {
      
      status = sym_->get_gobject_value()->get_member_variable_type(mem_id_, type);	
    } else {
      type = sym_->type();
    }
  } else {
    return false;
  }

  return (status == Status::OK) ? true : false;
}

int Variable::get_int() {
	if (sym_ == NULL) return 0;

	if (sym_->type() == GAME_OBJECT) {
		int value;

		sym_->get_gobject_value()->get_member_variable(mem_id_, value);

		return value;
	}

  return sym_->get_int_value();
}

double Variable::get_double() {
	if (sym_ == NULL) return 0.0;

	if (sym_->type() == GAME_OBJECT) {
		double value;

		sym_->get_gobject_value()->get_member_variable(mem_id_, value);

		return value;
	}

  return sym_->get_double_value();
}

string Variable::get_string() {
	if (sym_ == NULL) return "";

	if (sym_->type() == GAME_OBJECT) {
		string value;

		sym_->get_gobject_value()->get_member_variable(mem_id_, value);

		return value;
	}

  return sym_->get_string_value();
}

Animation_block *Variable::get_animation_block() {
	if (sym_ == NULL) return NULL;

	return sym_->get_animation_block();
}
