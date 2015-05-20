#include "expression.h"

#include <cmath>
#include <sstream>

using namespace std;

#include "error.h"
#include "assert.h"
#include "indent.h"

Expression::Expression(int value)
  : Expression(INT, value, 0.0, "") {

}

Expression::Expression(double value)
  : Expression(DOUBLE, 0, value, "") {

}

Expression::Expression(string value)
  : Expression(STRING, 0, 0.0, value) {

}

Expression::Expression(Gpl_type gpl_type, int ival, double dval, string sval)
  : var_(NULL), 
    type_(gpl_type),
    const_int_(ival),
    const_double_(dval),
    const_string_(sval),
		op_type_(PLUS),
    lexp_(NULL),
    rexp_(NULL) {

}

Expression::Expression(Variable *var)
  : var_(var), 
    type_(INT),
    const_int_(0),
    const_double_(0.0),
    const_string_(""),
		op_type_(PLUS),
    lexp_(NULL),
    rexp_(NULL) {

}

Expression::Expression(Operator_type op_type, Expression *exp)
  : Expression(op_type, exp, NULL) {

}

Expression::Expression(Operator_type op_type, Expression *lexp, Expression *rexp)
  : var_(NULL), 
    type_(INT),
    const_int_(0),
    const_double_(0.0),
    const_string_(""),
		op_type_(op_type),
    lexp_(lexp),
    rexp_(rexp) {

}

bool Expression::eval_int(int &value) {
	Gpl_type t;

	type(t);

	if ((t & INT) == 0) return false;

	switch (t) {
	case INT: 
		value = get_int();
		break;
	default: break;
	}

	return true;
}

bool Expression::eval_double(double &value) {
	Gpl_type t;

	type(t);

	if ((t & (INT | DOUBLE)) == 0) return false;

	switch (t) {
	case INT: 
		value = (double)get_int();
		break;
	case DOUBLE: 
		value = get_double();
		break;
	default: break;
	}	

	return true;
}

bool Expression::eval_string(string &value) {
	Gpl_type t;
	ostringstream oss;

	type(t);

	if ((t & (INT | DOUBLE | STRING)) == 0) return false;

	switch (t) {
	case INT: oss << get_int(); break;
	case DOUBLE: oss << get_double(); break;
	case STRING: oss << get_string(); break;
	default: break;
	}

	value = oss.str();

	return true;
}

bool Expression::eval_animation_block(Animation_block **value) {
	Gpl_type t;

	type(t);

	if (t != ANIMATION_BLOCK) return false;

	*value = var_->get_animation_block();

	return true;
}

bool Expression::type(Gpl_type &type) {
	if (lexp_ != NULL && rexp_ != NULL) {
		// return type for binary expressions
		switch (op_type_) {
		case OR:
		case AND:
		case EQUAL:
		case NOT_EQUAL:
		case LESS_THAN:
		case LESS_THAN_EQUAL:
		case GREATER_THAN:
		case GREATER_THAN_EQUAL:
			// all comparisons actually return as an integer
			type = INT;	
			break;
		default:
			// all other operands return their most general type
			Gpl_type ltype;
			Gpl_type rtype;

			if (!lexp_->type(ltype) || !rexp_->type(rtype)) {
				return false;
			}

			type = (ltype >= rtype) ? ltype : rtype;
			break;
		}
	} else if (lexp_ != NULL && rexp_ == NULL) {
		// return type for unary expression	
		switch (op_type_) {
		case SIN:
		case COS:
		case TAN:
		case ASIN:
		case ACOS:
		case ATAN:
		case SQRT:
			// trig functions return double
			type = DOUBLE;
			break;
		case NOT:
		case FLOOR:
		case RANDOM: 
			type = INT;
			break;
		default: 
			lexp_->type(type);
			break;
		}	
	} else if (var_ != NULL) {
		// return variable type
		return var_->type(type);
	} else {
		type = type_; // returns constant type
	}

	return true;
}

