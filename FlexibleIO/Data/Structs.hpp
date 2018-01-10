/*=======================================================================
  Structs.hpp, Felipe de Vargas, Willingthon Pavan
  Structs to store Weather, C02, Soil
-----------------------------------------------------------------------
  REVISION HISTORY
  07/10/2016 FV Written.
========================================================================*/

struct Weather
{
    std::vector<int>   date;
    std::vector<int>   dateRead;
    std::vector<float> srad;
    std::vector<float> tmax;
    std::vector<float> tmin;
    std::vector<float> rain;
    std::vector<float> dewp;
    std::vector<float> wind;
    std::vector<float> par;
    std::vector<float> evap;
    std::vector<float> rhum;
    std::vector<float> vapr;
    std::vector<float> co2;
    std::string file;
    std::string insi;
    float lat;
    float longi;
    float elev;
    float tav;
    float amp;
    float refht;
    float wndht;
    float cco2;

};
struct Co2
{
    std::vector<int>   year;
    std::vector<int>   doy;
    std::vector<float> co2;
    float co2bas;
    bool co2bash;
    bool dataHeader;
    std::string name;
    std::string site;
    std::string file;
};
struct Soil
{
    std::string PEDON;
    std::string SLSOUR;
    std::string SLTXS;
    std::string SLDESC;
    std::string TAXON;

    std::string SSITE;
    std::string SCOUNT;
    std::string SCOM;
    std::string SMHB;
    std::string SMPX;
    std::string SMKE;
    std::string SGRP;
    float SLAT;
    float SLONG;
    float SLDP;
    float SALB;
    float SLNF;
    float SLPF;
    std::vector<float> ZLYR_SLB;
    std::vector<float> CLAY_SLCL;
    std::vector<float> SILT_SLSI;
    std::vector<float> STONES_SLCF;
    std::vector<float> OC_SLOC;
    std::vector<float> PH_SLHW;
    std::vector<float> BD_SBDM;
    std::vector<float> LL_SLLL;
    std::vector<float> DUL_SDUL;
    std::vector<float> SAT_SSAT;
    std::vector<float> SWCN_SSKS;
    std::vector<float> PHKCL_SLHB;
    std::vector<float> CEC_SCEC;
    float U_SLU1;
    float SWCON_SLDR;
    float CN2_SLRO;
    std::vector<float> SHF_SRGF;
    std::vector<float> TOTN_SLNI;
    std::vector<float> ADCOEF_SADC;
    std::vector<std::string> MH_SLMH;
    //2nd tier
    std::vector<float> EXTP_SLPX;
    std::vector<float> TOTP_SLPT;
    std::vector<float> ORGP_SLPO;
    std::vector<float> CACO_CACO3;
    std::vector<float> EXTAL_SLAL;
    std::vector<float> EXTFE_SLFE;
    std::vector<float> EXTMN_SLMN;
    std::vector<float> TOTBAS_SLBS;
    std::vector<float> PTERMA_SLPA;
    std::vector<float> PTERMB_SLPB;
    std::vector<float> EXK_SLKE;
    std::vector<float> EXMG_SLMG;
    std::vector<float> EXNA_SLNA;
    std::vector<float> EXTS_SLSU;
    std::vector<float> SLEC;
    std::vector<float> EXCA_SLCA;
    std::vector<float> SASC;
};
struct Salus_Opgrow{
    std::string DSSAT;
    std::string RUN;
    std::string MODEL;
    std::string EXPERIMENT;
    std::string TREATMENT;
};
