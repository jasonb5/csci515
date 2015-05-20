#include "statement_block.h"
#include "gpl_assert.h"
using namespace std;


Statement_block::Statement_block()
{

}

// Return true if this statement_block has no statements, false otherwise
// Implement this function for p7 (but you won't need it until p8)
bool Statement_block::empty()
{
  // This function MUST be defined for p8
  // If you forget to define it, none of your animations will work
  // So define it when you implement p7

  // place holder to keep the compiler from issuing a warning
  return true;
}

// this function is called for all non-animation_block statement_blocks
// Implement it for p7
void Statement_block::execute()
{
  // This function should be defined before it is ever called
  // This assert will cause the program to abort if this function 
  // is called before it is implemented.

  // *** ==> Remove this assert when you implement this function
  assert(false);
}
