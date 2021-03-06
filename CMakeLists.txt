##########################################################################################
# CMake project file for DSSAT-CSM
##########################################################################################
# Define the project and the dependencies that it has
##########################################################################################

CMAKE_MINIMUM_REQUIRED(VERSION 2.8.5)

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
   message(FATAL_ERROR "DSSAT in-source builds are not permitted. \nMake a separate folder"
   						"for building:\nmkdir build; cd build; cmake ..\nBefore that,"
   						"remove the files already created:\n"
   						"CMakeCache.txt and CMakeFiles\n")
endif("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")

PROJECT(DSSAT-CSM Fortran )

##########################################################################################
# DSSAT_VERSION from ModuleDefs.for
##########################################################################################

file(READ "${CMAKE_SOURCE_DIR}/Utilities/ModuleDefs.for" File_Content)

# Take DSSAT_VERSION from ModuleDefs.for
STRING(REGEX REPLACE ".*Major = ([0-9]+).*" "\\1" MAJOR "${File_Content}")
STRING(REGEX REPLACE ".*Minor = ([0-9]+).*" "\\1" MINOR "${File_Content}")
STRING(REGEX REPLACE ".*Model = ([0-9]+).*" "\\1" MODEL "${File_Content}")
STRING(REGEX REPLACE ".*Build = ([0-9]+).*" "\\1" BUILD "${File_Content}")
MESSAGE(STATUS "MAJOR: ${MAJOR} MINOR: ${MINOR} MODEL: ${MODEL} BUILD: ${BUILD}")

# Set the version
SET(VERSION ${MAJOR}.${MINOR}.${MODEL})

##########################################################################################

# Add our local modlues to the module path
SET(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules/")

# Organize output files.  On Windows this also keeps .dll files next
# to the .exe files that need them, making tests easy to run.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/mod)

# Keep Uncomment if Fortran 90 support is required
IF(NOT CMAKE_Fortran_COMPILER_SUPPORTS_F90)
    MESSAGE(FATAL_ERROR "Fortran compiler does not support F90")
ENDIF(NOT CMAKE_Fortran_COMPILER_SUPPORTS_F90)

# This INCLUDE statement executes code that sets the compile flags for DEBUG,
# RELEASE, and TESTING.  You should  review this file and make sure the flags
# are to your liking.
INCLUDE(${CMAKE_MODULE_PATH}/SetFortranFlags.cmake)

# There is an error in CMAKE with this flag for pgf90.  Unset it
GET_FILENAME_COMPONENT(FCNAME ${CMAKE_Fortran_COMPILER} NAME)
IF(FCNAME STREQUAL "pgf90")
    UNSET(CMAKE_SHARED_LIBRARY_LINK_Fortran_FLAGS)
ENDIF(FCNAME STREQUAL "pgf90")

##########################################################################################
# Define the actual files and folders that make the build
##########################################################################################

# Define the executable name and OSDefinitions file
IF(WIN32)
    SET(EXECUTABLE_NAME dscsm0${MAJOR}${MINOR})
    SET(OSDefinitions "Utilities/OSDefsWINDOWS.for")
    add_definitions(-DWIN32=1})
ELSE()
    SET(EXECUTABLE_NAME dscsm0${MAJOR}${MINOR}.exe)
    SET(OSDefinitions "Utilities/OSDefsLINUX.for")
ENDIF(WIN32)