ostream &operator<<(ostream &os, Expression &exp) {
	Gpl_type type;
	
  if (exp.lexp_ != NULL && exp.rexp_ != NULL) {
    os << indent << "Binary expression" << endl;
		os << indent << "Operator: " << operator_to_string(exp.op_type_) << endl;
		exp.type(type);
		os << indent << "Type: " << gpl_type_to_string(type) << endl;
		os << indent << "Left: " << endl;
		indent++;
		os << *exp.lexp_;
		indent--;
		os << indent << "Right: " << endl;
		indent++;
		os << *exp.rexp_;
		indent--;
  } else if (exp.lexp_ != NULL && exp.rexp_ == NULL) {
    os << indent << "Unary expression" << endl;
		os << indent << "Operator: " << operator_to_string(exp.op_type_) << endl;
		exp.type(type);
		os << indent << "Type: " << gpl_type_to_string(type) << endl;
		os << indent << "Left: " << endl;
		indent++;
		os << *exp.lexp_;
		indent--;
  } else if (exp.var_ != NULL) {
    os << indent << "Variable expression" << endl;
		exp.type(type);
		os << indent << "Type: " << gpl_type_to_string(type) << endl;
		os << indent << "Value: ";
		exp.type(type);
		switch (type) {
		case INT: {
			int value;
			exp.eval_int(value);
			os << value; 
			break;
		}
		case DOUBLE: {
			double value;
			exp.eval_double(value);
			os << value;
			break;
		}	
		case STRING: {
			string value;
			exp.eval_string(value); 
			os << value;
			break;
		}
		default: assert(false);
		}
		os << endl;
  } else {
    os << indent << "Constant expression" << endl;
		exp.type(type);
		os << indent << "Type: " << gpl_type_to_string(type) << endl;
		os << indent << "Value: ";
		exp.type(type);
		switch (type) {
		case INT: {
			int value;
			exp.eval_int(value);
			os << value; 
			break;
		}
		case DOUBLE: {
			double value;
			exp.eval_double(value);
			os << value;
			break;
		}	
		case STRING: {
			string value;
			exp.eval_string(value); 
			os << value;
			break;
		}
		default: assert(false);
		}
		os << endl;
  }

  os << endl;

  return os;
}

int Expression::eval_comparison() {
	Gpl_type ltype;

 	lexp_->type(ltype);

	Gpl_type rtype;

	rexp_->type(rtype);

	Gpl_type ctype = (ltype >= rtype) ? ltype : rtype;

	switch (ctype) {
	case INT:	{
		int lval, rval;

		lexp_->eval_int(lval);

		rexp_->eval_int(rval);
	
		return eval_numerical_comp<int>(lval, rval);
	}
	case DOUBLE: {
		double lval, rval;

		lexp_->eval_double(lval);

		rexp_->eval_double(rval);

		return eval_numerical_comp<double>(lval, rval);
	}
	case STRING: {
		string lval, rval;

		lexp_->eval_string(lval);
	
		rexp_->eval_string(rval);

		return eval_string_comp(lval, rval);
	}
	default: assert(false);
	}

	return 0;
}

int Expression::eval_string_comp(string v1, string v2) {
	switch (op_type_) {
	case EQUAL: return v1 == v2;
	case NOT_EQUAL: return v1 != v2;
	case LESS_THAN: return v1 < v2;
	case LESS_THAN_EQUAL: return v1 <= v2;
	case GREATER_THAN: return v1 > v2;
	case GREATER_THAN_EQUAL: return v1 >= v2;
	default: assert(false);
	}

	return 0;
}

template<typename T>
int Expression::eval_numerical_comp(T v1, T v2) {
	switch (op_type_) {
	case OR: return v1 || v2;
	case AND: return v1 && v2;
	case EQUAL: return v1 == v2;
	case NOT_EQUAL: return v1 != v2;
	case LESS_THAN: return v1 < v2;
	case LESS_THAN_EQUAL: return v1 <= v2;
	case GREATER_THAN: return v1 > v2;
	case GREATER_THAN_EQUAL: return v1 >= v2;
	default: assert(false);
	}

	return 0;
}

