/*=======================================================================
  GettersAndSetters.cpp, Felipe de Vargas, Willingthon Pavan
  Functions to manipulate memory in c++.
-----------------------------------------------------------------------
  REVISION HISTORY
  07/10/2016 FV Written.
  09/01/2016 FV Create get's for read weather data.
  09/25/2016 FV Create set's for write data in memory.
  06/18/2017 FV Create new version of getters for weather data.
  12/04/2017 FO Update all FlexibleIO Getters and Setters data structure
  12/04/2017 FO Added a parameter in the functions for the new FlexibleIO data structure
========================================================================*/
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <string.h>
#include <unordered_map>
#include <vector>
#include <algorithm>
#include "SharedVarDef.hpp"
#include "Util/Util.hpp"


extern "C" {

    int findJson(char *filex, int *jsonExist);
    int getReal(char *MODINP, char *VNAME, float *val);
    int getChar(char *MODINP, char *VNAME, char  *val);
    int getInt(char *MODINP, char *VNAME, int *val);
    int getRealInd(char *MODINP, char *VNAME, float *val, int *ind);
    int getIntInd(char *MODINP, char *VNAME, int *val, int *ind);
    int getCharInd(char *MODINP, char *VNAME, char *val, int *ind);
    int getIntArray(char *MODINP, char *VNAME, int *val, int *size);
    int getRealArray(char *MODINP, char *VNAME, float *val, int *size);
    int getRealYrdoy(char *MODINP, int *YRDOY, char *VNAME, float *val);
    int getCharYrdoy(char *MODINP, int *YRDOY, char *VNAME, char  *val);
    int getIntYrdoy(char *MODINP, int *YRDOY, char *VNAME, int *val);

    int setRealMem(char *MODINP, char *VNAME, float *val);
    int setCharMem(char *MODINP, char *VNAME, char  *val);
    int setIntMem(char *MODINP, char *VNAME, int *val);
    int setRealMemInd(char *MODINP, char *VNAME, float *val, int *IND);
    int setCharMemInd(char *MODINP, char *VNAME, char  *val, int *IND);
    int setIntMemInd(char *MODINP, char *VNAME, int *val, int *IND);

    int setIntMemYrdoy(char *MODINP, int *yrdoy, char *VNAME, int *val);
    int setRealMemYrdoy(char *MODINP, int *yrdoy, char *VNAME, float *val);
    int setCharMemYrdoy(char *MODINP, int *yrdoy, char *VNAME, char *val);
}

int findJson(char *filex, int *jsonExist) {

	std::string file(filex);
	file = file.substr(0, file.find(".") + 1);
	file += "json";

	std::ifstream myfile(file);

	if (myfile.is_open()) {
		*jsonExist = 1;
		return 1;
	} else {
		*jsonExist = -1;
		return 1;
	}
}

int getReal(char *MODINP, char *VNAME, float * val) {

	std::string modinp(MODINP), vname(VNAME);
  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());

	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);

  std::unordered_map<std::string, std::unordered_map<std::string, std::string>>::iterator i;
  std::unordered_map<std::string, std::string>::iterator j;
  for(i = dataGlobal.begin(); i != dataGlobal.end(); ++i){
    if(i->first == modinp){
      for(j = i->second.begin(); j != i->second.end(); ++j){
        if(j->first == vname){
          *val = strtof (dataGlobal[modinp][vname].c_str(), NULL);
          return 1;
        }
      }
    }
  }

  *val = -99.0;
	return 1;
}

int getChar(char *MODINP, char *VNAME, char *val) {

	std::string modinp(MODINP), vname(VNAME);
  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());

	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);
	*val = '\0';

  std::unordered_map<std::string, std::unordered_map<std::string, std::string>>::iterator i;
  std::unordered_map<std::string, std::string>::iterator j;
  for(i = dataGlobal.begin(); i != dataGlobal.end(); ++i){
    if(i->first == modinp){
      for(j = i->second.begin(); j != i->second.end(); ++j){
        if(j->first == vname){
          strcpy(val, Util::trim(dataGlobal[modinp][vname]).c_str());
          return 1;
        }
      }
    }
  }
  strcpy(val, "-99");
	return 1;
}

int getInt(char *MODINP, char *VNAME, int *val) {

	std::string modinp(MODINP), vname(VNAME);
  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());

	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);

  std::unordered_map<std::string, std::unordered_map<std::string, std::string>>::iterator i;
  std::unordered_map<std::string, std::string>::iterator j;
  for(i = dataGlobal.begin(); i != dataGlobal.end(); ++i){
    if(i->first == modinp){
      for(j = i->second.begin(); j != i->second.end(); ++j){
        if(j->first == vname){
          *val = (int)strtol(dataGlobal[modinp][vname].c_str(), NULL, 0);
          return 1;
        }
      }
    }
  }

  *val = -99;
	return 1;
}

