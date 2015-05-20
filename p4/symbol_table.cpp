#include "symbol_table.h"

Symbol_table *Symbol_table::instance_ = NULL;

void Symbol_table::print(ostream &os) {
  map<string, Symbol*>::const_iterator it;

	// Iterate and print all symbols
  for (it = instance_->symbol_map_.begin(); it != instance_->symbol_map_.end(); ++it) {
    Symbol *s = it->second;

    os << *s;
  }
}

bool Symbol_table::Exists(string key) {
  map<string, Symbol*>::const_iterator it;

	// Iterator through table until a key matches
  for (it = instance_->symbol_map_.begin(); it != instance_->symbol_map_.end(); ++it) {
		if (it->first.find(key) != string::npos) {
			return true;
		}
  }

	return false;
}

void Symbol_table::Put(string key, Symbol *sym) {
  symbol_map_[key] = sym;
}
