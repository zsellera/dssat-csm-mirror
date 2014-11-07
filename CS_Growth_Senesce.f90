!***************************************************************************************************************************
! This is the code from the section (DYNAMIC.EQ.RATE) lines 4525 - 4629 of the original CSCAS code. The names of the 
! dummy arguments are the same as in the original CSCAS code and the call statement and are declared here. The variables 
! that are not arguments are declared in Module_CSCAS_Vars_List. Unless identified as by MF, all comments are those of 
! the original CSCAS.FOR code.
!
! Subroutine CS_Growth_Senesce calculates senescence and remobilization.
!***************************************************************************************************************************
    SUBROUTINE CS_Growth_Senesce ( &
        ISWNIT      , ISWWAT      & 
        )
    
        USE ModuleDefs
        USE Module_CSCAS_Vars_List
    
        IMPLICIT NONE
        
        CHARACTER(LEN=1) ISWNIT      , ISWWAT      
    
        !-----------------------------------------------------------------------
        !           Calculate senescence of leaves,stems,etc..
        !-----------------------------------------------------------------------

        ! LAH Notes from original cassava model. May need to take
        ! into account procedure to calculate leaf senescence. 
        ! Leaves are assumed to have a variety-specific maximum 
        ! life, which can be influenced by temperature and shading
        ! by leaves above. Water stress is assumed not to have any
        ! effect on leaf life (Cock, pers. comm.). However, on 
        ! release of stress leaves drop off and are replaced by a 
        ! flush of new leaves. This is not yet built into the 
        ! model.

        PLASP = 0.0
        PLASI = 0.0
        PLASL = 0.0
        PLASS = 0.0

        ! Leaf senescence - phyllochron or real time driven
        LAPSTMP = 0.0
        DO L = 1,LNUMSG
            IF (LAGETT(L)+TTLFLIFE*EMRGFR.LE.LLIFATT+LLIFGTT) EXIT
            IF (LAP(L)-LAPS(L).GT.0.0) THEN
                LAPSTMP = AMIN1((LAP(L)-LAPS(L)),LAP(L)/LLIFSTT*AMIN1((LAGETT(L)+(TTLFLIFE*EMRGFR)-(LLIFGTT+LLIFATT)), &
                    (TTLFLIFE*EMRGFR)))
                LAPS(L) = LAPS(L) + LAPSTMP
                PLASP = PLASP + LAPSTMP
            ENDIF
        ENDDO

        ! Leaf senescence - injury        ! LAH  To add later?
        !PLASI = PLA*(LSENI/100.0)*DU/STDAY  ! May need injury loss

        ! Leaf senescence - water or N stress
        ! LAH Need to accelerated senescence rather than lose leaf
        PLASW = 0.0
        PLASN = 0.0
        IF (ISWWAT.NE.'N') THEN
            IF (PLA-SENLA.GT.0.0.AND.WUPR.LT.WFSU) PLASW = AMAX1(0.0,AMIN1((PLA-SENLA)-PLAS,(PLA-SENLA)*LLOSA))
        ENDIF
        IF (ISWNIT.NE.'N') THEN
            LNCSEN = LNCM + NFSU * (LNCX-LNCM)
            IF (PLA-SENLA.GT.0.0.AND.LANC.LT.LNCSEN) PLASN = AMAX1(0.0,AMIN1((PLA-SENLA)-PLAS,(PLA-SENLA)*LLOSA))
        ENDIF
        ! LAH TMP
        PLASW = 0.0
        PLASN = 0.0
        PLASS = PLASW + PLASN    ! Loss because of stress
              
        ! Leaf senescence - low light at base of canopy
        ! NB. Just senesces any leaf below critical light fr 
        PLASL = 0.0
        IF (LAI.GT.LAIXX) THEN
            PLASL = (LAI-LAIXX) / (PLTPOP*0.0001)
            ! LAH Eliminated! Replaced by accelerated senescence
            PLASL = 0.0
        ENDIF
            
        ! Leaf senescence - overall
        PLAS =  PLASP + PLASI + PLASS + PLASL
        ! Overall check to restrict senescence to what available
        PLAS = AMAX1(0.0,AMIN1(PLAS,PLA-SENLA))

        !-----------------------------------------------------------------------
        !           Calculate C and N made available through senescence
        !-----------------------------------------------------------------------

        SENLFG = 0.0
        SENLFGRS = 0.0
        SENNLFG = 0.0
        SENNLFGRS = 0.0
        IF (PLA-SENLA.GT.0.0) THEN
        ! LAH New algorithms 03/04/13
        SENLFG = AMIN1(LFWT*LWLOS,(AMAX1(0.0,(LFWT*(PLAS/(PLA-SENLA))*LWLOS))))
        SENLFGRS = AMIN1(LFWT*(1.0-LWLOS),(AMAX1(0.0,(LFWT*(PLAS/(PLA-SENLA))*(1.0-LWLOS)))))
        ENDIF
  
        IF (ISWNIT.NE.'N') THEN
            ! NB. N loss has a big effect if low N
            ! Assumes that all reserve N in leaves
            IF (LFWT.GT.0.0) LANCRS = (LEAFN+RSN) / LFWT
            SENNLFG = AMIN1(LEAFN,(SENLFG+SENLFGRS)*LNCM)
            SENNLFGRS = AMIN1(LEAFN-SENNLFG,(SENLFG+SENLFGRS)*(LANC-LNCM))
        ELSE
            SENNLFG = 0.0
            SENNLFGRS = 0.0
        ENDIF

        !-----------------------------------------------------------------------
        !           Calculate overall senescence loss from tops
        !-----------------------------------------------------------------------

        SENFR = 1.0
        SENTOPLITTERG = 0.0
        SENTOPLITTERG = SENLFG*SENFR
        
    END SUBROUTINE CS_Growth_Senesce