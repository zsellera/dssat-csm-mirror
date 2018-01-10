/*=======================================================================
  Data.hpp, Felipe de Vargas, Willingthon Pavan
  Class to store the header configuration of the input files.
-----------------------------------------------------------------------
  REVISION HISTORY
  07/10/2016 FV Written.
========================================================================*/
#ifndef DATA_H
#define DATA_H

#include <string>

class Data
{
private:
	std::string varname;
	std::string type;
	int size;
	int length;
	std::string section;
	std::string subSection;
	std::string line;
	char readBy;

public:
	std::string getVarname() const {
		return varname;
	}

	void setVarname(std::string varname) {
		this->varname = varname;
	}

	std::string getType() const {
		return type;
	}

	void setType(std::string type) {
		this->type = type;
	}

	int getSize() const {
		return size;
	}

	void setSize(int size) {
		this->size = size;
	}

	int getLength() const {
		return length;
	}

	void setLength(int length) {
		this->length = length;
	}

	std::string getSection() const {
		return section;
	}

	void setSection(std::string section) {
		this->section = section;
	}

	std::string getLine() const {
		return line;
	}

	void setLine(std::string line) {
		this->line = line;
	}

	char getReadBy() const {
		return readBy;
	}

	void setReadBy(char readBy) {
		this->readBy = readBy;
	}

	std::string getSubSection() const {
		return subSection;
	}

	void setSubSection(std::string subSection) {
		this->subSection = subSection;
	}

};

#endif
