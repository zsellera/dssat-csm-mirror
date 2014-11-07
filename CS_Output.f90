!***************************************************************************************************************************
! Subroutine CS_Output takes all the code from CSCAS lines 6656 - 9620. The names of the dummy arguments are the same 
! as in the original CSCAS code and the call statement and are declared here. The variables  that are not arguments 
! are declared in Module_CSCAS_Vars_List. Unless identified as by MF, all comments are those of the original CSCAS.FOR code.
!    
! Subroutine CS_Output calls 12 subroutines that cover model failure, time sequence outputs, output of N balance, outputs 
! for harvest and evaluation,  output for OVERVIEW.OUT, summary output for the simulation run, for leaf cohorts and 
! branching levels, details for the WORK.OUT file, details for the ERROR.OUT file, outputs for the DSSAT shell, screen 
! outputs for sensitivity mode, store  variables and interface with CSM summary output. 
!***************************************************************************************************************************
    
    SUBROUTINE CS_Output ( & 
        BRSTAGE     , CAID        , CANHT       , CN          , CO2         , DOY         , DYNAMIC     , EOP         , &
        IDETG       , IDETL       , IDETO       , IDETS       , IRRAMT      , ISWNIT      , ISWWAT      , KCAN        , &
        MESOM       , NFP         , NLAYR       , ON          , RAIN        , REP         , RLV         , RN          , &
        RNMODE      , RUN         , RUNI        , SN          , SRAD        , STGYEARDOY  , TN          , TNIMBSOM    , &
        TOMINSOM1   , UNH4        , UNO3        , WINDSP      , YEAR        &
        )
        
        USE Module_CSCAS_Vars_List
        USE Module_CS_Formats
     
        IMPLICIT NONE 
     
        INTEGER :: CN          , DOY         , DYNAMIC     , NLAYR       , ON          , REP         , RN          
        INTEGER :: RUN         , RUNI        , SN          , STGYEARDOY(20)            , TN          , YEAR

        REAL    :: BRSTAGE     , CAID        , CANHT       , CO2         , DAYL        , EO          , EOP         , IRRAMT
        REAL    :: KCAN        , NFP         , RAIN        , RLV(NL)     , SRAD        , TNIMBSOM    , TOMINSOM1   , UNH4(NL)        
        REAL    :: UNO3(NL)    , WINDSP      

        CHARACTER(LEN=1)  :: IDETG       , IDETL       , IDETO       , IDETS       , ISWNIT      , ISWWAT      
        CHARACTER(LEN=1)  :: MESOM       , RNMODE      
        
        ! Simulated outputs only                                                              ! LAH comments in original code
        !  IDETG (GROUT in controls (Y,N))  Plant growth outputs
        !   Y->Work_details+Plantgro+Plantgr2+Plantgrf
        !      +PlantN(If N switched on)
        !   FROUT->#=number of days between outputs
        !  IDETS (SUMRY in controls (Y,N)) Summary outputs
        !   Y->Summary+Plantsum+Work(Harvest)                        
        !
        ! Simulated+Measured outputs
        !  IDETO (OVVEW in controls (Y,E,N)) Overview outputs
        !   Y->Overview+Evaluate(+Measured if IDETG=Y)
        !   E->Evaluate only
        !  IDETL (VBOSE in controls (0,N,Y,D,A))
        !   Y->Leaves+Tiers+Measured                 
        !   D->+Phenols+Phenolm+Plantres+Plantrem
        !   A->Errora+Errors+Errort+Full Reads
        !   0,A are meta switches:
        !     0 switches everything to N apart from IDETS,which given a Y,
        !       and IDETO,which given an E when RNMODE is not N (seasonal)
        !     A switches ALL outputs on 
        
        !-------------------------------------------------------------------------------------------------------------------
        !               ! If model failure so that cycle not completed
        !-------------------------------------------------------------------------------------------------------------------
        CALL CS_Out_ModFail ( &
            BRSTAGE     , CAID        , DYNAMIC     , KCAN        &
            )

        !-------------------------------------------------------------------------------------------------------------------
        !       TIME SEQUENCE OUTPUTS (Work, Plantgro, gr2, grf)
        !-------------------------------------------------------------------------------------------------------------------

        IF (  (MOD(DAS,FROPADJ).EQ.0.AND.YEARDOY.GE.PLYEARDOY).OR. (YEARDOY.EQ.PLYEARDOY).OR. (YEARDOY.EQ.STGYEARDOY(1)).OR. &
            (YEARDOY.EQ.STGYEARDOY(HSTG)).OR. (YEARDOY.EQ.STGYEARDOY(11))) THEN
            
            !---------------------------------------------------------------------------------------------------------------
            !          Output WORK data (IDETL: Work details)
            !---------------------------------------------------------------------------------------------------------------     

            CALL CS_Out_Work ( &
                BRSTAGE     , CN          , CO2         , DOY         , IDETL       , IRRAMT      , NFP         , RAIN        , &
                WINDSP      , YEAR        &
                )
            !---------------------------------------------------------------------------------------------------------------
            !         Output plant growth factors (Plantgro, gr2, grf, N) (IDETG NE N)
            !---------------------------------------------------------------------------------------------------------------
             CALL CS_Out_PlGrow ( & 
                BRSTAGE     , CANHT       , DOY         ,  EOP         , IDETG       , IDETL       , ISWNIT      , &
                NFP         , RLV         , RUN         , TN          , YEAR        &
                )  
            
        ELSEIF(YEARDOY.LT.PLYEARDOY.AND.(MOD(DAS,FROPADJ)).EQ.0.AND.IPLTI.EQ.'A') THEN
                
            !! Automatic planting                                                              ! MF Commented out bt LAH in original code. Left in case useful in debugging.
            !WRITE (fnumwrk,*) 'Yeardoy ',yeardoy
            !WRITE (fnumwrk,*) 'Water thresholds ',swpltl,swplth
            !WRITE (fnumwrk,*) 'Water ',avgsw
            !WRITE (fnumwrk,*) 'Temperature thresholds ',pttn,ptx
            !WRITE (fnumwrk,*) 'Temperature ',tsdep
                
        ENDIF  ! End time-course outputs (appropriate day, etc.)
        ! (MOD(DAS,FROPADJ).EQ.0.AND.YEARDOY.GE.PLYEARDOY),etc..
            
        !***************************************************************************************************************
        IF (STGYEARDOY(11).EQ.YEARDOY .OR.DYNAMIC.EQ.SEASEND) THEN         ! If harvest/failure day
        !***************************************************************************************************************

            !-----------------------------------------------------------------------------------------------------------
            !          Output Evaluate & Overview and necessary input data (IDETO)
            !-----------------------------------------------------------------------------------------------------------
            CALL CS_Out_Eval ( &  
                CN          , DOY         , DYNAMIC     , IDETG       , IDETL       , IDETO       , ISWNIT      , ISWWAT      , &
                MESOM       , ON          , RN          , RUN         , RUNI        , SN          , STGYEARDOY  , TN          , &
                TNIMBSOM    , TOMINSOM1   , YEAR        &
                )
                
            !-----------------------------------------------------------------------------------------------------------
            !         Plantsum outputs (IDETS)
            !-----------------------------------------------------------------------------------------------------------
            CALL CS_Out_PlantSum ( &  
                CN          , IDETL       , IDETS       , ON          , REP         , RN          , RUN         , RUNI        , &
                SN          , TN          &
                )   
                
            !-----------------------------------------------------------------------------------------------------------
            !         Output leaves and tiers data (IDETL = Y or D)
            !-----------------------------------------------------------------------------------------------------------
            CALL CS_Out_LfTier ( &  
                IDETL       , RUN         , STGYEARDOY   &
                )
                
            !-----------------------------------------------------------------------------------------------------------
            !          Outputs work details, phenology and plant responses (IDETL = D).
            !-----------------------------------------------------------------------------------------------------------
            CALL CS_Out_WrkPhenRes ( & 
                DYNAMIC     , IDETL       , IDETO       , ISWNIT      , NLAYR       , RLV         , RN          , RUN         , TN          &
                )
                
            !-----------------------------------------------------------------------------------------------------------
            !         Errora, Errort, Errors (IDETL = A)
            !-----------------------------------------------------------------------------------------------------------
            CALL CS_Out_Error ( & 
                IDETL       , RN          , RUN         , TN          &
                )    
                
            !-----------------------------------------------------------------------------------------------------------
            !         Screens for CROPSIM SHELL (IDETD)
            !-----------------------------------------------------------------------------------------------------------
            CALL CS_Out_CrpSim ( & 
                CN          , DOY         , ON          , REP         , RN          , RUN         , RUNI        , &
                SN          , STGYEARDOY  , TN          , YEAR        &
                )
                
            !-----------------------------------------------------------------------------------------------------------
            !         Screens for sensitivity mode
            !-----------------------------------------------------------------------------------------------------------
            CALL CS_Out_Sens ( & 
                CN          , DOY         , RNMODE      , STGYEARDOY  , TN          , YEAR        &
                )   
                
            !-----------------------------------------------------------------------------------------------------------
            !         Store variables for sending to CSM summary output routines
            !-----------------------------------------------------------------------------------------------------------
            CALL CS_Out_StoreVars ( & 
                IDETO       , ISWNIT      , STGYEARDOY  &
                )
                
        ENDIF ! End STGYEARDOY(11).EQ.YEARDOY.OR.DYNAMIC.EQ.SEASEND
        
        !---------------------------------------------------------------------------------------------------------------
        !       Store variables for possible use next day/step and re-initialize if harvest/fail
        !---------------------------------------------------------------------------------------------------------------
        CALL CS_Out_ReInit ( &  
            BRSTAGE     , CN          , DYNAMIC     , IDETL       , NFP         , RNMODE      , SRAD        , STGYEARDOY  , &
            UNH4        , UNO3        &
            )
            
    END SUBROUTINE CS_Output

