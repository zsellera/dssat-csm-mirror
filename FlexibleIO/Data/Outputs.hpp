/*=======================================================================
  Outputs.hpp, Felipe de Vargas, Willingthon Pavan
  Class to store output data.
-----------------------------------------------------------------------
  REVISION HISTORY
  07/10/2016 FV Written.
========================================================================*/
#ifndef OUTPUTS_H
#define OUTPUTS_H

class Outputs
{
private:
	std::string name;
	std::string inf;


public:
	std::string getName() const {
		return name;
	}

	void setName(std::string name) {
		this->name = name;
	}

	std::string getInf() const {
		return inf;
	}

	void setInf(std::string inf) {
		this->inf = inf;
	}
};

#endif
