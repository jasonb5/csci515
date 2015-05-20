#include "symbol_table.h"

Symbol_table *Symbol_table::instance_ = NULL;

void Symbol_table::print(ostream &os) {
	map<string, Symbol*>::const_iterator it;

	for (it = instance_->symbol_map_.begin(); it != instance_->symbol_map_.end(); ++it) {
		Symbol *s = (*it).second;

		if (s == NULL) {
			os << "DUH ITS NULL" << endl;	
		}	

		os << *it->second;
	}
}

bool Symbol_table::Exists(string key) {
  map<string, Symbol*>::const_iterator it;

  for (it = instance_->symbol_map_.begin(); it != instance_->symbol_map_.end(); ++it) {
    if (it->first.compare(key) == 0) {
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
  symbol_map_[sym->name()] = sym;

	return true;
}

bool Symbol_table::get(string name, int &value) {
  Symbol *sym = Get(name);

  if (sym == NULL || sym->type() != INT) {
    return false;
  }

  value = sym->get_int_value();

  return true;
}

bool Symbol_table::get(string name, double &value) {
  Symbol *sym = Get(name);

  if (sym == NULL || sym->type() != DOUBLE) {
    return false;
  }

  value = sym->get_double_value();

  return true;
}

bool Symbol_table::get(string name, string &value) {
  Symbol *sym = Get(name);

  if (sym == NULL || sym->type() != STRING) {
    return false;
  }

  value = sym->get_string_value();
  
  return true;
}

bool Symbol_table::get_type(string name, Gpl_type &type) {
	Symbol *sym = Get(name);

	if (sym == NULL) {
		return false;
	}

	type = sym->type();

  return true;
}

bool Symbol_table::set(string name, int value) {
  return true;
}
