#ifndef GPL_SYMBOL_TABLE_H_
#define GPL_SYMBOL_TABLE_H_

#include <map>
#include <string>
#include <iostream>

using namespace std;

#include "symbol.h"

// Encapsulates a map of Symbols.
// Class is implemented as a singleton
// to manager a global Symbol table
class Symbol_table {
 public:
	// Returns singleton instance
  static Symbol_table *instance() {
    if (instance_ == NULL) {
      instance_ = new Symbol_table();
    }

    return instance_;
  };

	// Prints out all symbols in the format
	// of TYPE NAME VALUE
  static void print(ostream &os);

	// Returns true if a symbol name exists
	bool Exists(string key);
	// Puts a symbol into the table
  void Put(string key, Symbol *sym);

 private:
	// Private default constructor
  Symbol_table() { };
	// Override copy constructor
  Symbol_table(const Symbol_table &);
	// Override assignement operator
  Symbol_table &operator=(const Symbol_table &);

	// Map of symbol names and symbol pointers
  map<string, Symbol*> symbol_map_; 
 
	// Singletone variable 
  static Symbol_table *instance_;
};

#endif // GPL_SYMBOL_TABLE_H_
