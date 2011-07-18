!=======================================================================
!  ORYZA_Interface, Subroutine
!  DSSAT interface for ORYZA2000 rice growth routine.
!-----------------------------------------------------------------------
!  REVISION       HISTORY
!  01/26/2011 TL/CHP Written.
!=======================================================================
      SUBROUTINE ORYZA_Interface (CONTROL, ISWITCH,               &    !Input
          EOP, FLOODWAT, HARVFRAC, NH4, NO3, SOILPROP,            &    !Input
          SomLitC, SomLitE,                                       &    !Input
          ST, SW, TRWUP, UPPM, WEATHER, YRPLT, YREND,             &    !Input
          CANHT, HARVRES, KCAN, KEP, MDATE, NSTRES, PORMIN,       &    !Output
          RWUMX, SENESCE, STGDOY, UNH4, UNO3, UH2O, XLAI)              !Output

      USE ModuleDefs
      USE FloodModule
      USE ModuleData
      USE Public_Module		!VARIABLES
	  USE RootGrowth

      IMPLICIT NONE
      SAVE

      CHARACTER*6  ERRKEY
      PARAMETER (ERRKEY = 'ORYZA ')

      CHARACTER*30  FILEIO
      CHARACTER*78  MSG(4)
      CHARACTER*120 FILEIOCS

      INTEGER DOY1, DYNAMIC, TN, RUNI, RN, ON
      INTEGER REP, STEP, CN, YRHAR, YREND, YRDOY
      INTEGER MDATE, L, NLAYR
      INTEGER SN, YEAR1
      INTEGER STGDOY(20), YRPLT
      INTEGER, PARAMETER :: NL_OR = 10

      REAL WUPT, EOP, EP, ET, TRWUP
      REAL KCAN, KEP
      REAL NSTRES, XLAI, NFP
      REAL PORMIN, RWUMX
      REAL CANHT, TOTIR

      REAL, DIMENSION(NL) :: DS
      REAL, DIMENSION(2)  :: HARVFRAC

!     Soil water
      REAL, DIMENSION(NL) :: BD, ST, SW, WPkPa
      REAL, DIMENSION(NL_OR) :: SANDX, CLAYX, MSKPA

!     Soil N
      REAL, DIMENSION(NL) :: NH4, NO3, UPPM, UNO3, UNH4, UH2O
      REAL SomLitC(0:NL), SomLitE(0:NL,NELEM)
      REAL, DIMENSION(NL_OR) :: SNH4X, SNO3X, SOC, SON, SUREA

!-----Formal ORYZA parameters
      INTEGER       ITASK , IUNITD, IUNITL, CROPSTA, IDOY, TDATE
      LOGICAL       OR_OUTPUT, TERMNL
      CHARACTER (128) FILEI1, FILEIT, FILEI2
      CHARACTER (32) ESTAB
      REAL    YEAR, DOY , TIME, DELT  , LAT  , RDD, TRC, NFLV, NSLLV
      REAL    TMMN, TMMX, TKLT  , ZRTMS, LRSTRS, LDSTRS, LESTRS, NRT
      REAL    PCEW, CPEW, DAE , LAIROL, ZRT  , DVS, RNSTRS, WCL(10), WL0, DLDR
      REAL    LAI, LLV  , SLA , WLVG  , WST  , WSO, GSO, GGR, GST, GLV, PLTR 
      REAL    TRW, TRWL(10), TKL(10), WRT, WRR14
      REAL    HU, WAGT, WLVD, WRR, NGR, PLOWPAN, TNSOIL, NACR

!     FOR EXPERIMENT FILE 
      INTEGER YRSIM, EDATE, iPAGE, IRRCOD 
      CHARACTER*1, ISWWAT, ISWNIT, PLME,IIRRI
      REAL PLPH, PLTPOP, PLANTS, PLDP,IRRI, WL0MIN, KPAMIN, WLODAY, SLMIN
      REAL IRMTAB(300), RIRRIT(750),ISTAGET(900), TMCTB(750)

!     FILEIO data
      CHARACTER*1  PLDS
      INTEGER INCDAT
      REAL PAGE, ROWSPC, SDWTPL, ATEMP

