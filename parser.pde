

//str: token in the form of Xnnn
//old: head of object chain else null
//returns: head of object chain

struct command_t command_list[MAX_COMMANDS];
uint8_t commandLength = 0;



void addObj(uint8_t *str) {
  command c;
  if (commandLength == MAX_COMMANDS) {
     error("addObj FULL");
     return;
  }
  c = &command_list[commandLength++];
  c->type   = str[0];
  c->value  = strtod((const char*)&str[1], NULL);
}


void purge_commands() {
  commandLength = 0;
}


void parse_commands(uint8_t *str) {
  uint8_t *token;
  
  do {
    token = (uint8_t*)strtok((char*)str, " \t"); //split on spaces and tabs
    str = NULL;
    if (token) addObj(token);
  } while (token);
}


//returns zero if value does not exist.
double getValue(const char x) {
  int i;
  //find entry
  for (i=0; i<commandLength; i++) {
    if (command_list[i].type == x) break;
  } 
  //did we find or run out?
  if (i==commandLength) return 0;
  
  return command_list[i].value;
}


bool command_exists(const char x) {
  for (int i=0; i<commandLength; i++) {
    if (command_list[i].type == x) return 1;
  } 
  return 0;
}

/*
command addObj(uint8_t *str, command old) {
  command newCommand;
  command head = old;

  debug("addObj()");  
  newCommand = (command) malloc(sizeof(command));
  if (!newCommand) {
    debug("\tCannot Malloc()");
    return NULL;
  }
  newCommand->type =  str[0];
  newCommand->str  = &str[1];
  newCommand->next =  0;

debug3("\ttype:",(char)newCommand->type,BYTE);
debug2("\tstr:",(char*)newCommand->str);
debug3("\tnext:",(long int)newCommand->next, HEX);

  //return if beginning of chain
  if (!old) return newCommand;

  //append and return old if adding to chain
  while(old->next) old=old->next;
  old->next = newCommand;	
  
  return head;
}

void purge_commands(command head) {
  command next;
  debug("purge_commands()");
  while (head) {
    debug("\tDelete Object");
    
debug3("\t\ttype:",(char)head->type,BYTE);
debug2("\t\tstr:",(char*)head->str);
debug3("\t\tnext:",(long int)head->next, HEX);

    next = head->next;
    free(head);
    head = next;
  }
  debug("\tDone");
}

//assumes null terminated string
command parse_commands(uint8_t *str) {
  uint8_t *token;
  command list = NULL;
  debug("parse_commands()");
  
  do {
    token = (uint8_t*)strtok((char*)str, " \t"); //split on spaces and tabs
    str = NULL;
    if (token) 	list = addObj(token, list);
  } while (token);
  
  return list;
}

bool command_exists(const char x, command list) {
  debug("command_exists()");
  while(list) {
    if (x == list->type) return 1;
    list = list->next;
  }
  return 0;
}

//returns zero if value does not exist.
double getValue(const char x, command list) {
  debug("getValue()");
  while(list) {
    if (x == list->type) break;
    list = list->next;
  }
  if (!list) return 0; //XXX getValue called for object that doesn't exist

  return strtod((const char*)list->str, NULL);
}
*/
