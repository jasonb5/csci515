#include "error.h"

#include <iostream>
using namespace std;

// The following is a global variable defined by the scanner (the lex .l file)
extern int line_count; // the line number of current token

/* static */ bool Error::m_runtime = false;
/* static */ int Error::m_num_errors = 0;

/* static */ void Error::error_header()
{
  if (m_runtime)
    cerr << "Runtime error: ";
  else cerr << "Semantic error on line " << line_count  << ": ";
}

/* static */ void Error::error(Error_type type,
                               string s1 /* = "" */,
                               string s2 /* = "" */,
                               string s3 /* = "" */
                               )
{
  switch (type)
  {
    // in future phases of the assignment, many other errors will be defined here

    // this error originates from gpl.y when it finds an illegal token
    case ILLEGAL_TOKEN:
      cerr << "Syntax error on line "
        << line_count
        << " '" << s1 << "'" << " is not a legal token."
        << endl;
      break;

    // only called in gpl.cpp when parser finds an error
    // called from yyerror()
    case PARSE_ERROR:
      cerr << "Parse error on line "
        << line_count
        << " reported by parser: "
        << s1 << "."
        << endl;
      break;

    case UNDEFINED_ERROR:
      error_header();
      cerr << "Undefined error passed to Error::error().  "
        << "This is probably because error.cpp was not updated "
        << "when a new error was added to error.h."
        << endl;
      break;
    default:
      cerr << "Unknown error sent to class Error::error()."
        << endl;
      break;
  }
  m_num_errors++;
}