!     Output data needed for DSSAT output files
      CHARACTER*10 STNAME(20) 
      INTEGER ISDATE, ISTAGE 

      TYPE (ControlType) CONTROL
      TYPE (SoilType)    SOILPROP
      TYPE (SwitchType)  ISWITCH
      Type (ResidueType) HARVRES
      Type (ResidueType) SENESCE
      TYPE (WeatherType) WEATHER
      TYPE (FloodWatType)FLOODWAT
      
      COMMON /FSECM1/ YEAR,DOY,IUNITD,IUNITL,TERMNL
      
      DYNAMIC = CONTROL % DYNAMIC
      YRDOY   = CONTROL % YRDOY
      CALL YR_DOY(YRDOY, YEAR1, DOY1)

!***********************************************************************
!***********************************************************************
!     Seasonal initialization - run once per planting season
!***********************************************************************
      IF (DYNAMIC == SEASINIT) THEN

        ITASK = 1
        TIME =0.0
        ALLOCATE(pv)                              !Added by TaoLi, 24 April 2011

!       ORYZA does its own root water uptake - how to handle?
!       Variables required by DSSAT for root water uptake calculations
        PORMIN = 0.0  !Minimum pore space required for supplying oxygen to roots for 
!                      optimal growth and function (cm3/cm3)
        RWUMX  = 0.03 !Maximum water uptake per unit root length, constrained by soil 
!                      water (cm3[water] / cm [root])

        FILEIO  = CONTROL % FILEIO
        YRSIM   = CONTROL % YRSIM
        ISWWAT  = ISWITCH % ISWWAT
        ISWNIT  = ISWITCH % ISWNIT
        LAT     = WEATHER % XLAT
      
        DS     = SOILPROP % DS    
        NLAYR  = SOILPROP % NLAYR  

        IF (NLAYR > NL_OR) THEN
          MSG(1) = "Too many layers for ORYZA2000 model."
          WRITE(MSG(2),'("Number of layers = ",I3)') NLAYR
          WRITE(MSG(3),'("Max # of layers  = ",I3)') NL_OR
          MSG(4) = "Program will stop."
          CALL WARNING(4,ERRKEY,MSG)
          CALL ERROR(ERRKEY,75," ",0)
        ENDIF

        CALL WaterPotential(SW, SOILPROP,  &    !Input
          WPkPa)                                !Output

!       Transfer from DSSAT SOILPROP variables to ORYZA variables, by layer
        PV % PNL = NLAYR
        DO L = 1, NLAYR
          BD(L)     = SOILPROP % BD(L)    
          SANDX(L)  = SOILPROP % SAND(L) / 100.
          CLAYX(L)  = SOILPROP % CLAY(L) / 100.

!         These are only used for a seasonal initialization, not needed daily
          SOC(L)    = SomLitC(L)    !Soil organic C (kg/ha)
          SON(L)    = SomLitE(L,1)  !Soil organic N (kg/ha)

!         ORYZA public variables:
          PV%PDLAYER(L) = SOILPROP % DLAYR(L)*10.0       !CONVERT LAYER THICKNESS FROM cm TO mm
          TKL(L) = PV%PDLAYER(L)/1000.0      !CONVERT SOIL LAYER THICKNESS FROM mm TO m
          PV%PWCST(L) = SOILPROP % SAT(L)
          PV%PWCFC(L) = SOILPROP % DUL(L)
          PV%PWCWP(L) = SOILPROP % LL(L)

!         These will also be transferred daily
          PV % PNO3(L) = NO3(L) / SOILPROP % KG2PPM(L) !Convert from ppm to kg/ha
          PV % PNH4(L) = NH4(L) / SOILPROP % KG2PPM(L) !Convert from ppm to kg/ha
          SUREA(L) = UPPM(L) / SOILPROP % KG2PPM(L)
          SNH4X(L) = PV % PNH4(L)
          SNO3X(L) = PV % PNO3(L)
          MSKPA(L) = WPkpa(L)
        END DO

    
        FILEIOCS(1:30) = FILEIO
        TN = 0
        RN = 0
        SN = 0
        ON = 0
        CN = 0  !Crop component
        REP = 1
        STEP = 1
        RUNI = 1
        TOTIR = 0.0

        HU = 0.0
        WAGT = 0.0
        WLVD = 0.0
        WRR = 0.0
        TRC = 0.0