int getRealInd(char *MODINP, char *VNAME, float * val, int *ind) {

	std::string modinp(MODINP), vname(VNAME);
  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());

	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);
  vname += std::to_string(*ind);

  std::unordered_map<std::string, std::unordered_map<std::string, std::string>>::iterator i;
  std::unordered_map<std::string, std::string>::iterator j;
  for(i = dataGlobal.begin(); i != dataGlobal.end(); ++i){
    if(i->first == modinp){
      for(j = i->second.begin(); j != i->second.end(); ++j){
        if(j->first == vname){
          *val = strtof (dataGlobal[modinp][vname].c_str(), NULL);
          return 1;
        }
      }
    }
  }

  *val = -99.0;
	return 1;
}
int getIntInd(char *MODINP, char *VNAME, int *val, int *ind) {

	std::string modinp(MODINP), vname(VNAME);
  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());

	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);
	vname += std::to_string(*ind);

  std::unordered_map<std::string, std::unordered_map<std::string, std::string>>::iterator i;
  std::unordered_map<std::string, std::string>::iterator j;
  for(i = dataGlobal.begin(); i != dataGlobal.end(); ++i){
    if(i->first == modinp){
      for(j = i->second.begin(); j != i->second.end(); ++j){
        if(j->first == vname){
          *val = (int)strtol(dataGlobal[modinp][vname].c_str(), NULL, 0);
          return 1;
        }
      }
    }
  }

  *val = -99;
	return 1;
}

int getCharInd(char *MODINP, char *VNAME, char *val, int *ind) {

	std::string modinp(MODINP), vname(VNAME);
  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());

	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);
	vname += std::to_string(*ind);

  std::unordered_map<std::string, std::unordered_map<std::string, std::string>>::iterator i;
  std::unordered_map<std::string, std::string>::iterator j;
  for(i = dataGlobal.begin(); i != dataGlobal.end(); ++i){
    if(i->first == modinp){
      for(j = i->second.begin(); j != i->second.end(); ++j){
        if(j->first == vname){
          strcpy(val, Util::trim(dataGlobal[modinp][vname]).c_str());
          return 1;
        }
      }
    }
  }

  strcpy(val, "-99");
	return 1;
}

int getIntArray(char *MODINP, char *VNAME, int *val, int *size) {

	std::string modinp(MODINP), vname(VNAME), aux;
  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());
	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);

  std::unordered_map<std::string, std::unordered_map<std::string, std::string>>::iterator it;
  std::unordered_map<std::string, std::string>::iterator jt;

	 for (int i = 0; i < *size; i++) {
		  vname = aux;
		  vname += std::to_string(i + 1);
      for(it = dataGlobal.begin(); it != dataGlobal.end(); ++it){
        if(it->first == modinp){
          for(jt = it->second.begin(); jt != it->second.end(); ++jt){
            if(jt->first == vname){
              val[i] = (int)strtol(dataGlobal[modinp][vname].c_str(), NULL, 0);
              return 1;
            }
          }
        }
      }
	 }
	return 1;
}

int getRealArray(char *MODINP, char *VNAME, float * val, int *size) {

	std::string modinp(MODINP), vname(VNAME), aux;
  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());

	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);


  std::unordered_map<std::string, std::unordered_map<std::string, std::string>>::iterator it;
  std::unordered_map<std::string, std::string>::iterator jt;
	for (int i = 0; i < *size; i++) {
		vname = aux;
		vname += std::to_string(i + 1);
    for(it = dataGlobal.begin(); it != dataGlobal.end(); ++it){
      if(it->first == modinp){
        for(jt = it->second.begin(); jt != it->second.end(); ++jt){
          if(jt->first == vname){
            val[i] = strtof (dataGlobal[modinp][vname].c_str(), NULL);
            return 1;
          }
        }
      }
    }
	}
	return 1;
}

