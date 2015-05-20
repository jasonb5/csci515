#include "assignment_stmt.h"

#include "assert.h"
#include "error.h"

#include <sstream>

Assignment_stmt::Assignment_stmt(Operator_type op_type, Variable *var, Expression *exp)
  : Statement(),
    var_(var),
    exp_(exp),
    op_type_(op_type) {

}

Assignment_stmt::~Assignment_stmt() {

}

void Assignment_stmt::execute() {
  if (!var_->eval_symbol()) {
    if (var_->is_array()) {
      int index;
      if (!var_->valid_array_index(index)) {
        ostringstream oss;

        oss << index;

        Error::error(Error::ARRAY_INDEX_OUT_OF_BOUNDS, var_->id(), oss.str());

        var_->set_array_index(0);
      }
    }
  }

  switch (op_type_) {
  case ASSIGN:
    execute_assign();
    break;
  case PLUS_ASSIGN:
    execute_plus_assign();
    break;
  case MINUS_ASSIGN:
    execute_minus_assign();
    break;
  default:
    assert(false);
  }
}

void Assignment_stmt::execute_assign() {
  Gpl_type type;

  var_->type(type);
	
  switch (type) {
  case INT: {
    int value;
    
    exp_->eval_int(value);
    var_->set_value(value);    
    break;
  }
  case DOUBLE: {
    double value;

    exp_->eval_double(value);
    var_->set_value(value);
    break;
  }
  case STRING: {
    string value;

    exp_->eval_string(value);
    var_->set_value(value);
    break;
  }
  case ANIMATION_BLOCK: {
    Animation_block *value;

    exp_->eval_animation_block(&value);
    var_->set_value(value);
    break;
  }
  default:
    assert(false);
  }
}

void Assignment_stmt::execute_plus_assign() {
	Gpl_type type;

	var_->type(type);

	switch (type) {
	case INT: {
		int incr;
		int current = var_->get_int();
	
		exp_->eval_int(incr);

		var_->set_value(current+incr);
		break;
	}
	case DOUBLE: {
		double incr;
		double current = var_->get_double();

		exp_->eval_double(incr);

		var_->set_value(current+incr);
		break;
	}
	case STRING: {
		string incr;
		string current = var_->get_string();

		exp_->eval_string(incr);

		var_->set_value(current+incr);
		break;	
	}
	default: assert(false);
	}
}

void Assignment_stmt::execute_minus_assign() {
	Gpl_type type;

	var_->type(type);

	switch (type) {
	case INT: {
		int incr;
		int current = var_->get_int();
	
		exp_->eval_int(incr);

		var_->set_value(current-incr);
		break;
	}
	case DOUBLE: {
		double incr;
		double current = var_->get_double();

		exp_->eval_double(incr);

		var_->set_value(current-incr);
		break;
	}
	default: assert(false);
	}
}