!       Water & N stresses
        LRSTRS = 1.0
        LDSTRS = 1.0
        LESTRS = 1.0
        PCEW   = 1.0
        CPEW   = 1.0
        RNSTRS = 1.0

        CANHT = 0.0   !Canopy height
        KCAN  = 0.85  !Canopy light extinction coef
        KEP   = 1.0   !Energy extinction coef
        STGDOY= 9999999   !Dates for developement stages

!       Depth to plowpan (cm)
        PLOWPAN = (DS(NLAYR) + 10.)/100.0   !converted into m
        DO L = 2, NLAYR
          IF (SOILPROP % WR(L) < 0.001) THEN
            PLOWPAN = DS(L-1) /100.0    !converted into m
            EXIT
          ENDIF
        ENDDO

        WL0  = FLOODWAT % FLOOD

!       Read DSSAT cultivar and planting data from FILEIO
        CALL OR_IPRICE (CONTROL,                       &
          FILEI1, PLANTS, PLTPOP, PLME, PLDS,      &
          ROWSPC, PLDP, SDWTPL, PAGE, ATEMP, PLPH, &
          STGDOY, STNAME)
 
        STGDOY(14) = YRDOY !start of simulation
        ISTAGE = 14

!----------------------------------------------------------------
!       ORYZA initialization section - moved up to initialization section
        !initialize OBSSYS routine
        CALL OBSINI

        !get emergence date and transplanting date
        TDATE = YRPLT
        IF(INDEX(PLME,"T").GT.0) THEN
!           By definition, DSSAT YRPLT = transplant date.  We need to keep this definition
!           for the FILEX data for compatibility with other models.  But we need to start calling
!           ORYZA on the sowing date, because the model calculates growth in the seed bed.
!           So - for transplants, re-set YRPLT = sowing date so that ORYZA is called prior
!           to transplant date.
            iPAGE = NINT(PAGE)
            EDATE = INCDAT(YRPLT,-iPAGE)
            YRPLT = EDATE  
        ELSE
            EDATE = YRPLT
        END IF

!       Used STRING
!       ESSENTIAL INFORMATION MUST BE PROVIDED FROM UPPER LAYER
!       FILEI1 = 'D:\...\...\IR72.CRP
!       FILEIT = 'D:\...\...\...\N150.exp
        FILEIT = CONTROL % FILEX(1:8) // ".EXP"
        FILEI2 = CONTROL % FILEX(1:8) // ".SOL"
        IIRRI  = ISWITCH % IIRRI
!       IRCOD  = 0  !Potential production  - need to get value for water limited. 
        !THE 'IRCOD', IT IS NOT USED IN THE ROUTINE YET, COMMENT IT OUT TEMPORARY.

        !GENERATE EXPERIMENT AND SOIL FILES
        CALL UPPERC(ISWWAT)
        CALL UPPERC(ISWNIT)
        CALL ExperimentFileEdit(FILEIT, YRSIM, EDATE,& 
                ISWWAT, ISWNIT, PLME, iPAGE, PLPH, PLTPOP, PLANTS, PLANTS, PLDP, &
                IIRRI, IRRCOD, IRMTAB, RIRRIT, IRRI, WL0MIN, KPAMIN, SLMIN, WLODAY, ISTAGET, TMCTB)

        OR_OUTPUT = .FALSE.;TERMNL = .FALSE.
        IF ((ISWNIT == 'Y').OR.(ISWWAT == 'Y')) THEN
            PV%PROOT_NUTRIENT = .TRUE.
            CALL SOILFILEEDIT(FILEI2, NLAYR, TKL, SANDX, CLAYX, BD, SOC, SON, SNH4X, SNO3X, SUREA, PLOWPAN)
        ELSE
            PV%PROOT_NUTRIENT = .FALSE.; FILEI2=""
        END IF

        IF(INDEX(ISWWAT,"N")>0) THEN
            TRW =TRC
        ENDIF

        CALL GETLUN("ORYZA1",IUNITD)
        CALL GETLUN("ORYZA2",IUNITL)
        IUNITD = IUNITD+10
        IUNITL = IUNITL+20
        
        DELT = 1.0  !TIME STEP IS 1.0
        IDOY = DOY
        DAE = 0.0        
        
         !open a temporary file for ORYZA2000 outputs
        OPEN(UNIT = IUNITD+50, FILE = "ORYZA_RES.DAT")
        OPEN(UNIT = IUNITD+60, FILE = "ORYZA_CLI.DAT")
        WRITE(IUNITD+50,'(A)') "DOY,DAE,DVS,ZRT,LAI,LLV,WLVD,WLVG,WST,WSO,WRR14,WRT,GSO,GGR,GST,GLV,WAGT" 