# Add the source files
set(
    source_list
    	"${OSDefinitions}"
        "Utilities/ModuleDefs.for"
        "Utilities/DATES.for"
        "Utilities/ERROR.for"
        "Utilities/Info.for"
        "Utilities/IPIBS.for"
        "Utilities/OPGeneric.for"
        "Utilities/OPSTRESS.for"
        "Utilities/OPSUM.for"
        "Utilities/OPVIEW.for"
        "Utilities/READS.for"
        "Utilities/RunList.for"
        "Utilities/UTILS.for"
        "Utilities/Warning.for"
        "Utilities/CsvOuts/csvlinklist.f90"
        "Utilities/CsvOuts/csvoutput.f90"
        "CSM_Main/CSM.for"
        "CSM_Main/LAND.for"
        "InputModule/COMGEN.blk"
        "InputModule/COMIBS.blk"
        "InputModule/COMSOI.blk"
        "InputModule/COMSWI.blk"
        "InputModule/input_sub.for"
        "InputModule/INSOIL.for"
        "InputModule/INSTGE.for"
        "InputModule/INTRO.for"
        "InputModule/INVAR.for"
        "InputModule/IPCHEM.for"
        "InputModule/IPECO.for"
        "InputModule/IPENV.for"
        "InputModule/ipexp.for"
        "InputModule/IPMAN.for"
        "InputModule/IPSIM.for"
        "InputModule/IPSLIN.for"
        "InputModule/IPSOIL_Inp.for"
        "InputModule/IPTILL.for"
        "InputModule/IPVAR.for"
        "InputModule/OPGEN.for"
        "InputModule/OPHEAD.for"
        "InputModule/OPTEMPXY2K.for"
        "InputModule/optempy2k.for"
        "InputModule/PATH.for"
        "InputModule/WEATHR_Inp.for"
        "InputModule/WTHSET.for"
        "InputModule/SECLI.for"
        "InputModule/SECROP.for"
        "InputModule/SEFERT.for"
        "InputModule/SEFLD.for"
        "InputModule/SEFREQ.for"
        "InputModule/SEHARV.for"
        "InputModule/SEINIT.for"
        "InputModule/SEIRR.for"
        "InputModule/SENS.for"
        "InputModule/SEPEST.for"
        "InputModule/SEPLT.for"
        "InputModule/SERES.for"
        "InputModule/SESIM.for"
        "InputModule/SESOIL.for"
        "InputModule/SETIME.for"
        "InputModule/SEVAR.for"
        "InputModule/SEWTH.for"
        "Management/AUTHAR.for"
        "Management/AUTPLT.for"
        "Management/CHEMICAL.for"
        "Management/Fert_Place.for"
        "Management/Flood_Irrig.for"
        "Management/IRRIG.for"
        "Management/MgmtOps.for"
        "Management/OM_Place.for"
        "Management/OpFlood.for"
        "Management/Paddy_Mgmt.for"
        "Management/Tillage.for"
        "Management/TillEvent.for"
        "Plant/plant.for"
        "Plant/ALOHA-Pineapple/Aloha_GROSUB.for"
        "Plant/ALOHA-Pineapple/Aloha_mod.f90"
        "Plant/ALOHA-Pineapple/Aloha_NFACTO.for"
        "Plant/ALOHA-Pineapple/Aloha_NUPTAK.for"
        "Plant/ALOHA-Pineapple/Aloha_OPGROW.f90"
        "Plant/ALOHA-Pineapple/Aloha_OPHARV.for"
        "Plant/ALOHA-Pineapple/Aloha_PHENOL.for"
        "Plant/ALOHA-Pineapple/Aloha_PINE.for"
        "Plant/ALOHA-Pineapple/Aloha_ROOTGR.for"
        "Plant/AROIDS/TR_Calcshk.for"
        "Plant/AROIDS/TR_Grosub.for"
        "Plant/AROIDS/TR_Ipcrop.for"
        "Plant/AROIDS/TR_Nfacto.for"
        "Plant/AROIDS/TR_Nuptak.for"
        "Plant/AROIDS/TR_OPGROW.for"
        "Plant/AROIDS/TR_Opharv.for"
        "Plant/AROIDS/TR_Phenol.for"
        "Plant/AROIDS/TR_Rootgr.for"
        "Plant/AROIDS/TR_SUBSTOR.for"
        "Plant/AROIDS/TR_Tillsub.for"
        "Plant/AROIDS/TR_Transpl_g.for"
        "Plant/AROIDS/TR_Transpl_p.for"
        "Plant/CANEGRO-Sugarcane/SC_Canop3.for"
        "Plant/CANEGRO-Sugarcane/SC_CCOUT.for"    
        "Plant/CANEGRO-Sugarcane/SC_CNGRO.for"
        "Plant/CANEGRO-Sugarcane/SC_CNG_mods.for"
        "Plant/CANEGRO-Sugarcane/SC_COEFFS.for"
        "Plant/CANEGRO-Sugarcane/SC_ETOUT.for"     
        "Plant/CANEGRO-Sugarcane/SC_GTP_SHOOTS.for"
        "Plant/CANEGRO-Sugarcane/SC_OPHARV.for"
        "Plant/CANEGRO-Sugarcane/SC_OUTPUT.for"
        "Plant/CANEGRO-Sugarcane/SC_PARTIT.for"
        "Plant/CANEGRO-Sugarcane/SC_PHENOL.for"
        "Plant/CANEGRO-Sugarcane/SC_PHOTOS.for"
        "Plant/CANEGRO-Sugarcane/SC_Poplt3.for"
        "Plant/CANEGRO-Sugarcane/SC_ROOTG.for"
        "Plant/CANEGRO-Sugarcane/SC_UM_WSTRESS.for"
        "Plant/CASUPRO-Sugarcane/CSP_CANOPY.for"
        "Plant/CASUPRO-Sugarcane/CSP_CASUPRO.for"
        "Plant/CASUPRO-Sugarcane/CSP_DEMAND.for"
        "Plant/CASUPRO-Sugarcane/CSP_GROW.for"
        "Plant/CASUPRO-Sugarcane/CSP_GROW_CANE.for"
        "Plant/CASUPRO-Sugarcane/CSP_HRes.for"
        "Plant/CASUPRO-Sugarcane/CSP_INCOMP.for"
        "Plant/CASUPRO-Sugarcane/CSP_INCOMP_OUT.for"
        "Plant/CASUPRO-Sugarcane/CSP_INPHENOL.for"
        "Plant/CASUPRO-Sugarcane/CSP_IPDMND_OUT.for"
        "Plant/CASUPRO-Sugarcane/CSP_IPPHENOL.for"
        "Plant/CASUPRO-Sugarcane/CSP_IPPLNT.for"
        "Plant/CASUPRO-Sugarcane/CSP_MOBIL.for"
        "Plant/CASUPRO-Sugarcane/CSP_NUPTAK.for"
        "Plant/CASUPRO-Sugarcane/CSP_OPGROW.for"
        "Plant/CASUPRO-Sugarcane/CSP_OPHARV.for"
        "Plant/CASUPRO-Sugarcane/CSP_PHENOL.for"
        "Plant/CASUPRO-Sugarcane/CSP_PHOTO.for"
        "Plant/CASUPRO-Sugarcane/CSP_RESPIR.for"
        "Plant/CASUPRO-Sugarcane/CSP_ROOTS.for"
        "Plant/CASUPRO-Sugarcane/CSP_SENES.for"
        "Plant/CASUPRO-Sugarcane/CSP_VEGGR.for"
        "Plant/CERES-IXIM-Maize/MZ_IX_GROSUB.for"
        "Plant/CERES-IXIM-Maize/MZ_IX_KNUMBER.for"
        "Plant/CERES-IXIM-Maize/MZ_IX_LEAFAREA.for"
        "Plant/CERES-IXIM-Maize/MZ_IX_NUPTAK.for"
        "Plant/CERES-IXIM-Maize/MZ_IX_PHENOL.for"
        "Plant/CERES-IXIM-Maize/MZ_IX_PHOTSYNT.for"
        "Plant/CERES-IXIM-Maize/MZ_IX_PLANTG.for"
        "Plant/CERES-IXIM-Maize/MZ_IX_RADABS.for"
        "Plant/CERES-IXIM-Maize/MZ_IX_RESPIR.for"
        "Plant/CERES-Maize/MZ_CERES.for"
        "Plant/CERES-Maize/MZ_GROSUB.for"
        "Plant/CERES-Maize/MZ_KUPTAK.for"
        "Plant/CERES-Maize/MZ_NFACTO.for"
        "Plant/CERES-Maize/MZ_NUPTAK.for"
        "Plant/CERES-Maize/MZ_OPGROW.for"
        "Plant/CERES-Maize/MZ_OPHARV.for"
        "Plant/CERES-Maize/MZ_OPNIT.for"
        "Plant/CERES-Maize/MZ_PHENOL.for"
        "Plant/CERES-Maize/MZ_ROOTS.for"
        "Plant/CERES-Millet/ML_CERES.for"
        "Plant/CERES-Millet/ML_GROSUB.for"
        "Plant/CERES-Millet/ML_NFACT.for"
        "Plant/CERES-Millet/ML_NUPTAK.for"
        "Plant/CERES-Millet/ML_OPGROW.for"
        "Plant/CERES-Millet/ML_opharv.for"
        "Plant/CERES-Millet/ML_PHASEI.for"
        "Plant/CERES-Millet/ML_PHENOL.for"
        "Plant/CERES-Millet/ML_rootgr.for"
        "Plant/CERES-Millet/ML_TILLSUB.for"
        "Plant/CERES-Rice/RICE.for"
        "Plant/CERES-Rice/RI_Calcshk.for"
        "Plant/CERES-Rice/RI_GNURSE.for"
        "Plant/CERES-Rice/RI_Grosub.for"
        "Plant/CERES-Rice/RI_Ipcrop.for"
        "Plant/CERES-Rice/RI_KUPTAK.for"
        "Plant/CERES-Rice/RI_Nfacto.for"
        "Plant/CERES-Rice/RI_Nuptak.for"
        "Plant/CERES-Rice/RI_Opgrow.for"
        "Plant/CERES-Rice/RI_Opharv.for"
        "Plant/CERES-Rice/RI_Phenol.for"
        "Plant/CERES-Rice/RI_Rootgr.for"
        "Plant/CERES-Rice/RI_Tillsub.for"
        "Plant/CERES-Rice/RI_Transpl_g.for"
        "Plant/CERES-Rice/RI_Transpl_p.for"
        "Plant/CERES-SharedFiles/HResCeres.for"
        "Plant/CERES-SharedFiles/SLigCeres.for"
        "Plant/CERES-Sorghum/SG_CERES.for"
        "Plant/CERES-Sorghum/SG_GROSUB.for"
        "Plant/CERES-Sorghum/SG_NFACT.for"
        "Plant/CERES-Sorghum/SG_NUPTAK.for"
        "Plant/CERES-Sorghum/SG_OPHARV.for"
        "Plant/CERES-Sorghum/SG_PHASEI.for"
        "Plant/CERES-Sorghum/SG_PHENOL.for"
        "Plant/CERES-Sorghum/SG_ROOTGR.for"
        "Plant/CERES-Sugarbeet/BS_CERES.for"
        "Plant/CERES-Sugarbeet/BS_GROSUB.for"
        "Plant/CERES-Sugarbeet/BS_NFACTO.for"
        "Plant/CERES-Sugarbeet/BS_NUPTAK.for"
        "Plant/CERES-Sugarbeet/BS_OPGROW.for"
        "Plant/CERES-Sugarbeet/BS_OPHARV.for"
        "Plant/CERES-Sugarbeet/BS_OPNIT.for"
        "Plant/CERES-Sugarbeet/BS_PHENOL.for"
        "Plant/CERES-Sugarbeet/BS_ROOTS.for"
        "Plant/CERES-SweetCorn/SW_FreshWt.for"
        "Plant/CERES-SweetCorn/SW_GROSUB.for"
        "Plant/CROPGRO/CANOPY.for"
        "Plant/CROPGRO/CROPGRO.for"
        "Plant/CROPGRO/DEMAND.for"
        "Plant/CROPGRO/FREEZE.for"
        "Plant/CROPGRO/FreshWt.for"
        "Plant/CROPGRO/GROW.for"
        "Plant/CROPGRO/HRes_CGRO.for"
        "Plant/CROPGRO/INCOMP.for"
        "Plant/CROPGRO/Ipphenol.for"
        "Plant/CROPGRO/IPPLNT.for"
        "Plant/CROPGRO/MOBIL.for"
        "Plant/CROPGRO/NFIX.for"
        "Plant/CROPGRO/NUPTAK.for"
        "Plant/CROPGRO/Opgrow.for"
        "Plant/CROPGRO/OPHARV.for"
        "Plant/CROPGRO/PHENOL.for"
        "Plant/CROPGRO/PHOTO.for"
        "Plant/CROPGRO/PlantNBal.for"
        "Plant/CROPGRO/PODDET.for"
        "Plant/CROPGRO/PODS.for"
        "Plant/CROPGRO/RESPIR.for"
        "Plant/CROPGRO/ROOTS.for"
        "Plant/CROPGRO/RStages.for"
        "Plant/CROPGRO/SDCOMP.for"
        "Plant/CROPGRO/SENES.for"
        "Plant/CROPGRO/VEGGR.for"
        "Plant/CSCER_CSCRP_CSCAS/CSCAS.for"
        "Plant/CSCER_CSCRP_CSCAS/CSCAS_Interface.for"
        "Plant/CSCER_CSCRP_CSCAS/CSCER.for"
        "Plant/CSCER_CSCRP_CSCAS/CSCERES_Interface.for"
        "Plant/CSCER_CSCRP_CSCAS/CSCRP.for"
        "Plant/CSCER_CSCRP_CSCAS/CSCRP_Interface.for"
        "Plant/CSCER_CSCRP_CSCAS/CSDISEASE.for"
        "Plant/CSCER_CSCRP_CSCAS/CSREADS.for"
        "Plant/CSCER_CSCRP_CSCAS/CSUTS.for"
        "Plant/CSYCA-Cassava/CSYCA.f90"
        "Plant/CSYCA-Cassava/CSYCA_Interface.for"
        "Plant/CSYCA-Cassava/YCA_Albedo_Check_m.f90"
        "Plant/CSYCA-Cassava/YCA_Control_Environment.f90"
        "Plant/CSYCA-Cassava/YCA_Control_Leaf.f90"
        "Plant/CSYCA-Cassava/YCA_Control_Photosynthesis.f90"
        "Plant/CSYCA-Cassava/YCA_Control_Plant.f90"
        "Plant/CSYCA-Cassava/YCA_Control_VPDEffect.f90"
        "Plant/CSYCA-Cassava/YCA_First_Trans_m.f90"
        "Plant/CSYCA-Cassava/YCA_Formats_m.f90"
        "Plant/CSYCA-Cassava/YCA_Growth.f90"
        "Plant/CSYCA-Cassava/YCA_Growth_Distribute.f90"
        "Plant/CSYCA-Cassava/YCA_Growth_Evapo.f90"
        "Plant/CSYCA-Cassava/YCA_Growth_Init.f90"
        "Plant/CSYCA-Cassava/YCA_Growth_NUptake.f90"
        "Plant/CSYCA-Cassava/YCA_Growth_Part.f90"
        "Plant/CSYCA-Cassava/YCA_Growth_Photo.f90"
        "Plant/CSYCA-Cassava/YCA_Growth_Rates.f90"
        "Plant/CSYCA-Cassava/YCA_Growth_Senesce.f90"
        "Plant/CSYCA-Cassava/YCA_Integrate.f90"
        "Plant/CSYCA-Cassava/YCA_Integ_AgesWts.f90"
        "Plant/CSYCA-Cassava/YCA_Integ_EndCrop.f90"
        "Plant/CSYCA-Cassava/YCA_Integ_HstFail.f90"
        "Plant/CSYCA-Cassava/YCA_Integ_LA.f90"
        "Plant/CSYCA-Cassava/YCA_Integ_N.f90"
        "Plant/CSYCA-Cassava/YCA_Integ_Nconc.f90"
        "Plant/CSYCA-Cassava/YCA_Integ_SeasEnd.f90"
        "Plant/CSYCA-Cassava/YCA_Integ_Stages.f90"
        "Plant/CSYCA-Cassava/YCA_Integ_WthrSum.f90"
        "Plant/CSYCA-Cassava/YCA_Node.f90"
        "Plant/CSYCA-Cassava/YCA_Output.f90"
        "Plant/CSYCA-Cassava/YCA_Out_CrpSim.f90"
        "Plant/CSYCA-Cassava/YCA_Out_Error.f90"
        "Plant/CSYCA-Cassava/YCA_Out_Eval.f90"
        "Plant/CSYCA-Cassava/YCA_Out_LfTier.f90"
        "Plant/CSYCA-Cassava/YCA_Out_ModFail.f90"
        "Plant/CSYCA-Cassava/YCA_Out_PlantSum.f90"
        "Plant/CSYCA-Cassava/YCA_Out_PlGrow.f90"
        "Plant/CSYCA-Cassava/YCA_Out_ReInit.f90"
        "Plant/CSYCA-Cassava/YCA_Out_Sens.f90"
        "Plant/CSYCA-Cassava/YCA_Out_StoreVars.f90"
        "Plant/CSYCA-Cassava/YCA_Out_Work.f90"
        "Plant/CSYCA-Cassava/YCA_Out_WrkPhenRes.f90"
        "Plant/CSYCA-Cassava/YCA_PrePlant.f90"
        "Plant/CSYCA-Cassava/YCA_RunInit.f90"
        "Plant/CSYCA-Cassava/YCA_SeasInit.f90"
        "Plant/CSYCA-Cassava/YCA_SeasInit_Final.f90"
        "Plant/CSYCA-Cassava/YCA_SeasInit_PlHarvDat.f90"
        "Plant/CSYCA-Cassava/YCA_SeasInit_ReadGeno.f90"
        "Plant/CSYCA-Cassava/YCA_SeasInit_ReadXfile.f90"
        "Plant/CSYCA-Cassava/YCA_SeasInit_SetStage.f90"
        "Plant/CSYCA-Cassava/YCA_SeasInit_VarInit.f90"
        "Plant/FORAGE/forage.for"
        "Plant/FORAGE/for_asmdm.for"
        "Plant/FORAGE/for_canopy.for"
        "Plant/FORAGE/for_ch2oref.for"
        "Plant/FORAGE/for_demand.for"
        "Plant/FORAGE/for_dormancy.for"
        "Plant/FORAGE/for_freeze.for"
        "Plant/FORAGE/for_grow.for"
        "Plant/FORAGE/for_harv.for"
        "Plant/FORAGE/for_hres_cgro.for"
        "Plant/FORAGE/for_incomp.for"
        "Plant/FORAGE/for_ipparm.for"
        "Plant/FORAGE/for_ippest.for"
        "Plant/FORAGE/for_ipphenol.for"
        "Plant/FORAGE/for_ipplnt.for"
        "Plant/FORAGE/for_ipprog.for"
        "Plant/FORAGE/for_lindm.for"
        "Plant/FORAGE/for_mobil.for"
        "Plant/FORAGE/for_nfix.for"
        "Plant/FORAGE/for_nuptak.for"
        "Plant/FORAGE/for_opgrow.for"
        "Plant/FORAGE/for_opharv.for"
        "Plant/FORAGE/for_opmob.for"
        "Plant/FORAGE/for_oppest.for"
        "Plant/FORAGE/for_opview.for"
        "Plant/FORAGE/for_pest.for"
        "Plant/FORAGE/for_pestcp.for"
        "Plant/FORAGE/for_phenol.for"
        "Plant/FORAGE/for_photo.for"
        "Plant/FORAGE/for_plantnbal.for"
        "Plant/FORAGE/for_poddet.for"
        "Plant/FORAGE/for_pods.for"
        "Plant/FORAGE/for_respir.for"
        "Plant/FORAGE/for_rootdm.for"
        "Plant/FORAGE/for_roots.for"
        "Plant/FORAGE/for_rstages.for"
        "Plant/FORAGE/for_sdcomp.for"
        "Plant/FORAGE/for_seeddm.for"
        "Plant/FORAGE/for_senmob.for"
        "Plant/FORAGE/for_vegdm.for"
        "Plant/FORAGE/for_veggr.for"
        "Plant/Generic-Pest/ASMDM.for"
        "Plant/Generic-Pest/IPPARM.for"
        "Plant/Generic-Pest/IPPEST.for"
        "Plant/Generic-Pest/IPPROG.for"
        "Plant/Generic-Pest/LINDM.for"
        "Plant/Generic-Pest/OPPEST.for"
        "Plant/Generic-Pest/PEST.for"
        "Plant/Generic-Pest/PESTCP.for"
        "Plant/Generic-Pest/ROOTDM.for"
        "Plant/Generic-Pest/SEEDDM.for"
        "Plant/Generic-Pest/VEGDM.for"
        "Plant/Generic-PlantP/OpPlantP.for"
        "Plant/Generic-PlantP/PPlantSubs.for"
        "Plant/Generic-PlantP/P_CASUPRO.for"
        "Plant/Generic-PlantP/P_CERES.for"
        "Plant/Generic-PlantP/P_CGRO.for"
        "Plant/Generic-PlantP/P_IPPLNT.for"
        "Plant/Generic-PlantP/P_Plant.for"
        "Plant/Generic-PlantP/P_Uptake.for"
        "Plant/Generic-PlantP/RootSoilVol.for"
        "Plant/NWHEAT/WH_APSIM.for"
        "Plant/NWHEAT/WH_COLD.for"
        "Plant/NWHEAT/WH_GROSUB.for"
        "Plant/NWHEAT/WH_KUPTAK.for"
        "Plant/NWHEAT/WH_module.f90"
        "Plant/NWHEAT/WH_NFACTO.for"
        "Plant/NWHEAT/WH_NUPTAK.for"
        "Plant/NWHEAT/WH_OPGROW.for"
        "Plant/NWHEAT/WH_OPHARV.for"
        "Plant/NWHEAT/WH_OPNIT.for"
        "Plant/NWHEAT/WH_PHENOL.for"
        "Plant/NWHEAT/WH_ROOTS.for"
        "Plant/NWHEAT/WH_SW_SUBS.for"
        "Plant/NWHEAT/WH_temp.for"
        "Plant/ORYZA/GPPARGET.f90"
        "Plant/ORYZA/GPPARSET.f90"
        "Plant/ORYZA/G_Exper.f90"
        "Plant/ORYZA/G_Soil.f90"
        "Plant/ORYZA/Ncrop3.f90"
        "Plant/ORYZA/NightT.f90"
        "Plant/ORYZA/Nnostress2.f90"
        "Plant/ORYZA/ORYZA1.f90"
        "Plant/ORYZA/ORYZA_Interface.f90"
        "Plant/ORYZA/OR_Opgrow.f90"
        "Plant/ORYZA/OR_Opharv.for"
        "Plant/ORYZA/OR_PHENOL.f90"
        "Plant/ORYZA/OR_ROOTG.f90"
        "Plant/ORYZA/PARTITION.f90"
        "Plant/ORYZA/quadpack.f90"
        "Plant/ORYZA/SASTRO.f90"
        "Plant/ORYZA/SGPC1.f90"
        "Plant/ORYZA/SGPC2.f90"
        "Plant/ORYZA/SGPCDT.f90"
        "Plant/ORYZA/SGPL.f90"
        "Plant/ORYZA/SRDPRF.f90"
        "Plant/ORYZA/SSKYC.f90"
        "Plant/ORYZA/SUBCBC.f90"
        "Plant/ORYZA/SUBCD2.f90"
        "Plant/ORYZA/SUBDD.f90"
        "Plant/ORYZA/SUBGRN.f90"
        "Plant/ORYZA/SUBLAI3.f90"
        "Plant/ORYZA/SVPS1.f90"
        "Plant/ORYZA/VARIABLE.f90"
        "Plant/ORYZA/wnostress.f90"
        "Plant/ORYZA/WStress2.f90"
        "Plant/ORYZA/OP_OBS/DS1900.f90"
        "Plant/ORYZA/OP_OBS/GETOBS.f90"
        "Plant/ORYZA/OP_OBS/INDEXX.f90"
        "Plant/ORYZA/OP_OBS/INQOBS.f90"
        "Plant/ORYZA/OP_OBS/INTGR2.f90"
        "Plant/ORYZA/OP_OBS/OBSINI.f90"
        "Plant/ORYZA/OP_OBS/OBSSYS.f90"
        "Plant/ORYZA/OP_OBS/OBSTRG.f90"
        "Plant/ORYZA/OP_OBS/OPCF.f90"
        "Plant/ORYZA/OP_OBS/OPINIT.f90"
        "Plant/ORYZA/OP_OBS/OPNF.f90"
        "Plant/ORYZA/OP_OBS/OPREAD.f90"
        "Plant/ORYZA/OP_OBS/OPSC.f90"
        "Plant/ORYZA/OP_OBS/OPSTOR.f90"
        "Plant/ORYZA/OP_OBS/OPSYS.f90"
        "Plant/ORYZA/OP_OBS/OPWRITE.f90"
        "Plant/ORYZA/OP_OBS/TTHEAD.f90"
        "Plant/ORYZA/ttutil/addinf.for"
        "Plant/ORYZA/ttutil/addint.for"
        "Plant/ORYZA/ttutil/addrea.for"
        "Plant/ORYZA/ttutil/addref.for"
        "Plant/ORYZA/ttutil/addstf.for"
        "Plant/ORYZA/ttutil/addstr.for"
        "Plant/ORYZA/ttutil/ambusy.for"
        "Plant/ORYZA/ttutil/copfl2.for"
        "Plant/ORYZA/ttutil/decchk.for"
        "Plant/ORYZA/ttutil/decdou.for"
        "Plant/ORYZA/ttutil/decint.for"
        "Plant/ORYZA/ttutil/decrea.for"
        "Plant/ORYZA/ttutil/decrec.for"
        "Plant/ORYZA/ttutil/dectim.for"
        "Plant/ORYZA/ttutil/delfil.for"
        "Plant/ORYZA/ttutil/dtardp.for"
        "Plant/ORYZA/ttutil/dtdpar.for"
        "Plant/ORYZA/ttutil/dtdpst.for"
        "Plant/ORYZA/ttutil/dtfsecmp.for"
        "Plant/ORYZA/ttutil/dtfsedp.for"
        "Plant/ORYZA/ttutil/dtleap.for"
        "Plant/ORYZA/ttutil/dtnow.f90"
        "Plant/ORYZA/ttutil/dtsys.for"
        "Plant/ORYZA/ttutil/entcha.for"
        "Plant/ORYZA/ttutil/entdch.for"
        "Plant/ORYZA/ttutil/entddo.for"
        "Plant/ORYZA/ttutil/entdin.for"
        "Plant/ORYZA/ttutil/entdou.for"
        "Plant/ORYZA/ttutil/entdre.for"
        "Plant/ORYZA/ttutil/entdti.for"
        "Plant/ORYZA/ttutil/entdyn.for"
        "Plant/ORYZA/ttutil/enthlp.for"
        "Plant/ORYZA/ttutil/entint.for"
        "Plant/ORYZA/ttutil/entrea.for"
        "Plant/ORYZA/ttutil/enttim.for"
        "Plant/ORYZA/ttutil/entyno.for"
        "Plant/ORYZA/ttutil/extens.for"
        "Plant/ORYZA/ttutil/fatalerr.f90"
        "Plant/ORYZA/ttutil/flexist.for"
        "Plant/ORYZA/ttutil/flname.for"
        "Plant/ORYZA/ttutil/fopengstandard.f90"
        "Plant/ORYZA/ttutil/fopens.for"
        "Plant/ORYZA/ttutil/getrec.for"
        "Plant/ORYZA/ttutil/getun.for"
        "Plant/ORYZA/ttutil/getun2.for"
        "Plant/ORYZA/ttutil/ifindc.f90"
        "Plant/ORYZA/ttutil/ifindi.for"
        "Plant/ORYZA/ttutil/INSW.for"
        "Plant/ORYZA/ttutil/INTGRL.for"
        "Plant/ORYZA/ttutil/istart.for"
        "Plant/ORYZA/ttutil/iunifl.for"
        "Plant/ORYZA/ttutil/lextokin.inc"
        "Plant/ORYZA/ttutil/LIMIT.for"
        "Plant/ORYZA/ttutil/lint.for"
        "Plant/ORYZA/ttutil/LINT2.for"
        "Plant/ORYZA/ttutil/lowerc.for"
        "Plant/ORYZA/ttutil/messini.f90"
        "Plant/ORYZA/ttutil/messinq.f90"
        "Plant/ORYZA/ttutil/messwrt.for"
        "Plant/ORYZA/ttutil/movavr.for"
        "Plant/ORYZA/ttutil/notnul.for"
        "Plant/ORYZA/ttutil/openlogf.f90"
        "Plant/ORYZA/ttutil/outar2.for"
        "Plant/ORYZA/ttutil/outcom.for"
        "Plant/ORYZA/ttutil/outdat.f90"
        "Plant/ORYZA/ttutil/outplt.for"
        "Plant/ORYZA/ttutil/outsel.f90"
        "Plant/ORYZA/ttutil/parsword.for"
        "Plant/ORYZA/ttutil/rchrsrc.for"
        "Plant/ORYZA/ttutil/rdacha.for"
        "Plant/ORYZA/ttutil/rdador.for"
        "Plant/ORYZA/ttutil/rdadou.for"
        "Plant/ORYZA/ttutil/rdainr.for"
        "Plant/ORYZA/ttutil/rdaint.for"
        "Plant/ORYZA/ttutil/rdalog.for"
        "Plant/ORYZA/ttutil/rdarea.for"
        "Plant/ORYZA/ttutil/rdarer.for"
        "Plant/ORYZA/ttutil/rdatim.for"
        "Plant/ORYZA/ttutil/rddata.for"
        "Plant/ORYZA/ttutil/rddata.inc"
        "Plant/ORYZA/ttutil/rddecinf.inc"
        "Plant/ORYZA/ttutil/rddtmp.for"
        "Plant/ORYZA/ttutil/rderr.for"
        "Plant/ORYZA/ttutil/rderri.for"
        "Plant/ORYZA/ttutil/rderrinf.inc"
        "Plant/ORYZA/ttutil/rdfcha.for"
        "Plant/ORYZA/ttutil/rdfdor.for"
        "Plant/ORYZA/ttutil/rdfdou.for"
        "Plant/ORYZA/ttutil/rdfilinf.inc"
        "Plant/ORYZA/ttutil/rdfinr.for"
        "Plant/ORYZA/ttutil/rdfint.for"
        "Plant/ORYZA/ttutil/rdflog.for"
        "Plant/ORYZA/ttutil/rdfrea.for"
        "Plant/ORYZA/ttutil/rdfrer.for"
        "Plant/ORYZA/ttutil/rdfrom.for"
        "Plant/ORYZA/ttutil/rdftim.for"
        "Plant/ORYZA/ttutil/rdinar.for"
        "Plant/ORYZA/ttutil/rdindt.for"
        "Plant/ORYZA/ttutil/rdindx.for"
        "Plant/ORYZA/ttutil/rdinit.for"
        "Plant/ORYZA/ttutil/rdinlv.for"
        "Plant/ORYZA/ttutil/rdinne.for"
        "Plant/ORYZA/ttutil/rdinqr.for"
        "Plant/ORYZA/ttutil/rdinqr2.for"
        "Plant/ORYZA/ttutil/rdinqr3.for"
        "Plant/ORYZA/ttutil/rdjdat.gin"
        "Plant/ORYZA/ttutil/rdjdec.gin"
        "Plant/ORYZA/ttutil/rdlex.for"
        "Plant/ORYZA/ttutil/rdmachin.inc"
        "Plant/ORYZA/ttutil/rdmcha.for"
        "Plant/ORYZA/ttutil/rdmdef.for"
        "Plant/ORYZA/ttutil/rdmdou.for"
        "Plant/ORYZA/ttutil/rdmint.for"
        "Plant/ORYZA/ttutil/rdmlog.for"
        "Plant/ORYZA/ttutil/rdmrea.for"
        "Plant/ORYZA/ttutil/rdmtim.for"
        "Plant/ORYZA/ttutil/rdndat.gin"
        "Plant/ORYZA/ttutil/rdndec.gin"
        "Plant/ORYZA/ttutil/rdpars.for"
        "Plant/ORYZA/ttutil/rdrecinf.inc"
        "Plant/ORYZA/ttutil/rdscha.for"
        "Plant/ORYZA/ttutil/rdsctb.for"
        "Plant/ORYZA/ttutil/rdsdor.for"
        "Plant/ORYZA/ttutil/rdsdou.for"
        "Plant/ORYZA/ttutil/rdsets.for"
        "Plant/ORYZA/ttutil/rdsinr.for"
        "Plant/ORYZA/ttutil/rdsint.for"
        "Plant/ORYZA/ttutil/rdslog.for"
        "Plant/ORYZA/ttutil/rdsrea.for"
        "Plant/ORYZA/ttutil/rdsrer.for"
        "Plant/ORYZA/ttutil/rdstainf.inc"
        "Plant/ORYZA/ttutil/rdstim.for"
        "Plant/ORYZA/ttutil/rdtblinf.inc"
        "Plant/ORYZA/ttutil/rdtmp1.for"
        "Plant/ORYZA/ttutil/rdtmp2.for"
        "Plant/ORYZA/ttutil/reaand.for"
        "Plant/ORYZA/ttutil/reanor.for"
        "Plant/ORYZA/ttutil/recread.f90"
        "Plant/ORYZA/ttutil/recread.inc"
        "Plant/ORYZA/ttutil/recreadi.f90"
        "Plant/ORYZA/ttutil/recreadt.f90"
        "Plant/ORYZA/ttutil/remove.for"
        "Plant/ORYZA/ttutil/sfindg.for"
        "Plant/ORYZA/ttutil/sortch.for"
        "Plant/ORYZA/ttutil/sortin.for"
        "Plant/ORYZA/ttutil/str_copy.for"
        "Plant/ORYZA/ttutil/swpi4.for"
        "Plant/ORYZA/ttutil/TIMER2.for"
        "Plant/ORYZA/ttutil/ttutil.f90"
        "Plant/ORYZA/ttutil/ttutilprefs.f90"
        "Plant/ORYZA/ttutil/ttuver.for"
        "Plant/ORYZA/ttutil/unifl.for"
        "Plant/ORYZA/ttutil/upperc.f90"
        "Plant/ORYZA/ttutil/usedun.for"
        "Plant/ORYZA/ttutil/ver4_23.for"
        "Plant/ORYZA/ttutil/warning_OR.for"
        "Plant/ORYZA/ttutil/words.for"
        "Plant/ORYZA/ttutil/wracha.for"
        "Plant/ORYZA/ttutil/wradou.for"
        "Plant/ORYZA/ttutil/wraint.for"
        "Plant/ORYZA/ttutil/wralog.for"
        "Plant/ORYZA/ttutil/wrarea.for"
        "Plant/ORYZA/ttutil/wratim.for"
        "Plant/ORYZA/ttutil/wrinit.for"
        "Plant/ORYZA/ttutil/wrscha.for"
        "Plant/ORYZA/ttutil/wrsdou.for"
        "Plant/ORYZA/ttutil/wrsint.for"
        "Plant/ORYZA/ttutil/wrslog.for"
        "Plant/ORYZA/ttutil/wrsrea.for"
        "Plant/ORYZA/ttutil/wrstim.for"
        "Plant/ORYZA/ttutil/wr_sys.inc"
        "Plant/SUBSTOR-Potato/PT_GROSUB.for"
        "Plant/SUBSTOR-Potato/PT_NFACTO.for"
        "Plant/SUBSTOR-Potato/PT_NUPTAK.for"
        "Plant/SUBSTOR-Potato/PT_OPGROW.for"
        "Plant/SUBSTOR-Potato/PT_OPHARV.for"
        "Plant/SUBSTOR-Potato/PT_PHASEI.for"
        "Plant/SUBSTOR-Potato/PT_PHENOL.for"
        "Plant/SUBSTOR-Potato/PT_ROOTGR.for"
        "Plant/SUBSTOR-Potato/PT_SUBSTOR.for"
        "Plant/SUBSTOR-Potato/PT_THTIME.for"
        "Soil/SOIL.for"
        "Soil/CENTURY_OrganicMatter/CENTURY.for"
        "Soil/CENTURY_OrganicMatter/CE_RATIO_C.for"
        "Soil/CENTURY_OrganicMatter/DECRAT_C.for"
        "Soil/CENTURY_OrganicMatter/EFLOW_C.for"
        "Soil/CENTURY_OrganicMatter/IMMOBLIMIT_C.for"
        "Soil/CENTURY_OrganicMatter/INCORPOR_C.for"
        "Soil/CENTURY_OrganicMatter/IPHedley_C.for"
        "Soil/CENTURY_OrganicMatter/LITDEC_C.for"
        "Soil/CENTURY_OrganicMatter/NCHECK_C.for"
        "Soil/CENTURY_OrganicMatter/OPSOMLIT_C.for"
        "Soil/CENTURY_OrganicMatter/PARTIT_C.for"
        "Soil/CENTURY_OrganicMatter/RPLACE_C.for"
        "Soil/CENTURY_OrganicMatter/SENESADD_C.for"
        "Soil/CENTURY_OrganicMatter/SoilCBal_C.for"
        "Soil/CENTURY_OrganicMatter/SoilCNPinit_C.for"
        "Soil/CENTURY_OrganicMatter/SoilNoBal_C.for"
        "Soil/CENTURY_OrganicMatter/SoilPoBal_C.for"
        "Soil/CENTURY_OrganicMatter/SOMDEC_C.for"
        "Soil/CENTURY_OrganicMatter/SOMFIX_C.for"
        "Soil/CENTURY_OrganicMatter/SOMINIT_c.for"
        "Soil/CENTURY_OrganicMatter/SOMLITPRINT_C.for"
        "Soil/CENTURY_OrganicMatter/TSOMLIT_C.for"
        "Soil/CERES_OrganicMatter/NCHECK_organic.for"
        "Soil/CERES_OrganicMatter/OpSoilOrg.for"
        "Soil/CERES_OrganicMatter/SoilOrg.for"
        "Soil/CERES_OrganicMatter/SoilOrg_init.for"
        "Soil/FloodN/FCHEM.for"
        "Soil/FloodN/FLOODI.for"
        "Soil/FloodN/Flood_Chem.for"
        "Soil/FloodN/OPFLOODN.for"
        "Soil/GHG/Denit_Ceres.for"
        "Soil/GHG/Denit_DayCent.for"
        "Soil/GHG/diffusiv.for"
        "Soil/GHG/N2O_mod.for"
        "Soil/GHG/nox_pulse.f90"
        "Soil/Inorganic_K/OpSoilKi.for"
        "Soil/Inorganic_K/SoilKi.for"
        "Soil/Inorganic_K/SoilK_init.for"
        "Soil/Inorganic_N/EQUIL2.for"
        "Soil/Inorganic_N/NCHECK_inorg.for"
        "Soil/Inorganic_N/NFLUX.for"
        "Soil/Inorganic_N/OPSOILNI.for"
        "Soil/Inorganic_N/OXLAYER.for"
        "Soil/Inorganic_N/SOILNI.for"
        "Soil/Inorganic_N/SoilNiBal.for"
        "Soil/Inorganic_N/SoilNi_init.for"
        "Soil/Inorganic_P/IPHedley_inorg.for"
        "Soil/Inorganic_P/OpSoilPi.for"
        "Soil/Inorganic_P/SoilPi.for"
        "Soil/Inorganic_P/SoilPiBal.for"
        "Soil/Inorganic_P/SoilPi_init.for"
        "Soil/Mulch/MULCHEVAP.for"
        "Soil/Mulch/MULCHLAYER.for"
        "Soil/Mulch/MULCHWAT.for"
        "Soil/Mulch/OPMULCH.for"
        "Soil/SoilUtilities/IPSOIL.for"
        "Soil/SoilUtilities/LMATCH.for"
        "Soil/SoilUtilities/SOILDYN.for"
        "Soil/SoilUtilities/SoilMixing.for"
        "Soil/SoilUtilities/SoilNBalSum.for"
        "Soil/SoilUtilities/SoilNoBal.for"
        "Soil/SoilUtilities/SoilNoPoBal.for"
        "Soil/SoilUtilities/SoilPBalSum.for"
        "Soil/SoilUtilities/SoilPoBal.for"
        "Soil/SoilUtilities/TextureClass.for"
        "Soil/SoilWater/INFIL.for"
        "Soil/SoilWater/OPWBAL.for"
        "Soil/SoilWater/RETC_VG.for"
        "Soil/SoilWater/RNOFF.for"
        "Soil/SoilWater/SATFLO.for"
        "Soil/SoilWater/TILEDRAIN.for"
        "Soil/SoilWater/WATBAL.for"
        "Soil/SoilWater/WBAL.for"
        "Soil/SoilWater/WBSUBS.for"
        "SPAM/ESR_SoilEvap.for"
        "SPAM/ETPHOT.for"
        "SPAM/ETPHR.for"
        "SPAM/OPETPHOT.for"
        "SPAM/OpStemp.for"
        "SPAM/PET.for"
        "SPAM/ROOTWU.for"
        "SPAM/SAL_Stemp.for"
        "SPAM/SOILEV.for"
        "SPAM/SPAM.for"
        "SPAM/SPSUBS.for"
        "SPAM/STEMP.for"
        "SPAM/STEMP_EPIC.for"
        "SPAM/TRANS.for"
        "Weather/CO2VAL.for"
        "Weather/HMET.for"
        "Weather/IPWTH_alt.for"
        "Weather/OPWEATH.for"
        "Weather/SOLAR.for"
        "Weather/weathr.for"
        "Weather/WGEN.for"
        "Weather/WTHMOD.for"
)
ADD_EXECUTABLE(${EXECUTABLE_NAME} ${source_list})

foreach(source IN LISTS source_list)
    get_filename_component(source_path "${source}" PATH)
    string(REPLACE "/" "\\" source_path_msvc "${source_path}")
    source_group("${source_path_msvc}" FILES "${source}")
endforeach()

##################################################
# Resume information about flags and option used #
##################################################

message( "-- Flags" )
message( "   FFLAGS       ${CMAKE_Fortran_FLAGS}" )
message( "   RELEASE      ${CMAKE_Fortran_FLAGS_RELEASE}" )
message( "   DEBUG        ${CMAKE_Fortran_FLAGS_DEBUG}" )
message( "-- Build Info" )
message( "   BUILD TYPE   ${CMAKE_BUILD_TYPE}" )
message( "   VERSION      ${MAJOR}.${MINOR}.${MODEL}.${BUILD}" )
message( "   I. PREFIX    ${CMAKE_INSTALL_PREFIX}" )
message( "   Executable   ${EXECUTABLE_NAME}" )
