#ifndef GPL_SYMBOL_TABLE_H_
#define GPL_SYMBOL_TABLE_H_

#include <map>
#include <string>
#include <iostream>

using namespace std;

#include "symbol.h"

class Symbol_table {
 public:
  static Symbol_table *instance() {
    if (instance_ == NULL) {
      instance_ = new Symbol_table();
    }

    return instance_;
  };

  static void print(ostream &os);

	bool Exists(string key);
  Symbol *Get(string key);
  bool Put(Symbol *sym);

 private:
  Symbol_table() { };
  Symbol_table(const Symbol_table &);
  Symbol_table &operator=(const Symbol_table &);

  map<string, Symbol*> symbol_map_; 
  
  static Symbol_table *instance_;
};

#endif // GPL_SYMBOL_TABLE_H_