!***********************************************************************
!***********************************************************************
!     Rate - daily
!***********************************************************************
      ELSEIF (DYNAMIC == RATE) THEN

        ITASK = 2

        CALL GET('SPAM','EP',  EP)
!       CALL GET('SPAM','EO',  EO)
!       CALL GET('SPAM','UH2O',UH2O)

!       Transfer DSSAT variables into ORYZA variables
        RDD   = WEATHER % SRAD*1000000.0
        TMMX  = WEATHER % TMAX
        TMMN  = WEATHER % TMIN
        TRC   = EOP

        WL0  = FLOODWAT % FLOOD  !the surface water depth in mm
        pv%pwl0 = wl0

        CALL WaterPotential(SW, SOILPROP,  &    !Input
          WPkPa)                                !Output

        DO L = 1, NLAYR
          WCL(L) = SW(L)      !Soil water content (mm3/mm3)
          pv%Pswc(L)   = SW(L)      !Soil water content (mm3/mm3)
          pv%pSOILTx(L) = ST(L)      !Soil temperature (oC)
          PV % PNO3(L) = NO3(L) / SOILPROP % KG2PPM(L) !NO3 (kg/ha)
          PV % PNH4(L) = NH4(L) / SOILPROP % KG2PPM(L) !NH4 (kg/ha)
          SNH4X(L) = PV % PNH4(L)
          SNO3X(L) = PV % PNO3(L)
          MSKPA(L) = WPkpa(L)
        ENDDO

!-----  Set CROPSTA: 0=before sowing; 1=day of sowing; 2=in seedbed;
!                  3=day of transplanting; 4=main growth period

!       YRPLT = sowing date for direct seed 
        IF (YRDOY == YRPLT) THEN
          STGDOY(7) = YRDOY
          ISTAGE = 7
        ENDIF

        IF(YRDOY.LT.EDATE) THEN
           CROPSTA = 0             
        END IF

        IF (CROPSTA .EQ. 3) CROPSTA = 4

        IF (CROPSTA .EQ. 2) THEN
           IF (YRDOY.EQ.TDATE) THEN
!             Transplant
              CROPSTA = 3
              STGDOY(11) = YRDOY
              ISTAGE = 11
           ENDIF
        END IF

        IF (CROPSTA .EQ. 1) THEN
           IF (INDEX(PLME,"T").GT.0) THEN
              CROPSTA = 2
           ELSE 
              CROPSTA = 4
           END IF
        END IF

        IF (CROPSTA .EQ. 0) THEN
           IF (YRDOY.EQ.EDATE) THEN
!              Emergence
               CROPSTA = 1
               STGDOY(9) = YRDOY
               ISTAGE = 9
            ENDIF
        END IF

        DOY = REAL(DOY1);YEAR = real(YEAR1); IDOY = DOY1
        CALL GET('SPAM','ET',  ET)
        CALL Get('MGMT','TOTIR', TOTIR)

!***********************************************************************
!***********************************************************************
!     Integration - daily
!***********************************************************************
     ELSEIF (DYNAMIC == INTEGR) THEN

        ITASK = 3
        TIME = TIME+DELT

        YRHAR = YREND
        WUPT  = TRWUP

!          DO L=0, NLAYR
!            SENESCE % ResWt(L)  = (SENC(L) + CRESC(L)) / 0.40
!            SENESCE % ResLig(L) = SENLIG(L) + CRESLIG(L)
!            SENESCE % ResE(L,1) = SENN(L) + CRESN(L)
!          ENDDO
!
!        endif
!
!        IF (YREND == YRDOY .AND. DYNAMIC == INTEGR) THEN 
!          !Transfer harvest residue from senescence variable to 
!          !harvest residue variable on day of harvest.
!          HARVRES = SENESCE
!          SENESCE % ResWt  = 0.0
!          SENESCE % ResLig = 0.0
!          SENESCE % ResE   = 0.0
!        ELSE
!          MDATE = -99
!        ENDIF


