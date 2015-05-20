#ifndef GPL_SYMBOL_H_
#define GPL_SYMBOL_H_

#include <string>
#include <iostream>

using namespace std;

#include "gpl_type.h"
#include "game_object.h"

class Animation_block;

union Symbol_value {
  int value_int;
  double value_double;
  string *value_string;
	Game_object *value_gobject;
	Animation_block *value_animation_block;
};

class Symbol { 
 public:
  Symbol(string name, int value);
  Symbol(string name, double value);
  Symbol(string name, string value);
	Symbol(string name, Game_object *gobj);
	Symbol(string name, Animation_block *anim_blk);

  string name() { return name_; }
  enum Gpl_type type() { return type_; }

  int get_int_value();
  double get_double_value();
  string get_string_value();
	Game_object *get_gobject_value();
	Animation_block *get_animation_block();

	friend ostream &operator<<(ostream &os, Symbol &symbol);

 private:
  enum Gpl_type type_;
  string name_;
  Symbol_value value_;
};

#endif // GPL_SYMBOL_H_
