#include <vector>
#include "animation_block.h"
#include "game_object.h"
#include "indent.h"
#include "gpl_assert.h"
#include "symbol.h"

using namespace std;

Animation_block::Animation_block(Symbol *parameter_symbol, string name) {
  complete_ = false;

  m_name = name;

  m_parameter_symbol = parameter_symbol;
}

void Animation_block::mark_complete() {
  complete_ = true;
}

bool Animation_block::complete() {
  return complete_;
}

void Animation_block::execute(Game_object *argument) {
  Game_object *gobj = m_parameter_symbol->get_gobject_value();

  m_parameter_symbol->set_value(argument);

  Statement_block::execute();

  m_parameter_symbol->set_value(gobj);
}
