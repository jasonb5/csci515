#include "variable.h"

#include <sstream>

using namespace std;

#include "assert.h"
#include "error.h"
#include "expression.h"
#include "symbol_table.h"

Variable::Variable(string id)
	:	Variable(id, NULL, "") {
	sym_ = Symbol_table::instance()->Get(id);
}

Variable::Variable(string id, string mem_id)
	: Variable(id, NULL, mem_id) {
	sym_ = Symbol_table::instance()->Get(id);
}

Variable::Variable(string id, Expression *exp)
	:	Variable(id, exp, "") {

}

Variable::Variable(string id, Expression *exp, string mem_id)
	:	sym_(NULL),
		id_(id),
		mem_id_(mem_id),
		exp_(exp) {
  // we don't evaluate the index expression in order to prevent 
  // errors from being thrown when creating an assign statement
  // where the parse time index is invalid, instead we lookup a
  // known symbol so we can still provide a valid type call
	if (exp != NULL) {
    ostringstream oss;

		oss << id << "[0]";

		sym_ = Symbol_table::instance()->Get(oss.str());	
	}
}

Variable::~Variable() {

}

bool Variable::type(Gpl_type &type) {
	if (sym_ == NULL) {
    if (exp_ != NULL) {
      // we guard against bad eval_symbol calls that can potentially
      // set sym_ to NULL and guarentee a valid type for a valid array
      sym_ = Symbol_table::instance()->Get(id_ + "[0]");
    }

    // symbol must really not exists, should this ever be an actual state?
    if (sym_ == NULL) return false;
  }

  // get the true symbol type
	symbol_type(type);

  // get the member type if we're accessing an object
	if (type == GAME_OBJECT && !mem_id_.empty()) {
		Status status = member_type(type);

		return (status == Status::OK) ? true : false;	
	}

	return true;
}
// returns true symbol type
void Variable::symbol_type(Gpl_type &type) {
	assert(sym_ != NULL);

	type = sym_->type();
}

// returns member type of object
Status Variable::member_type(Gpl_type &type) {
	assert(sym_ != NULL && sym_->type() == GAME_OBJECT);

	return sym_->get_gobject_value()->get_member_variable_type(mem_id_, type);
}

bool Variable::valid_array_index(int &index) {
  ostringstream oss;

  exp_->eval_int(index);

  oss << id_ << "[" << index << "]"; 

  if (!Symbol_table::instance()->Exists(oss.str())) {
    return false;
  }

  return true;
}

void Variable::set_array_index(int index) {
  ostringstream oss;

  exp_->eval_int(index);

  oss << id_ << "[" << index << "]"; 

  sym_ = Symbol_table::instance()->Get(oss.str());
}

int Variable::get_int() {
	eval_symbol();

	if (sym_ == NULL) return 0;

	if (sym_->type() == GAME_OBJECT) {
		int value;

		sym_->get_gobject_value()->get_member_variable(mem_id_, value);

		return value;
	}

  return sym_->get_int_value();
}

double Variable::get_double() {
	eval_symbol();

	if (sym_ == NULL) return 0.0;

	if (sym_->type() == GAME_OBJECT) {
		double value;

		sym_->get_gobject_value()->get_member_variable(mem_id_, value);

		return value;
	}

  return sym_->get_double_value();
}

string Variable::get_string() {
	eval_symbol();

	if (sym_ == NULL) return "";

	if (sym_->type() == GAME_OBJECT) {
		string value;

		sym_->get_gobject_value()->get_member_variable(mem_id_, value);

		return value;
	}

  return sym_->get_string_value();
}

Game_object *Variable::get_game_object() {
  eval_symbol();

  if (sym_ == NULL) return NULL;

  return sym_->get_gobject_value();
}

Animation_block *Variable::get_animation_block() {
	if (sym_ == NULL) return NULL;

	return sym_->get_animation_block();
}

void Variable::set_value(int value) {
  if (sym_->type() == GAME_OBJECT) {
    sym_->get_gobject_value()->set_member_variable(mem_id_, value);
  } else {
    sym_->set_value(value);
  }
}

void Variable::set_value(double value) {
  if (sym_->type() == GAME_OBJECT) {
    sym_->get_gobject_value()->set_member_variable(mem_id_, value);
  } else {
    sym_->set_value(value);
  }
}

void Variable::set_value(string value) {
  if (sym_->type() == GAME_OBJECT) {
    sym_->get_gobject_value()->set_member_variable(mem_id_, value);
  } else {
    sym_->set_value(value);
  }
}

void Variable::set_value(Animation_block *anim_blk) {
  if (sym_->type() == GAME_OBJECT) {
    sym_->get_gobject_value()->set_member_variable(mem_id_, anim_blk);
  } else {
    sym_->set_value(anim_blk);
  }
}

bool Variable::eval_symbol() {
  // attempt to update the symbol basic on runtime evaluation
  // of the arrays index expression, this may differ from
  // it's parse time value
	if (exp_ != NULL) {
		int index;
		ostringstream oss;

		exp_->eval_int(index);

		oss << id_ << "[" << index << "]";

    // only update symbol if it's currently null from a previous
    // bad eval or of the symbol has changed. Used for variable 
    // index calls to array values
		if (sym_ == NULL || sym_->name() != oss.str()) {
			sym_ = Symbol_table::instance()->Get(oss.str());

      return (sym_ == NULL) ? false :true;
		}
	}

  return (sym_ == NULL) ? false : true;
}