!***********************************************************************
!***********************************************************************
!     Daily or seasonal output
!***********************************************************************
      ELSE

        ITASK = 0

        IF (DYNAMIC == SEASEND) THEN
          STGDOY(20) = YRDOY
          ISTAGE = 20
          YREND = YRDOY
          TERMNL = .TRUE.
          DEALLOCATE(PV) 
          CALL RDDTMP (IUNITD)  !delete all temporary files
          CLOSE(IUNITD+50)
          CLOSE(IUNITD+60)
        ENDIF

      ENDIF

!***********************************************************************
!***********************************************************************

    IF(.NOT.TERMNL .AND. DYNAMIC > RUNINIT) THEN
        IF(INDEX(ISWWAT,"Y").GT.0) THEN

            CALL WSTRESS2 (ITASK,  DELT,   OR_OUTPUT, IUNITD, IUNITL, FILEI1, FILEIT, &
                          TRC,    ZRT,    TKL,    NLAYR,    CROPSTA, &
                          WCL,    pv%PWCWP,   MSKPA, &
                          TRW,    TRWL,   LRSTRS, LDSTRS, LESTRS, PCEW, CPEW)
        !       Check for potential production condition  
        ELSEIF(INDEX(ISWWAT, "N").GT.0) THEN              !POTENTIAL WATER CONDITION
            TRW = EP; TKLT = SUM(TKL); ZRTMS = TKLT   !THE TOTAL TRANSPIRATION EQUALS TO POTENTIAL TRANSPIRATION
            CALL WNOSTRESS (NLAYR, TRW, TRWL, ZRT, TKL, LRSTRS, LDSTRS, LESTRS, PCEW, CPEW)
        END IF

!   TRC = EOP
!   ZRT         Root depth (cm)
!   TKL         Soil thickness (m)
!   pv%PWCWP    Wilting point (mm3/mm3)
!   MSKPA       Water potential (kPa)
!   TRW         Actual transpiration rate (output from ORYZA) (mm/d)
!   TRWL        Actual transpiration rate layers (mm/d) (Output from ORYZA)
!   

        CALL ORYZA1(ITASK,  IUNITD, IUNITL, FILEI1, FILEI2,FILEIT, &
                        OR_OUTPUT, TERMNL, IDOY  , DOY, &
                        TIME,   DELT,   LAT,    RDD,    TMMN,   TMMX, &
                        NFLV,   NSLLV,  NRT,	RNSTRS,                 &
                        ESTAB,  TKLT,   ZRTMS,  CROPSTA, &
                        LRSTRS, LDSTRS, LESTRS, PCEW,  CPEW, TRC, &
                        DAE,    SLA, LAI,    LAIROL, ZRT,    DVS, &
                        LLV,    DLDR, WLVG, WST, WSO, GSO, GGR, GST, GLV, &
                        PLTR, WCL, WL0, WRT, WRR14, NGR, HU)

!       IF(INDEX(ISWNIT, "N").GT.0) THEN           !POTENTIAL NITROGEN CONDITION
            CALL NNOSTRESS2(DELT, IUNITD, IUNITL, ITASK, FILEI1, FILEIT, &
                           CROPSTA, DVS, WLVG, LAI, SLA, NFLV, NSLLV, RNSTRS)
!        ELSE
!            CALL NCROP3 (ITASK, IUNITD, IUNITL, FILEI1, FILEI2, FILEIT, DELT, TIME, OR_OUTPUT, &
!                       TERMNL, DVS, LLV, DLDR, WLVG, WST, WSO, GSO, GST, GLV, &
!                       PLTR, LAI, SLA, CROPSTA, TNSOIL, NACR, NFLV, NSLLV,NRT, RNSTRS, RNH4, RNO3)

!        END IF

      IF (ITASK == 2) THEN
        DO L = 1, NLAYR
          UNH4(L) = SNH4X(L) - PV % PNH4(L)    !NH4 uptake (kg/ha)
          UNO3(L) = SNO3X(L) - PV % PNO3(L)    !NO3 uptake (kg/ha)
          UH2O(L) = TRWL(L)                    !H2O uptake (mm/d)
        ENDDO 
        NSTRES = NFP

      ELSEIF (ITASK == 3) THEN
        XLAI   = LAI
        WLVD = WLVD+ (DLDR+LLV)*DELT        
        WAGT = WST + WLVG + WSO + WLVD
        WRR  = WRR14 * 0.86

