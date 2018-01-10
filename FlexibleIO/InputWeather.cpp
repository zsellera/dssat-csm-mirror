/*=======================================================================
  InputWeather.cpp, Felipe de Vargas, Willingthon Pavan
  Function to read Weather header and data.
-----------------------------------------------------------------------
  REVISION HISTORY
  09/01/2016 FV Written.
  06/18/2017 FV Create new version for weather data.
	12/11/2017 FO Added new date format.
	12/11/2017 FO Added variable to return error code.
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
#include "Data/json.hpp"
#include "Data/Structs.hpp"
#include "Data/Data.hpp"
#include "Data/DataOutput.hpp"
#include "Util/Util.hpp"
#include "SharedVarDef.hpp"

#define DEFREAD 365;
#define DEFPIECE 50;

using json = nlohmann::json;

extern "C" {
	int readwJson(int *YRDOYWY, int *YRDOY, int *YRSIM, int *MULTI, int *readHeader, std::string file);
	int readw_(char *fileW, int *YRDOYWY, int *YRDOY, int *YRSIM, int *MULTI, int *ENDFILE, char *fileX, char *modelW, int *DAYB, int *ERRNUM);
}

//std::vector<Weather> weatherData;
std::vector<json> JJ, JJEVA;
Co2 co2;
json jd, jh, jdEva, jhEva;
std::vector<json> headerEva, dataEva;
std::vector<std::vector<json>> data;
std::string fileXWTH;
std::string outCsv, ouCsvCol, outTxt;
std::string outEva, ouCsvEva, outEvaCsvC;

//for generic read.
std::unordered_map<std::string, std::unordered_map<std::string, std::string>> dataGlobal;

std::vector<Data> speciesInp;
std::vector<Data> soilsInp;
std::vector<Data> weatherInp;
std::vector<Data> Xfile;

std::vector<DataOutput>outPlantGro;
std::vector<DataOutput>outPlantGroCsv;
std::vector<DataOutput>outEvaCsv;
std::vector<DataOutput>outEvaluate;
std::vector<DataOutput>outSummary;

std::vector<std::string> outputCsvH;
int CFILEH = 0; int lineWeather = 0; int DAYS = 0; int DAYSREAD = 0, lastDay = 0;
bool foundSoi, eof = false, wheader = false, plantOutTitle = true;
bool evaluateOutTitle = true, summaryOutTile = true;
char plantGWriteBy, summaryWriteBy, evaluateWriteBy;
std::string plantGSep, summarySep, evaluateSep, fristSet = "", fristSetEva = "";

int readwJson(int *YRDOYWY, int *YRDOY, int *YRSIM, int *MULTI, int *readHeader, std::string file) {
	json js;
	Weather weather;
	std::ifstream myfile(file, std::ifstream::binary);
	int d;
	float f;
	std::string date;
	if (myfile.is_open()) {
		myfile >> js;
		for (int i = 0; i < js["weathers"][0]["dailyWeather"].size(); i++) {
			d = js["weathers"][0]["dailyWeather"][i]["w_date"];
			date = std::to_string(Util::Y2K_DOY(d));
			dataGlobal["WTH"][date + "_DATE"] = date;
			if (!js["weathers"][0]["dailyWeather"][i]["srad"].empty()) {
				f = js["weathers"][0]["dailyWeather"][i]["srad"];
				dataGlobal["WTH"][date + "_SRAD"] = std::to_string(f);
			}

			if (!js["weathers"][0]["dailyWeather"][i]["tmax"].empty()) {
				f = js["weathers"][0]["dailyWeather"][i]["tmax"];
				dataGlobal["WTH"][date + "_TMAX"] = std::to_string(f);
			}

			if (!js["weathers"][0]["dailyWeather"][i]["tmin"].empty()) {
				f = js["weathers"][0]["dailyWeather"][i]["tmin"];
				dataGlobal["WTH"][date + "_TMIN"] = std::to_string(f);
			}
			if (!js["weathers"][0]["dailyWeather"][i]["rain"].empty()) {
				f = js["weathers"][0]["dailyWeather"][i]["rain"];
				dataGlobal["WTH"][date + "_RAIN"] = std::to_string(f);
			}
			if (!js["weathers"][0]["dailyWeather"][i]["dewp"].empty()) {
				f = js["weathers"][0]["dailyWeather"][i]["dewp"];
				dataGlobal["WTH"][date + "_DEWP"] = std::to_string(f);
			}
			if (!js["weathers"][0]["dailyWeather"][i]["wind"].empty()) {
				f = js["weathers"][0]["dailyWeather"][i]["wind"];
				dataGlobal["WTH"][date + "_WIND"] = std::to_string(f);
			}
			if (!js["weathers"][0]["dailyWeather"][i]["par"].empty()) {
				f = js["weathers"][0]["dailyWeather"][i]["par"];
				dataGlobal["WTH"][date + "_PAR"] = std::to_string(f);
			}
			if (!js["weathers"][0]["dailyWeather"][i]["rhum"].empty()) {
				f = js["weathers"][0]["dailyWeather"][i]["rhum"];
				dataGlobal["WTH"][date + "_RHUM"] = std::to_string(f);
			}

			if (!js["weathers"][0]["dailyWeather"][i]["vapr"].empty()) {
				f = js["weathers"][0]["dailyWeather"][i]["vapr"];
				dataGlobal["WTH"][date + "_VAPR"] = std::to_string(f);
			}
			if (!js["weathers"][0]["dailyWeather"][i]["co2"].empty()) {
				f = js["weathers"][0]["dailyWeather"][i]["co2"];
				dataGlobal["WTH"][date + "_DCO2"] = std::to_string(f);
			}

		}
		dataGlobal["WTH"]["INSI"] = js["weathers"][0]["dssat_insi"];

		if (!js["weathers"][0]["wst_lat"].empty()) {
			f = js["weathers"][0]["wst_lat"];
			dataGlobal["WTH"]["LAT"] = std::to_string(f);
		}
		else
			dataGlobal["WTH"]["LAT"] = "0.0";

		if (!js["weathers"][0]["wst_long"].empty()) {
			f = js["weathers"][0]["wst_long"];
			dataGlobal["WTH"]["LONG"] = std::to_string(f);
		}
		else
			dataGlobal["WTH"]["LONG"] = "-99";

		if (!js["weathers"][0]["wst_elev"].empty()) {
			f = js["weathers"][0]["wst_elev"];
			dataGlobal["WTH"]["ELEV"] =  std::to_string(f);
		}
		else
			dataGlobal["WTH"]["ELEV"] = "-99";
		if (!js["weathers"][0]["tav"].empty()) {
			f = js["weathers"][0]["tav"];
			dataGlobal["WTH"]["TAV"] = std::to_string(f);
		}
		else
			dataGlobal["WTH"]["TAV"] = "-99";
		if (!js["weathers"][0]["tamp"].empty()) {
			f = js["weathers"][0]["tamp"];
			dataGlobal["WTH"]["AMP"] = std::to_string(f);
		}
		else
			dataGlobal["WTH"]["AMP"] = "-99";
		if (!js["weathers"][0]["refht"].empty()) {
			f = js["weathers"][0]["refht"];
			dataGlobal["WTH"]["REFHT"] = std::to_string(f);
		}
		else
			dataGlobal["WTH"]["REFHT"] = "1.5";
		if (!js["weathers"][0]["wndht"].empty()) {
			dataGlobal["WTH"]["WINDHT"] = std::to_string(f);
			f = js["weathers"][0]["wndht"];
		}
		else
			dataGlobal["WTH"]["WINDHT"] = "-99";
		if (!js["weathers"][0]["cco2"].empty()) {
			f = js["weathers"][0]["cco2"];
			dataGlobal["WTH"]["CCO2"] = std::to_string(f);
		}
		else
			dataGlobal["WTH"]["CCO2"] = "-99";
		weather.file = file;

		return 1;
	} else {
		return -1;
	}

}
int readWeatherH(std::string file) {
	std::string line, varname, sec;
	int test, type = 0;

	std::ifstream myfile(file);
	if(!myfile){return -99;}

	if (myfile.is_open())
	{
		while (getline (myfile, line) )
		{
			test =  Util::ignore_line3(line);
			if (test > 2 && test < 5) {
				type++;
				line.erase(0, 1);
				std::stringstream ss(line);
				if (type == 1) {
					sec = "HEADER";
				} else {
					sec = "DATA";
				}

				while (ss >> varname) {
					if(varname[0] != '!'){
							Data wea;
							std::transform(varname.begin(), varname.end(), varname.begin(), ::toupper);
							wea.setVarname(varname);
							wea.setSection(sec);
							weatherInp.push_back(wea);
					}
				}

			}
		}
	}

	int isect = -1;
	for (int i = 0; i < weatherInp.size(); i++)
	{
		if (weatherInp[i].getSection().compare("DATA") == 0 && isect == -1) {
			isect = i;
		}
	}
	return isect;
}
std::string lastFile;

int readw_(char *fileW, int *YRDOYWY, int *YRDOY, int *YRSIM, int *MULTI, int *ENDFILE, char *fileX, char *modelW, int *DAYB, int *ERRNUM)
{
	int yrdoywy = *YRDOYWY, yrdoy = *YRDOY - *DAYB, yrsim = *YRSIM, findDate;
	int changeSec;
	std::string file(fileW), filexx(fileX), model(modelW);

	if (fileXWTH.compare(filexx) != 0 || file.compare(lastFile) != 0) {
		fileXWTH = filexx;
		dataGlobal.erase("WTH");
		CFILEH = 0;
		lineWeather = 0;
		DAYS = 0;
		DAYSREAD = 0;
		lastDay = 0;
		eof = false;
		wheader = false;
		weatherInp.clear();

	}

	filexx = filexx.substr(0, filexx.find(".") + 1);
	model = model.substr(0, 5);
	filexx += "json";

	if (yrdoywy <= 0 )
		yrdoy--;

	file.erase(file.find(".WTH") + 4, file.size());
	bool readFile = true;
	std::string subsec, aux, line;

	int countHeader = 0, sec = 0;
	std::vector<int> indices;

	if (CFILEH == 0 ) {
		lastFile = file;
		changeSec = readWeatherH(file);
			if(changeSec == -99){
				*ERRNUM = 30;
				return 0;
			}
	}
	if (readwJson(YRDOYWY, YRDOY, YRSIM, MULTI, ENDFILE, filexx) == 1) {
		return 1;
	}
	bool fileExist = false;

	for (int i = 0; i < CFILEH; i++)
	{
		if (file.compare(dataGlobal["WTH"]["fileWTH" + std::to_string(i)]) == 0)
			fileExist = true;
	}

	if (!fileExist) {
		dataGlobal["WTH"]["fileWTH" + std::to_string(CFILEH)] = file;
		CFILEH++;
		wheader = false;
		eof = false;
		DAYSREAD = 0;
	} else {
		DAYS = DEFPIECE;
	}
	if (DAYS <= 0)
		DAYS = DEFREAD;

	if (DAYSREAD > 0  && !eof) {
		DAYS = DEFPIECE;
		DAYSREAD = 0;

		if (Util::Y2K_DOY(lastDay) > yrdoy) {
			lastDay += 1;
			yrdoy = Util::Y2K_DOY(lastDay);
		}

	}

	subsec = weatherInp[0].getSection();


	for (int i = 0; i < weatherInp.size(); i++)
	{
		if (subsec.compare(weatherInp[i].getSection()) != 0) {
			subsec = weatherInp[i].getSection();
			sec++;
			indices.push_back(i);
		}
	}
	for (int i = indices[0]; i < weatherInp.size() ; i++)
	{
		if (weatherInp[i].getVarname().compare("DATE") == 0) {
			findDate = i;
		}
	}
	if (eof) {
		*ENDFILE = 1;
		return 1;
	} else {
		*ENDFILE = 0;
	}

	std::vector<std::string> vecDateidentified;
	std::vector<std::string> vecDateUnidentified;
	int dateReadFormat = 0; //1 mean dd/mm - 0 mean mm/dd
	int checkDateFormat = 0;// if checkDateFormat is != 0 then file WTH has errors.
	int sizeVec = 0;

	std::ifstream myfile(file);
	if(!myfile){*ERRNUM = 29; return 0;}

	int isect = 0;
	if (myfile.is_open())
	{
		while (true)
		{
			if (!getline (myfile, line)) {
				eof = true;
				*ENDFILE = 1;

				while(!vecDateUnidentified.empty()){
						checkDateFormat = Util::checkDate(dateReadFormat, vecDateidentified, vecDateUnidentified[findDate - indices[0]]);

						if(checkDateFormat == 0){
								if (strtol(vecDateUnidentified[findDate - indices[0]].c_str(), NULL, 10) >= yrdoy) {

									for (int i = 0; i < sizeVec; i++)
									{
										if(vecDateUnidentified[i].compare(".") == 0)
										vecDateUnidentified[i] = "-99";

										dataGlobal["WTH"][vecDateUnidentified[findDate - indices[0]] + "_" + weatherInp[i + indices[0]].getVarname()] = vecDateUnidentified[i];

										//std::cout << vecDateUnidentified[findDate - indices[0]] + "_" + weatherInp[i + indices[0]].getVarname() << " : "
										//					<< dataGlobal["WTH"][vecDateUnidentified[findDate - indices[0]]+ "_" + weatherInp[i + indices[0]].getVarname()] << std::endl;
									}

									if(lastDay < strtol(vecDateUnidentified[findDate - indices[0]].c_str(), NULL, 10))
									lastDay = strtol(vecDateUnidentified[findDate - indices[0]].c_str(), NULL, 10);
								}
						}
						else{
							*ERRNUM = checkDateFormat;
							return 0;
						}

					vecDateUnidentified.erase(vecDateUnidentified.begin(), vecDateUnidentified.begin()+sizeVec);
				}

				break;
			}

			line = Util::trim(line);
			if (Util::ignore_line2(line) == 1) {
				aux = line;
				if (isect < indices[0]) {
					if (!wheader) {
						for (isect; isect < indices[0]; isect++)
						{
							if (weatherInp[isect].getType().compare("STRING") == 0) {
								aux = Util::trim(aux);
								if (weatherInp[isect].getLength() + 1 <= aux.size())
									dataGlobal["WTH"][weatherInp[isect].getVarname()] = aux.substr(0, weatherInp[isect].getLength() + 1);
								else
									dataGlobal["WTH"][weatherInp[isect].getVarname()] = aux.substr(0, aux.size());

								//std::cout << weatherInp[isect].getVarname() << " : " << dataGlobal["WTH"][weatherInp[isect].getVarname()] <<
								//        std::endl;
								aux = aux.substr(weatherInp[isect].getLength(), aux.size());
							} else {
								aux = Util::trim(aux);
								std::stringstream ss (aux);
								ss >> dataGlobal["WTH"][weatherInp[isect].getVarname()];
								//std::cout << weatherInp[isect].getVarname() << " : " << dataGlobal["WTH"][weatherInp[isect].getVarname()] << std::endl;
								aux = Util::trim(aux);
								aux.erase(0, aux.find_first_of(" "));
							}
						}
						wheader = true;
					} else
						isect = changeSec;
				} else {
					if (DAYSREAD <= DAYS) {
						std::vector<std::string> vectorAux;
						for (int i = isect; i < weatherInp.size(); i++)
						{
							if (weatherInp[i].getType().compare("STRING") == 0) {
								aux = Util::trim(aux);
								if (weatherInp[i].getLength() + 1 <= aux.size())
									vectorAux.push_back(aux.substr(0, weatherInp[i].getLength() + 1));
								else
									vectorAux.push_back(aux.substr(0, aux.size()));

								aux = aux.substr(weatherInp[i].getLength(), aux.size());
							} else {
								aux = Util::trim(aux);
								std::string auxNumeric;
								std::stringstream ss (aux);
								ss >> auxNumeric;
								vectorAux.push_back(auxNumeric);
								aux = Util::trim(aux);
								aux.erase(0, aux.find_first_of(" "));
							}
						}

						std::string ss = vectorAux[findDate - indices[0]];
						bool dateidentified = Util::formatDate(checkDateFormat, dateReadFormat, ss);

						if(checkDateFormat == 0){
								if(dateidentified){
									vectorAux[findDate - indices[0]] = ss;
									vecDateidentified.push_back(ss);

									if (strtol(vectorAux[findDate - indices[0]].c_str(), NULL, 10) >= yrdoy) {

										for (int i = 0; i < vectorAux.size(); i++)
										{
											if(vectorAux[i].compare(".") == 0)
											vectorAux[i] = "-99";
											dataGlobal["WTH"][vectorAux[findDate - indices[0]] + "_" + weatherInp[i + indices[0]].getVarname()] = vectorAux[i];

											//std::cout << vectorAux[findDate - indices[0]] + "_" + weatherInp[i + indices[0]].getVarname() << " : "
											//          << dataGlobal["WTH"][vectorAux[findDate - indices[0]]+ "_" + weatherInp[i + indices[0]].getVarname()] << std::endl;
										}

										if(lastDay < strtol(vectorAux[findDate - indices[0]].c_str(), NULL, 10))
										lastDay = strtol(vectorAux[findDate - indices[0]].c_str(), NULL, 10);

										//DAYSREAD++;
									}

								}
								else {
									sizeVec = vectorAux.size();
									for(int i=0; i < vectorAux.size(); i++)
									vecDateUnidentified.push_back(vectorAux[i]);
								}

						}
						else{
							*ERRNUM = checkDateFormat;
							return 0;
						}

					}

				}
			}

			line = "";
		}

		myfile.close();
	}
	else{
		*ERRNUM = 30;
		return 0;
	}

	return 1;
}
