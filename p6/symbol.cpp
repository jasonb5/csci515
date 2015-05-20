#include "symbol.h"

#include "indent.h"
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

Symbol::Symbol(string name, Game_object *gobj)
	: type_(GAME_OBJECT),
		name_(name) {
	value_.value_gobject = gobj;
}

Symbol::Symbol(string name, Animation_block *anim_blk)
	:	type_(ANIMATION_BLOCK),
		name_(name) {
	value_.value_animation_block = anim_blk;
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

Game_object *Symbol::get_gobject_value() {
	assert(type_ == GAME_OBJECT);
	
	return value_.value_gobject;
}

Animation_block *Symbol::get_animation_block() {
	assert(type_ == ANIMATION_BLOCK);

	return value_.value_animation_block;
}

ostream &operator<<(ostream &os, Symbol &symbol) {
  os << gpl_type_to_string(symbol.type()) << " " << symbol.name();

  switch (symbol.type()) {
  case INT: os << " " << symbol.get_int_value(); break;
  case DOUBLE: os << " " << symbol.get_double_value(); break;
  case STRING: os << " \"" << symbol.get_string_value() << "\""; break;
	case GAME_OBJECT: 
		indent++;
		os << endl << symbol.get_gobject_value();
		indent--;
		break;
	default: break;	
  }

  os << endl;

  return os;
}