!       Temporary
        WRITE(IUNITD+50,5000) DOY,DAE,DVS,ZRT,LAI,LLV,WLVD, WLVG, WST, WSO, WRR14, WRT,&
                            GSO, GGR, GST, GLV,WAGT
        WRITE(IUNITD+60,6000) 1,YEAR, DOY, RDD/1000.0, TMMN, TMMX, -99.0, -99.0           
        
        IF (DVS >= 0.65 .AND. STGDOY(2) > YRDOY) THEN
!         Panicle initiation date DVS = 0.65
          STGDOY(2) = YRDOY
          ISTAGE = 2
        ELSEIF (DVS >= 1.0 .AND. STGDOY(3) > YRDOY) THEN
!         Anthesis date when DVS = 1.0
          STGDOY(3) = YRDOY
          ISTAGE = 3
          ISDATE = YRDOY
        ELSEIF (TERMNL.AND. STGDOY(6) > YRDOY) THEN
!         Maturity date when DVS =2.0
          STGDOY(6) = YRDOY
          ISTAGE = 6
          MDATE = YRDOY
        ENDIF 
      
        IF (TERMNL) THEN
          MDATE = YRDOY
          YREND = YRDOY
          CALL RDDTMP (IUNITD)
        ENDIF
      ENDIF
    ENDIF

    SELECT CASE(DYNAMIC)
    CASE(RUNINIT, SEASINIT, OUTPUT, SEASEND)
      CALL OR_OPGROW (CONTROL, ISWITCH, SOILPROP,      &
         CPEW, DVS, HU, LAI, LDSTRS, LESTRS, LRSTRS,   &
         NFLV, NGR, NSLLV, PCEW, RDCL,                 &
         WAGT, WLVD, WLVG, WRR, WRT, WSO, WST, YRPLT, ZRT)

      CALL OR_OPHARV (CONTROL, ISWITCH,                 &
         NSLLV, WAGT, WST, WLVG, WLVD, WSO, WRR, NGR,   & !Input
         HARVFRAC, ISDATE, ISTAGE, LAI, MDATE,          & !Input
         STGDOY, STNAME, YRPLT)                           !Input
    END SELECT

!-----------------------------------------------------------------------
5000 FORMAT(2(F5.0,","),(F7.4,","),13(F12.3,","),F12.3)
6000 FORMAT(1(I3,","),2(F5.0,","),(F12.3,","),4(F12.3,","),F12.3)
      RETURN
      END SUBROUTINE ORYZA_Interface

!=====================================================================

!=======================================================================
!  RI_IPGROSUB, Subroutine
!
!  Reads FILEIO for GROSUB routine
!  05/07/2002 CHP Written
!  08/12/2003 CHP Added I/O error checking
!=======================================================================
      SUBROUTINE OR_IPRICE (CONTROL,               &
          FILEI1, PLANTS, PLTPOP, PLME, PLDS,      &
          ROWSPC, PLDP, SDWTPL, PAGE, ATEMP, PLPH, &
          STGDOY, STNAME)

      USE ModuleDefs     !Definitions of constructed variable types, 
                         ! which contain control information, soil
                         ! parameters, hourly weather data.
      IMPLICIT     NONE

      CHARACTER*1   PLME, PLDS
      CHARACTER*2   CROP
      CHARACTER*6   VARTY
      CHARACTER*10  STNAME(20)     
      CHARACTER*20  VARNAME
      CHARACTER*30  FILEIO
      CHARACTER*78  MSG(2)
      CHARACTER*128 FILEI1

      CHARACTER*6  ERRKEY, SECTION
      PARAMETER (ERRKEY = 'IPRICE')

      INTEGER LINC, LNUM, LUNIO, ERR, FOUND, STGDOY(20)
      REAL PLANTS, PLTPOP, ROWSPC, PLDP, SDWTPL, PAGE, ATEMP, PLPH

