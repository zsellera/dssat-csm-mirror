!***************************************************************************************************************************
! This is the code from the section (DYNAMIC.EQ.RATE) lines 3951 - 5516 of the original CSCAS code. The names of the 
! dummy arguments are the same as in the original CSCAS code and the call statement and are declared here. The variables 
! that are not arguments are declared in Module_CSCAS_Vars_List. Unless identified as by MF, all comments are those of 
! the original CSCAS.FOR code.
!
! Subroutine CS_Growth calls eight subroutines to calculate photosynthesis germination timing, daylength and development 
! units, reserves and grazing (?), PAR interception, rate factors, senescence, assimilation and its partitioning, growth of 
! storage roots, leaves, stems and crowns, reserves and plant height, and soil water.
!
!***************************************************************************************************************************

    SUBROUTINE CS_Growth ( &  
        ALBEDO      , BD          , BRSTAGE     ,  CLOUDS     , CO2         , DAYL        , DLAYR       , DOY         , &
        DUL         , EO          , EOP         , ES          , ISWDIS      , ISWNIT      , ISWWAT      , KCAN        , &
        KEP         , LL          , NFP         , NH4LEFT     , NLAYR       , NO3LEFT     , PARIP       , PARIPA      , &
        RLV         , RNMODE      , RWUMX       , RWUPM       , SAT         , SENCALG     , SENLALG     , SENNALG     , &
        SHF         , SLPF        , SRAD        , ST          , STGYEARDOY  , SW          , TAIRHR      , TDEW        , &
        TMAX        , TMIN        , TRWUP       , UH2O        , UNH4        , UNO3        , WEATHER     , WINDSP        &
        )
    
        USE ModuleDefs
        USE Module_CSCAS_Vars_List
    
        IMPLICIT NONE
        
        TYPE (WeatherType) WEATHER    ! Defined in ModuleDefs
    
        INTEGER DOY         , NLAYR       , STGYEARDOY(20)            , YEAR        , YEARPLTCSM  

        REAL    ALBEDO      , BD(NL)      , BRSTAGE     , CLOUDS      , CO2         , DAYL        , DLAYR(NL)   , DUL(NL)     
        REAL    EO          , EOP         , ES          , KCAN        , kep         , LL(NL)      , NFP         , NH4LEFT(NL) 
        REAL    NO3LEFT(NL) , PARIP       , PARIPA      , RLV(NL)     , RWUMX       , RWUPM       , SAT(NL)      
        REAL    SENCALG(0:NL)             , SENLALG(0:NL)             , SENNALG(0:NL)             , SHF(NL)     , SLPF        
        REAL    SRAD        , ST(NL)      , SW(NL)      , TAIRHR(24)  , TDEW        , TMAX        , TMIN        , TRWUP       
        REAL    UH2O(NL)    , UNH4(NL)    , UNO3(NL)    , WINDSP       

        CHARACTER(LEN=1) ISWDIS      , ISWNIT      , ISWWAT      , RNMODE      
    
        !!-----------------------------------------------------------------------------------------------------------------------
        !!     Set up the switches for establishment and determine whether today is a planting day.
        !!-----------------------------------------------------------------------------------------------------------------------
        !
        !CALL  CS_PrePlant( &  
        !    BD          , CO2         , DLAYR       , DOY         , DUL         , LL          , NH4LEFT     , NLAYR       , &
        !    NO3LEFT     , RNMODE      , ST          , STGYEARDOY  , SW          , TMAX        , TMIN        , YEAR        , &
        !    YEARPLTCSM  &                 ! WEATHER     ,      
        !    )
        !
        !===================================================================================================================
        IF (YEARDOY.GT.PLYEARDOY) THEN ! If planted (assumed in evening)
        !===================================================================================================================
        !----------------------------------------------------------------------------------------------------------------------
        !     Determine whether the water and thermal conditions allow the planting material to grow (called germination).
        !----------------------------------------------------------------------------------------------------------------------
            
            CALL CS_Growth_Germ ( & 
                ALBEDO      , BRSTAGE     , CLOUDS      , CO2         , DLAYR       , DUL         , EO          , EOP         , &
                ES          , ISWWAT      , KEP         , LL          , NLAYR       , RLV         , RWUMX       , RWUPM       , &
                SAT         , SRAD        , SW          , TAIRHR      , TDEW        , TMAX        , TMIN        , TRWUP       , &
                UH2O        , WEATHER     , WINDSP      , YEAR        & 
                )
            
            !=============================================================================================================
            IF (GEUCUM+TTGEM*WFGE.GE.PEGD) THEN  ! If germinated by endday
            !=============================================================================================================
        
                !--------------------------------------------------------------------------------
                !      Calculate germination timing, daylength and development units, reserves
                !--------------------------------------------------------------------------------
                CALL CS_Growth_Init ( &
                    BRSTAGE     , DAYL        &  
                    )
        
                !--------------------------------------------------------------------------------
                !       Calcualate PAR interception and rate factors
                !--------------------------------------------------------------------------------
                CALL CS_Growth_Rates ( &
                    CO2         , EOP         , ISWDIS      , ISWNIT      , ISWWAT      , KCAN        , NFP         , &
                    PARIP       , PARIPA      , TDEW        , TMAX        , TMIN        , TRWUP       & 
                    )
        
                !-----------------------------------------------------------------------
                !           Calculate senescence of leaves,stems,etc..
                !-----------------------------------------------------------------------
                CALL CS_Growth_Senesce ( &
                    ISWNIT      , ISWWAT      & 
                    )
                
                
                !-----------------------------------------------------------------------
                !           Calculate C assimilation at beginning of day
                !-----------------------------------------------------------------------
                
                CALL CS_Growth_Photo ( &
                    CO2         , NFP         , SLPF        , SRAD        , TAIRHR      , TDEW        , TMAX        , &
                    TMIN        , WEATHER     &        
                    )
                
                !-----------------------------------------------------------------------
                !           Partition C to above ground and roots (minimum) 
                !-----------------------------------------------------------------------
                CALL CS_Growth_Part ( &
                    BRSTAGE     , ISWNIT      , NFP         &
                    )
                
                !-----------------------------------------------------------------------
                !           Calculate N uptake  -  and growth adjustments if inadequate N
                !-----------------------------------------------------------------------
                CALL CS_Growth_NUptake ( &
                    BD          , DLAYR       , DUL         , ISWNIT      , LL          , NH4LEFT     , NLAYR       , &
                    NO3LEFT     , RLV         , SAT         , SW          , UNH4        , UNO3          & 
                    )
                
                !-----------------------------------------------------------------------
                !           Distribute growth
                !-----------------------------------------------------------------------
                CALL CS_Growth_Distribute ( &
                    DLAYR       , ISWNIT      , ISWWAT      , LL          , NH4LEFT     , NLAYR       , NO3LEFT     , &
                    RLV         , SENCALG     , SENLALG     , SENNALG     , SHF         , SW          & 
                    )
                
            !=============================================================================================================
            ENDIF  ! End of after germinated section
            !=============================================================================================================
            
        !===================================================================================================================
        ENDIF  ! End of after planted (rate) section
        !===================================================================================================================
        


    END SUBROUTINE CS_GROWTH
