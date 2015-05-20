/*
  Normally when using flex and bison, you include the file y.tab.h

  For gpl you will include parser.h instead of y.tab.h

  parser.h will include y.tab.h

  The reason:
   Since the union created by bison contains the following types

    std::string

   and in future assignments it will contain the types

   Symbol *
   Expression_tree *
   Statement_block *

   The header file for each of these types must be included before
   y.tab.h is included

*/

#ifndef PARSER_H
#define PARSER_H

// In future gpl assignments you will include other include file here
// For this assignment the only non-built-in type is a C++ string
//   so we include the string library here
//
// Students often forget about adding the appropriate include to 
// parser.h when they add a type to the union (defined in the .y file)

#include <string>

#include "y.tab.h"

#endif // #ifndef PARSER_H