!     The variable "CONTROL" is of type "ControlType".
      TYPE (ControlType) CONTROL
      FILEIO = CONTROL % FILEIO
      LUNIO  = CONTROL % LUNIO

      LNUM = 0

!-----------------------------------------------------------------------
!       Read data from FILEIO for use in PLANT module
!-----------------------------------------------------------------------
      OPEN (LUNIO, FILE = FILEIO, STATUS = 'OLD', IOSTAT=ERR)
      IF (ERR .NE. 0) CALL ERROR(ERRKEY,ERR,FILEIO,0)

!-----------------------------------------------------------------------
!    Read Cultivars Section
!-----------------------------------------------------------------------
!C CR INGENO CNAME
!  RI IB0118 IR 72   
        
      SECTION = '*CULTI'
      CALL FIND(LUNIO, SECTION, LINC, FOUND) ; LNUM = LNUM + LINC
      IF (FOUND .EQ. 0) CALL ERROR(SECTION, 42, FILEIO, LNUM)
      READ(LUNIO,'(3X,A2,1X,A6,1X,A20)', IOSTAT=ERR) CROP, VARTY, VARNAME ; LNUM = LNUM + 1
      IF (ERR .NE. 0) CALL ERROR(ERRKEY,ERR,FILEIO,LNUM)

      SELECT CASE(VARTY)
      CASE ('IB0118'); FILEI1 = 'IR72.CRP'
      CASE DEFAULT
        MSG(1) = 'Invalid ORYZA cultivar found.'
        MSG(2) = 'Program will stop.'
        CALL WARNING(2, ERRKEY, MSG)
        CALL ERROR(ERRKEY,36,FILEIO,LNUM)
      END SELECT

!-----------------------------------------------------------------------
!    Read Planting Details Section
!-----------------------------------------------------------------------
!P   PDATE   EDATE  PPOP  PPOE  PLME  PLDS  PLRS  PLRD  PLDP  PLWT  PAGE  PENV  PLPH  SPRL
!  1992195     -99 999.0 125.0     T     H   20.    0.   5.0    0.   12.  25.0   5.0   0.0

      SECTION = '*PLANT'
      CALL FIND(LUNIO, SECTION, LINC, FOUND) ; LNUM = LNUM + LINC
      IF (FOUND .EQ. 0) CALL ERROR(SECTION, 42, FILEIO, LNUM)
      READ (LUNIO,70, IOSTAT=ERR) PLANTS, PLTPOP, PLME, PLDS, ROWSPC, PLDP, SDWTPL, PAGE, ATEMP, PLPH
   70 FORMAT (18X,2F6.0,2(5X,A1),F6.0,6X,5F6.0)
      LNUM = LNUM + 1
      IF (ERR .NE. 0) CALL ERROR(ERRKEY,ERR,FILEIO,LNUM)

      CLOSE (LUNIO)

      ROWSPC = ROWSPC / 100.0

!     ORYZA life cycle:
!      DVS  Stage
!     0.00  Emergence 
!     0.40  Start of photoperiod sensitive phase
!     0.65  Panicle initiation
!     1.00  50% flowering
!     2.00  Physiological maturity

!     Stages from CERES-Rice:  (X indicates that stages are transferred to DSSAT
      STNAME(1)  = 'End Juveni'
      STNAME(2)  = 'Pan Init  '  !DVS = 0.65  !X
      STNAME(3)  = 'Heading   '  !DVS = 1.0
      STNAME(4)  = 'Beg Gr Fil'
      STNAME(5)  = 'End Mn Fil'
      STNAME(6)  = 'Maturity  '  !DVS = 2.0  !X
      STNAME(7)  = 'Sowing    '  !
      STNAME(8)  = 'Germinate '
      STNAME(9)  = 'Emergence '  !DVS = 0.0  !X
      STNAME(10) = 'Prgerm Sow'
      STNAME(11) = 'Transplant'  !X
      STNAME(12) = 'End Ti Fil'
      STNAME(13) = '          '
      STNAME(14) = 'Start Sim '  !X
      STNAME(15) = '          '
      STNAME(16) = '          '
      STNAME(17) = '          '
      STNAME(18) = '          '
      STNAME(19) = '          '
      STNAME(20) = 'Harvest   '

      STGDOY     = 9999999  

       RETURN
       END SUBROUTINE OR_IPRICE
 !=======================================================================
