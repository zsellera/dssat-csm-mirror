/*=======================================================================
  SharedVarDef.hpp, Felipe de Vargas, Willingthon Pavan
  Header file to define shared variables.
-----------------------------------------------------------------------
  REVISION HISTORY
  07/10/2016 FV Written.
========================================================================*/
#ifndef SHAREDVARDEF_H
#define SHAREDVARDEF_H

#include <unordered_map>
#include <string>

  extern std::unordered_map<std::string, std::unordered_map<std::string, std::string>> dataGlobal;
#endif