int getRealYrdoy(char *MODINP, int *YRDOY, char *VNAME, float * val) {

	std::string modinp(MODINP), vname(VNAME);
  int yrdoy = *YRDOY;

  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());
	vname = Util::trim(vname);
	vname = std::to_string(yrdoy) + "_" + vname;
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);

  std::unordered_map<std::string, std::unordered_map<std::string, std::string>>::iterator i;
  std::unordered_map<std::string, std::string>::iterator j;
  for(i = dataGlobal.begin(); i != dataGlobal.end(); ++i){
    if(i->first == modinp){
      for(j = i->second.begin(); j != i->second.end(); ++j){
        if(j->first == vname){
          *val = strtof (dataGlobal[modinp][vname].c_str(), NULL);
          return 1;
        }
      }
    }
  }

  *val = -99.0;
	return 1;
}
int getCharYrdoy(char *MODINP, int *YRDOY, char *VNAME, char *val) {

	std::string modinp(MODINP), vname(VNAME), aux;
  int yrdoy = *YRDOY;

  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());
	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);
	vname = std::to_string(yrdoy) + "_" + vname;
	*val = '\0';

  std::unordered_map<std::string, std::unordered_map<std::string, std::string>>::iterator i;
  std::unordered_map<std::string, std::string>::iterator j;
  for(i = dataGlobal.begin(); i != dataGlobal.end(); ++i){
    if(i->first == modinp){
      for(j = i->second.begin(); j != i->second.end(); ++j){
        if(j->first == vname){
          strcpy(val, Util::trim(dataGlobal[modinp][vname]).c_str());
          return 1;
        }
      }
    }
  }

  strcpy(val, "-99");
	return 1;
}
int getIntYrdoy(char *MODINP, int *YRDOY, char *VNAME, int *val) {

	std::string modinp(MODINP), vname(VNAME), aux;
  int yrdoy = *YRDOY;

  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());
	vname = Util::trim(vname);
	vname = std::to_string(yrdoy) + "_" + vname;
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);

  std::unordered_map<std::string, std::unordered_map<std::string, std::string>>::iterator i;
  std::unordered_map<std::string, std::string>::iterator j;
  for(i = dataGlobal.begin(); i != dataGlobal.end(); ++i){
    if(i->first == modinp){
      for(j = i->second.begin(); j != i->second.end(); ++j){
        if(j->first == vname){
          *val = (int)strtol(dataGlobal[modinp][vname].c_str(), NULL, 0);
          return 1;
        }
      }
    }
  }

  *val = -99;
	return 1;
}


int setRealMem(char *MODINP, char *VNAME, float *val) {
	std::string modinp(MODINP), vname(VNAME);
  
  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());
	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);

	dataGlobal[modinp][vname] = std::to_string(*val);
  
	return 1;
}
int setCharMem(char *MODINP, char *VNAME, char  *val) {
  std::string modinp(MODINP), vname(VNAME), value(val);
  
  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());

	if (value.find("=") == std::string::npos)
		value.erase(value.find_first_of("="), value.size());
	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);
	dataGlobal[modinp][vname] = value;
  
	return 1;
}
int setIntMem(char *MODINP, char *VNAME, int *val) {
  std::string modinp(MODINP), vname(VNAME);

  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());
	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);

	dataGlobal[modinp][vname] = std::to_string(*val);
  
	return 1;
}

int setRealMemInd(char *MODINP, char *VNAME, float *val, int *IND) {
	std::string modinp(MODINP), vname(VNAME);

  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());
	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);
	dataGlobal[modinp][vname + std::to_string(*IND)] = std::to_string(*val);
	return 1;
}
int setCharMemInd(char *MODINP, char *VNAME, char  *val, int *IND) {
	std::string modinp(MODINP), vname(VNAME), value(val);
  
  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());
	if (value.find("=") == std::string::npos)
		value.erase(value.find_first_of("="), value.size());
	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);
	dataGlobal[modinp][vname + std::to_string(*IND)] = value;
	return 1;
}
int setIntMemInd(char *MODINP, char *VNAME, int *val, int *IND) {
	std::string modinp(MODINP), vname(VNAME);
  
  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());
	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);
	dataGlobal[modinp][vname + std::to_string(*IND)] = std::to_string(*val);
	return 1;
}

int setIntMemYrdoy(char *MODINP, int *yrdoy, char *VNAME, int *val) {
	std::string modinp(MODINP), vname(VNAME);
  
  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());
	vname = std::to_string(*yrdoy) + "_" + vname;
	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);
	dataGlobal[modinp][vname] = std::to_string(*val);
	return 1;
}

int setRealMemYrdoy(char *MODINP, int *yrdoy, char *VNAME, float *val) {
	std::string modinp(MODINP), vname(VNAME);

  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());
	vname = std::to_string(*yrdoy) + "_" + vname;
	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);
	dataGlobal[modinp][vname] = std::to_string(*val);
	return 1;
}

int setCharMemYrdoy(char *MODINP, int *yrdoy, char *VNAME, char  *val) {
	std::string modinp(MODINP), vname(VNAME), value(val);
  
  if (modinp.find("=") != std::string::npos)
    modinp.erase(modinp.find_first_of("="), modinp.size());
	if (vname.find("=") != std::string::npos)
		vname.erase(vname.find_first_of("="), vname.size());

	if (value.find("=") == std::string::npos)
		value.erase(value.find_first_of("="), value.size());

	vname = std::to_string(*yrdoy) + "_" + vname;
	vname = Util::trim(vname);
	std::transform(vname.begin(), vname.end(), vname.begin(), ::toupper);
	dataGlobal[modinp][vname] = value;
	return 1;
}