int Expression::get_int() {
	if (lexp_ != NULL && rexp_ != NULL) {
		switch (op_type_) {
		case OR:
		case AND:
		case EQUAL:
		case NOT_EQUAL:
		case LESS_THAN:
		case LESS_THAN_EQUAL:
		case GREATER_THAN:
		case GREATER_THAN_EQUAL:
			return eval_comparison();
		case PLUS: {
			int lval, rval;

			lexp_->eval_int(lval);

			rexp_->eval_int(rval);

			return lval + rval;
		}
		case MINUS: {
			int lval, rval;

			lexp_->eval_int(lval);

			rexp_->eval_int(rval);

			return lval - rval;
		}
		case MULTIPLY: {
			int lval, rval;

			lexp_->eval_int(lval);

			rexp_->eval_int(rval);

			return lval * rval;
		}
		case DIVIDE: { 
			int lval, rval;

			lexp_->eval_int(lval);

			rexp_->eval_int(rval);	

			if (rval == 0) {
				Error::error(Error::DIVIDE_BY_ZERO_AT_PARSE_TIME);

				return 0;
			}	

			return lval / rval;
		}
		case MOD: {
			int lval, rval;

			lexp_->eval_int(lval);

			rexp_->eval_int(rval);	

			if (rval == 0) {
				Error::error(Error::MOD_BY_ZERO_AT_PARSE_TIME);

				return 0;
			}
	
			return lval % rval;
		}
		default: assert(false);	
		}
	} else if (lexp_ != NULL && rexp_ == NULL) {
		Gpl_type type;

		lexp_->type(type);

		if (op_type_ == FLOOR) {
			double value;

			lexp_->eval_double(value);

			return floor(value);	
		} else if (op_type_ == NOT && type == DOUBLE) {
			double value;
	
			lexp_->eval_double(value);

			return !(int)value;
		}

		int lval;
		
		lexp_->eval_int(lval);

		switch (op_type_) {
		case UNARY_MINUS: return -lval;
		case NOT: return !lval;
		case RANDOM: return rand() % lval;
		case ABS: return abs(lval);
		case SQRT: return sqrt(lval);
		default: assert(false);
		}
	} else if (var_ != NULL) {
		return var_->get_int();
	}

	return const_int_;
}

double Expression::get_double() {
	if (lexp_ != NULL && rexp_ != NULL) {
		double lval;
		double rval;

		lexp_->eval_double(lval);

 		rexp_->eval_double(rval);

		switch (op_type_) {
		case PLUS: return lval + rval;
		case MINUS: return lval - rval;
		case MULTIPLY: return lval * rval;
		case DIVIDE: 
			if (rval == 0) {
				Error::error(Error::DIVIDE_BY_ZERO_AT_PARSE_TIME);

				return 0;
			}

			return lval / rval;
		default: assert(false);	
		}
	} else if (lexp_ != NULL && rexp_ == NULL) {
		double val;

		lexp_->eval_double(val);

		switch (op_type_) {
		case UNARY_MINUS: return -val;
		case NOT: return !val;
		case SIN: return sin(val*M_PI/180);
		case COS: return cos(val*M_PI/180);
		case TAN: return tan(val*M_PI/180);
		case ASIN: return asin(val)*180/M_PI;
		case ACOS: return acos(val)*180/M_PI;
		case ATAN: return atan(val)*180/M_PI;
		case SQRT: return sqrt(val);
		case FLOOR: return floor(val);
		case ABS: return abs(val);
		default: assert(false);
		}	
	} else if (var_ != NULL) {
		return var_->get_double();
	}

	return const_double_;
}

string Expression::get_string() {
	if (lexp_ != NULL && rexp_ != NULL) {
		string lval;
		string rval;

		lexp_->eval_string(lval);

 		rexp_->eval_string(rval);

		switch (op_type_) {
		case PLUS: return lval + rval;
		default: assert(false);	
		}
	} else if (lexp_ != NULL && rexp_ == NULL) {
	
	} else if (var_ != NULL) {
		return var_->get_string();
	}

	return const_string_;
}
