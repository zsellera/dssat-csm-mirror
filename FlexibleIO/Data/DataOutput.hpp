/*=======================================================================
  DataOutput.hpp, Felipe de Vargas, Willingthon Pavan
  Class to store output data.
-----------------------------------------------------------------------
  REVISION HISTORY
  07/10/2016 FV Written.
========================================================================*/
#ifndef DATAOUTPUT_H
#define DATAOUTPUT_H

#include <string>

class DataOutput
{
private:
	std::string name;
	bool output;
	int endLine;
	std::string format;
	bool title;
	std::string tformat;
	std::string section;
	bool outSection;
	std::string outCsv;

public:
	std::string getName() const {
		return name;
	}

	void setName(std::string name) {
		this->name = name;
	}

	bool getOutput() const {
		return output;
	}

	void setOutput(bool output) {
		this->output = output;
	}

	int getEndLine() const {
		return endLine;
	}

	void setEndline(int endLine) {
		this->endLine = endLine;
	}

	std::string getFormat() const {
		return format;
	}

	void setFormat(std::string format) {
		this->format = format;
	}

	bool getTitle() const {
		return title;
	}
	void setTitle(bool title) {
		this->title = title;
	}
	std::string getTformat() const {
		return tformat;
	}
	void setTformat(std::string tformat) {
		this->tformat = tformat;
	}

	std::string getSection() const {
		return section;
	}

	void setSection(std::string section) {
		this->section = section;
	}

	bool getOutSection() const {
		return outSection;
	}

	void setOutSection(bool outSection) {
		this->outSection = outSection;
	}

	std::string getOutCsv() const{
		return outCsv;
	}
	void setOutCsv(std::string outCsv){
		this->outCsv = outCsv;
	}

};

#endif
