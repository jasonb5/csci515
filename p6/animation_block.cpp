#include <vector>
#include "animation_block.h"
#include "game_object.h"
#include "indent.h"
#include "gpl_assert.h"
#include "symbol.h"
using namespace std;

Animation_block::Animation_block(Symbol *parameter_symbol, string name)
{
  m_name = name;
  m_parameter_symbol = parameter_symbol;
}

void Animation_block::mark_complete()
{
  // you have to implement this as part of p8
}

bool Animation_block::complete()
{
  // you have to implement this as part of p8

  return false; // this line is temporary until you implement function
}

void Animation_block::execute(Game_object *argument)
{
  // you have to implement this as part of p8
}
