#include "symbol_table.h"

Symbol_table *Symbol_table::instance_ = NULL;

void Symbol_table::print(ostream &os) {
	map<string, Symbol*>::const_iterator it;

	for (it = instance_->symbol_map_.begin(); it != instance_->symbol_map_.end(); ++it) {
		os << *it->second;
	}
}

bool Symbol_table::Exists(string key) {
  map<string, Symbol*>::const_iterator it;

  for (it = instance_->symbol_map_.begin(); it != instance_->symbol_map_.end(); ++it) {
    if (!it->first.compare(key)) {
      return true;
    }
  }

	return false;
}

Symbol *Symbol_table::Get(string key) {
  if (!Exists(key)) {
    return NULL;
  }

  return symbol_map_[key];
}

bool Symbol_table::Put(Symbol *sym) {
	if (Exists(sym->name())) {
		return false;
	}

  symbol_map_[sym->name()] = sym;

	return true;
}
