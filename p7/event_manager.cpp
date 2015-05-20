#include "event_manager.h"

#include "gpl_assert.h"
#include "statement_block.h"

using namespace std;

Event_manager *Event_manager::m_instance = 0;

Event_manager *Event_manager::instance() {
  if (!m_instance)
    m_instance = new Event_manager();
  return m_instance;
}

Event_manager::Event_manager()
	:	event_stmt_(Window::Keystroke::NUMBER_OF_KEYS)	{

}

Event_manager::~Event_manager() {

}

void Event_manager::execute_handlers(Window::Keystroke keystroke) {
  vector<Statement_block*>::iterator it;

  for (it = event_stmt_[keystroke].begin(); it != event_stmt_[keystroke].end(); ++it) { 
    (*it)->execute();
  }
}

void Event_manager::set_stmt(Window::Keystroke key, Statement_block *stmt_block) {
	event_stmt_[key].push_back(stmt_block);
}
